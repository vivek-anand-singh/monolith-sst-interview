#!/usr/bin/env bash
# Creates the Secret the chart reads (DB_URL, JWT_SECRET, GOOGLE_CLIENT_ID, optional DB_USERNAME/DB_PASSWORD)
# from an env file, so the values never appear in git, in the chart or on the command line.
#   usage: create-secret.sh <env-file> [namespace]
set -euo pipefail

ENV_FILE=${1:?usage: create-secret.sh <env-file> [namespace]}
NAMESPACE=${2:-interview}

kubectl apply -f "$(dirname "$0")/../kind/namespace.yaml" >/dev/null

filtered=$(mktemp)
trap 'rm -f "$filtered"' EXIT
grep -E '^(DB_URL|DB_USERNAME|DB_PASSWORD|JWT_SECRET|GOOGLE_CLIENT_ID)=' "$ENV_FILE" > "$filtered"

for required in DB_URL JWT_SECRET GOOGLE_CLIENT_ID; do
  grep -q "^${required}=" "$filtered" || { echo "${required} missing from ${ENV_FILE}" >&2; exit 1; }
done

# HS256 needs a key of at least 256 bits; a short secret makes tokens guessable offline.
jwt_secret=$(grep "^JWT_SECRET=" "$filtered" | cut -d= -f2-)
[ "${#jwt_secret}" -ge 32 ] || { echo "JWT_SECRET must be at least 32 characters (try: openssl rand -hex 32)" >&2; exit 1; }

kubectl -n "$NAMESPACE" create secret generic interview-monolith-secrets \
  --from-env-file="$filtered" --dry-run=client -o yaml | kubectl apply -f -
