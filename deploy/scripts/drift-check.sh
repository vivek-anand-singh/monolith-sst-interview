#!/usr/bin/env bash
# Reports drift between what Git/Helm says should be running and what is actually running.
#   usage: drift-check.sh [namespace]      exit 0 = no drift, 1 = drift found
set -euo pipefail
cd "$(dirname "$0")/../.."

NAMESPACE=${1:-default}
CHART=deploy/helm/interview-monolith
drift=0

release_tag=$(helm get values interview -n "$NAMESPACE" -o json | grep -o '"tag":"[^"]*"' | cut -d'"' -f4)
echo "Helm release image tag : $release_tag"

running_tags=$(kubectl -n "$NAMESPACE" get pods -l app.kubernetes.io/instance=interview \
  -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' | cut -d: -f2 | sort -u)
echo "Running pod image tags : $(echo "$running_tags" | tr '\n' ' ')"
[ "$running_tags" = "$release_tag" ] || { echo "DRIFT: pods are not all running the release tag"; drift=1; }

# Anything edited by hand (kubectl edit/scale/set image) shows up as a diff against the chart's rendering.
values_file=$(mktemp)
trap 'rm -f "$values_file"' EXIT
helm get values interview -n "$NAMESPACE" -o yaml > "$values_file"
if helm template interview "$CHART" -n "$NAMESPACE" -f "$values_file" | kubectl -n "$NAMESPACE" diff -f - >/dev/null 2>&1; then
  echo "Live objects match the chart rendering"
else
  echo "DRIFT: live objects differ from the chart rendering (run the same command without >/dev/null to see it)"
  drift=1
fi

exit $drift
