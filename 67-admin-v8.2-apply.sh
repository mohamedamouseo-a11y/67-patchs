#!/usr/bin/env bash
set -euo pipefail

ROOT=/67
PATCH_REPO=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main
CSS_URL="$PATCH_REPO/67-admin-v8-reference-lock.css"
HERO_URL="$PATCH_REPO/67-v8-hero-small.jpg.b64"
HEALTH_URL="$PATCH_REPO/67-v8-health-small.jpg.b64"
CSS_DST="$ROOT/src/pages/AdminDashboard.v8.css"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
ASSET_DIR="$ROOT/src/assets"
HERO_DST="$ASSET_DIR/admin-v8-hero.jpg"
HEALTH_DST="$ASSET_DIR/admin-v8-health.jpg"

EXPECTED_HERO_SHA="b8132ee6e81965b728682518b7f2e89201f906c4a50b42f8ff42983f56b2c195"
EXPECTED_HEALTH_SHA="f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db"

cd "$ROOT"
mkdir -p "$ASSET_DIR"

curl -fsSL "$CSS_URL" -o /tmp/67-admin-v8.css
curl -fsSL "$HERO_URL" -o /tmp/67-v8-hero.b64
curl -fsSL "$HEALTH_URL" -o /tmp/67-v8-health.b64

CSS_BYTES=$(wc -c < /tmp/67-admin-v8.css | tr -d ' ')
CSS_LINES=$(wc -l < /tmp/67-admin-v8.css | tr -d ' ')
if [ "$CSS_BYTES" -lt 12000 ] || [ "$CSS_LINES" -lt 250 ]; then
  echo "ERROR=V8 CSS payload incomplete (${CSS_BYTES} bytes / ${CSS_LINES} lines)"
  exit 20
fi

python3 - <<'PY'
from pathlib import Path
import base64, hashlib
pairs = [
    ('/tmp/67-v8-hero.b64', '/tmp/admin-v8-hero.jpg', 'b8132ee6e81965b728682518b7f2e89201f906c4a50b42f8ff42983f56b2c195'),
    ('/tmp/67-v8-health.b64', '/tmp/admin-v8-health.jpg', 'f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db'),
]
for src, dst, expected in pairs:
    raw = ''.join(Path(src).read_text().split())
    try:
        data = base64.b64decode(raw, validate=True)
    except Exception as e:
        raise SystemExit(f'BASE64_DECODE_FAILED:{src}:{e}')
    got = hashlib.sha256(data).hexdigest()
    if got != expected:
        raise SystemExit(f'SHA256_MISMATCH:{src}:{got}')
    Path(dst).write_bytes(data)
PY

file /tmp/admin-v8-hero.jpg | grep -qi 'JPEG image data'
file /tmp/admin-v8-health.jpg | grep -qi 'JPEG image data'

HERO_BYTES=$(wc -c < /tmp/admin-v8-hero.jpg | tr -d ' ')
HEALTH_BYTES=$(wc -c < /tmp/admin-v8-health.jpg | tr -d ' ')
if [ "$HERO_BYTES" -lt 3500 ]; then
  echo "ERROR=Decoded hero asset too small (${HERO_BYTES} bytes)"
  exit 21
fi
if [ "$HEALTH_BYTES" -lt 3500 ]; then
  echo "ERROR=Decoded health asset too small (${HEALTH_BYTES} bytes)"
  exit 22
fi

cp /tmp/admin-v8-hero.jpg "$HERO_DST.tmp"
cp /tmp/admin-v8-health.jpg "$HEALTH_DST.tmp"
cp /tmp/67-admin-v8.css "$CSS_DST.tmp"

mv "$HERO_DST.tmp" "$HERO_DST"
mv "$HEALTH_DST.tmp" "$HEALTH_DST"
mv "$CSS_DST.tmp" "$CSS_DST"

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
s=re.sub(r"^import './AdminDashboard\.v\d+(?:\.\d+)?\.css';\s*\n",'',s,flags=re.M)
base="import './AdminDashboard.css';"
imp="import './AdminDashboard.v8.css';"
if base not in s:
    raise SystemExit('BASE_CSS_IMPORT_NOT_FOUND')
s=s.replace(base,base+'\n'+imp,1)
p.write_text(s)
PY

grep -q "AdminDashboard.v8.css" "$JSX"
if grep -Eq "AdminDashboard\.v(5|6|7)" "$JSX"; then
  echo "ERROR=Old versioned dashboard import still present"
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

echo "PATCH_APPLIED=YES"
echo "V8_2_PAYLOAD_VALIDATION=PASS"
echo "V8_CSS_BYTES=$CSS_BYTES"
echo "V8_CSS_LINES=$CSS_LINES"
echo "HERO_ASSET_BYTES=$HERO_BYTES"
echo "HEALTH_ASSET_BYTES=$HEALTH_BYTES"
echo "V8_IMPORT_PRESENT=YES"
echo "OLD_VERSIONED_IMPORTS=NO"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx, src/pages/AdminDashboard.v8.css, src/assets/admin-v8-hero.jpg, src/assets/admin-v8-health.jpg"
echo "ERROR=NONE"
