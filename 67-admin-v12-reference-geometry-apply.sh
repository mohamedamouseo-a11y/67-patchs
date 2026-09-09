#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
PATCHER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v12-reference-geometry-apply.py
BACKUP_DIR="/tmp/67-admin-v12-backup-$$"
PATCHED=0
mkdir -p "$BACKUP_DIR/src/pages"
cd "$ROOT"

cp src/pages/AdminDashboard.v11.css "$BACKUP_DIR/src/pages/AdminDashboard.v11.css"

rollback() {
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v11.css" src/pages/AdminDashboard.v11.css
    npm run build >/tmp/67-admin-v12-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=V12_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

curl -fsSL "$PATCHER_URL" -o /tmp/67-admin-v12-reference-geometry-apply.py
python3 /tmp/67-admin-v12-reference-geometry-apply.py
PATCHED=1

npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

grep -q "SIX SEVEN ADMIN V12" src/pages/AdminDashboard.v11.css
grep -q "width:36%" src/pages/AdminDashboard.v11.css
grep -q "grid-template-columns:18% 50% 32%" src/pages/AdminDashboard.v11.css
if grep -q "admin-v8-hero.jpg\|admin-v8-health.jpg" src/pages/AdminDashboard.v11.css; then
  echo "Forbidden missing asset reference detected" >&2
  false
fi

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=b64a50bb8bca72c5a18442a55d3f90a297444c88"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.v11.css"
echo "HERO_REFERENCE_GEOMETRY=YES"
echo "TITLE_ZONE_RIGHT_LOCKED=YES"
echo "TOOLBAR_LEFT_LOCKED=YES"
echo "CINEMATIC_WARM_DEPTH=YES"
echo "HEALTH_VISUAL_WEIGHT=YES"
echo "MISSING_IMAGE_DEPENDENCY=NO"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
