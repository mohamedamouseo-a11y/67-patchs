#!/usr/bin/env bash
set -euo pipefail

ROOT=/67
PATCH_REPO=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main
CSS_URL="$PATCH_REPO/67-admin-v8-reference-lock.css"
CSS_DST="$ROOT/src/pages/AdminDashboard.v8.css"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
ASSET_DIR="$ROOT/src/assets"
HERO_DST="$ASSET_DIR/admin-v8-hero.jpg"
HEALTH_DST="$ASSET_DIR/admin-v8-health.jpg"

HERO_EXPECTED_HEX=10860
HEALTH_EXPECTED_HEX=8308
HERO_SHA256=88e9f283c72b75a071b884ca08980cf11b492286515b53eb4d5ff36ba7d1c969
HEALTH_SHA256=f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db

cd "$ROOT"
mkdir -p "$ASSET_DIR"

# Download CSS and six small HEX chunks. No base64 is used anywhere in V8.3.
curl -fsSL "$CSS_URL" -o /tmp/67-admin-v8.css
for n in 01 02 03; do
  curl -fsSL "$PATCH_REPO/67-v8.3-hero.hex.$n" -o "/tmp/67-v8.3-hero.$n"
  curl -fsSL "$PATCH_REPO/67-v8.3-health.hex.$n" -o "/tmp/67-v8.3-health.$n"
done

cat /tmp/67-v8.3-hero.01 /tmp/67-v8.3-hero.02 /tmp/67-v8.3-hero.03 | tr -d '[:space:]' > /tmp/67-v8.3-hero.hex
cat /tmp/67-v8.3-health.01 /tmp/67-v8.3-health.02 /tmp/67-v8.3-health.03 | tr -d '[:space:]' > /tmp/67-v8.3-health.hex

CSS_BYTES=$(wc -c < /tmp/67-admin-v8.css | tr -d ' ')
CSS_LINES=$(wc -l < /tmp/67-admin-v8.css | tr -d ' ')
HERO_HEX_LEN=$(wc -c < /tmp/67-v8.3-hero.hex | tr -d ' ')
HEALTH_HEX_LEN=$(wc -c < /tmp/67-v8.3-health.hex | tr -d ' ')

if [ "$CSS_BYTES" -lt 12000 ] || [ "$CSS_LINES" -lt 250 ]; then
  echo "ERROR=V8_CSS_INCOMPLETE:${CSS_BYTES}_bytes_${CSS_LINES}_lines"
  exit 30
fi
if [ "$HERO_HEX_LEN" -ne "$HERO_EXPECTED_HEX" ]; then
  echo "ERROR=HERO_HEX_LENGTH_MISMATCH:${HERO_HEX_LEN}_expected_${HERO_EXPECTED_HEX}"
  exit 31
fi
if [ "$HEALTH_HEX_LEN" -ne "$HEALTH_EXPECTED_HEX" ]; then
  echo "ERROR=HEALTH_HEX_LENGTH_MISMATCH:${HEALTH_HEX_LEN}_expected_${HEALTH_EXPECTED_HEX}"
  exit 32
fi

python3 - <<'PY'
from pathlib import Path
import re, hashlib, sys
items = [
    ('hero', Path('/tmp/67-v8.3-hero.hex'), Path('/tmp/67-v8.3-hero.jpg'), '88e9f283c72b75a071b884ca08980cf11b492286515b53eb4d5ff36ba7d1c969'),
    ('health', Path('/tmp/67-v8.3-health.hex'), Path('/tmp/67-v8.3-health.jpg'), 'f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db'),
]
for name, src, dst, expected in items:
    text = src.read_text().strip()
    if len(text) % 2:
        print(f'ERROR={name.upper()}_HEX_ODD_LENGTH:{len(text)}')
        sys.exit(40)
    if not re.fullmatch(r'[0-9a-fA-F]+', text):
        print(f'ERROR={name.upper()}_HEX_NON_HEX_CHARACTER')
        sys.exit(41)
    raw = bytes.fromhex(text)
    if not (raw.startswith(b'\xff\xd8\xff') and raw.endswith(b'\xff\xd9')):
        print(f'ERROR={name.upper()}_JPEG_MAGIC_INVALID')
        sys.exit(42)
    actual = hashlib.sha256(raw).hexdigest()
    if actual != expected:
        print(f'ERROR={name.upper()}_SHA256_MISMATCH:{actual}')
        sys.exit(43)
    dst.write_bytes(raw)
print('V8_3_PAYLOAD_VALIDATION=PASS')
PY

# Only after all payload checks pass do we touch /67.
cp /tmp/67-v8.3-hero.jpg "$HERO_DST.tmp"
cp /tmp/67-v8.3-health.jpg "$HEALTH_DST.tmp"
cp /tmp/67-admin-v8.css "$CSS_DST.tmp"

mv "$HERO_DST.tmp" "$HERO_DST"
mv "$HEALTH_DST.tmp" "$HEALTH_DST"
mv "$CSS_DST.tmp" "$CSS_DST"

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
# Keep base stylesheet, remove all previous versioned override layers, then import V8 only.
s=re.sub(r"^import './AdminDashboard\.v\d+(?:\.\d+)?\.css';\s*\n", '', s, flags=re.M)
base="import './AdminDashboard.css';"
imp="import './AdminDashboard.v8.css';"
if base not in s:
    raise SystemExit('BASE_CSS_IMPORT_NOT_FOUND')
s=s.replace(base, base+'\n'+imp, 1)
p.write_text(s)
PY

grep -q "AdminDashboard.v8.css" "$JSX"
if grep -Eq "AdminDashboard\.v(5|6|7)(\.[0-9]+)?\.css" "$JSX"; then
  echo "ERROR=OLD_VERSIONED_IMPORT_STILL_PRESENT"
  exit 44
fi

npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service
HTTP=$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin)
if [ "$HTTP" != "200" ]; then
  echo "ERROR=LOCAL_ADMIN_HTTP_${HTTP}"
  exit 45
fi

HERO_BYTES=$(wc -c < "$HERO_DST" | tr -d ' ')
HEALTH_BYTES=$(wc -c < "$HEALTH_DST" | tr -d ' ')

echo "PATCH_APPLIED=YES"
echo "V8_3_PAYLOAD_VALIDATION=PASS"
echo "V8_CSS_BYTES=$CSS_BYTES"
echo "V8_CSS_LINES=$CSS_LINES"
echo "HERO_HEX_LENGTH=$HERO_HEX_LEN"
echo "HEALTH_HEX_LENGTH=$HEALTH_HEX_LEN"
echo "HERO_ASSET_BYTES=$HERO_BYTES"
echo "HEALTH_ASSET_BYTES=$HEALTH_BYTES"
echo "V8_IMPORT_PRESENT=YES"
echo "OLD_VERSIONED_IMPORTS=NO"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx, src/pages/AdminDashboard.v8.css, src/assets/admin-v8-hero.jpg, src/assets/admin-v8-health.jpg"
echo "ERROR=NONE"
