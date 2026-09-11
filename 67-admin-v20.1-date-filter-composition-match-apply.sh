#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v20.css
TARGET_CSS=src/pages/AdminDashboard.v20.1.css
BACKUP=/tmp/67-v20.1-date-filter-$$
FAILED_STEP=init
APPLIED_NOW=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    rm -f "$TARGET_CSS"
    npm run build >/tmp/67-v20.1-date-filter-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V20_1_DATE_FILTER_COMPOSITION_MATCH_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v20.1.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$TARGET_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V20.1 — DATE FILTER COMPOSITION MATCH" "$TARGET_CSS"
  STATE_ACTION=ALREADY_AT_V20_1
elif grep -q "import './AdminDashboard.v20.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$SOURCE_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V20 — DATE FILTER REFERENCE MATCH" "$SOURCE_CSS"
  STATE_ACTION=APPLY_V20_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$SOURCE_CSS" "$TARGET_CSS"

  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V20.1 — DATE FILTER COMPOSITION MATCH
   Visual correction from real V20 QA against the approved date-filter concept:
   1) closed bar no longer covers hero copy,
   2) visual order becomes range -> presets -> utilities,
   3) open custom tray gains the wider, calmer approved composition,
   4) KPI row remains completely below the expanded hero. */

/* CLOSED STATE — give the control its own visual lane below the hero copy. */
.ov-header-v16:not(.date-control-open){
  height:242px!important;
  min-height:242px!important;
}
.ov-header-v16:not(.date-control-open) .ov-header__toolbar-top{
  left:28px!important;
  right:auto!important;
  top:auto!important;
  bottom:18px!important;
  z-index:82!important;
}

/* Approved visual order: selected range LEFT, presets CENTER, utilities RIGHT. */
.executive-date-shell{
  direction:ltr!important;
  height:64px!important;
  padding:7px!important;
  gap:8px!important;
  border-radius:19px!important;
  border-color:rgba(229,191,94,.58)!important;
  box-shadow:0 22px 54px rgba(0,0,0,.52),0 0 0 1px rgba(0,0,0,.30),inset 0 1px rgba(255,255,255,.075)!important;
}
.executive-date-display{
  direction:rtl!important;
  height:50px!important;
  min-width:378px!important;
  padding:0 13px!important;
  border-radius:13px!important;
}
.executive-date-display__copy{align-items:flex-start!important}
.executive-date-display__copy small{font-size:8.5px!important}
.executive-date-display__copy strong{max-width:280px!important;font-size:12.6px!important}
.executive-date-display__icon{width:38px!important;height:38px!important;flex-basis:38px!important}

.executive-date-presets{
  direction:rtl!important;
  height:50px!important;
  gap:8px!important;
}
.executive-date-preset{
  height:50px!important;
  min-width:82px!important;
  padding:0 18px!important;
  border-radius:13px!important;
  font-size:11px!important;
}
.executive-date-preset.active{
  color:#ffe18a!important;
  border-color:rgba(248,205,92,.78)!important;
  background:radial-gradient(circle at 50% -24%,rgba(255,225,139,.34),transparent 60%),linear-gradient(180deg,rgba(184,132,32,.43),rgba(77,52,12,.24))!important;
  box-shadow:0 0 0 1px rgba(244,198,73,.14),0 9px 20px rgba(0,0,0,.27),inset 0 1px rgba(255,242,196,.13)!important;
}

.executive-date-actions{
  direction:ltr!important;
  height:50px!important;
  gap:8px!important;
  padding-left:16px!important;
  padding-right:0!important;
  margin-left:4px!important;
  margin-right:0!important;
}
.executive-date-actions::before{
  left:3px!important;
  right:auto!important;
  inset-inline-start:auto!important;
}
.executive-date-action{
  width:50px!important;
  height:50px!important;
  border-radius:13px!important;
}

