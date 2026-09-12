#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
DOMAIN=sixty-seven.net
RUNSTAMP=$(date +%Y%m%d-%H%M%S)
TMP=/tmp/67-v294-trace-$RUNSTAMP
mkdir -p "$TMP"
cd "$ROOT"

fail(){ echo "FAILED_STEP=$1"; echo "ERROR=${2:-$1}"; exit 1; }

# Guards
[ -f src/pages/AdminDashboard.jsx ] || fail SOURCE_MISSING
[ -f src/pages/AdminDashboard.v29.4.css ] || fail V29_4_CSS_MISSING
[ -f src/assets/admin-v29.4-hero-highres.jpg ] || fail HIGHRES_ASSET_MISSING
grep -q "import './AdminDashboard.v29.4.css';" src/pages/AdminDashboard.jsx || fail V29_4_NOT_ACTIVE_IN_SOURCE
npm run build >"$TMP/build.log" 2>&1 || { tail -n 120 "$TMP/build.log"; fail BUILD_FAILED; }

LOCAL_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' dist/index.html | sort -u | tr '\n' ' ')
LOCAL_SHA=$(sha256sum dist/index.html | awk '{print $1}')

# Full nginx trace. This is the source of truth for routing.
(nginx -T >"$TMP/nginx-T.txt" 2>&1) || fail NGINX_T_FAILED

python3 - "$TMP/nginx-T.txt" "$TMP/route.json" <<'PY'
import sys,re,json
text=open(sys.argv[1],errors='ignore').read()
# find server blocks containing the exact domain
blocks=[]
for m in re.finditer(r'\bserver\s*\{', text):
    i=m.start(); depth=0; end=None
    for j in range(m.start(), len(text)):
        c=text[j]
        if c=='{': depth+=1
        elif c=='}':
            depth-=1
            if depth==0:
                end=j+1; break
    if end:
        b=text[i:end]
        if re.search(r'\bserver_name\b[^;]*\bsixty-seven\.net\b', b): blocks.append(b)
if not blocks:
    json.dump({'mode':'UNRESOLVED','error':'SERVER_BLOCK_NOT_FOUND'},open(sys.argv[2],'w')); sys.exit()
# prefer ssl/443 block
block=next((b for b in blocks if re.search(r'\blisten\b[^;]*443',b)),blocks[0])
# capture simple directives within selected server block
proxy=re.findall(r'\bproxy_pass\s+([^;]+);',block)
roots=re.findall(r'\broot\s+([^;]+);',block)
aliases=re.findall(r'\balias\s+([^;]+);',block)
listen=re.findall(r'\blisten\s+([^;]+);',block)
# resolve named upstream if present
result={'server_block':block,'proxy_pass':proxy,'roots':roots,'aliases':aliases,'listen':listen}
if proxy:
    p=proxy[0].strip()
    result['mode']='PROXY'
    result['target']=p
    mm=re.match(r'https?://(?:127\.0\.0\.1|localhost):([0-9]+)',p)
    if mm: result['port']=int(mm.group(1))
    else:
        mn=re.match(r'https?://([A-Za-z0-9_.-]+)',p)
        if mn:
            name=mn.group(1)
            um=re.search(r'\bupstream\s+'+re.escape(name)+r'\s*\{(.*?)\}',text,re.S)
            if um:
                sm=re.search(r'\bserver\s+(?:127\.0\.0\.1|localhost):([0-9]+)',um.group(1))
                if sm: result['port']=int(sm.group(1)); result['upstream_name']=name
elif aliases:
    result['mode']='STATIC_ALIAS'; result['target']=aliases[0].strip()
elif roots:
    result['mode']='STATIC_ROOT'; result['target']=roots[-1].strip()
else:
    result['mode']='UNRESOLVED'; result['error']='NO_ROOT_OR_PROXY_PASS'
json.dump(result,open(sys.argv[2],'w'))
PY

MODE=$(python3 -c "import json;print(json.load(open('$TMP/route.json')).get('mode','UNRESOLVED'))")
TARGET=$(python3 -c "import json;print(json.load(open('$TMP/route.json')).get('target','UNRESOLVED'))")
PORT=$(python3 -c "import json;print(json.load(open('$TMP/route.json')).get('port',''))")
DEPLOY_ACTION=NONE
UPSTREAM_PID=N/A
UPSTREAM_CWD=N/A
UPSTREAM_CMD=N/A
SERVICE_UNIT=N/A
LIVE_ROOT=N/A

if [[ "$MODE" == STATIC_* ]]; then
  LIVE_ROOT="$TARGET"
  [ -d "$LIVE_ROOT" ] || fail STATIC_LIVE_ROOT_MISSING "$LIVE_ROOT"
  if [ "$LIVE_ROOT" != "$ROOT/dist" ]; then
    rsync -a --delete "$ROOT/dist/" "$LIVE_ROOT/"
    DEPLOY_ACTION=RSYNC_DIST_TO_STATIC_ROOT
  else
    DEPLOY_ACTION=STATIC_ROOT_ALREADY_LOCAL_DIST
  fi
  nginx -t >/dev/null 2>&1 || fail NGINX_CONFIG_INVALID
  systemctl reload nginx >/dev/null 2>&1 || true
