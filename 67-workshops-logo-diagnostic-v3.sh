#!/usr/bin/env bash
set -euo pipefail

cd /67

CSS="src/pages/WorkshopsPage.css"
JSX="src/pages/WorkshopsPage.jsx"
HEADER_JSX="src/components/HomeStoreHeader.jsx"
HEADER_CSS="src/components/HomeStoreHeader.css"
LOGO="public/assets/logo-67.png"

for f in "$CSS" "$JSX" "$HEADER_JSX" "$HEADER_CSS" "$LOGO"; do
  [[ -f "$f" ]] || { echo "ERROR: missing required file: $f"; exit 1; }
done

echo "=== WORKSHOPS LOGO DIAGNOSTIC V3 ==="

echo "SOURCE_V1_MARKER=$(grep -c 'WORKSHOPS_HEADER_LOGO_VISIBLE_V1' "$CSS" || true)"
echo "SOURCE_V2_MARKER=$(grep -c 'WORKSHOPS_HEADER_LOGO_FORCE_V2' "$CSS" || true)"
echo "SOURCE_WORKSHOPS_LOGO_RULES=$(grep -c 'ws67-page .h67-logo' "$CSS" || true)"
echo "HEADER_HAS_LOGO_BUTTON=$(grep -c 'className=\"h67-logo\"' "$HEADER_JSX" || true)"
echo "HEADER_LOGO_ASSET_REF=$(grep -c '/assets/logo-67.png' "$HEADER_JSX" || true)"
echo "LOCAL_LOGO_SHA256=$(sha256sum "$LOGO" | awk '{print $1}')"
echo "LOCAL_LOGO_BYTES=$(wc -c < "$LOGO" | tr -d ' ')"

# Dist inspection
DIST_CSS_COUNT=0
DIST_LOGO_RULE_COUNT=0
if [[ -d dist/assets ]]; then
  DIST_CSS_COUNT=$(find dist/assets -maxdepth 1 -type f -name 'WorkshopsPage-*.css' | wc -l | tr -d ' ')
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    c=$(grep -o '/assets/logo-67.png' "$f" 2>/dev/null | wc -l | tr -d ' ' || true)
    DIST_LOGO_RULE_COUNT=$((DIST_LOGO_RULE_COUNT + c))
    echo "DIST_WORKSHOPS_CSS=$f"
    echo "DIST_WORKSHOPS_CSS_SHA256=$(sha256sum "$f" | awk '{print $1}')"
    echo "DIST_WORKSHOPS_LOGO_REF_COUNT=$c"
  done < <(find dist/assets -maxdepth 1 -type f -name 'WorkshopsPage-*.css' | sort)
fi

echo "DIST_WORKSHOPS_CSS_COUNT=$DIST_CSS_COUNT"
echo "DIST_TOTAL_LOGO_REF_COUNT=$DIST_LOGO_RULE_COUNT"

# Port 3000 / process inspection
PID=""
if command -v lsof >/dev/null 2>&1; then
  PID=$(lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null | head -n1 || true)
fi
if [[ -z "$PID" ]] && command -v ss >/dev/null 2>&1; then
  PID=$(ss -ltnp 'sport = :3000' 2>/dev/null | sed -n 's/.*pid=\([0-9][0-9]*\).*/\1/p' | head -n1 || true)
fi

echo "PORT3000_PID=${PID:-NONE}"
if [[ -n "$PID" && -d "/proc/$PID" ]]; then
  echo -n "PORT3000_CWD="; readlink -f "/proc/$PID/cwd" || true
  echo -n "PORT3000_CMD="; tr '\0' ' ' < "/proc/$PID/cmdline" || true; echo
fi

# Detect serving mode
SERVING_MODE="UNKNOWN"
if curl -fsS --max-time 5 http://127.0.0.1:3000/@vite/client >/tmp/ws67-vite-client.$$ 2>/dev/null; then
  SERVING_MODE="VITE_DEV"
else
  rm -f /tmp/ws67-vite-client.$$ || true
  if curl -fsS --max-time 5 http://127.0.0.1:3000/workshops >/tmp/ws67-workshops-http.$$ 2>/dev/null; then
    SERVING_MODE="STATIC_OR_PREVIEW"
  fi
