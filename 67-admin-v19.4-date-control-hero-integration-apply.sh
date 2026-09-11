#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.3.css
TARGET_CSS=src/pages/AdminDashboard.v19.4.css
BACKUP=/tmp/67-v19.4-$$
FAILED_STEP=init
APPLIED_NOW=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    rm -f "$TARGET_CSS"
    npm run build >/tmp/67-v19.4-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V19_4_DATE_CONTROL_HERO_INTEGRATION_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v19.4.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$TARGET_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V19.4" "$TARGET_CSS"
  STATE_ACTION=ALREADY_AT_V19_4
elif grep -q "import './AdminDashboard.v19.3.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$SOURCE_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V19.3" "$SOURCE_CSS"
  STATE_ACTION=APPLY_V19_4
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$SOURCE_CSS" "$TARGET_CSS"

  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19.4 — DATE CONTROL HERO INTEGRATION
   Visual-QA correction: compact the custom-range tray so it reads as part of the hero,
   preserves the premium dark/ivory/gold language, and no longer masks the KPI row. */
.ov-header-v16.date-control-open .executive-date-popover{
  left:calc(100% + 14px)!important;
  right:auto!important;
  top:2px!important;
  width:468px!important;
  padding:0!important;
  border-radius:16px!important;
  overflow:hidden!important;
  background:linear-gradient(180deg,#0b1119 0%,#060a10 100%)!important;
  border:1px solid rgba(225,188,95,.34)!important;
  box-shadow:0 26px 64px rgba(0,0,0,.55),0 8px 24px rgba(107,70,11,.13),inset 0 1px rgba(255,255,255,.05)!important;
  backdrop-filter:blur(26px) saturate(145%)!important;
  transform-origin:top left!important;
  animation:v194DateTrayIn .18s cubic-bezier(.2,.75,.25,1) both!important;
  z-index:170!important;
}

@keyframes v194DateTrayIn{
  from{opacity:0;transform:translateY(-3px) scale(.992)}
  to{opacity:1;transform:translateY(0) scale(1)}
}

.ov-header-v16.date-control-open .executive-date-popover::after{
  left:24px!important;
  right:24px!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,rgba(242,207,116,.9),transparent)!important;
}

.executive-date-popover__head{
  min-height:0!important;
  padding:11px 14px 9px!important;
  gap:12px!important;
  border-bottom:1px solid rgba(255,255,255,.06)!important;
}
.executive-date-popover__head strong{
  margin:0 0 3px!important;
  font-size:13.5px!important;
  line-height:1.15!important;
  letter-spacing:-.018em!important;
}
.executive-date-popover__head span:not(.executive-date-popover__badge){
  max-width:300px!important;
  font-size:9.2px!important;
  line-height:1.42!important;
  color:#939aa4!important;
}
.executive-date-popover__badge{
  min-width:60px!important;
  height:26px!important;
  padding:0 9px!important;
  font-size:8.3px!important;
  border-color:rgba(229,193,100,.30)!important;
}

