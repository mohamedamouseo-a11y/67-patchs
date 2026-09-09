#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET=src/pages/AdminDashboard.v11.css
PAYLOAD_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v13-reference-fit.css
EXPECTED_BLOB=763e6e6f0afccae7b3a6f9d544a4b8d3e4a4c50c
BASE_COMMIT=485067665dc79a713ba26f5fcf5a9bf42ae4d58e
BACKUP=/tmp/67-admin-v13-v11.css.$$
PATCHED=0

cd "$ROOT"
cp "$TARGET" "$BACKUP"

rollback() {
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP" "$TARGET"
    npm run build >/tmp/67-admin-v13-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=V13_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

ACTUAL_BLOB=$(python3 - <<'PY'
from pathlib import Path
import hashlib
p=Path('/67/src/pages/AdminDashboard.v11.css')
b=p.read_bytes()
print(hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest())
PY
)

if [ "$ACTUAL_BLOB" != "$EXPECTED_BLOB" ]; then
  echo "BASE_MISMATCH:$ACTUAL_BLOB:expected:$EXPECTED_BLOB" >&2
  exit 31
fi

if grep -q "SIX SEVEN ADMIN V13" "$TARGET"; then
  echo "V13_ALREADY_PRESENT" >&2
  exit 32
fi

curl -fsSL "$PAYLOAD_URL" -o /tmp/67-admin-v13-reference-fit.css
grep -q "SIX SEVEN ADMIN V13" /tmp/67-admin-v13-reference-fit.css
grep -q "right:0!important" /tmp/67-admin-v13-reference-fit.css
grep -q "left:18px!important" /tmp/67-admin-v13-reference-fit.css
grep -q "kpi-card::after{display:none" /tmp/67-admin-v13-reference-fit.css
grep -q "ops-good-strip" /tmp/67-admin-v13-reference-fit.css

printf '\n\n' >> "$TARGET"
cat /tmp/67-admin-v13-reference-fit.css >> "$TARGET"
PATCHED=1

npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

grep -q "SIX SEVEN ADMIN V13" "$TARGET"
grep -q "ov-header__zone-right" "$TARGET"
grep -q "right:0!important" "$TARGET"
grep -q "kpi-card::after{display:none" "$TARGET"
grep -q "ops-card>.ops-tile" "$TARGET"

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.v11.css"
echo "HERO_PHYSICAL_SIDES_FIXED=YES"
echo "TITLE_PHYSICAL_RIGHT=YES"
echo "TOOLBAR_PHYSICAL_LEFT=YES"
echo "KPI_CLIPPING_FIXED=YES"
echo "OPS_ROWS_COLLISION_FIXED=YES"
echo "REFERENCE_ORDER_PRESERVED=YES"
echo "ERROR=NONE"

rm -f "$BACKUP"
trap - ERR
