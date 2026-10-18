# Security

Scope: the Interview Experience Repository backend, its container image, the Helm chart and the CI/CD pipeline.
It is a coursework project, so the notes below say what is enforced, how it was checked, and what is not covered.

## Trust boundaries

```
Internet --> Ingress (nginx) --> app pods :8000 --> PostgreSQL (Neon, outside the cluster)
                                     |  \--> Google (token verification, 443)
Prometheus --> app pods :8081 (actuator)         \--> Tempo (traces)
```

Users are anonymous until they sign in with Google; the app then issues its own JWT. Roles are `USER`, `ADMIN`,
`SUPERADMIN`. Everything except `/auth/google` requires a valid JWT.

## Controls

| Area | Control | How it was checked |
|---|---|---|
| Secrets in git | `.env*` is gitignored; gitleaks scans the whole history in CI (`.gitleaks.toml` has one narrow exception for test placeholders) | `gitleaks detect`: 16 commits, no findings |
| Secrets at runtime | The chart never creates the Secret; it references one created out-of-band (`deploy/scripts/create-secret.sh`). `JWT_SECRET` shorter than 32 characters is refused | Secret absent from `helm get values` and from the repo |
| Identity | JWT signature and expiry verified on every request; client-supplied `X-User-Id` / `X-User-Role` headers are discarded and rebuilt from the token | `JwtAuthenticationFilterTest`; integration test: non-admin approving gets 403 |
| Authorisation | Admin endpoints check the role from the verified token | Integration test |
| Exposure | Actuator is on a separate port (8081) that the Ingress never routes; Swagger and API docs are off in the image (`prod` profile); unknown paths and malformed input return 4xx, not stack traces | Integration tests; request to `/actuator/prometheus` through the Ingress returns 401 |
| Network | NetworkPolicy: only the Ingress controller reaches `:8000`, only Prometheus `:8081`; egress only to DNS, Tempo, and TCP 5432/443 | Test pod from another namespace got no response on either port; from inside the app pod, ports 80 and 22 to the internet are blocked, 443 is open |
| Pod hardening | Non-root (uid 10001), read-only root filesystem, all capabilities dropped, no privilege escalation, seccomp `RuntimeDefault`, no service-account token | `kubectl exec`: `touch` fails, `id -u` = 10001 |
| Namespace | Dedicated `interview` namespace with Pod Security `restricted` enforced | A privileged root pod was rejected by the admission controller |
| Image | Trivy fails the build on any fixable HIGH/CRITICAL finding in OS packages or Java dependencies; slim JRE base; tag is the commit SHA | The first scan found CRITICAL CVEs in Tomcat and Spring; fixed by upgrading Spring Boot and pinning patched versions |
| Config | Trivy checks the Dockerfile, CI manifests and the rendered chart on every build | 0 findings (one documented false positive in `.trivyignore`) |
| Supply chain | Dependabot for Maven, Docker and GitHub Actions; least-privilege workflow tokens (`contents: read`; `packages: write` only in the publish job) | |
| Release approval | The `cd` workflow runs in the `release` environment, where required reviewers can be set | |

## Known limitations

- **No TLS locally.** The kind Ingress serves plain HTTP. On a real cluster, add a certificate (for example
  cert-manager) and redirect to HTTPS; the JWT travels in a header and must not cross the network in clear text.
- **JWT design is basic.** HS256 with one shared secret, a 7-day lifetime, no `iss`/`aud` claims, and no revocation
  or refresh. A leaked token is valid until it expires; rotating `JWT_SECRET` invalidates all tokens at once.
- **No rate limiting** on the API or on `/auth/google`. An Ingress rate limit or a WAF would be the first addition.
- **Actuator has no authentication of its own**; it relies on the network policy and the separate port.
- **Egress to port 443 is open to any address**, because Google's addresses cannot be selected by label. An egress
  proxy or an FQDN-aware policy (Cilium) would narrow it.
- **Secrets are stored base64-encoded in the cluster's etcd** (kind does not encrypt them). Use encryption at rest and
  an external secret manager on a real cluster.
- **Images are not signed** and base images are pinned by tag, not by digest. Cosign keyless signing with a
  verification step before deploy would close this.
- **The monitoring namespace is not hardened** the way the application namespace is.
- `db/dev-token.sh` mints long-lived tokens from `JWT_SECRET` for local testing; it is excluded from the image and
  must not be pointed at a real environment's secret.

## Reporting

This is a student project; open an issue on the repository or contact the author.
