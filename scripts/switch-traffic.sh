#!/usr/bin/env bash
set -euo pipefail
color=${1:?usage: switch-traffic.sh blue|green [version]}
version=${2:-}
port=${PROXY_PORT:-8080}
[[ "$color" == blue || "$color" == green ]] || { echo 'Color must be blue or green.' >&2; exit 2; }
current=$(sed -n 's/.*server frontend-\(blue\|green\):8080.*/\1/p' proxy/conf.d/active.conf)
[[ -n "$current" ]] || { echo 'Could not read active Nginx upstream.' >&2; exit 1; }
./scripts/validate-candidate.sh "$color" "${version:-$(docker compose exec -T "frontend-$color" node -p 'process.env.APP_VERSION')}"
set_active(){
  local c=$1 tmp=proxy/conf.d/active.conf.tmp
  printf 'upstream active_frontend { server frontend-%s:8080; }\n' "$c" > "$tmp"
  mv "$tmp" proxy/conf.d/active.conf
  if ! docker compose exec -T reverse-proxy nginx -t >/dev/null; then
    printf 'upstream active_frontend { server frontend-%s:8080; }\n' "$current" > "$tmp"
    mv "$tmp" proxy/conf.d/active.conf
    return 1
  fi
  if ! docker compose exec -T reverse-proxy nginx -s reload >/dev/null; then
    printf 'upstream active_frontend { server frontend-%s:8080; }\n' "$current" > "$tmp"
    mv "$tmp" proxy/conf.d/active.conf
    docker compose exec -T reverse-proxy nginx -t >/dev/null || true
    docker compose exec -T reverse-proxy nginx -s reload >/dev/null || true
    return 1
  fi
}
set_active "$color"
ready=0
for _ in $(seq 1 20); do
  if curl -fsS "http://127.0.0.1:$port/health" >/dev/null && curl -fsS "http://127.0.0.1:$port/version" | grep -Fq "\"color\":\"$color\"" && { [[ -z "$version" ]] || curl -fsS "http://127.0.0.1:$port/version" | grep -Fq "\"version\":\"$version\""; }; then ready=1; break; fi
  sleep 1
done
if (( !ready )); then set_active "$current"; echo "Proxy smoke check failed; traffic restored to $current." >&2; exit 1; fi
echo "Nginx now routes traffic to $color."
