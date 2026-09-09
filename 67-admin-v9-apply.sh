#!/usr/bin/env bash
set -euo pipefail

ROOT=/67
PATCH_REPO=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main
BASE_CSS_URL="$PATCH_REPO/67-admin-v8-reference-lock.css"
HERO_CSS_URL="$PATCH_REPO/67-admin-v9-hero-data.css"
HEALTH_CSS_URL="$PATCH_REPO/67-admin-v9-health-data.css"
CSS_DST="$ROOT/src/pages/AdminDashboard.v9.css"
JSX="$ROOT/src/pages/AdminDashboard.jsx"

cd "$ROOT"

# Download only plain-text CSS. No base64/hex decoding happens on the server.
curl -fsSL "$BASE_CSS_URL" -o /tmp/67-admin-v9-base.css
curl -fsSL "$HERO_CSS_URL" -o /tmp/67-admin-v9-hero.css
curl -fsSL "$HEALTH_CSS_URL" -o /tmp/67-admin-v9-health.css

BASE_BYTES=$(wc -c < /tmp/67-admin-v9-base.css | tr -d ' ')
HERO_BYTES=$(wc -c < /tmp/67-admin-v9-hero.css | tr -d ' ')
HEALTH_BYTES=$(wc -c < /tmp/67-admin-v9-health.css | tr -d ' ')

if [ "$BASE_BYTES" -lt 12000 ]; then
  echo "ERROR=V9_BASE_CSS_INCOMPLETE:${BASE_BYTES}"
  exit 51
fi
if [ "$HERO_BYTES" -lt 7000 ]; then
  echo "ERROR=V9_HERO_CSS_INCOMPLETE:${HERO_BYTES}"
  exit 52
fi
if [ "$HEALTH_BYTES" -lt 5000 ]; then
  echo "ERROR=V9_HEALTH_CSS_INCOMPLETE:${HEALTH_BYTES}"
  exit 53
fi

grep -q 'data:image/jpeg;base64,' /tmp/67-admin-v9-hero.css
grep -q 'data:image/jpeg;base64,' /tmp/67-admin-v9-health.css

# Assemble one deterministic stylesheet. The last two rules override the old asset URLs.
{
  cat /tmp/67-admin-v9-base.css
  printf '\n\n/* V9 DIRECT HERO DATA URI */\n'
  cat /tmp/67-admin-v9-hero.css
  printf '\n\n/* V9 DIRECT HEALTH DATA URI */\n'
  cat /tmp/67-admin-v9-health.css
  printf '\n'
} > "$CSS_DST.tmp"

V9_BYTES=$(wc -c < "$CSS_DST.tmp" | tr -d ' ')
V9_LINES=$(wc -l < "$CSS_DST.tmp" | tr -d ' ')
if [ "$V9_BYTES" -lt 25000 ]; then
  echo "ERROR=V9_ASSEMBLED_CSS_TOO_SMALL:${V9_BYTES}"
  rm -f "$CSS_DST.tmp"
  exit 54
fi

mv "$CSS_DST.tmp" "$CSS_DST"

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
# Keep the base stylesheet, remove ALL old versioned override imports, then use V9 only.
s=re.sub(r"^import './AdminDashboard\.v\d+(?:\.\d+)?\.css';\s*\n", '', s, flags=re.M)
base="import './AdminDashboard.css';"
imp="import './AdminDashboard.v9.css';"
if base not in s:
    raise SystemExit('BASE_CSS_IMPORT_NOT_FOUND')
s=s.replace(base, base+'\n'+imp, 1)
p.write_text(s)
PY

grep -q "AdminDashboard.v9.css" "$JSX"
if grep -Eq "AdminDashboard\.v(5|6|7|8)(\.[0-9]+)?\.css" "$JSX"; then
  echo "ERROR=OLD_VERSIONED_IMPORT_STILL_PRESENT"
  exit 55
fi

grep -q 'data:image/jpeg;base64,' "$CSS_DST"

npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service
HTTP=$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin)
if [ "$HTTP" != "200" ]; then
  echo "ERROR=LOCAL_ADMIN_HTTP_${HTTP}"
  exit 56
fi

echo "PATCH_APPLIED=YES"
echo "V9_MODE=SELF_CONTAINED_CSS_DATA_URIS"
echo "V9_BASE_CSS_BYTES=$BASE_BYTES"
echo "V9_HERO_CSS_BYTES=$HERO_BYTES"
echo "V9_HEALTH_CSS_BYTES=$HEALTH_BYTES"
echo "V9_ASSEMBLED_CSS_BYTES=$V9_BYTES"
echo "V9_ASSEMBLED_CSS_LINES=$V9_LINES"
echo "V9_IMPORT_PRESENT=YES"
echo "OLD_VERSIONED_IMPORTS=NO"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx, src/pages/AdminDashboard.v9.css"
echo "ERROR=NONE"