#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
PORT="3000"
SRC="$ROOT/src/pages/TopPartsPage.jsx"
DIST="$ROOT/dist"

[ -f "$SRC" ] || { echo "ERROR: missing $SRC" >&2; exit 1; }
[ -d "$DIST" ] || { echo "ERROR: missing $DIST" >&2; exit 1; }

echo "SOURCE_TOP_PARTS_MARKER=$(grep -q 'className=\"tp67-page\"' "$SRC" && echo YES || echo NO)"
echo "SOURCE_OLD_B01P_MARKER=$(grep -q 'className=\"b01p-page\"' "$SRC" && echo YES || echo NO)"

if grep -Rqs --include='*.js' 'tp67-page' "$DIST/assets" 2>/dev/null; then
  echo "DIST_TOP_PARTS_MARKER=YES"
else
  echo "DIST_TOP_PARTS_MARKER=NO"
fi

if grep -Rqs --include='*.js' 'b01p-page' "$DIST/assets" 2>/dev/null; then
  echo "DIST_OLD_B01P_MARKER=YES"
else
  echo "DIST_OLD_B01P_MARKER=NO"
fi

PID=""
if command -v ss >/dev/null 2>&1; then
  PID="$(ss -ltnp 2>/dev/null | awk -v p=":$PORT" '$4 ~ p { if (match($0,/pid=([0-9]+)/,m)) { print m[1]; exit } }')"
fi
if [ -z "$PID" ] && command -v lsof >/dev/null 2>&1; then
  PID="$(lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null | head -n1 || true)"
fi

if [ -n "$PID" ] && [ -d "/proc/$PID" ]; then
  CWD="$(readlink -f "/proc/$PID/cwd" 2>/dev/null || true)"
  CMD="$(tr '\0' ' ' < "/proc/$PID/cmdline" 2>/dev/null || true)"
  echo "PORT_3000_PID=$PID"
  echo "PORT_3000_CWD=${CWD:-UNKNOWN}"
  echo "PORT_3000_CMD=${CMD:-UNKNOWN}"
else
  echo "PORT_3000_PID=NOT_FOUND"
  echo "PORT_3000_CWD=UNKNOWN"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

URL="http://127.0.0.1:$PORT/top-parts?diag=$(date +%s)"
if curl -fsSL -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' "$URL" -o "$TMP/page.html"; then
  echo "HTTP_TOP_PARTS_REACHABLE=YES"
  SCRIPT_SRC="$(grep -oE '<script[^>]+src="[^"]+"' "$TMP/page.html" | sed -E 's/.*src="([^"]+)"/\1/' | tail -n1 || true)"
  echo "HTTP_SCRIPT_SRC=${SCRIPT_SRC:-NOT_FOUND}"
  if [ -n "$SCRIPT_SRC" ]; then
    case "$SCRIPT_SRC" in
      http://*|https://*) JS_URL="$SCRIPT_SRC" ;;
      /*) JS_URL="http://127.0.0.1:$PORT$SCRIPT_SRC" ;;
      *) JS_URL="http://127.0.0.1:$PORT/$SCRIPT_SRC" ;;
    esac
    if curl -fsSL -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' "$JS_URL?diag=$(date +%s)" -o "$TMP/app.js"; then
      echo "HTTP_BUNDLE_TOP_PARTS_MARKER=$(grep -q 'tp67-page' "$TMP/app.js" && echo YES || echo NO)"
      echo "HTTP_BUNDLE_OLD_B01P_MARKER=$(grep -q 'b01p-page' "$TMP/app.js" && echo YES || echo NO)"
    else
      echo "HTTP_BUNDLE_FETCH=FAIL"
    fi
  fi
else
  echo "HTTP_TOP_PARTS_REACHABLE=NO"
fi

echo "NO_FILES_CHANGED=YES"
