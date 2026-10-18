#!/usr/bin/env bash
# Verifies a deployed release: the running pod reports the expected commit, is ready, and enforces auth.
#   usage: smoke-test.sh <expected-commit-sha> [namespace] [deployment]
set -euo pipefail

EXPECTED_SHA=${1:?usage: smoke-test.sh <expected-commit-sha> [namespace] [deployment]}
NAMESPACE=${2:-interview}
DEPLOYMENT=${3:-interview-monolith}
API_PORT=18000
MANAGEMENT_PORT=18081

kubectl -n "$NAMESPACE" port-forward "deploy/$DEPLOYMENT" "$API_PORT:8000" "$MANAGEMENT_PORT:8081" >/dev/null &
FORWARD_PID=$!
trap 'kill $FORWARD_PID 2>/dev/null || true' EXIT

for _ in $(seq 1 20); do
  curl -sf "localhost:$MANAGEMENT_PORT/actuator/health/readiness" >/dev/null 2>&1 && break
  sleep 1
done

fail() { echo "SMOKE TEST FAILED: $1" >&2; exit 1; }

readiness=$(curl -sf "localhost:$MANAGEMENT_PORT/actuator/health/readiness") || fail "readiness endpoint unreachable"
echo "$readiness" | grep -q '"status":"UP"' || fail "not ready: $readiness"

info=$(curl -sf "localhost:$MANAGEMENT_PORT/actuator/info") || fail "info endpoint unreachable"
running_sha=$(echo "$info" | grep -o '"revision":"[^"]*"' | cut -d'"' -f4)
[ "$running_sha" = "$EXPECTED_SHA" ] || fail "running revision '$running_sha' != expected '$EXPECTED_SHA'"

status=$(curl -s -o /dev/null -w '%{http_code}' "localhost:$API_PORT/experiences")
[ "$status" = "401" ] || fail "unauthenticated /experiences returned $status, expected 401"

echo "SMOKE TEST PASSED: revision $running_sha is ready and enforcing auth"
