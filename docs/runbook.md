# Runbook: Interview Monolith

## What "healthy" means

| Signal | Healthy | Where |
|---|---|---|
| Availability | At least 99.5% of requests are not 5xx (the SLO) | Dashboard: *Availability*, *Error budget left* |
| Latency | At least 95% of requests finish within 500 ms | Dashboard: *p95 latency*, rule `interview:http_slow_ratio:rate10m` |
| Capacity | 2 or more replicas Ready, no restarts | *Ready replicas*, *Pod restarts* |
| Dependency | DB pool not saturated, no connection timeouts | *DB connection pool*, *DB connection timeouts* |
| User success | Submissions are arriving and reviewed | *User journey* panel |
| Version | Every pod runs the commit you expect | *Running version* panel, `/actuator/info` |

401 and 404 responses are caller mistakes and do not count against availability; only 5xx does.

How to look:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80          # dashboard "Interview Monolith: service health"
kubectl -n monitoring port-forward svc/monitoring-prometheus 9090          # alerts: http://localhost:9090/alerts
kubectl logs deploy/interview-monolith | grep '"log.level":"ERROR"'       # JSON logs; each line has trace.id
```

To follow one failing request: take the `trace.id` from the error log line and open it in Grafana > Explore > Tempo.

## Alerts

### InterviewErrorBudgetFastBurn
**Meaning:** 5xx rate is above 7.2% in both the last 5 minutes and the last hour, which would spend the 30-day budget in about two days. Page.
**Check:** *Requests by status* (which status), error logs with `trace.id`, `helm history interview` (did a release just go out?), *DB connection timeouts*.
**Act:**
- Started right after a release: `deploy/scripts/rollback.sh`.
- Database errors or pool timeouts: see InterviewDbConnectionTimeouts.
- Otherwise follow a trace from an error log line to the failing span.
**Verify recovery:** `interview:http_error_ratio:rate5m` is below the threshold and the alert resolves; run `deploy/scripts/smoke-test.sh <sha>`.

### InterviewErrorBudgetSlowBurn
**Meaning:** a lower, steady 5xx rate (above 3% over 30m and 6h) is eating the budget. Ticket, not a page.
**Check/Act:** same investigation as the fast burn, but there is time to find the cause before changing anything. Group errors by endpoint with `sum by (uri) (rate(http_server_requests_seconds_count{status=~"5.."}[30m]))`.

### InterviewLatencySloBreach
**Meaning:** more than 5% of requests took over 500 ms for 10 minutes.
**Check:** *Latency percentiles*, *DB connection pool* (waiting > 0), *CPU vs request* (CPU-bound?), a slow trace in Tempo to see whether time goes to the database.
**Act:** pool saturated or CPU near the limit: raise `autoscaling.maxReplicas` or the resource limits. Slow database (Neon cold start/suspend): wait, or check the Neon console.
**Verify recovery:** `interview:http_slow_ratio:rate10m` back under 5%.

### InterviewDown
**Meaning:** no instance is scrapeable for a minute, so nothing is serving.
**Check:** `kubectl get pods`, `kubectl describe pod`, `kubectl logs --previous`.
**Act:** crash loop after a release: `deploy/scripts/rollback.sh`. Bad Secret (wrong `DB_URL`, missing `JWT_SECRET`): fix it with `deploy/scripts/create-secret.sh` and `kubectl rollout restart deploy/interview-monolith`.

### InterviewReplicasUnavailable
**Meaning:** some replicas have not been Ready for 5 minutes: a stuck rollout, a failing readiness probe, or no node capacity.
**Check:** `kubectl rollout status deploy/interview-monolith`, `kubectl describe pod` (events), `kubectl get hpa`.
**Act:** if it is a rollout that `--atomic` has not already reverted, `deploy/scripts/rollback.sh`.

### InterviewDbPoolSaturated
**Meaning:** more than 90% of the connection pool is in use for 5 minutes. Users are about to queue for connections.
**Check:** *DB connection pool*; traces for slow queries.
**Act:** scale out only helps if the database can take more connections (Neon limits them), so first look for a slow query or a leak; then raise `spring.datasource.hikari.maximum-pool-size` and replicas together.

### InterviewDbConnectionTimeouts
**Meaning:** requests waited for a database connection and gave up. The database is unreachable or exhausted. Page.
**Check:** `kubectl logs deploy/interview-monolith | grep -i hikari`, the database provider's status page and console, whether `DB_URL` in the Secret is still valid (Neon password rotated, project suspended).
**Act:** restore the database or correct the Secret and restart the pods. Readiness deliberately does not include the database, so pods stay in the Service and return 500 until the database is back; the page tells you.
**Verify recovery:** timeouts stop, the 5xx ratio falls, a request to `/experiences` with a valid token returns 200.
