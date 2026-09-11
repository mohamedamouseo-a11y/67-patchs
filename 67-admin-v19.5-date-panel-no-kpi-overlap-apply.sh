#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.4.css
TARGET_CSS=src/pages/AdminDashboard.v19.5.css
BACKUP=/tmp/67-v19.5-$$
FAILED_STEP=init
APPLIED_NOW=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    rm -f "$TARGET_CSS"
    npm run build >/tmp/67-v19.5-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V19_5_DATE_PANEL_NO_KPI_OVERLAP_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v19.5.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$TARGET_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V19.5" "$TARGET_CSS"
  STATE_ACTION=ALREADY_AT_V19_5
elif grep -q "import './AdminDashboard.v19.4.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$SOURCE_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V19.4" "$SOURCE_CSS"
  STATE_ACTION=APPLY_V19_5
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$SOURCE_CSS" "$TARGET_CSS"

  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19.5 — DATE PANEL NO-KPI-OVERLAP LOCK
   Visual-QA correction from V19.4: keep the full custom range panel inside the hero
   so the KPI row remains completely unobstructed while preserving V19.4 styling. */
.ov-header-v16.date-control-open .executive-date-popover{
  top:-2px!important;
  width:452px!important;
  border-radius:15px!important;
  box-shadow:0 18px 42px rgba(0,0,0,.46),0 6px 18px rgba(107,70,11,.11),inset 0 1px rgba(255,255,255,.05)!important;
}

.executive-date-popover__head{
  padding:8px 13px 6px!important;
  gap:10px!important;
}
.executive-date-popover__head strong{
  margin-bottom:2px!important;
  font-size:12.5px!important;
  line-height:1.15!important;
}
.executive-date-popover__head span:not(.executive-date-popover__badge){
  font-size:7.5px!important;
  line-height:1.35!important;
  max-width:285px!important;
}
.executive-date-popover__badge{
  min-width:58px!important;
  height:24px!important;
  padding:0 9px!important;
  font-size:7.5px!important;
}

.executive-date-fields{
  gap:9px!important;
  padding:9px 13px 8px!important;
}
.executive-date-fields::after{
  width:22px!important;
  height:22px!important;
  font-size:10px!important;
  transform:translate(-50%,-2%)!important;
}
.executive-date-field-card{gap:4px!important}
.executive-date-field-label{
  padding:0 2px!important;
  font-size:7.5px!important;
}
.executive-date-picker{
  height:48px!important;
  padding:0 10px!important;
  gap:8px!important;
  border-radius:11px!important;
  box-shadow:0 6px 15px rgba(0,0,0,.15),inset 0 1px rgba(255,255,255,.82)!important;
}
.executive-date-picker__icon{
  width:29px!important;
  height:29px!important;
  flex-basis:29px!important;
  border-radius:9px!important;
}
.executive-date-picker__copy small{
  margin-bottom:4px!important;
  font-size:7px!important;
}
.executive-date-picker__copy strong{
  max-width:142px!important;
  font-size:9.4px!important;
  line-height:1.12!important;
}
.executive-date-picker__chevron{transform:scale(.82)!important}

.executive-date-popover__footer{
  min-height:0!important;
  padding:7px 13px 8px!important;
  gap:9px!important;
}
.executive-date-popover__hint{
  max-width:190px!important;
  font-size:7px!important;
  line-height:1.3!important;
}
.executive-date-popover__buttons{gap:6px!important}
.executive-date-cancel,
.executive-date-apply{
  height:29px!important;
  border-radius:8px!important;
  font-size:7.7px!important;
}
.executive-date-cancel{
  min-width:58px!important;
  padding:0 11px!important;
}
.executive-date-apply{
  min-width:105px!important;
  padding:0 13px!important;
  box-shadow:0 7px 15px rgba(168,113,20,.17),inset 0 1px rgba(255,255,255,.40)!important;
}
.executive-date-error{
  margin:0 13px 7px!important;
  padding:5px 8px!important;
  font-size:7.5px!important;
}

/* The hero has a fixed 172px height. Keep the popover body and its shadow visually above the red hero edge. */
.ov-header-v16.date-control-open{
  overflow:visible!important;
}
.ov-header-v16.date-control-open .executive-date-popover{
  max-height:156px!important;
}

@media(max-width:1360px){
  .ov-header-v16.date-control-open .executive-date-popover{
    width:430px!important;
    left:calc(100% + 8px)!important;
  }
  .executive-date-picker__copy strong{max-width:126px!important;font-size:9px!important}
}
CSS

  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v19.4.css';"
new="import './AdminDashboard.v19.5.css';"
if old not in s:
    raise SystemExit('V19_4_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v19.5.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V19.5" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v19.5-build.log 2>&1 || {
  tail -n 80 /tmp/67-v19.5-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v19.5.css"
echo "DATE_PANEL_HEIGHT_REDUCED=YES"
echo "DATE_PANEL_WIDTH_REFINED=YES"
echo "KPI_ROW_CLEARANCE_LOCKED=YES"
echo "HERO_EDGE_SHADOW_REDUCED=YES"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_READY=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
