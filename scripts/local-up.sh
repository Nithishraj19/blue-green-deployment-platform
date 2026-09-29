#!/usr/bin/env bash
set -euo pipefail
for c in docker kind kubectl;do command -v "$c" >/dev/null||{ echo "Missing $c" >&2;exit 1;};done
if ! kind get clusters|grep -Fxq project6;then kind create cluster --name project6 --wait 90s;fi
docker build -t demo-app:local .;kind load docker-image demo-app:local --name project6
KUBE_CONTEXT=kind-project6 IMAGE=demo-app:local VERSION=local ./scripts/promote.sh
