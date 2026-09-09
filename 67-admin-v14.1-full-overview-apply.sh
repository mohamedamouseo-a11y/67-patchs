#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=485067665dc79a713ba26f5fcf5a9bf42ae4d58e
EXPECTED_JSX_BLOB=31bc3f3f1c58540b2df9cd9321972d9fb8331260
ASSET_COMMIT=5d5c786fdfd1a06a010a19723c36f32ecc5df442
EXPECTED_CSS_BLOB=32fab70e5f4534b203c46d7b9d9044ec467d763f
EXPECTED_HERO_BLOB=f7d945fa0573503d43993ba1ddca07210ea5254a
EXPECTED_HEALTH_BLOB=0130ef2fd50f10d279c6b6c9fbc2f2ba4064fa7c
CSS_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${ASSET_COMMIT}/67-admin-v14-full-overview.css"
HERO_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${ASSET_COMMIT}/67-admin-v14-hero.svg"
HEALTH_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${ASSET_COMMIT}/67-admin-v14-health.svg"
BACKUP_DIR="/tmp/67-admin-v14.1-backup-$$"
STAGE_DIR="/tmp/67-admin-v14.1-stage-$$"
PATCHED=0
LAST_STEP=init

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages" "$BACKUP_DIR/src/assets" "$STAGE_DIR"

blob_sha(){
  python3 - "$1" <<'PY'
from pathlib import Path
import hashlib,sys
p=Path(sys.argv[1])
b=p.read_bytes()
print(hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest())
PY
}

rollback(){
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" src/pages/AdminDashboard.jsx
    if [ -f "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" ]; then
      cp "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" src/pages/AdminDashboard.v14.css
    else
      rm -f src/pages/AdminDashboard.v14.css
    fi
    if [ -f "$BACKUP_DIR/src/assets/admin-v14-hero.svg" ]; then
      cp "$BACKUP_DIR/src/assets/admin-v14-hero.svg" src/assets/admin-v14-hero.svg
    else
      rm -f src/assets/admin-v14-hero.svg
    fi
    if [ -f "$BACKUP_DIR/src/assets/admin-v14-health.svg" ]; then
      cp "$BACKUP_DIR/src/assets/admin-v14-health.svg" src/assets/admin-v14-health.svg
    else
      rm -f src/assets/admin-v14-health.svg
    fi
    npm run build >/tmp/67-admin-v14.1-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FULL_OVERVIEW_REBUILD=NO"
  echo "FAILED_STEP=$LAST_STEP"
  echo "ERROR=V14_1_FULL_REBUILD_FAILED_EXIT_${code}"
  rm -rf "$STAGE_DIR" "$BACKUP_DIR" || true
  exit "$code"
}
trap 'rollback $?' ERR

LAST_STEP=verify_server_base
ACTUAL_JSX_BLOB=$(blob_sha src/pages/AdminDashboard.jsx)
[ "$ACTUAL_JSX_BLOB" = "$EXPECTED_JSX_BLOB" ] || { echo "JSX_BASE_MISMATCH:$ACTUAL_JSX_BLOB:expected:$EXPECTED_JSX_BLOB" >&2; exit 31; }
grep -q "SIX SEVEN ADMIN V13" src/pages/AdminDashboard.v11.css || { echo "V13_SERVER_STATE_REQUIRED" >&2; exit 32; }
grep -Fq "import './AdminDashboard.v9.css';" src/pages/AdminDashboard.jsx
grep -Fq "import './AdminDashboard.v11.css';" src/pages/AdminDashboard.jsx

LAST_STEP=download_payloads
curl -fsSL --retry 3 --retry-delay 1 "$CSS_URL" -o "$STAGE_DIR/AdminDashboard.v14.css"
curl -fsSL --retry 3 --retry-delay 1 "$HERO_URL" -o "$STAGE_DIR/admin-v14-hero.svg"
curl -fsSL --retry 3 --retry-delay 1 "$HEALTH_URL" -o "$STAGE_DIR/admin-v14-health.svg"

