#!/usr/bin/env bash
# Prints the chain of evidence from source to a working user request for what is deployed right now:
#   commit -> image -> Helm release -> running pods (and the commit they report) -> user journey -> metrics/traces
# Needs the demo setup (kind cluster, seeded users, monitoring). Tokens and secrets are never printed.
#   usage: evidence.sh [namespace]
set -uo pipefail
cd "$(dirname "$0")/../.."

NS=${1:-interview}
URL=${URL:-http://interview.localtest.me:8080}
section() { printf '\n== %s\n' "$1"; }

section "1. Source"
echo "commit under test : $(git rev-parse HEAD)"
echo "baseline commit   : c439e190445d5a22c342a6f3bcd54973ce98c0bc"
echo "working tree      : $( [ -z "$(git status --porcelain)" ] && echo clean || echo DIRTY )"
echo "commits since baseline: $(git rev-list --count c439e19..HEAD)"

section "2. Delivery: image and Helm release"
helm -n "$NS" list --filter '^interview$' | cut -c1-150
echo "deployed image    : $(kubectl -n "$NS" get deploy interview-monolith -o jsonpath='{.spec.template.spec.containers[0].image}')"
echo "image revision label: $(docker image inspect "interview-monolith:$(git rev-parse HEAD)" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' 2>/dev/null || echo 'n/a (image not local)')"

section "3. Runtime: pods and the commit each one reports"
kubectl -n "$NS" get pods -l app.kubernetes.io/name=interview-monolith \
  -o custom-columns='POD:.metadata.name,READY:.status.containerStatuses[0].ready,RESTARTS:.status.containerStatuses[0].restartCount,VERSION-LABEL:.metadata.labels.app\.kubernetes\.io/version'
for pod in $(kubectl -n "$NS" get pods -l app.kubernetes.io/name=interview-monolith -o name); do
  revision=$(kubectl -n "$NS" exec "$pod" -- bash -c 'exec 3<>/dev/tcp/localhost/8081; printf "GET /actuator/info HTTP/1.0\r\n\r\n" >&3; tail -1 <&3' | grep -o '"revision":"[^"]*"' | cut -d'"' -f4)
  echo "$pod /actuator/info revision: $revision"
done

section "4. Verification: smoke test and drift check"
deploy/scripts/smoke-test.sh "$(git rev-parse HEAD)" "$NS"
deploy/scripts/drift-check.sh "$NS" | tail -1

section "5. User journey through the Ingress ($URL)"
JWT_SECRET=$(kubectl -n "$NS" get secret interview-monolith-secrets -o jsonpath='{.data.JWT_SECRET}' | base64 -d)
b64url() { openssl base64 -e -A | tr '+' '-' | tr '/' '_' | tr -d '='; }
token_for() {
  local now header payload signature
  now=$(date +%s)
  header=$(printf '{"alg":"HS256","typ":"JWT"}' | b64url)
  payload=$(printf '{"sub":"%s","role":"%s","iat":%d,"exp":%d}' "$1" "$2" "$now" $((now + 600)) | b64url)
  signature=$(printf '%s' "$header.$payload" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | b64url)
  echo "$header.$payload.$signature"
}
ALICE=$(token_for 00000000-0000-0000-0000-000000000001 USER)
ADMIN=$(token_for 00000000-0000-0000-0000-000000000003 ADMIN)
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
json_field() { python3 -c "import sys,json; d=json.load(sys.stdin); d=d['content'] if isinstance(d,dict) and 'content' in d and '$1'=='first_id' else d; print(d[0]['id'] if '$1'=='first_id' else d['$1'])"; }

echo "no token                          -> $(code "$URL/experiences")   (expect 401)"
COMPANY=$(curl -s -H "Authorization: Bearer $ALICE" "$URL/companies?size=1" | json_field first_id)
ROUND=$(curl -s -H "Authorization: Bearer $ALICE" "$URL/round-types" | json_field first_id)
CREATED=$(curl -s -X POST -H "Authorization: Bearer $ALICE" -H 'Content-Type: application/json' "$URL/experiences" \
  -d "{\"companyId\":\"$COMPANY\",\"roundTypeId\":\"$ROUND\",\"roundNumber\":1,\"content\":\"evidence run $(git rev-parse --short HEAD)\",\"questions\":[\"Trace a commit to a running pod\"]}")
EXPERIENCE=$(echo "$CREATED" | json_field id)
echo "alice submits an experience       -> id $EXPERIENCE, status $(echo "$CREATED" | json_field status)   (expect PENDING)"
listed() { curl -s -H "Authorization: Bearer $ALICE" "$URL/experiences?companyId=$COMPANY&size=100" | python3 -c "import sys,json; print(sum(1 for e in json.load(sys.stdin)['content'] if e['id']=='$EXPERIENCE'))"; }
echo "in the public listing (pending)   -> $(listed)   (expect 0)"
echo "alice tries to approve her own    -> $(code -X POST -H "Authorization: Bearer $ALICE" -H 'Content-Type: application/json' "$URL/admin/experiences/$EXPERIENCE/review" -d '{"status":"APPROVED"}')   (expect 403)"
echo "admin approves                    -> $(code -X POST -H "Authorization: Bearer $ADMIN" -H 'Content-Type: application/json' "$URL/admin/experiences/$EXPERIENCE/review" -d '{"status":"APPROVED"}')   (expect 200)"
echo "in the public listing (approved)  -> $(listed)   (expect 1)"
echo "actuator through the Ingress      -> $(code "$URL/actuator/prometheus")   (expect 401: not routed to the management port)"

section "6. Observability for that journey"
kubectl -n monitoring port-forward svc/monitoring-prometheus 9090 >/dev/null 2>&1 &
PROM=$!
kubectl -n monitoring port-forward svc/tempo 3200 >/dev/null 2>&1 &
TEMPO=$!
trap 'kill $PROM $TEMPO 2>/dev/null' EXIT
until curl -s localhost:9090/-/ready >/dev/null && curl -s localhost:3200/ready >/dev/null; do sleep 1; done
sleep 20   # one scrape interval plus margin
query() { curl -s --data-urlencode "query=$1" localhost:9090/api/v1/query | python3 -c "import sys,json; r=json.load(sys.stdin)['data']['result']; print(round(float(r[0]['value'][1]),2) if r else 'n/a')"; }
echo "experiences submitted (counter)   : $(query 'sum(interview_experiences_submitted_total)')"
echo "experiences approved (counter)    : $(query 'sum(interview_experiences_reviewed_total{status="APPROVED"})')"
echo "availability, last 15m            : $(query '1 - sum(increase(http_server_requests_seconds_count{application="interview-backend",status=~"5.."}[15m])) / sum(increase(http_server_requests_seconds_count{application="interview-backend"}[15m]))')"
echo "pods scraped and up               : $(query 'sum(up{job="interview-monolith-metrics",namespace="'"$NS"'"})')"
echo "alerts firing                     : $(curl -s localhost:9090/api/v1/alerts | python3 -c "import sys,json; a=[x['labels']['alertname'] for x in json.load(sys.stdin)['data']['alerts'] if x['state']=='firing' and x['labels']['alertname'].startswith('Interview')]; print(a or 'none')")"
echo "traces for the approve call (Tempo): $(curl -s -G localhost:3200/api/search --data-urlencode 'q={ name = "http post /admin/experiences/{id}/review" }' --data-urlencode 'limit=5' | python3 -c "import sys,json; t=json.load(sys.stdin).get('traces',[]); print(len(t),'found; latest trace id', t[0]['traceID'] if t else 'n/a')" 2>/dev/null)"
