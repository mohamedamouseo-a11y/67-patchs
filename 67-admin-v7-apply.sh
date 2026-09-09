#!/usr/bin/env bash
set -euo pipefail
cd /67

TMP=/tmp/AdminDashboard.v7.css
TARGET=/67/src/pages/AdminDashboard.v7.css
JSX=/67/src/pages/AdminDashboard.jsx
URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v7-reference.css

curl -fL "$URL" -o "$TMP"

BYTES=$(wc -c < "$TMP" | tr -d ' ')
LINES=$(wc -l < "$TMP" | tr -d ' ')
if [ "$BYTES" -lt 10000 ] || [ "$LINES" -lt 250 ]; then
  echo "ERROR=DOWNLOADED_V7_CSS_TOO_SMALL bytes=$BYTES lines=$LINES"
  exit 1
fi

install -m 0644 "$TMP" "$TARGET"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
imp="import './AdminDashboard.v7.css';"
if imp not in s:
    anchor="import './AdminDashboard.v6.css';"
    if anchor in s:
        s=s.replace(anchor, anchor+'\n'+imp, 1)
    else:
        anchor="import './AdminDashboard.css';"
        if anchor not in s:
            raise SystemExit('ERROR=NO_ADMIN_CSS_IMPORT_ANCHOR')
        s=s.replace(anchor, anchor+'\n'+imp, 1)
p.write_text(s)
PY

grep -n "AdminDashboard.v7.css" "$JSX"
test -s "$TARGET"
wc -c "$TARGET"
wc -l "$TARGET"

npm run build
systemctl restart sixty-seven.service
sleep 1
systemctl is-active sixty-seven.service
curl -s -o /dev/null -w 'LOCAL_ADMIN_HTTP=%{http_code}\n' http://127.0.0.1:4173/admin

echo "PATCH_APPLIED=YES"
echo "V7_CSS_BYTES=$(wc -c < "$TARGET" | tr -d ' ')"
echo "V7_CSS_LINES=$(wc -l < "$TARGET" | tr -d ' ')"
echo "V7_IMPORT_PRESENT=YES"
echo "BUILD=PASS"
echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service)"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v7.css"
echo "ERROR=NONE"
