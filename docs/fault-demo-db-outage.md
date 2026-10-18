# Fault demonstration: database outage under load

Everything below was run on the kind cluster against commit `edce6556e739cd3ff6c47dc3faf88d973dc0b6c2`, with
synthetic traffic from `deploy/scripts/traffic.sh` (about 37 requests/s, including submit and approve calls).
The database was a PostgreSQL container standing in for Neon, stopped and started with `docker stop/start`.

## Symptom
At 22:02:05 the database was stopped. Users would see `5xx` responses and the dashboard's *Availability* and
*Error budget left* panels fall.

## Hypothesis
The app should fail fast on the missing dependency (pool timeouts, 5xx), the two long-running pods should keep
running (readiness deliberately excludes the database), and the alerts should fire in this order: pool timeouts,
then the error-budget burn alerts. Recovery should need no restart, because the connection pool reconnects.

## Evidence (times after the outage began)

| Time | What was observed |
|---|---|
| about +15 s | the HPA, reacting to the traffic ramp, scaled from 2 to 4 pods; the 2 new pods could not start (Flyway needs the database at boot) and went into CrashLoop; `InterviewReplicasUnavailable` went pending at +40 s |
| +100 s | `InterviewDbConnectionTimeouts` **firing** (page): requests were timing out waiting for a pooled connection |
| +161 s | `InterviewErrorBudgetSlowBurn` pending; 5xx ratio (5 min) 10.6% |
| +342 s | `InterviewReplicasUnavailable` **firing**: it reported exactly that |
| +362 s | `InterviewErrorBudgetFastBurn` **firing** (page): 5xx ratio 100% over 5 min and 12.3% over 1 h, both above the 7.2% threshold |

The two original pods stayed Running and Ready the whole time and returned 5xx quickly instead of hanging.

## Change
At 22:08:24 the database was started again. Nothing else was touched (no pod restart, no redeploy).

## Verification

| Time after restart | Result |
|---|---|
| +20 s | 4/4 replicas Ready (the crash-looping pods booted as soon as Flyway could connect); `InterviewReplicasUnavailable` cleared |
| +101 s | `InterviewErrorBudgetFastBurn` cleared |
| +221 s | `InterviewErrorBudgetSlowBurn` cleared |
| +342 s | `InterviewDbConnectionTimeouts` cleared; 5xx ratio 0.0 |

The delay between the database coming back and the alerts clearing is the length of the alert windows draining,
not the service being unhealthy: requests succeeded within seconds of the restart.

## What this found, and what changed because of it
1. **A 60-second pool timeout hid the outage.** In a first run, one request hung 75 s before the client gave up,
   and the 5xx alerts barely moved because errors arrived about once a minute per worker. The connection timeout is
   now configurable (`DB_CONNECTION_TIMEOUT_MS`) and the chart sets 10 s; the run above is with 10 s.
2. **Malformed input and unknown paths were counted as server errors** (500 instead of 400/404), which would
   have inflated the error rate. Fixed, with tests.
3. **Autoscaling cannot help during a database outage**, because new pods cannot start without it. Mitigation, if
   this mattered more: keep a higher `minReplicas`, or let the app start without running migrations (run Flyway as a
   separate release step).
4. **Readiness excludes the database on purpose.** The alternative, including it, would have removed every pod from
   the Service during the outage and replaced 5xx with a connection error from the Ingress; with Neon cold starts it
   would also flap. The page-level alerts above are what tell an operator the database is the problem.
5. **Detection lag of the fast-burn alert (about 6 minutes) is the price of two windows.** It prevents paging
   on a short blip; `InterviewDbConnectionTimeouts` fires in under 2 minutes and covers this exact failure.
