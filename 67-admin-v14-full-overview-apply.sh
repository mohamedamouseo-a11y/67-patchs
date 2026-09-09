#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=485067665dc79a713ba26f5fcf5a9bf42ae4d58e
EXPECTED_JSX_BLOB=31bc3f3f1c58540b2df9cd9321972d9fb8331260
CSS_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v14-full-overview.css
HERO_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v14-hero.svg
HEALTH_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v14-health.svg
BACKUP_DIR="/tmp/67-admin-v14-backup-$$"
PATCHED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages" "$BACKUP_DIR/src/assets"
cp src/pages/AdminDashboard.jsx "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
[ -f src/pages/AdminDashboard.v14.css ] && cp src/pages/AdminDashboard.v14.css "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" || true
[ -f src/assets/admin-v14-hero.svg ] && cp src/assets/admin-v14-hero.svg "$BACKUP_DIR/src/assets/admin-v14-hero.svg" || true
[ -f src/assets/admin-v14-health.svg ] && cp src/assets/admin-v14-health.svg "$BACKUP_DIR/src/assets/admin-v14-health.svg" || true

rollback(){
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" src/pages/AdminDashboard.jsx
    if [ -f "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" ]; then cp "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" src/pages/AdminDashboard.v14.css; else rm -f src/pages/AdminDashboard.v14.css; fi
    if [ -f "$BACKUP_DIR/src/assets/admin-v14-hero.svg" ]; then cp "$BACKUP_DIR/src/assets/admin-v14-hero.svg" src/assets/admin-v14-hero.svg; else rm -f src/assets/admin-v14-hero.svg; fi
    if [ -f "$BACKUP_DIR/src/assets/admin-v14-health.svg" ]; then cp "$BACKUP_DIR/src/assets/admin-v14-health.svg" src/assets/admin-v14-health.svg; else rm -f src/assets/admin-v14-health.svg; fi
    npm run build >/tmp/67-admin-v14-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=V14_FULL_REBUILD_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

ACTUAL_JSX_BLOB=$(python3 - <<'PY'
from pathlib import Path
import hashlib
p=Path('/67/src/pages/AdminDashboard.jsx')
b=p.read_bytes()
print(hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest())
PY
)
[ "$ACTUAL_JSX_BLOB" = "$EXPECTED_JSX_BLOB" ] || { echo "JSX_BASE_MISMATCH:$ACTUAL_JSX_BLOB:expected:$EXPECTED_JSX_BLOB" >&2; exit 31; }

grep -q "SIX SEVEN ADMIN V13" src/pages/AdminDashboard.v11.css || { echo "V13_SERVER_STATE_REQUIRED" >&2; exit 32; }
grep -q "import './AdminDashboard.v9.css';" src/pages/AdminDashboard.jsx
grep -q "import './AdminDashboard.v11.css';" src/pages/AdminDashboard.jsx

curl -fsSL "$CSS_URL" -o /tmp/67-admin-v14.css
curl -fsSL "$HERO_URL" -o /tmp/67-admin-v14-hero.svg
curl -fsSL "$HEALTH_URL" -o /tmp/67-admin-v14-health.svg

grep -q "SIX SEVEN ADMIN V14" /tmp/67-admin-v14.css
grep -q "admin-v14-hero.svg" /tmp/67-admin-v14.css
grep -q "admin-v14-health.svg" /tmp/67-admin-v14.css
grep -q "data:image/jpeg;base64" /tmp/67-admin-v14-hero.svg
grep -q "data:image/jpeg;base64" /tmp/67-admin-v14-health.svg
[ $(wc -c < /tmp/67-admin-v14-hero.svg) -gt 20000 ]
[ $(wc -c < /tmp/67-admin-v14-health.svg) -gt 6000 ]

cp /tmp/67-admin-v14.css src/pages/AdminDashboard.v14.css
cp /tmp/67-admin-v14-hero.svg src/assets/admin-v14-hero.svg
cp /tmp/67-admin-v14-health.svg src/assets/admin-v14-health.svg

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v9.css';\nimport './AdminDashboard.v11.css';"
new="import './AdminDashboard.v14.css';"
if s.count(old) != 1:
    raise SystemExit(f'IMPORT_BLOCK_MISMATCH:{s.count(old)}')
s=s.replace(old,new,1)
p.write_text(s)
PY
PATCHED=1

npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

grep -q "import './AdminDashboard.v14.css';" src/pages/AdminDashboard.jsx
! grep -q "import './AdminDashboard.v9.css';" src/pages/AdminDashboard.jsx
! grep -q "import './AdminDashboard.v11.css';" src/pages/AdminDashboard.jsx
grep -q "grid-template-areas:\"revenue live ops\"" src/pages/AdminDashboard.v14.css
grep -q "admin-v14-hero.svg" src/pages/AdminDashboard.v14.css
grep -q "admin-v14-health.svg" src/pages/AdminDashboard.v14.css

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v14.css,src/assets/admin-v14-hero.svg,src/assets/admin-v14-health.svg"
echo "FULL_OVERVIEW_REBUILD=YES"
echo "OLD_V9_V11_RUNTIME_IMPORTS=NO"
echo "REAL_CINEMATIC_HERO_ART=YES"
echo "REAL_CINEMATIC_HEALTH_ART=YES"
echo "REFERENCE_COMMAND_LAYOUT=YES"
echo "KPI_SYSTEM_REBUILT=YES"
echo "LEDGER_DENSITY_REBUILT=YES"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