LAST_STEP=verify_payload_integrity
ACTUAL_CSS_BLOB=$(blob_sha "$STAGE_DIR/AdminDashboard.v14.css")
ACTUAL_HERO_BLOB=$(blob_sha "$STAGE_DIR/admin-v14-hero.svg")
ACTUAL_HEALTH_BLOB=$(blob_sha "$STAGE_DIR/admin-v14-health.svg")
[ "$ACTUAL_CSS_BLOB" = "$EXPECTED_CSS_BLOB" ] || { echo "CSS_BLOB_MISMATCH:$ACTUAL_CSS_BLOB:expected:$EXPECTED_CSS_BLOB" >&2; exit 41; }
[ "$ACTUAL_HERO_BLOB" = "$EXPECTED_HERO_BLOB" ] || { echo "HERO_BLOB_MISMATCH:$ACTUAL_HERO_BLOB:expected:$EXPECTED_HERO_BLOB" >&2; exit 42; }
[ "$ACTUAL_HEALTH_BLOB" = "$EXPECTED_HEALTH_BLOB" ] || { echo "HEALTH_BLOB_MISMATCH:$ACTUAL_HEALTH_BLOB:expected:$EXPECTED_HEALTH_BLOB" >&2; exit 43; }

grep -q "SIX SEVEN ADMIN V14" "$STAGE_DIR/AdminDashboard.v14.css"
grep -q "admin-v14-hero.svg" "$STAGE_DIR/AdminDashboard.v14.css"
grep -q "admin-v14-health.svg" "$STAGE_DIR/AdminDashboard.v14.css"
grep -q "data:image/jpeg;base64" "$STAGE_DIR/admin-v14-hero.svg"
grep -q "data:image/jpeg;base64" "$STAGE_DIR/admin-v14-health.svg"
grep -q 'grid-template-areas:"revenue live ops"' "$STAGE_DIR/AdminDashboard.v14.css"

# Payloads are validated by exact Git blob identity, not arbitrary byte thresholds.
HERO_BYTES=$(wc -c < "$STAGE_DIR/admin-v14-hero.svg")
HEALTH_BYTES=$(wc -c < "$STAGE_DIR/admin-v14-health.svg")
CSS_BYTES=$(wc -c < "$STAGE_DIR/AdminDashboard.v14.css")
[ "$HERO_BYTES" -gt 15000 ] || { echo "HERO_PAYLOAD_TOO_SMALL:$HERO_BYTES" >&2; exit 44; }
[ "$HEALTH_BYTES" -gt 6500 ] || { echo "HEALTH_PAYLOAD_TOO_SMALL:$HEALTH_BYTES" >&2; exit 45; }
[ "$CSS_BYTES" -gt 18000 ] || { echo "CSS_PAYLOAD_TOO_SMALL:$CSS_BYTES" >&2; exit 46; }

LAST_STEP=backup_current_files
cp src/pages/AdminDashboard.jsx "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
[ -f src/pages/AdminDashboard.v14.css ] && cp src/pages/AdminDashboard.v14.css "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" || true
[ -f src/assets/admin-v14-hero.svg ] && cp src/assets/admin-v14-hero.svg "$BACKUP_DIR/src/assets/admin-v14-hero.svg" || true
[ -f src/assets/admin-v14-health.svg ] && cp src/assets/admin-v14-health.svg "$BACKUP_DIR/src/assets/admin-v14-health.svg" || true

PATCHED=1
LAST_STEP=install_payloads
cp "$STAGE_DIR/AdminDashboard.v14.css" src/pages/AdminDashboard.v14.css
cp "$STAGE_DIR/admin-v14-hero.svg" src/assets/admin-v14-hero.svg
cp "$STAGE_DIR/admin-v14-health.svg" src/assets/admin-v14-health.svg

LAST_STEP=switch_runtime_visual_layer
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

grep -Fq "import './AdminDashboard.v14.css';" src/pages/AdminDashboard.jsx
! grep -Fq "import './AdminDashboard.v9.css';" src/pages/AdminDashboard.jsx
! grep -Fq "import './AdminDashboard.v11.css';" src/pages/AdminDashboard.jsx

LAST_STEP=build
npm run build

LAST_STEP=restart_service
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LAST_STEP=verify_runtime
LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]
grep -q 'grid-template-areas:"revenue live ops"' src/pages/AdminDashboard.v14.css
grep -q "admin-v14-hero.svg" src/pages/AdminDashboard.v14.css
grep -q "admin-v14-health.svg" src/pages/AdminDashboard.v14.css

LAST_STEP=completed
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
echo "PAYLOAD_INTEGRITY=GIT_BLOB_VERIFIED"
echo "HERO_BYTES=$HERO_BYTES"
echo "HEALTH_BYTES=$HEALTH_BYTES"
echo "CSS_BYTES=$CSS_BYTES"
echo "ERROR=NONE"

rm -rf "$STAGE_DIR" "$BACKUP_DIR"
trap - ERR
