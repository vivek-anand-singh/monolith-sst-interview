# Interview Experience Repository — Monolith

One Spring Boot app (Java 17, port **8000**) that replaces the four microservices of
`sst-interview-backend` (API Gateway, User, Content, Notification). The REST API is identical
(same 41 endpoints), so the frontend works as before.

## Structure

A plain layered Spring Boot app — one `src`, no modules:

```
com.sstinterview
├── controller   REST endpoints (auth, companies, experiences, comments, replies, flags, notifications, ...)
├── service      business logic (interface + Impl); UserService, NotificationService are ordinary services
├── repository   Spring Data JPA repositories
├── models       JPA entities and the Role enum
├── dto          request / response objects
├── exception    exceptions + the global exception handler
├── config       CORS, Swagger
├── security     JWT filter (validates the token, sets X-User-Id / X-User-Role)
└── util         RoleUtils
```

One PostgreSQL database, one DB user, one Flyway history (`V1`–`V6` content, `V7` users,
`V8` notification). Services call each other directly — e.g. `ExperienceServiceImpl` calls
`NotificationService.notifyExperienceSubmitted(...)`. Notifications are best-effort: a failure is
logged and never fails the request.

## What changed vs. the microservices

| Before | Now |
|---|---|
| API Gateway (JWT check + routing) | `security/JwtAuthenticationFilter`; client-supplied `X-User-*` headers are discarded |
| gRPC to User Service | `UserService` (plain method calls) |
| 5 Kafka topics → Notification Service | direct `NotificationService.notify*` calls |
| Redis cache of author names | removed (primary-key lookup in the same DB) |
| 3 databases, 3 DB users | 1 database, 1 DB user (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`) |

Behaviour fixes that fell out of the merge: CORS now allows `PATCH`; `SecurityException` maps to
403 everywhere (was 500 in Notification Service); `/actuator/health` and CORS preflights need no
JWT. The REST API itself is unchanged.

## Run

```bash
cp .env.example .env        # fill in values (read from the working directory: run from the repo root / set your IDE working dir to it)
docker compose up -d db     # local Postgres on 127.0.0.1:5433, data kept in the `pgdata` volume
./mvnw spring-boot:run      # app on :8000 (DB_URL in .env points at localhost)
```
Or run everything in Docker: `./deploy.sh` (app + db). Stop with `docker compose down`;
add `-v` only if you want to wipe the database volume.
Swagger UI: http://localhost:8000/swagger-ui/index.html

## Seed data

```bash
./db/seed.sh           # idempotent; safe to re-run
./db/seed.sh --reset   # wipe content + seed users first, then re-seed
```
Loads 17 users, 21 companies, tags, round types, ~47 experiences (most `APPROVED`), comments,
replies and a few notifications, into the database named by `DB_URL` in `.env` (needs `psql` on
PATH, or set `PSQL="docker compose exec -T db psql -U interviewuser -d interview"`). It prints
dev JWTs for `alice` (USER) and `admin` (ADMIN) so you can call the API with
`Authorization: Bearer <token>`.

Login is Google-only, so the seed users can't sign in. To test as them:
```bash
./db/dev-token.sh alice      # or bob / admin — prints a 1-year JWT
curl -H "Authorization: Bearer $(./db/dev-token.sh alice)" localhost:8000/experiences
```
The separate frontend authenticates with a cookie named `sst_token`; set it to that token
(DevTools → Application → Cookies) to use the UI without Google login.

To get an admin you can really log in as (the seed leaves 5 experiences pending, and 2 rejected, for
moderation testing): sign in with Google once, then `./db/make-admin.sh you@gmail.com`, or run the
seed with `SEED_ADMIN_EMAIL=you@gmail.com ./db/seed.sh`. Log in again afterwards so your token carries the new role.

## Moving existing data

Point `DB_URL` at the old **contentservice** database: its Flyway history is untouched, `V7`/`V8`
only add the `users` and `notification` tables. Then copy the other two databases in
(adjust database names; run once):

```bash
pg_dump -a -t users               userservice         | psql contentservice
pg_dump -a -t notification        notificationservice | psql contentservice
```
Back up first. This copy procedure has not been run against real data.

## Notes
- Authorization is still per-endpoint via `RoleUtils.hasAtLeast`. The known gaps in the old
  ARCHITECTURE.md (open `POST /tags`, `POST /round-types`; seed script) are carried over as-is.
