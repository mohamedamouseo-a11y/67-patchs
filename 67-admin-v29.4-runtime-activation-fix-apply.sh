#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
DOMAIN=sixty-seven.net
RUNSTAMP=$(date +%Y%m%d-%H%M%S)
TMP=/tmp/67-v294-runtime-$RUNSTAMP
mkdir -p "$TMP"
cd "$ROOT"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29.4"
echo "TASK=RUNTIME ACTIVATION FIX"
echo "MODE=DEPLOYMENT/RUNTIME ONLY"
echo "=================================================="

# Source/runtime guards.
grep -q "import './AdminDashboard.v29.4.css';" src/pages/AdminDashboard.jsx
[ -f src/pages/AdminDashboard.v29.4.css ]
[ -f src/assets/admin-v29.4-hero-highres.jpg ]

npm run build >"$TMP/build.log" 2>&1
NEW_ASSET=$(find dist/assets -maxdepth 1 -type f -name 'admin-v29.4-hero-highres-*.jpg' | head -n1)
[ -n "$NEW_ASSET" ] && [ -s "$NEW_ASSET" ]

LOCAL_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' dist/index.html | sort -u | tr '\n' ' ')

# Public edge and local-origin HTML snapshots.
curl -fsSL -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294=$RUNSTAMP" -o "$TMP/public.html" || true
curl -kfsSL --resolve "$DOMAIN:443:127.0.0.1" -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294=$RUNSTAMP" -o "$TMP/origin.html" || true

PUBLIC_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/public.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
ORIGIN_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/origin.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)

LIVE_ROOT=""
DEPLOY_ACTION="NONE"
ORIGIN_MATCH="NO"
PUBLIC_MATCH="NO"
EDGE_CACHE_STALE="NO"

[ -n "$ORIGIN_REFS" ] && [ "$ORIGIN_REFS" = "$LOCAL_REFS" ] && ORIGIN_MATCH="YES"
[ -n "$PUBLIC_REFS" ] && [ "$PUBLIC_REFS" = "$LOCAL_REFS" ] && PUBLIC_MATCH="YES"

# If local origin is stale, identify the exact currently-served dist root from the legacy hashed asset.
if [ "$ORIGIN_MATCH" != "YES" ]; then
  mapfile -t LEGACY_FILES < <(find /var/www /srv /opt /home /67 -type f -name 'admin-v17-hero-C9PZPqT4.jpg' 2>/dev/null | sort -u)
  CANDIDATES=()
  for f in "${LEGACY_FILES[@]:-}"; do
    root=$(dirname "$(dirname "$f")")
    if [ -f "$root/index.html" ] && [ -d "$root/assets" ]; then
      CANDIDATES+=("$root")
    fi
  done
  mapfile -t UNIQUE_ROOTS < <(printf '%s\n' "${CANDIDATES[@]:-}" | sed '/^$/d' | sort -u)

  if [ "${#UNIQUE_ROOTS[@]}" -eq 1 ]; then
    LIVE_ROOT="${UNIQUE_ROOTS[0]}"
    if [ "$LIVE_ROOT" != "$ROOT/dist" ]; then
      BACKUP="$TMP/live-root-backup"
      mkdir -p "$BACKUP"
      cp -a "$LIVE_ROOT/index.html" "$BACKUP/" 2>/dev/null || true
      rsync -a "$ROOT/dist/" "$LIVE_ROOT/"
      DEPLOY_ACTION="RSYNC_DIST_TO_LIVE_ROOT"
      if command -v nginx >/dev/null 2>&1 && nginx -t >/dev/null 2>&1; then
        systemctl reload nginx >/dev/null 2>&1 || true
      fi
    fi
  fi
fi

# Recheck after activation attempt.
curl -kfsSL --resolve "$DOMAIN:443:127.0.0.1" -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294b=$RUNSTAMP" -o "$TMP/origin-after.html" || true
curl -fsSL -H 'Cache-Control: no-cache' "https://$DOMAIN/admin/?v294b=$RUNSTAMP" -o "$TMP/public-after.html" || true
ORIGIN_AFTER_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/origin-after.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)
PUBLIC_AFTER_REFS=$(grep -oE '/assets/[^" ]+\.(js|css)' "$TMP/public-after.html" 2>/dev/null | sort -u | tr '\n' ' ' || true)

[ -n "$ORIGIN_AFTER_REFS" ] && [ "$ORIGIN_AFTER_REFS" = "$LOCAL_REFS" ] && ORIGIN_MATCH="YES" || true
[ -n "$PUBLIC_AFTER_REFS" ] && [ "$PUBLIC_AFTER_REFS" = "$LOCAL_REFS" ] && PUBLIC_MATCH="YES" || true
if [ "$ORIGIN_MATCH" = "YES" ] && [ "$PUBLIC_MATCH" != "YES" ]; then EDGE_CACHE_STALE="YES"; fi

# Inspect public headers for upstream cache hints without printing secrets.
curl -sSI "https://$DOMAIN/admin/?v294h=$RUNSTAMP" > "$TMP/public-headers.txt" || true
EDGE_SERVER=$(awk -F': ' 'tolower($1)=="server"{gsub("\r","");print $2;exit}' "$TMP/public-headers.txt")
CF_CACHE_STATUS=$(awk -F': ' 'tolower($1)=="cf-cache-status"{gsub("\r","");print $2;exit}' "$TMP/public-headers.txt")

printf 'BUILD=PASS\n'
printf 'LOCAL_DIST_REFS=%s\n' "$LOCAL_REFS"
printf 'LIVE_ROOT=%s\n' "${LIVE_ROOT:-UNRESOLVED}"
printf 'DEPLOY_ACTION=%s\n' "$DEPLOY_ACTION"
printf 'ORIGIN_MATCH_LOCAL_DIST=%s\n' "$ORIGIN_MATCH"
printf 'PUBLIC_MATCH_LOCAL_DIST=%s\n' "$PUBLIC_MATCH"
printf 'EDGE_CACHE_STALE=%s\n' "$EDGE_CACHE_STALE"
printf 'EDGE_SERVER=%s\n' "${EDGE_SERVER:-UNKNOWN}"
printf 'CF_CACHE_STATUS=%s\n' "${CF_CACHE_STATUS:-UNKNOWN}"
printf 'HIGHRES_BUILT_ASSET=%s\n' "$NEW_ASSET"
printf 'SOURCE_PROJECT_PUSHED=NO\n'

if [ "$ORIGIN_MATCH" != "YES" ]; then
  echo 'FAILED_STEP=LIVE_RUNTIME_ROOT_NOT_ACTIVATED'
  exit 2
fi

if [ "$PUBLIC_MATCH" != "YES" ]; then
  echo 'FAILED_STEP=PUBLIC_EDGE_STILL_STALE'
  exit 3
fi

echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
