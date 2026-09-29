#!/usr/bin/env bash
set -euo pipefail
command -v docker >/dev/null || { echo 'Docker is required.' >&2; exit 1; }
docker compose version >/dev/null
export VERSION=${VERSION:-local} FRONTEND_IMAGE=${FRONTEND_IMAGE:-bluegreen/frontend:local} BACKEND_IMAGE=${BACKEND_IMAGE:-bluegreen/backend:local}
docker compose build
docker compose up -d
for _ in $(seq 1 30); do if curl -fsS "http://127.0.0.1:${PROXY_PORT:-8080}/health" >/dev/null; then echo "Blue environment is serving release $VERSION."; exit 0; fi; sleep 1; done
docker compose ps
echo 'Stack started but proxy health check did not pass.' >&2; exit 1
