#!/usr/bin/env bash
# Generates authenticated traffic through the Ingress so dashboards and alerts have something to show.
# Uses the seeded demo users (db/seed.sh) and mints their tokens with the cluster's JWT secret, which is read
# straight from the Kubernetes Secret and never printed.
#   usage: traffic.sh [seconds=300] [parallel-workers=3]
set -euo pipefail

DURATION=${1:-300}
WORKERS=${2:-3}
URL=${URL:-http://interview.localtest.me:8080}

JWT_SECRET=$(kubectl get secret interview-monolith-secrets -o jsonpath='{.data.JWT_SECRET}' | base64 -d)
b64url() { openssl base64 -e -A | tr '+' '-' | tr '/' '_' | tr -d '='; }
token_for() {
  local header payload now signature
  now=$(date +%s)
  header=$(printf '{"alg":"HS256","typ":"JWT"}' | b64url)
  payload=$(printf '{"sub":"%s","role":"%s","iat":%d,"exp":%d}' "$1" "$2" "$now" $((now + DURATION + 60)) | b64url)
  signature=$(printf '%s' "$header.$payload" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | b64url)
  echo "$header.$payload.$signature"
}
ALICE=$(token_for 00000000-0000-0000-0000-000000000001 USER)
ADMIN=$(token_for 00000000-0000-0000-0000-000000000003 ADMIN)

first_id() { python3 -c "import sys,json; d=json.load(sys.stdin); d=d['content'] if isinstance(d,dict) else d; print(d[0]['id'])"; }
COMPANY=$(curl -sf -H "Authorization: Bearer $ALICE" "$URL/companies?size=1" | first_id)
ROUND=$(curl -sf -H "Authorization: Bearer $ALICE" "$URL/round-types" | first_id)

worker() {
  local end=$((SECONDS + DURATION)) n=0 id
  while [ $SECONDS -lt $end ]; do
    curl -s -o /dev/null -m 70 -H "Authorization: Bearer $ALICE" "$URL/experiences?page=0&size=10"
    curl -s -o /dev/null -m 70 -H "Authorization: Bearer $ALICE" "$URL/companies"
    n=$((n + 1))
    if [ $((n % 10)) -eq 0 ]; then
      # Every so often, run the whole journey: submit, then an admin approves.
      id=$(curl -s -m 70 -X POST -H "Authorization: Bearer $ALICE" -H 'Content-Type: application/json' "$URL/experiences" \
        -d "{\"companyId\":\"$COMPANY\",\"roundTypeId\":\"$ROUND\",\"roundNumber\":1,\"content\":\"traffic\",\"questions\":[\"q\"]}" \
        | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null || true)
      [ -n "$id" ] && curl -s -o /dev/null -m 70 -X POST -H "Authorization: Bearer $ADMIN" -H 'Content-Type: application/json' \
        "$URL/admin/experiences/$id/review" -d '{"status":"APPROVED"}'
    fi
    sleep 0.3
  done
}

for _ in $(seq 1 "$WORKERS"); do worker & done
wait
echo "traffic finished"
