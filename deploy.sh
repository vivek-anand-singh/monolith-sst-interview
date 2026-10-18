#!/bin/bash
set -e

export DOCKER_BUILDKIT=1
export GIT_SHA=$(git rev-parse HEAD)

docker compose down
docker compose up --build -d
