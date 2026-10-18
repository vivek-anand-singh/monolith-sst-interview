#!/bin/bash
# Sourced by the seed scripts. Defines $PSQL, a psql command connected to the app database.
#
# Built from DB_URL / DB_USERNAME / DB_PASSWORD (jdbc:postgresql://host:port/db), so it hits
# exactly the database the app uses. Needs `psql` on PATH. Without it, use the container:
#   PSQL="docker compose exec -T db psql -U interviewuser -d interview -v ON_ERROR_STOP=1" ./db/seed.sh

if [ -z "$PSQL" ]; then
    _jdbc="${DB_URL#jdbc:postgresql://}"
    _hostport="${_jdbc%%/*}"
    _dbname="${_jdbc#*/}"; _dbname="${_dbname%%\?*}"
    _host="${_hostport%%:*}"
    _port="${_hostport##*:}"; [ "$_port" = "$_hostport" ] && _port=5432

    export PGPASSWORD="$DB_PASSWORD"
    PSQL="psql -h $_host -p $_port -U $DB_USERNAME -d $_dbname -v ON_ERROR_STOP=1"
fi
export PSQL
