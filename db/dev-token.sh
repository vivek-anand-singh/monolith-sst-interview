#!/bin/bash
# Print a dev JWT (valid 1 year, signed with JWT_SECRET from .env) for a seeded user.
#   ./db/dev-token.sh alice|bob|admin
# Use it as `Authorization: Bearer <token>`, or in the browser set a cookie named `sst_token`
# (DevTools → Application → Cookies → localhost:3000) to use the frontend without Google login.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] || { echo ".env not found (cp .env.example .env)"; exit 1; }
set -a; . "$SCRIPT_DIR/../.env"; set +a

case "$1" in
    alice) USER_ID="00000000-0000-0000-0000-000000000001"; ROLE=USER ;;
    bob)   USER_ID="00000000-0000-0000-0000-000000000002"; ROLE=USER ;;
    admin) USER_ID="00000000-0000-0000-0000-000000000003"; ROLE=ADMIN ;;
    *) echo "usage: $0 alice|bob|admin"; exit 1 ;;
esac

_b64url() { openssl base64 -e -A | tr '+' '-' | tr '/' '_' | tr -d '='; }
header=$(printf '{"alg":"HS256","typ":"JWT"}' | _b64url)
now=$(date +%s); exp=$((now + 31536000))
payload=$(printf '{"sub":"%s","role":"%s","iat":%d,"exp":%d}' "$USER_ID" "$ROLE" "$now" "$exp" | _b64url)
sig=$(printf '%s' "${header}.${payload}" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | _b64url)
echo "${header}.${payload}.${sig}"