elif [ "$MODE" = "PROXY" ]; then
  [ -n "$PORT" ] || fail PROXY_UPSTREAM_PORT_UNRESOLVED "$TARGET"
  UPSTREAM_PID=$(ss -ltnp 2>/dev/null | awk -v p=":$PORT" '$4 ~ p { if (match($0,/pid=([0-9]+)/,m)){print m[1]; exit}}')
  [ -n "$UPSTREAM_PID" ] || fail UPSTREAM_PID_UNRESOLVED "$PORT"
  UPSTREAM_CWD=$(readlink -f "/proc/$UPSTREAM_PID/cwd" 2>/dev/null || true)
  UPSTREAM_CMD=$(tr '\0' ' ' < "/proc/$UPSTREAM_PID/cmdline" 2>/dev/null || true)
  # Map PID to systemd unit if possible.
  SERVICE_UNIT=$(sed -n 's#.*system.slice/\([^/]*\.service\).*#\1#p' "/proc/$UPSTREAM_PID/cgroup" | head -n1)
  [ -n "$SERVICE_UNIT" ] || SERVICE_UNIT=N/A

  curl -fsSL -H "Host: $DOMAIN" "http://127.0.0.1:$PORT/admin/?trace=$RUNSTAMP" -o "$TMP/upstream-before.html" || true
  UPSTREAM_BEFORE_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/upstream-before.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
  if [ "$UPSTREAM_BEFORE_REFS" != "$LOCAL_REFS" ]; then
    # Only restart a verified 67 service/process.
    if [ "$UPSTREAM_CWD" = "$ROOT" ] && [[ "$UPSTREAM_CMD" == *"server/index.js"* ]] && [ "$SERVICE_UNIT" != "N/A" ]; then
      systemctl restart "$SERVICE_UNIT"
      sleep 2
      DEPLOY_ACTION=RESTART_VERIFIED_67_SYSTEMD_SERVICE
    elif [ "$UPSTREAM_CWD" = "$ROOT" ] && [[ "$UPSTREAM_CMD" == *"server/index.js"* ]]; then
      fail VERIFIED_67_PROCESS_HAS_NO_SAFE_RESTART_UNIT "$UPSTREAM_CMD"
    else
      fail PROXY_POINTS_TO_UNVERIFIED_PROCESS "cwd=$UPSTREAM_CWD cmd=$UPSTREAM_CMD"
    fi
  else
    DEPLOY_ACTION=UPSTREAM_ALREADY_LOCAL_DIST
  fi
else
  fail ROUTING_MODE_UNRESOLVED "$(cat "$TMP/route.json")"
fi

# Recheck origin and public after exact activation path.
curl -kfsSL --resolve "$DOMAIN:443:127.0.0.1" -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?trace-origin=$RUNSTAMP" -o "$TMP/origin.html" || true
curl -fsSL -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?trace-public=$RUNSTAMP" -o "$TMP/public.html" || true
ORIGIN_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/origin.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
PUBLIC_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/public.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
ORIGIN_MATCH=NO; PUBLIC_MATCH=NO
[ -n "$ORIGIN_REFS" ] && [ "$ORIGIN_REFS" = "$LOCAL_REFS" ] && ORIGIN_MATCH=YES
[ -n "$PUBLIC_REFS" ] && [ "$PUBLIC_REFS" = "$LOCAL_REFS" ] && PUBLIC_MATCH=YES

# If static root is correct but origin still stale, force one nginx restart to clear open_file_cache/fds.
if [[ "$MODE" == STATIC_* ]] && [ "$ORIGIN_MATCH" != YES ]; then
  systemctl restart nginx
  sleep 2
  curl -kfsSL --resolve "$DOMAIN:443:127.0.0.1" -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?trace-origin2=$RUNSTAMP" -o "$TMP/origin2.html" || true
  ORIGIN_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/origin2.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
  [ -n "$ORIGIN_REFS" ] && [ "$ORIGIN_REFS" = "$LOCAL_REFS" ] && ORIGIN_MATCH=YES
  DEPLOY_ACTION=${DEPLOY_ACTION}+NGINX_RESTART
fi

printf 'BUILD=PASS\n'
printf 'NGINX_ROUTE_MODE=%s\n' "$MODE"
printf 'NGINX_ROUTE_TARGET=%s\n' "$TARGET"
printf 'LIVE_ROOT=%s\n' "$LIVE_ROOT"
printf 'UPSTREAM_PORT=%s\n' "${PORT:-N/A}"
printf 'UPSTREAM_PID=%s\n' "$UPSTREAM_PID"
printf 'UPSTREAM_CWD=%s\n' "$UPSTREAM_CWD"
printf 'UPSTREAM_CMD=%s\n' "$UPSTREAM_CMD"
printf 'SERVICE_UNIT=%s\n' "$SERVICE_UNIT"
printf 'DEPLOY_ACTION=%s\n' "$DEPLOY_ACTION"
printf 'LOCAL_INDEX_SHA=%s\n' "$LOCAL_SHA"
printf 'ORIGIN_MATCH_LOCAL_DIST=%s\n' "$ORIGIN_MATCH"
printf 'PUBLIC_MATCH_LOCAL_DIST=%s\n' "$PUBLIC_MATCH"
printf 'LOCAL_DIST_REFS=%s\n' "$LOCAL_REFS"
printf 'ORIGIN_REFS=%s\n' "$ORIGIN_REFS"
printf 'PUBLIC_REFS=%s\n' "$PUBLIC_REFS"
printf 'SOURCE_PROJECT_PUSHED=NO\n'

[ "$ORIGIN_MATCH" = YES ] || fail ORIGIN_STILL_NOT_LOCAL_DIST
[ "$PUBLIC_MATCH" = YES ] || fail PUBLIC_STILL_NOT_LOCAL_DIST

echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
