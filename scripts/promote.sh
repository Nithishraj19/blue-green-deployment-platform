#!/usr/bin/env bash
set -euo pipefail
NS=${NAMESPACE:-blue-green}; CTX=${KUBE_CONTEXT:-}; IMG=${IMAGE:-}; VER=${VERSION:-local}
[[ "$CTX" == kind-* ]] || { echo "KUBE_CONTEXT must be a local Kind context (kind-...)." >&2; exit 2; }
[[ -n "$IMG" ]] || { echo "Set IMAGE to the built application image." >&2; exit 2; }
kubectl config get-contexts "$CTX" >/dev/null
K=(kubectl --context "$CTX" -n "$NS"); "${K[@]}" apply -f k8s/namespace.yaml >/dev/null
b=0;g=0;"${K[@]}" get deploy demo-app-blue >/dev/null 2>&1 && b=1 || true;"${K[@]}" get deploy demo-app-green >/dev/null 2>&1 && g=1 || true
if (( !b && !g )); then "${K[@]}" apply -f k8s/deployments.yaml; elif (( b != g )); then echo 'Repair incomplete blue/green deployment pair.' >&2; exit 1; fi
"${K[@]}" get svc demo-app >/dev/null 2>&1 || "${K[@]}" apply -f k8s/service.yaml
active=$("${K[@]}" get svc demo-app -o jsonpath='{.spec.selector.track}');case "$active" in blue) next=green;;green) next=blue;;*) echo "Unknown active color: $active" >&2;exit 1;;esac
d=demo-app-$next;"${K[@]}" set image deploy/$d app=$IMG;"${K[@]}" set env deploy/$d VERSION=$VER;"${K[@]}" rollout status deploy/$d --timeout=180s
p1='';p2='';cleanup(){ [[ -z $p1 ]]||kill "$p1" 2>/dev/null||true;[[ -z $p2 ]]||kill "$p2" 2>/dev/null||true;};trap cleanup EXIT
"${K[@]}" port-forward --address 127.0.0.1 deploy/$d 18081:8080 >/tmp/project6-candidate-forward.log 2>&1 & p1=$!
check(){ for _ in $(seq 1 30);do if curl -fsS http://127.0.0.1:$1/health >/dev/null && curl -fsS http://127.0.0.1:$1/version|grep -Fq "\"version\":\"$VER\"";then return 0;fi;sleep 1;done;return 1;}
patch(){ "${K[@]}" patch svc demo-app --type=merge -p "{\"spec\":{\"selector\":{\"app\":\"demo-app\",\"track\":\"$1\"}}}";}
if ! check 18081;then echo "Candidate failed; traffic remains on $active." >&2;exit 1;fi
patch "$next" >/dev/null;"${K[@]}" port-forward --address 127.0.0.1 svc/demo-app 18080:80 >/tmp/project6-service-forward.log 2>&1 & p2=$!
if ! check 18080;then patch "$active" >/dev/null;echo "Post-switch check failed; restored $active." >&2;exit 1;fi
echo "Promoted $next release $VER; previous color $active remains available."
