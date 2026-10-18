# Baseline submission

| | |
|---|---|
| Name | Vivek Anand Singh |
| Student ID | 23BCS10172 |
| Project | Interview Experience Repository (monolith backend) |
| Repository | https://github.com/vivek-anand-singh/monolith-sst-interview |

## Baseline commit

`c439e190445d5a22c342a6f3bcd54973ce98c0bc` on `main`

https://github.com/vivek-anand-singh/monolith-sst-interview/commit/c439e190445d5a22c342a6f3bcd54973ce98c0bc

All DevOps work is done on `devops/advanced-devops-project` and submitted as one pull request against this commit.

## The application

A Spring Boot 4.1 (Java 17) backend for an interview-experience sharing platform. Candidates sign in with
Google, post how a company's interview process went, and others read, comment, reply and flag content.
Admins approve or reject submissions. It is one layered application (controller, service, repository)
backed by one PostgreSQL database (hosted on Neon) with Flyway migrations, JWT authentication and in-app
notifications. It exposes about 50 REST endpoints on port 8000. The frontend lives in a separate repository
and is out of scope here.

## DevOps features that already exist at the baseline

- `Dockerfile`: multi-stage Maven build into a JRE 17 image (runs as root, tests skipped)
- `docker-compose.yml`: app plus local Postgres 16 with a volume, DB healthcheck, app healthcheck on `/actuator/health`
- `deploy.sh`: `docker compose down` then `up --build`
- Configuration through environment variables (`.env` ignored, `.env.example` committed)
- Flyway schema migrations V1 to V8
- Actuator `health` endpoint only
- `db/` helper scripts for seeding data, minting a dev token and promoting an admin

Not present at the baseline: automated tests, CI/CD, Kubernetes manifests, metrics, tracing, image scanning.
