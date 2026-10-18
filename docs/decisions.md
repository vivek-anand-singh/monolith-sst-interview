# Design decisions and trade-offs

Each entry says what was chosen, why it fits this application, what was rejected, and what would change the answer.

## Application and environment

**Keep the monolith.** The app already replaced four microservices with one deployable unit. It has one database,
one team and modest traffic, so splitting it again would add network hops and failure modes without a benefit.
*Would change if:* parts needed to scale or be released independently (for example notifications at high volume).

**kind on Docker Desktop, no cloud, no Terraform.** The guide allows a local cluster and makes Terraform optional.
kind is quick to create and throw away and runs the real Kubernetes API, NetworkPolicy and Pod Security.
Minikube would also work; a managed cluster would add cost and little learning for this scope.
*Would change if:* the app had to be reachable by real users: a managed cluster, a real domain and TLS, and Terraform
to make the infrastructure reproducible.

**Neon (PostgreSQL) stays outside the cluster.** The data is the one thing that must not be lost, and a managed
database already gives backups, upgrades and storage. The app stays stateless, which is what makes the rest of the
design simple. The cost is a dependency the cluster cannot heal, so the design makes that dependency visible
(see readiness below, and the outage rehearsal).
*Would change if:* data had to stay on-premises or cost mattered more: a StatefulSet with a PVC and a backup job, or
an operator such as CloudNativePG.

## Kubernetes

**A Deployment, not a StatefulSet.** Pods hold no state and are interchangeable. A StatefulSet would add stable
identities and ordered rollout that nothing here needs.

**2 replicas minimum, HPA up to 4 on CPU at 70%.** Two replicas let one pod fail or roll without downtime;
the PodDisruptionBudget (`minAvailable: 1`) protects against node drains. CPU is a reasonable proxy for a
request-per-thread web app. The 250m / 512Mi requests and 768Mi limit leave the JVM a heap of about 576Mi
(`MaxRAMPercentage=75`). *Known limit:* during a database outage the HPA adds pods that cannot start (Flyway needs the
database at boot), so autoscaling does not help then.

**Three probes, with readiness excluding the database.** The startup probe tolerates slow starts (migrations over a
remote link) so liveness cannot kill a booting pod. Readiness reports only app state. If it included the database,
a Neon blip or cold start would pull every pod out of the Service at once and users would get gateway errors instead
of fast, honest 5xx; the page-level alerts tell an operator the database is the problem.
*Would change if:* there were several independent backends: then readiness on the database could route users to a
healthy region.

**Actuator on a separate port (8081).** Health, info and metrics must not be reachable from the internet. A second
port means the Ingress simply never routes to it, and the NetworkPolicy lets only Prometheus in.

## Configuration and releases

**Helm with one chart and a small `values-local.yaml`.** The chart is the single source of truth, with the image tag
as the only value that must be supplied. Kustomize overlays would work equally well; Helm is also what makes
`helm rollback` and `--atomic` available. The guide does not require several environments, so there is one values
file for the local cluster and safe defaults in `values.yaml`.
*Would change if:* there were dev, staging and production: one values file per environment, promoted by the same
image tag.

**Secrets are referenced, never templated.** The chart reads a Secret created by `create-secret.sh` from an env file
that is gitignored. Credentials therefore never appear in git, in the chart or in Helm's release history.
*Would change if:* on a real cluster, an external secrets operator or sealed secrets.

**Rolling update, `maxUnavailable: 0`, `--atomic`, and a manual rollback command.** A new pod must be Ready before an
old one is removed; if the new version never becomes Ready, Helm rolls back by itself. I measured it: during a normal
rollout 262 of 262 requests succeeded, and during a deliberately broken release 741 of 741 did. Blue-green would need
double the capacity for a seconds-long switch; canary or feature flags need traffic splitting or flag infrastructure
that this traffic level does not justify.
*Would change if:* a release could pass health checks but still break users (a bad business rule): then a canary with
automated SLO checks (Argo Rollouts) is the right tool, because readiness cannot catch that.

