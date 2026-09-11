#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v22.css
TARGET_CSS=src/pages/AdminDashboard.v22.1.css
BACKUP=/tmp/67-v22.1-kpi-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v22.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v22.1-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V22_1_KPI_CLIPPING_FIX_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v22.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V22.1 — KPI CLIPPING FIX" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V22_1
elif grep -q "import './AdminDashboard.v22.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V22 — PREMIUM KPI CARDS" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V22_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v22.1.css"
  fi

  cp "$SOURCE_CSS" "$TARGET_CSS"
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V22.1 — KPI CLIPPING FIX
   Scope lock: KPI cards only.
   Fixes the visible lower-row clipping caused by V22's 128px card height.
   No KPI values, data, calculations, hero, date filter, system health,
   command center, transactions, sidebar, backend or auth changes. */

.kpi-card{
  height:146px!important;
  min-height:146px!important;
  padding:14px 16px 13px!important;
  grid-template-rows:46px minmax(38px,1fr) 24px!important;
  gap:5px!important;
}

.kpi-card__top{
  min-height:46px!important;
}

.kpi-card__value{
  align-self:center!important;
  line-height:1!important;
}

.kpi-card__note{
  min-height:24px!important;
  height:24px!important;
  padding-top:5px!important;
  align-items:center!important;
  overflow:visible!important;
}

.kpi-microbar{
  height:16px!important;
  min-height:16px!important;
  align-self:center!important;
}
.kpi-microbar>span:nth-child(1){height:5px!important}
.kpi-microbar>span:nth-child(2){height:8px!important}
.kpi-microbar>span:nth-child(3){height:7px!important}
.kpi-microbar>span:nth-child(4){height:11px!important}
.kpi-microbar>span:nth-child(5){height:15px!important}

@media(max-width:1360px){
  .kpi-card{
    height:136px!important;
    min-height:136px!important;
    padding:12px 14px 11px!important;
    grid-template-rows:42px minmax(34px,1fr) 22px!important;
    gap:4px!important;
  }
  .kpi-card__top{min-height:42px!important}
  .kpi-card__note{min-height:22px!important;height:22px!important;padding-top:4px!important}
}

@media(max-width:1080px){
  .kpi-card{
    height:132px!important;
    min-height:132px!important;
  }
}
CSS

  FAILED_STEP=wire_runtime
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v22.css';"
new="import './AdminDashboard.v22.1.css';"
if old not in s:
    raise SystemExit('V22_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v22.1.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V22.1 — KPI CLIPPING FIX" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v22.1-kpi-build.log 2>&1 || {
  tail -n 120 /tmp/67-v22.1-kpi-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V22"
echo "TARGET_VERSION=V22.1"
echo "RUNTIME_CSS=AdminDashboard.v22.1.css"
echo "ELEMENT=KPI_CARDS_ONLY"
echo "KPI_CLIPPING_FIXED_BY_LAYOUT=YES"
echo "KPI_DESKTOP_HEIGHT=146PX"
echo "KPI_VALUES_CHANGED=NO"
echo "KPI_LOGIC_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "COMMAND_CENTER_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
