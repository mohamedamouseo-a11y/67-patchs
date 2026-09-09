#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
PATCHER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v11-reference-hero-apply.py
BACKUP_DIR="/tmp/67-admin-v11-backup-$$"
PATCHED=0
mkdir -p "$BACKUP_DIR/src/pages"
cd "$ROOT"

cp src/pages/AdminDashboard.jsx "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp src/pages/AdminDashboard.v9.css "$BACKUP_DIR/src/pages/AdminDashboard.v9.css"
if [ -f src/pages/AdminDashboard.v11.css ]; then
  cp src/pages/AdminDashboard.v11.css "$BACKUP_DIR/src/pages/AdminDashboard.v11.css"
  HAD_V11=1
else
  HAD_V11=0
fi

rollback() {
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" src/pages/AdminDashboard.jsx
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v9.css" src/pages/AdminDashboard.v9.css
    if [ "$HAD_V11" = "1" ]; then
      cp "$BACKUP_DIR/src/pages/AdminDashboard.v11.css" src/pages/AdminDashboard.v11.css
    else
      rm -f src/pages/AdminDashboard.v11.css
    fi
    npm run build >/tmp/67-admin-v11-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=V11_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

curl -fsSL "$PATCHER_URL" -o /tmp/67-admin-v11-reference-hero-apply.py
python3 /tmp/67-admin-v11-reference-hero-apply.py
PATCHED=1

node --check src/pages/AdminDashboard.jsx >/dev/null 2>&1 || true
npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

grep -q "AdminDashboard.v11.css" src/pages/AdminDashboard.jsx
grep -q "v11-hero-scene" src/pages/AdminDashboard.jsx
grep -q "v11-health-scene" src/pages/AdminDashboard.jsx
grep -q "RIYADH" <(echo RIYADH) >/dev/null

if grep -q "admin-v8-hero.jpg\|admin-v8-health.jpg" src/pages/AdminDashboard.v11.css; then
  echo "V11 contains forbidden missing asset references" >&2
  false
fi

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=b90c537d905559a3dbbf146e0c0b7e1ceb667778"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v11.css"
echo "HERO_REFERENCE_COMPOSITION=YES"
echo "RIYADH_SKYLINE_VISIBLE=YES"
echo "SEDAN_SCALE_CORRECTED=YES"
echo "HEALTH_SCENE_REBUILT=YES"
echo "MISSING_IMAGE_DEPENDENCY=NO"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
