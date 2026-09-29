#!/usr/bin/env bash
set -euo pipefail
version=${VERSION:-local}; frontend_image=${FRONTEND_IMAGE:-bluegreen/frontend:local}; backend_image=${BACKEND_IMAGE:-bluegreen/backend:local}
active=$(sed -n 's/.*server frontend-\(blue\|green\):8080.*/\1/p' proxy/conf.d/active.conf)
case "$active" in blue) candidate=green;;green) candidate=blue;;*) echo 'Invalid active Nginx upstream.' >&2;exit 1;;esac
services=("frontend-$candidate" "api-$candidate" "catalog-$candidate" "billing-$candidate")
export VERSION="$version" FRONTEND_IMAGE="$frontend_image" BACKEND_IMAGE="$backend_image"
if [[ ${PULL_IMAGES:-false} == true ]]; then docker compose pull "${services[@]}"; else docker compose build "${services[@]}"; fi
docker compose up -d --no-deps "${services[@]}"
./scripts/switch-traffic.sh "$candidate" "$version"
echo "Release $version is active in $candidate; $active remains available for rollback."
