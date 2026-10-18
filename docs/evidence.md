# Evidence

Everything below comes from this repository and from runs on the local cluster. Items marked **TO ADD** are things
that exist only on GitHub or on screen and must be filled in from there.

## The traceability chain

One captured run, `docs/evidence/run-e59f2bc.txt`, produced by `deploy/scripts/evidence.sh` on a clean working tree:

| Link in the chain | Value |
|---|---|
| Source commit | `e59f2bc4a6124002103990ab53d9f5f00ed4130e` (baseline: `c439e190445d5a22c342a6f3bcd54973ce98c0bc`, 17 commits earlier) |
| Image built from it | `interview-monolith:e59f2bc4…`, label `org.opencontainers.image.revision` = the same SHA |
| Helm release | `interview`, namespace `interview`, status `deployed` |
| Running pods | 2 of 2 Ready, 0 restarts; each pod's `app.kubernetes.io/version` label and its `/actuator/info` revision equal the commit |
| Smoke test | `SMOKE TEST PASSED: revision e59f2bc… is ready and enforcing auth` |
| Drift check | `Live objects match the chart rendering` |
| User journey through the Ingress | 401 without a token; submit gives `PENDING`; hidden from the public listing; the author's own approve attempt gets 403; the admin's approve gets 200; now visible |
| Metrics for that journey | submitted and approved counters incremented, availability 1.0, 2 of 2 pods scraped, no alerts firing |
| Traces | Tempo holds traces for `http post /admin/experiences/{id}/review` |

Re-create it with `deploy/scripts/evidence.sh` (needs the cluster from `deploy/README.md`).

The version tested is `e59f2bc`. Commits after it change documentation only, not the application, chart or workflows
(the doc commits are listed in the PR).

## Evidence by marking criterion

| Criterion | Where to look |
|---|---|
| **Kubernetes operation** | `deploy/helm/interview-monolith/templates/` (Deployment, probes, resources, HPA, PDB, Service, Ingress, NetworkPolicy); section 3 of the captured run; `docs/decisions.md` (workload, probe and sizing choices) |
| **CI/CD and release delivery** | `.github/workflows/ci.yml` and `cd.yml`; `deploy/scripts/deploy.sh`, `smoke-test.sh`, `rollback.sh`, `drift-check.sh`; the release measurements below. **TO ADD:** link to a green `ci` run on the final commit, and to a `cd` run with its approval |
| **Observability and reliability** | `deploy/helm/interview-monolith/templates/prometheusrule.yaml` and `files/dashboard.json`; `docs/runbook.md` (what healthy means, each alert with checks, actions and recovery); `docs/fault-demo-db-outage.md`. **TO ADD:** a screenshot of the dashboard during the outage and of the Alerts page |
| **Security practices** | `SECURITY.md` (controls, how each was verified, limitations); `.gitleaks.toml`; the `security` job in `ci.yml`; `networkpolicy.yaml`; `deploy/kind/namespace.yaml` |
| **Architecture and configuration** | `docs/architecture.md`; `values.yaml` and `values-local.yaml`; `docs/decisions.md` |
| **Verification and operational evidence** | This page and `docs/evidence/run-e59f2bc.txt` |
| **Submission and reviewability** | `BASELINE.md`; one pull request; `deploy/README.md` and the README for run instructions |

## Measurements from actual runs

| What | Result | Source |
|---|---|---|
| Tests | 36 passing: unit, filter, and a Testcontainers integration test that runs all 8 Flyway migrations on PostgreSQL 16 and the submit/approve journey | `./mvnw verify` |
| First image scan | CRITICAL CVEs in Tomcat and Spring MVC, HIGH in Jackson, the Postgres driver and the base image; all fixed, scan now clean | commit `add0107` |
| Rolling update | 262 of 262 requests served while the version changed | `deploy/scripts/deploy.sh` with a request loop |
| Bad release (readiness cannot pass) | The new pod stayed `0/1`; 741 of 741 requests served by the old pods; Helm rolled back by itself after the timeout | `helm upgrade --atomic` with a broken readiness probe |
| Drift | A hand-edited memory limit made `drift-check.sh` exit 1 and show `1Gi` versus `768Mi`; `helm upgrade --force-conflicts` reset it | `drift-check.sh` |
| Database outage under load | Alerts fired at +100 s (DB timeouts) and +362 s (error-budget burn); every pod Ready 20 s after the database returned; all alerts cleared within 6 minutes; no restart | `docs/fault-demo-db-outage.md` |
| Network policy | A pod in another namespace could not reach `:8000` or `:8081`; egress on ports 80 and 22 is blocked | `SECURITY.md` |
| Pod Security | A privileged root pod was rejected in the app namespace | `SECURITY.md` |

## Limits of this evidence
- The cluster is a single-node kind cluster on a laptop, with a PostgreSQL container standing in for Neon during the
  runs above. Neon's real behaviour (cold starts, connection limits) was not exercised.
- Traffic in the outage and rollout tests was synthetic (`deploy/scripts/traffic.sh`).
- The `cd` workflow deploys to an ephemeral cluster on a GitHub runner, so it proves the published image deploys and
  reports the right commit; it does not update the laptop cluster.
- Alertmanager has no receiver configured, so alerts are visible in the UI only.
