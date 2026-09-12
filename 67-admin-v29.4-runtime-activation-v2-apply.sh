#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
DOMAIN=sixty-seven.net
RUNSTAMP=$(date +%Y%m%d-%H%M%S)
TMP=/tmp/67-v294-runtime-v2-$RUNSTAMP
mkdir -p "$TMP"
cd "$ROOT"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29.4"
echo "TASK=RUNTIME ACTIVATION V2"
echo "MODE=DEPLOYMENT/RUNTIME ONLY — NO SOURCE DESIGN CHANGES"
echo "=================================================="

# Guard the intended V29.4 source state.
grep -q "import './AdminDashboard.v29.4.css';" src/pages/AdminDashboard.jsx
[ -f src/pages/AdminDashboard.v29.4.css ]
[ -f src/assets/admin-v29.4-hero-highres.jpg ]

npm run build >"$TMP/build.log" 2>&1
NEW_ASSET=$(find dist/assets -maxdepth 1 -type f -name 'admin-v29.4-hero-highres-*.jpg' | head -n1)
[ -n "$NEW_ASSET" ] && [ -s "$NEW_ASSET" ]
LOCAL_INDEX_SHA=$(sha256sum dist/index.html | awk '{print $1}')
LOCAL_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' dist/index.html | sort -u | tr '\n' ' ')

# Snapshot live HTML before deployment.
curl -kfsSL --resolve "$DOMAIN:443:127.0.0.1" -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294v2=$RUNSTAMP" -o "$TMP/origin-before.html" || true
curl -fsSL -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294v2=$RUNSTAMP" -o "$TMP/public-before.html" || true
ORIGIN_BEFORE_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/origin-before.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
PUBLIC_BEFORE_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/public-before.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)

# Discover the actual Nginx config files that mention this domain.
mapfile -t NGINX_FILES < <(grep -RIl --include='*.conf' "$DOMAIN" /etc/nginx 2>/dev/null | sort -u)
printf '%s\n' "${NGINX_FILES[@]:-}" > "$TMP/nginx-domain-files.txt"

ROOT_CANDIDATES=()
UPSTREAMS=()
for f in "${NGINX_FILES[@]:-}"; do
  while IFS= read -r root; do [ -n "$root" ] && ROOT_CANDIDATES+=("$root"); done < <(sed -nE 's/^[[:space:]]*root[[:space:]]+([^;]+);.*/\1/p' "$f" | sed 's/[[:space:]]*$//' | sort -u)
  while IFS= read -r up; do [ -n "$up" ] && UPSTREAMS+=("$up"); done < <(sed -nE 's/^[[:space:]]*proxy_pass[[:space:]]+http:\/\/([^;]+);.*/\1/p' "$f" | sort -u)
done
mapfile -t ROOT_CANDIDATES_UNIQ < <(printf '%s\n' "${ROOT_CANDIDATES[@]:-}" | sed '/^$/d' | sort -u)
mapfile -t UPSTREAMS_UNIQ < <(printf '%s\n' "${UPSTREAMS[@]:-}" | sed '/^$/d' | sort -u)

LIVE_MODE=UNRESOLVED
LIVE_ROOT=UNRESOLVED
UPSTREAM=UNRESOLVED
UPSTREAM_PID=UNRESOLVED
UPSTREAM_CWD=UNRESOLVED
DEPLOY_ACTION=NONE

