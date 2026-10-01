#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
cd "$ROOT"

FILE="server/index.js"
BACKUP="$(mktemp /tmp/67-seller-upload-limit.XXXXXX.js)"
cp "$FILE" "$BACKUP"

restore() {
  cp "$BACKUP" "$FILE"
}
trap restore ERR

python3 - <<'PY'
from pathlib import Path

p = Path("/67/server/index.js")
s = p.read_text()

old = "const body = await readJson(req, 10 * 1024 * 1024);"
new = "const body = await readJson(req, 15 * 1024 * 1024);"

if new in s:
    pass
elif old in s:
    s = s.replace(old, new, 1)
else:
    raise SystemExit("seller application JSON limit anchor not found")

p.write_text(s)
PY

grep -q "readJson(req, 15 \* 1024 \* 1024)" "$FILE"
npm run build

trap - ERR
rm -f "$BACKUP"

echo "PATCH=67-SELLER-APPLICATION-UPLOAD-LIMIT-HOTFIX-V1"
echo "BUILD=PASS"
echo "BACKEND_SELLER_APPLICATION_LIMIT=15MB"
echo "NGINX_TARGET_LIMIT=20MB"
echo "SUPERADMIN_SECURITY_CHANGED=NO"
echo "DEVELOPER_HUB_CHANGED=NO"
echo "READY_FOR_REVIEW=YES"
echo "ERROR=NONE"
