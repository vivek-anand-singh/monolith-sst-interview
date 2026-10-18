# Deploying and releasing

Everything runs on a local kind cluster. The database is external (Neon in real use); the app reaches it
through the `DB_URL` in a Kubernetes Secret.

## One-time setup

```bash
brew install kind helm          # kubectl comes with Docker Desktop
deploy/scripts/kind-up.sh       # cluster + ingress-nginx + metrics-server
deploy/scripts/create-secret.sh .env.neon   # DB_URL, JWT_SECRET, GOOGLE_CLIENT_ID (+ DB_USERNAME/DB_PASSWORD)
```

`.env.neon` is gitignored. The chart never creates the Secret, so credentials are not in git or in Helm history.

## Release

```bash
deploy/scripts/deploy.sh        # build image for HEAD, load into kind, helm upgrade --atomic, smoke test
```

Open http://interview.localtest.me:8080 (`localtest.me` resolves to 127.0.0.1).

- The image tag is the full commit SHA. The chart refuses to render without it; there is no `latest`.
- Rolling update with `maxUnavailable: 0`: a new pod must be Ready before an old one is removed.
- `--atomic`: if the new pods do not become Ready within the timeout, Helm rolls the release back by itself.
- The smoke test checks that the running pod reports the expected commit (`/actuator/info`), is ready, and rejects
  unauthenticated requests.

## What is running?

```bash
kubectl get deploy interview-monolith -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl port-forward deploy/interview-monolith 8081 &  curl -s localhost:8081/actuator/info
helm history interview
```

## Roll back

```bash
deploy/scripts/rollback.sh        # to the previous revision (or: rollback.sh <revision>)
```

Then verify what is running with the smoke test, which `rollback.sh` runs for you.

## Drift

```bash
deploy/scripts/drift-check.sh     # exit 1 if pods differ from the release, or live objects differ from the chart
```

Hand edits (`kubectl set ...`, `kubectl edit`) show up as drift. Helm applies server-side, so a plain
`helm upgrade` refuses to overwrite a hand-edited field and reports a conflict. To deliberately reset the
cluster to what Git says, add `--force-conflicts`.

## CI/CD in GitHub Actions

- `ci` runs on every push and pull request: tests (with a real PostgreSQL), chart lint, image build, Trivy scan,
  and, on pushes only, publishes `ghcr.io/<owner>/monolith-sst-interview:<commit-sha>`.
- `cd` is started by hand (Actions > cd > Run workflow). It is bound to the `release` environment; add required
  reviewers there (Settings > Environments) to make it wait for approval. It pulls the image that `ci` built for
  that commit, deploys it to a throwaway kind cluster, and runs the smoke test, so only an image that passed `ci`
  can be released.
