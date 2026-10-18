#!/bin/bash
set -e

export DOCKER_BUILDKIT=1

docker compose down
docker compose up --build -d