fi
rm -f /tmp/ws67-vite-client.$$ || true

echo "SERVING_MODE=$SERVING_MODE"

# Check what the running server actually serves for the logo.
HTTP_LOGO_STATUS=$(curl -sS -o /tmp/ws67-logo-http.$$ -w '%{http_code}' --max-time 8 http://127.0.0.1:3000/assets/logo-67.png || true)
echo "HTTP_LOGO_STATUS=$HTTP_LOGO_STATUS"
if [[ "$HTTP_LOGO_STATUS" == "200" && -s /tmp/ws67-logo-http.$$ ]]; then
  echo "HTTP_LOGO_SHA256=$(sha256sum /tmp/ws67-logo-http.$$ | awk '{print $1}')"
  echo "HTTP_LOGO_BYTES=$(wc -c < /tmp/ws67-logo-http.$$ | tr -d ' ')"
else
  echo "HTTP_LOGO_SHA256=UNAVAILABLE"
fi
rm -f /tmp/ws67-logo-http.$$ || true

# If Vite dev is serving, inspect the ACTUAL transformed CSS returned by the running server.
if [[ "$SERVING_MODE" == "VITE_DEV" ]]; then
  DEV_CSS_STATUS=$(curl -sS -o /tmp/ws67-css-http.$$ -w '%{http_code}' --max-time 8 http://127.0.0.1:3000/src/pages/WorkshopsPage.css || true)
  echo "DEV_WORKSHOPS_CSS_STATUS=$DEV_CSS_STATUS"
  if [[ "$DEV_CSS_STATUS" == "200" ]]; then
    echo "DEV_CSS_V2_MARKER=$(grep -c 'WORKSHOPS_HEADER_LOGO_FORCE_V2' /tmp/ws67-css-http.$$ || true)"
    echo "DEV_CSS_LOGO_REF_COUNT=$(grep -o '/assets/logo-67.png' /tmp/ws67-css-http.$$ | wc -l | tr -d ' ' || true)"
  fi
  rm -f /tmp/ws67-css-http.$$ || true
fi

# HTTP page reachability only. Do not mutate anything.
HTTP_PAGE_STATUS=$(curl -sS -o /tmp/ws67-page-http.$$ -w '%{http_code}' --max-time 8 http://127.0.0.1:3000/workshops || true)
echo "HTTP_WORKSHOPS_STATUS=$HTTP_PAGE_STATUS"
rm -f /tmp/ws67-page-http.$$ || true

# Explain the diagnostic classification without changing files.
if [[ "$HTTP_LOGO_STATUS" != "200" ]]; then
  echo "DIAGNOSIS=LOGO_ASSET_NOT_SERVED"
elif [[ "$SERVING_MODE" == "VITE_DEV" ]]; then
  DEV_MARKER=$(curl -fsS --max-time 8 http://127.0.0.1:3000/src/pages/WorkshopsPage.css 2>/dev/null | grep -c 'WORKSHOPS_HEADER_LOGO_FORCE_V2' || true)
  if [[ "$DEV_MARKER" == "0" ]]; then
    echo "DIAGNOSIS=RUNNING_VITE_IS_NOT_SERVING_CURRENT_WORKSHOPS_CSS"
  else
    echo "DIAGNOSIS=RUNNING_VITE_HAS_CURRENT_CSS_LOGO_NEEDS_DOM_OR_COMPUTED_STYLE_FIX"
  fi
elif [[ "$DIST_LOGO_RULE_COUNT" == "0" ]]; then
  echo "DIAGNOSIS=DIST_DOES_NOT_CONTAIN_LOGO_OVERRIDE"
else
  echo "DIAGNOSIS=SOURCE_AND_DIST_HAVE_FIX_SERVER_OR_BROWSER_IS_SERVING_DIFFERENT_BUILD_OR_DOM_STYLE_CONFLICT"
fi

echo "NO_SOURCE_FILES_CHANGED=YES"
echo "WORKSHOPS_LOGO_DIAGNOSTIC_V3_COMPLETE"