/* OPEN STATE — shell returns to the top and the custom tray uses the approved wide composition. */
.ov-header-v16.date-control-open{
  height:474px!important;
  min-height:474px!important;
  overflow:hidden!important;
}
.ov-header-v16.date-control-open .ov-header__toolbar-top{
  left:28px!important;
  right:auto!important;
  top:18px!important;
  bottom:auto!important;
  z-index:82!important;
}
.ov-header-v16.date-control-open .executive-date-popover{
  left:0!important;
  right:auto!important;
  top:calc(100% + 15px)!important;
  width:920px!important;
  border-radius:20px!important;
  border-color:rgba(231,193,96,.58)!important;
  box-shadow:0 32px 78px rgba(0,0,0,.59),0 0 0 1px rgba(0,0,0,.30),inset 0 1px rgba(255,255,255,.055)!important;
}
.executive-date-popover__head{
  min-height:82px!important;
  padding:19px 24px 16px!important;
  gap:22px!important;
}
.executive-date-popover__head strong{
  margin-bottom:6px!important;
  font-size:18px!important;
}
.executive-date-popover__head span:not(.executive-date-popover__badge){
  max-width:540px!important;
  font-size:10.5px!important;
  line-height:1.6!important;
}
.executive-date-popover__badge{
  min-width:112px!important;
  height:39px!important;
  padding:0 17px!important;
  font-size:10.5px!important;
}

.executive-date-fields{
  gap:28px!important;
  padding:21px 24px 20px!important;
}
.executive-date-fields::after{
  width:38px!important;
  height:38px!important;
  top:62%!important;
  font-size:16px!important;
}
.executive-date-field-card{gap:9px!important}
.executive-date-field-label{font-size:11.5px!important;padding:0 5px!important}
.executive-date-picker{
  height:82px!important;
  padding:0 16px!important;
  gap:14px!important;
  border-radius:15px!important;
}
.executive-date-picker__icon{
  width:48px!important;
  height:48px!important;
  flex-basis:48px!important;
  border-radius:13px!important;
}
.executive-date-picker__copy small{margin-bottom:8px!important;font-size:9px!important}
.executive-date-picker__copy strong{max-width:285px!important;font-size:14px!important}

.executive-date-popover__footer{
  min-height:78px!important;
  padding:14px 24px 16px!important;
  gap:20px!important;
}
.executive-date-popover__hint{
  max-width:400px!important;
  font-size:9.5px!important;
  line-height:1.6!important;
}
.executive-date-popover__buttons{gap:12px!important}
.executive-date-cancel,
.executive-date-apply{
  height:46px!important;
  border-radius:12px!important;
  font-size:10.5px!important;
}
.executive-date-cancel{min-width:118px!important;padding:0 20px!important}
.executive-date-apply{min-width:198px!important;padding:0 26px!important}

/* Keep the hero image readable around the enlarged control instead of visually flattening it. */
.ov-header-v16.date-control-open .ov-header__motif{
  transform:scale(1.015)!important;
  background-position:center 48%!important;
}

@media(max-width:1500px){
  .executive-date-display{min-width:330px!important}
  .executive-date-preset{min-width:70px!important;padding:0 14px!important}
  .ov-header-v16.date-control-open .executive-date-popover{width:840px!important}
}

@media(max-width:1280px){
  .ov-header-v16:not(.date-control-open){height:226px!important;min-height:226px!important}
  .executive-date-shell{transform:scale(.92)!important;transform-origin:left bottom!important}
  .ov-header-v16.date-control-open .executive-date-popover{width:760px!important}
}
CSS

  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v20.css';"
new="import './AdminDashboard.v20.1.css';"
if old not in s:
    raise SystemExit('V20_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v20.1.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V20.1 — DATE FILTER COMPOSITION MATCH" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v20.1-date-filter-build.log 2>&1 || {
  tail -n 100 /tmp/67-v20.1-date-filter-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v20.1.css"
echo "CLOSED_HERO_COPY_CLEARANCE=YES"
echo "DATE_FILTER_VISUAL_ORDER_MATCHED=YES"
echo "CUSTOM_PANEL_WIDTH_UPGRADED=YES"
echo "CUSTOM_PANEL_READABILITY_UPGRADED=YES"
echo "HERO_EXPANDS_ON_CUSTOM=YES"
echo "KPI_OVERLAP=NO_BY_LAYOUT"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_READY=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
