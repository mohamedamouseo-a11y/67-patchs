#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
V193_CSS=src/pages/AdminDashboard.v19.3.css
V1923_CSS=src/pages/AdminDashboard.v19.2.3.css
V1931_COMMIT=eeb42cc20c682d6d97df608dd4b4b0ddb632f7f4
FAILED_STEP=init

cd "$ROOT"

fail(){
  local msg="$1"
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "STATE_RECONCILED=NO"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V19_3_2_STATE_RECONCILE_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v19.3.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$V193_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V19.3" "$V193_CSS"
  STATE_ACTION=ALREADY_AT_V19_3
elif grep -q "import './AdminDashboard.v19.2.3.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$V1923_CSS" ]; then
  STATE_ACTION=APPLY_V19_3_1
  FAILED_STEP=apply_v19_3_1
  curl -fsSL \
    "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${V1931_COMMIT}/67-admin-v19.3.1-date-control-premium-redesign-verifyfix-apply.sh" \
    -o /tmp/67-admin-v19.3.1-reconcile-inner.sh
  chmod +x /tmp/67-admin-v19.3.1-reconcile-inner.sh
  /tmp/67-admin-v19.3.1-reconcile-inner.sh
  grep -q "import './AdminDashboard.v19.3.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V19.3" "$V193_CSS"
else
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  FAILED_STEP=unsupported_runtime_state
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v19.3.2-build.log 2>&1 || {
  tail -n 80 /tmp/67-v19.3.2-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_RECONCILED=YES"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v19.3.css"
echo "V19_3_PRESENT=YES"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_READY=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