**Image tag = commit SHA; no `latest`.** Any running pod can be traced to the exact commit, and a deployment can be
reproduced. The same SHA is in the image label, the pod label and `/actuator/info`, and the smoke test checks they match.

## CI/CD

**GitHub Actions, one CI and one CD workflow.** The code is on GitHub, so there is no extra system to run.
CI runs the real tests (including a Testcontainers PostgreSQL), lints the chart, scans for secrets and misconfiguration,
builds the image once, scans that exact image, and only then pushes it. A pull request never publishes.

**Tests run in CI, not in the Docker build.** The integration test needs Docker, which is not available inside an
image build. The image job depends on the test job, so a failing test still prevents an image.

**Manual CD behind a GitHub Environment.** Releasing is a human decision here. The `release` environment is where
required reviewers are configured. Because a GitHub-hosted runner cannot reach a laptop cluster, the workflow deploys
the *published* image into a throwaway kind cluster and smoke-tests it; the long-lived local cluster is released with
`deploy/scripts/deploy.sh`.

**No Argo CD / GitOps controller.** A push-based release with `--atomic` and a smoke test is enough for one cluster
and one service, and the guide says Argo CD is not required. Drift is checked on demand with `drift-check.sh`.
*Would change if:* several clusters or teams: Argo CD would reconcile continuously and make Git the only way to change
the cluster, instead of a script someone has to run.

## Observability

**Prometheus, Grafana, Alertmanager and Tempo; no log aggregation.** Docker has 8 GB and kind already uses about
2.3 GB, so Loki plus a log shipper was left out. Logs are structured JSON on stdout with `traceId` and `spanId`, so a
log line can be matched to a trace by hand.
*Would change if:* the memory were available or the app ran in a real cluster: Loki with Alloy, and Grafana's
trace-to-logs link.

**SLOs: 99.5% of requests not 5xx, 95% of requests under 500 ms.** Only 5xx counts as failure (401, 404 and 400 are
caller mistakes), and probes and scrapes are excluded from the metrics. The alert thresholds are derived from the SLO:
a fast-burn page at 14.4x the error budget over 5 minutes and 1 hour, a slow-burn ticket at 6x over 30 minutes and
6 hours. Two windows stop a short blip from paging; the cost is about six minutes of detection lag for the 5xx page,
which is why a faster alert exists for the specific database failure.

**Business counters.** `interview.experiences.submitted` and `.reviewed` show whether users succeed, which an
up-and-ready pod does not.

## Security

**Defence in depth, each layer checked.** Non-root, read-only filesystem, no capabilities, seccomp, no service-account
token; Pod Security `restricted` on the namespace; a NetworkPolicy limiting who can reach the pods and what they can
reach; a Trivy gate on the image and on the manifests; gitleaks over the whole history. `SECURITY.md` lists what is
not covered (TLS, rate limiting, JWT revocation, signed images).

**A fixable HIGH/CRITICAL vulnerability fails the build.** The first scan found real CRITICAL issues in Tomcat and
Spring; I upgraded Spring Boot and pinned patched versions rather than lowering the bar. Unfixed findings are ignored
because nobody can act on them yet.

## What I would change under different requirements

| Requirement | Change |
|---|---|
| Many more users | Raise `maxReplicas`, add a read replica and a cache, set real rate limits at the Ingress, review the DB pool size against Neon's connection limit |
| Strict uptime | Several nodes or zones with topology spread set to `DoNotSchedule`, a canary release with automated SLO checks, a higher `minReplicas` so a database outage does not leave only two pods |
| Several environments | One values file per environment, the same image promoted through them, Argo CD per cluster |
| Risky schema changes | Run Flyway as a separate pre-deploy Job instead of at pod start, with backwards-compatible (expand/contract) migrations, so two replicas never race and old pods keep working during a rollout |
| Compliance | TLS everywhere, secrets in a manager with rotation, image signing and SBOMs, audit logging, Loki retention |
