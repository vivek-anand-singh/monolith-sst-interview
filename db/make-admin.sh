#!/bin/bash
# Promote an existing user to ADMIN (there is no promotion endpoint). Log in with Google once
# first so the account exists.   Usage: ./db/make-admin.sh you@gmail.com [SUPERADMIN]
set -e

[ -n "$1" ] || { echo "usage: $0 <email> [ADMIN|SUPERADMIN]"; exit 1; }
ROLE="${2:-ADMIN}"
case "$ROLE" in ADMIN|SUPERADMIN) ;; *) echo "role must be ADMIN or SUPERADMIN"; exit 1;; esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] || { echo ".env not found (cp .env.example .env)"; exit 1; }
set -a; . "$SCRIPT_DIR/../.env"; set +a
source "$SCRIPT_DIR/_psql.sh"

EMAIL_SQL="${1//\'/\'\'}"
UPDATED=$($PSQL -Atq -c "UPDATE users SET role = '$ROLE', updated_at = now() WHERE email = '$EMAIL_SQL' RETURNING email")
[ -n "$UPDATED" ] && echo "$UPDATED is now $ROLE (log in again to get a token with the new role)" \
                  || { echo "No user with email $1 — log in with Google once first."; exit 1; }