.executive-date-fields{
  grid-template-columns:minmax(0,1fr) minmax(0,1fr)!important;
  gap:10px!important;
  padding:10px 14px 9px!important;
}
.executive-date-fields::after{
  content:"↔"!important;
  width:24px!important;
  height:24px!important;
  top:58%!important;
  transform:translate(-50%,-50%)!important;
  font-size:13px!important;
  line-height:1!important;
  color:#efd071!important;
  background:linear-gradient(180deg,#111a24,#080d13)!important;
  border:1px solid rgba(225,188,95,.28)!important;
  box-shadow:0 6px 14px rgba(0,0,0,.30),inset 0 1px rgba(255,255,255,.04)!important;
}
.executive-date-field-card{
  gap:5px!important;
}
.executive-date-field-label{
  padding:0 2px!important;
  font-size:8.8px!important;
  line-height:1!important;
  color:#cbc3b6!important;
}
.executive-date-picker{
  height:56px!important;
  padding:0 10px!important;
  gap:9px!important;
  border-radius:12px!important;
  background:radial-gradient(circle at 12% 0%,rgba(215,173,81,.10),transparent 34%),linear-gradient(180deg,#fffaf0 0%,#f3ead9 100%)!important;
  border-color:rgba(198,151,55,.30)!important;
  box-shadow:0 7px 18px rgba(0,0,0,.17),inset 0 1px rgba(255,255,255,.86)!important;
}
.executive-date-picker:hover,
.executive-date-picker:focus-within{
  transform:translateY(-1px)!important;
  border-color:rgba(194,142,38,.58)!important;
  box-shadow:0 10px 22px rgba(0,0,0,.20),0 0 0 2px rgba(215,173,81,.09),inset 0 1px rgba(255,255,255,.9)!important;
}
.executive-date-picker__icon{
  width:30px!important;
  height:30px!important;
  flex-basis:30px!important;
  border-radius:9px!important;
  box-shadow:inset 0 1px rgba(255,255,255,.62),0 4px 10px rgba(123,82,11,.12)!important;
}
.executive-date-picker__copy small{
  margin:0 0 5px!important;
  font-size:7.8px!important;
}
.executive-date-picker__copy strong{
  max-width:150px!important;
  font-size:10.8px!important;
  line-height:1.15!important;
}
.executive-date-picker__chevron{
  opacity:.78!important;
  transform:scale(.88)!important;
}
.executive-date-error{
  margin:0 14px 8px!important;
  padding:6px 8px!important;
  border-radius:8px!important;
  font-size:8.2px!important;
}

.executive-date-popover__footer{
  min-height:44px!important;
  padding:8px 14px 9px!important;
  gap:10px!important;
  border-top:1px solid rgba(255,255,255,.055)!important;
}
.executive-date-popover__hint{
  max-width:190px!important;
  font-size:7.8px!important;
  line-height:1.4!important;
  color:#818a95!important;
}
.executive-date-popover__buttons{
  gap:7px!important;
}
.executive-date-cancel,
.executive-date-apply{
  height:32px!important;
  border-radius:9px!important;
  font-size:8.5px!important;
}
.executive-date-cancel{
  min-width:60px!important;
  padding:0 12px!important;
}
.executive-date-apply{
  min-width:116px!important;
  padding:0 14px!important;
  box-shadow:0 8px 18px rgba(168,113,20,.18),inset 0 1px rgba(255,255,255,.42)!important;
}

/* Closed state: keep the command capsule compact and visually subordinate to hero messaging. */
.executive-date-shell{
  height:46px!important;
  padding:4px 5px!important;
  gap:5px!important;
  border-radius:13px!important;
  box-shadow:0 16px 38px rgba(0,0,0,.44),0 3px 10px rgba(157,105,18,.08),inset 0 1px rgba(255,255,255,.065)!important;
}
.executive-date-display{
  min-width:258px!important;
}
.executive-date-display__copy strong{
  font-size:10.6px!important;
}
.executive-date-preset{
  height:34px!important;
  min-height:34px!important;
}

/* The panel now remains inside the hero's visual footprint at desktop density;
   reserve only a tiny safety gap so its shadow never reads as covering KPI cards. */
.ov-header-v16.date-control-open{
  margin-bottom:6px!important;
}

@media(max-width:1360px){
  .ov-header-v16.date-control-open .executive-date-popover{
    left:calc(100% + 10px)!important;
    width:444px!important;
  }
  .executive-date-fields{gap:8px!important;padding-left:12px!important;padding-right:12px!important}
  .executive-date-picker__copy strong{max-width:130px!important;font-size:10.2px!important}
  .executive-date-display{min-width:228px!important}
}

@media(prefers-reduced-motion:reduce){
  .ov-header-v16.date-control-open .executive-date-popover{animation:none!important}
}
CSS

  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v19.3.css';"
new="import './AdminDashboard.v19.4.css';"
if old not in s:
    raise SystemExit('V19_3_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY
else
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=verify_source
grep -q "import './AdminDashboard.v19.4.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.4" "$TARGET_CSS"
grep -q 'content:"↔"' "$TARGET_CSS"
grep -q 'height:56px!important' "$TARGET_CSS"

FAILED_STEP=build
npm run build >/tmp/67-v19.4-build.log 2>&1 || {
  tail -n 100 /tmp/67-v19.4-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP" 2>/dev/null || true

echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v19.4.css"
echo "RUNTIME_CSS=AdminDashboard.v19.4.css"
echo "DATE_PANEL_COMPACTED=YES"
echo "KPI_OVERLAP_CORRECTION=YES"
echo "HERO_INTEGRATION_REFINED=YES"
echo "RANGE_CONNECTOR_REBUILT=YES"
echo "DATE_CARD_DENSITY_REFINED=YES"
echo "CLOSED_CONTROL_DENSITY_REFINED=YES"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "NATIVE_DATE_BEHAVIOR_PRESERVED=YES"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_REQUIRED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
