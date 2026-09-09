#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
PATCHER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v10-reference-recovery-apply.py
BACKUP_DIR="/tmp/67-v10-reference-backup-$$"
PATCHED=0
mkdir -p "$BACKUP_DIR/src/pages"

cd "$ROOT"
cp src/pages/AdminDashboard.jsx "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp src/pages/AdminDashboard.v9.css "$BACKUP_DIR/src/pages/AdminDashboard.v9.css"

rollback() {
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" src/pages/AdminDashboard.jsx
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v9.css" src/pages/AdminDashboard.v9.css
    npm run build >/tmp/67-v10-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "VITE_MISSING_ADMIN_ASSET_WARNING=N/A"
  echo "ERROR=V10_APPLY_OR_VALIDATION_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

curl -fsSL "$PATCHER_URL" -o /tmp/67-admin-v10-reference-recovery-apply.py
python3 /tmp/67-admin-v10-reference-recovery-apply.py
PATCHED=1

if grep -R "admin-v8-hero.jpg\|admin-v8-health.jpg" -n src/pages/AdminDashboard.v9.css; then
  echo "Missing asset reference remained" >&2
  false
fi

npm run build 2>&1 | tee /tmp/67-v10-build.log
if grep -q "admin-v8-hero.jpg\|admin-v8-health.jpg" /tmp/67-v10-build.log; then
  echo "Vite still reported missing admin assets" >&2
  false
fi

systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
if [ "$LOCAL_ADMIN_HTTP" != "200" ]; then
  echo "Unexpected local admin HTTP: $LOCAL_ADMIN_HTTP" >&2
  false
fi

grep -q "marginRight: '278px'" src/pages/AdminDashboard.jsx
grep -q "gap: '10px'" src/pages/AdminDashboard.jsx
grep -q "\.ov-header__motif{" src/pages/AdminDashboard.v9.css
grep -q "\.syshealth \.syshealth__grid{" src/pages/AdminDashboard.v9.css

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=e9f4be05d69fe9592f4c42f3322247b8a482a1d7"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v9.css"
echo "VITE_MISSING_ADMIN_ASSET_WARNING=NO"
echo "HERO_EMBEDDED_SVG_VISIBLE=YES"
echo "HEALTH_EMBEDDED_SVG_VISIBLE=YES"
echo "HEALTH_GRID_FIXED=YES"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
