#!/usr/bin/env bash
set -euo pipefail

ROOT=/67
PATCH_REPO=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main
CSS_URL="$PATCH_REPO/67-admin-v8-reference-lock.css"
HERO_URL="$PATCH_REPO/67-v8-hero.jpg.b64"
HEALTH_URL="$PATCH_REPO/67-v8-health.jpg.b64"
CSS_DST="$ROOT/src/pages/AdminDashboard.v8.css"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
ASSET_DIR="$ROOT/src/assets"
HERO_DST="$ASSET_DIR/admin-v8-hero.jpg"
HEALTH_DST="$ASSET_DIR/admin-v8-health.jpg"

cd "$ROOT"
mkdir -p "$ASSET_DIR"

curl -fsSL "$CSS_URL" -o /tmp/67-admin-v8.css
curl -fsSL "$HERO_URL" -o /tmp/67-v8-hero.b64
curl -fsSL "$HEALTH_URL" -o /tmp/67-v8-health.b64

CSS_BYTES=$(wc -c < /tmp/67-admin-v8.css | tr -d ' ')
CSS_LINES=$(wc -l < /tmp/67-admin-v8.css | tr -d ' ')
HERO_B64_BYTES=$(wc -c < /tmp/67-v8-hero.b64 | tr -d ' ')
HEALTH_B64_BYTES=$(wc -c < /tmp/67-v8-health.b64 | tr -d ' ')

if [ "$CSS_BYTES" -lt 12000 ] || [ "$CSS_LINES" -lt 250 ]; then
  echo "ERROR=V8 CSS payload incomplete (${CSS_BYTES} bytes / ${CSS_LINES} lines)"
  exit 20
fi
# Validate the actual asset, not an arbitrary compressed/base64 size. The hero is intentionally optimized.
if [ "$HERO_B64_BYTES" -lt 10000 ]; then
  echo "ERROR=Hero payload incomplete (${HERO_B64_BYTES} bytes)"
  exit 21
fi
if [ "$HEALTH_B64_BYTES" -lt 5000 ]; then
  echo "ERROR=Health payload incomplete (${HEALTH_B64_BYTES} bytes)"
  exit 22
fi

base64 -d /tmp/67-v8-hero.b64 > "$HERO_DST.tmp"
base64 -d /tmp/67-v8-health.b64 > "$HEALTH_DST.tmp"

# Hard validation on decoded files.
file "$HERO_DST.tmp" | grep -qi 'JPEG image data'
file "$HEALTH_DST.tmp" | grep -qi 'JPEG image data'
HERO_RAW_BYTES=$(wc -c < "$HERO_DST.tmp" | tr -d ' ')
HEALTH_RAW_BYTES=$(wc -c < "$HEALTH_DST.tmp" | tr -d ' ')
if [ "$HERO_RAW_BYTES" -lt 8000 ]; then
  echo "ERROR=Decoded hero asset too small (${HERO_RAW_BYTES} bytes)"
  exit 25
fi
if [ "$HEALTH_RAW_BYTES" -lt 4000 ]; then
  echo "ERROR=Decoded health asset too small (${HEALTH_RAW_BYTES} bytes)"
  exit 26
fi

mv "$HERO_DST.tmp" "$HERO_DST"
mv "$HEALTH_DST.tmp" "$HEALTH_DST"
cp /tmp/67-admin-v8.css "$CSS_DST.tmp"
mv "$CSS_DST.tmp" "$CSS_DST"

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
# Remove every previous versioned dashboard override so V8 is the only override layer.
s=re.sub(r"^import './AdminDashboard\.v\d+(?:\.\d+)?\.css';\s*\n",'',s,flags=re.M)
base="import './AdminDashboard.css';"
imp="import './AdminDashboard.v8.css';"
if base not in s:
    raise SystemExit('BASE_CSS_IMPORT_NOT_FOUND')
s=s.replace(base,base+'\n'+imp,1)
p.write_text(s)
PY

grep -q "AdminDashboard.v8.css" "$JSX"
if grep -Eq "AdminDashboard\.v(6|7)\.css" "$JSX"; then
  echo "ERROR=Old V6/V7 imports still present"
  exit 23
fi

npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service
HTTP=$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin)
if [ "$HTTP" != "200" ]; then
  echo "ERROR=LOCAL_ADMIN_HTTP_${HTTP}"
  exit 24
fi

HERO_BYTES=$(wc -c < "$HERO_DST" | tr -d ' ')
HEALTH_BYTES=$(wc -c < "$HEALTH_DST" | tr -d ' ')

echo "PATCH_APPLIED=YES"
echo "V8_CSS_BYTES=$CSS_BYTES"
echo "V8_CSS_LINES=$CSS_LINES"
echo "HERO_B64_BYTES=$HERO_B64_BYTES"
echo "HERO_ASSET_BYTES=$HERO_BYTES"
echo "HEALTH_ASSET_BYTES=$HEALTH_BYTES"
echo "V8_IMPORT_PRESENT=YES"
echo "OLD_V6_V7_IMPORTS=NO"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx, src/pages/AdminDashboard.v8.css, src/assets/admin-v8-hero.jpg, src/assets/admin-v8-health.jpg"
echo "ERROR=NONE"