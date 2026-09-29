#!/usr/bin/env bash
set -euo pipefail
color=${1:?usage: validate-candidate.sh blue|green version}
version=${2:?release version required}
[[ "$color" == blue || "$color" == green ]] || { echo 'Color must be blue or green.' >&2; exit 2; }
docker compose exec -T -e EXPECT_COLOR="$color" -e EXPECT_VERSION="$version" "frontend-$color" node -e '
(async()=>{const r=await fetch("http://127.0.0.1:8080/version");if(!r.ok)throw Error("frontend version endpoint unhealthy");const x=await r.json();if(x.color!==process.env.EXPECT_COLOR||x.version!==process.env.EXPECT_VERSION)throw Error("frontend release identity mismatch");if(!x.api||x.api.color!==process.env.EXPECT_COLOR||x.api.version!==process.env.EXPECT_VERSION)throw Error("API release identity mismatch");if(x.api.services.length<2||x.api.services.some(s=>s.color!==process.env.EXPECT_COLOR||s.version!==process.env.EXPECT_VERSION))throw Error("backend services unhealthy or wrong release");console.log(JSON.stringify(x))})().catch(e=>{console.error(e);process.exit(1)})'