# Prefer explicit Nginx static roots that contain an app index.
for r in "${ROOT_CANDIDATES_UNIQ[@]:-}"; do
  r=${r//\$document_root/}
  if [ -n "$r" ] && [ -d "$r" ] && [ -f "$r/index.html" ] && [ -d "$r/assets" ]; then
    LIVE_MODE=NGINX_STATIC
    LIVE_ROOT="$r"
    break
  fi
done

# If Nginx proxies to a local Node service, identify the listener PID and its working directory.
if [ "$LIVE_MODE" = "UNRESOLVED" ]; then
  for up in "${UPSTREAMS_UNIQ[@]:-}"; do
    hostport=${up%%/*}
    host=${hostport%%:*}
    port=${hostport##*:}
    case "$host" in
      127.0.0.1|localhost|0.0.0.0)
        if [[ "$port" =~ ^[0-9]+$ ]]; then
          pid=""
          if command -v lsof >/dev/null 2>&1; then pid=$(lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null | head -n1 || true); fi
          if [ -z "$pid" ] && command -v fuser >/dev/null 2>&1; then pid=$(fuser "$port"/tcp 2>/dev/null | awk '{print $1}' || true); fi
          if [ -z "$pid" ]; then pid=$(ss -ltnp 2>/dev/null | awk -v p=":$port" '$4 ~ p"$" { if (match($0,/pid=[0-9]+/)) { print substr($0,RSTART+4,RLENGTH-4); exit } }' || true); fi
          if [ -n "$pid" ] && [ -e "/proc/$pid/cwd" ]; then
            cwd=$(readlink -f "/proc/$pid/cwd" || true)
            if [ -n "$cwd" ] && [ -d "$cwd/dist" ]; then
              LIVE_MODE=NGINX_PROXY_NODE
              UPSTREAM="$up"
              UPSTREAM_PID="$pid"
              UPSTREAM_CWD="$cwd"
              LIVE_ROOT="$cwd/dist"
              break
            fi
          fi
        fi
      ;;
    esac
  done
fi

# Fallback: inspect active Node processes for server/index.js and derive process.cwd()/dist.
if [ "$LIVE_MODE" = "UNRESOLVED" ]; then
  while IFS= read -r pid; do
    [ -e "/proc/$pid/cwd" ] || continue
    cmd=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)
    case "$cmd" in
      *server/index.js*)
        cwd=$(readlink -f "/proc/$pid/cwd" || true)
        if [ -n "$cwd" ] && [ -d "$cwd/dist" ]; then
          LIVE_MODE=NODE_PROCESS_FALLBACK
          UPSTREAM_PID="$pid"
          UPSTREAM_CWD="$cwd"
          LIVE_ROOT="$cwd/dist"
          break
        fi
      ;;
    esac
  done < <(pgrep -f 'node .*server/index.js' || true)
fi

# If resolved, deploy the freshly built dist to the exact served root.
if [ "$LIVE_ROOT" != "UNRESOLVED" ] && [ -d "$LIVE_ROOT" ]; then
  LIVE_BEFORE_SHA=$(sha256sum "$LIVE_ROOT/index.html" 2>/dev/null | awk '{print $1}' || true)
  if [ "$LIVE_ROOT" = "$ROOT/dist" ]; then
    DEPLOY_ACTION=LIVE_ROOT_ALREADY_LOCAL_DIST
  else
    BACKUP="$TMP/live-root-backup"
    mkdir -p "$BACKUP"
    cp -a "$LIVE_ROOT/index.html" "$BACKUP/index.html" 2>/dev/null || true
    rsync -a "$ROOT/dist/" "$LIVE_ROOT/"
    DEPLOY_ACTION=RSYNC_DIST_TO_ACTUAL_LIVE_ROOT
  fi
  LIVE_AFTER_SHA=$(sha256sum "$LIVE_ROOT/index.html" 2>/dev/null | awk '{print $1}' || true)
else
  LIVE_BEFORE_SHA=UNAVAILABLE
  LIVE_AFTER_SHA=UNAVAILABLE
fi

# Nginx reload is safe after successful config validation; static files themselves need no restart.
if command -v nginx >/dev/null 2>&1 && nginx -t >/dev/null 2>&1; then
  systemctl reload nginx >/dev/null 2>&1 || true
fi

sleep 1
curl -kfsSL --resolve "$DOMAIN:443:127.0.0.1" -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294v2after=$RUNSTAMP" -o "$TMP/origin-after.html" || true
curl -fsSL -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294v2after=$RUNSTAMP" -o "$TMP/public-after.html" || true
ORIGIN_AFTER_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/origin-after.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
PUBLIC_AFTER_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/public-after.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)

ORIGIN_MATCH=NO
PUBLIC_MATCH=NO
[ -n "$ORIGIN_AFTER_REFS" ] && [ "$ORIGIN_AFTER_REFS" = "$LOCAL_REFS" ] && ORIGIN_MATCH=YES
[ -n "$PUBLIC_AFTER_REFS" ] && [ "$PUBLIC_AFTER_REFS" = "$LOCAL_REFS" ] && PUBLIC_MATCH=YES

curl -sSI "https://$DOMAIN/admin/?v294v2h=$RUNSTAMP" > "$TMP/public-headers.txt" || true
EDGE_SERVER=$(awk -F': ' 'tolower($1)=="server"{gsub("\r","");print $2;exit}' "$TMP/public-headers.txt")
CF_CACHE_STATUS=$(awk -F': ' 'tolower($1)=="cf-cache-status"{gsub("\r","");print $2;exit}' "$TMP/public-headers.txt")
EDGE_CACHE_STALE=NO
if [ "$ORIGIN_MATCH" = YES ] && [ "$PUBLIC_MATCH" != YES ]; then EDGE_CACHE_STALE=YES; fi

echo "BUILD=PASS"
echo "LOCAL_INDEX_SHA=$LOCAL_INDEX_SHA"
echo "LIVE_MODE=$LIVE_MODE"
echo "LIVE_ROOT=$LIVE_ROOT"
echo "UPSTREAM=$UPSTREAM"
echo "UPSTREAM_PID=$UPSTREAM_PID"
echo "UPSTREAM_CWD=$UPSTREAM_CWD"
echo "DEPLOY_ACTION=$DEPLOY_ACTION"
echo "LIVE_INDEX_SHA_BEFORE=$LIVE_BEFORE_SHA"
echo "LIVE_INDEX_SHA_AFTER=$LIVE_AFTER_SHA"
echo "ORIGIN_MATCH_LOCAL_DIST=$ORIGIN_MATCH"
echo "PUBLIC_MATCH_LOCAL_DIST=$PUBLIC_MATCH"
echo "EDGE_CACHE_STALE=$EDGE_CACHE_STALE"
echo "EDGE_SERVER=${EDGE_SERVER:-UNKNOWN}"
echo "CF_CACHE_STATUS=${CF_CACHE_STATUS:-UNKNOWN}"
echo "HIGHRES_BUILT_ASSET=$NEW_ASSET"
echo "SOURCE_PROJECT_PUSHED=NO"

if [ "$LIVE_MODE" = UNRESOLVED ]; then
  echo "FAILED_STEP=LIVE_RUNTIME_TARGET_UNRESOLVED"
  echo "ERROR=Could not resolve actual Nginx static root or proxied Node process working directory"
  exit 2
fi
if [ "$ORIGIN_MATCH" != YES ]; then
  echo "FAILED_STEP=ORIGIN_STILL_NOT_LOCAL_DIST"
  echo "ERROR=Actual localhost Nginx origin still serves different bundle after exact live-root activation"
  exit 3
fi
if [ "$PUBLIC_MATCH" != YES ]; then
  echo "FAILED_STEP=PUBLIC_EDGE_STILL_NOT_LOCAL_DIST"
  echo "ERROR=Origin is correct but public response still serves a different bundle"
  exit 4
fi

echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
