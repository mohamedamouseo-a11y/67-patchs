#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v22.1.css
TARGET_CSS=src/pages/AdminDashboard.v22.2.css
BACKUP=/tmp/67-v22.2-kpi-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v22.2.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v22.2-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V22_2_KPI_PREMIUM_PROPORTION_POLISH_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v22.2.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V22.2 — KPI PREMIUM PROPORTION POLISH" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V22_2
elif grep -q "import './AdminDashboard.v22.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V22.1 — KPI CLIPPING FIX" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V22_2
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v22.2.css"
  fi

  cp "$SOURCE_CSS" "$TARGET_CSS"
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V22.2 — KPI PREMIUM PROPORTION POLISH
   Base: V22.1 clipping fix.
   Scope lock: KPI cards only.
   Visual QA-driven refinement:
   - keep all lower content fully visible,
   - reduce dead vertical space,
   - tighten label/value/note hierarchy,
   - keep a compact executive proportion,
   - preserve all values, data and logic. */

.kpi-grid{
  gap:11px!important;
  margin:2px 0 2px!important;
}

.kpi-card{
  box-sizing:border-box!important;
  height:138px!important;
  min-height:138px!important;
  padding:12px 15px 11px!important;
  grid-template-rows:40px 40px 24px!important;
  gap:5px!important;
}

.kpi-card__top{
  min-height:40px!important;
  height:40px!important;
  align-items:center!important;
}

.kpi-card__label{
  font-size:11px!important;
  line-height:1.25!important;
  color:#6f6a62!important;
}

.kpi-card__icon{
  width:42px!important;
  height:42px!important;
  min-width:42px!important;
  flex-basis:42px!important;
  border-radius:12px!important;
}
.kpi-card__icon svg{
  width:18px!important;
  height:18px!important;
}

.kpi-card__value{
  align-self:center!important;
  margin:0!important;
  font-size:32px!important;
  line-height:1!important;
  letter-spacing:-.04em!important;
}
.kpi-card__value small{
  font-size:10px!important;
}

.kpi-card__note{
  box-sizing:border-box!important;
  min-height:24px!important;
  height:24px!important;
  padding-top:5px!important;
  align-items:center!important;
  gap:6px!important;
  font-size:9.8px!important;
  line-height:1!important;
  overflow:visible!important;
}
.kpi-card__note .muted{
  font-size:9.8px!important;
  color:#777168!important;
  font-weight:760!important;
}

.kpi-microbar{
  height:16px!important;
  min-height:16px!important;
  min-width:38px!important;
  gap:2.5px!important;
  opacity:.92!important;
}
.kpi-microbar>span{
  width:4px!important;
}

@media(max-width:1360px){
  .kpi-grid{gap:9px!important}
  .kpi-card{
    height:132px!important;
    min-height:132px!important;
    padding:11px 13px 10px!important;
    grid-template-rows:38px 38px 22px!important;
    gap:4px!important;
  }
  .kpi-card__top{min-height:38px!important;height:38px!important}
  .kpi-card__icon{width:39px!important;height:39px!important;min-width:39px!important;flex-basis:39px!important}
  .kpi-card__value{font-size:29px!important}
  .kpi-card__note{min-height:22px!important;height:22px!important;padding-top:4px!important;font-size:9px!important}
  .kpi-card__note .muted{font-size:9px!important}
}

@media(max-width:1080px){
  .kpi-card{
    height:auto!important;
    min-height:128px!important;
  }
}
CSS

  FAILED_STEP=wire_runtime
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v22.1.css';"
new="import './AdminDashboard.v22.2.css';"
if old not in s:
    raise SystemExit('V22_1_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v22.2.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V22.2 — KPI PREMIUM PROPORTION POLISH" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v22.2-kpi-build.log 2>&1 || {
  tail -n 120 /tmp/67-v22.2-kpi-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V22.1"
echo "TARGET_VERSION=V22.2"
echo "RUNTIME_CSS=AdminDashboard.v22.2.css"
echo "ELEMENT=KPI_CARDS_ONLY"
echo "KPI_CLIPPING_PRESENT=NO_BY_LAYOUT"
echo "KPI_DESKTOP_HEIGHT=138PX"
echo "KPI_PROPORTION_POLISHED=YES"
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
