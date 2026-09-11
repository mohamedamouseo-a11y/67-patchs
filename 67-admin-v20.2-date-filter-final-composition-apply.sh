#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v20.1.css
TARGET_CSS=src/pages/AdminDashboard.v20.2.css
BACKUP=/tmp/67-v20.2-date-filter-$$
FAILED_STEP=init
APPLIED_NOW=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    rm -f "$TARGET_CSS"
    npm run build >/tmp/67-v20.2-date-filter-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V20_2_DATE_FILTER_FINAL_COMPOSITION_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v20.2.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$TARGET_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V20.2 — DATE FILTER FINAL COMPOSITION" "$TARGET_CSS"
  STATE_ACTION=ALREADY_AT_V20_2
elif grep -q "import './AdminDashboard.v20.1.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$SOURCE_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V20.1 — DATE FILTER COMPOSITION MATCH" "$SOURCE_CSS"
  STATE_ACTION=APPLY_V20_2
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$SOURCE_CSS" "$TARGET_CSS"

  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V20.2 — DATE FILTER FINAL COMPOSITION
   Final visual lock from real V20.1 QA:
   - the command bar becomes a deliberate wide hero control,
   - custom mode removes competing lower-left hero copy,
   - custom tray becomes materially wider and calmer,
   - KPI row remains completely outside the expanded hero. */

/* ---------- CLOSED STATE: STRONG, WIDE, SINGLE COMMAND LANE ---------- */
.ov-header-v16:not(.date-control-open){
  height:252px!important;
  min-height:252px!important;
}
.ov-header-v16:not(.date-control-open) .ov-header__toolbar-top{
  left:30px!important;
  bottom:20px!important;
}
.ov-header-v16:not(.date-control-open) .executive-date-shell{
  width:1060px!important;
  max-width:calc(100vw - 620px)!important;
}
.executive-date-shell{
  min-height:66px!important;
  border-radius:20px!important;
  padding:7px!important;
  gap:9px!important;
  background:
    radial-gradient(circle at 12% -60%,rgba(238,197,94,.14),transparent 42%),
    linear-gradient(180deg,rgba(10,15,21,.992),rgba(4,7,11,.988))!important;
  border-color:rgba(233,195,97,.64)!important;
  box-shadow:0 24px 58px rgba(0,0,0,.54),0 0 0 1px rgba(0,0,0,.34),inset 0 1px rgba(255,255,255,.08)!important;
}
.executive-date-display{
  flex:1 1 430px!important;
  min-width:420px!important;
  height:52px!important;
  border-radius:14px!important;
  border-color:rgba(233,195,97,.34)!important;
}
.executive-date-display__copy small{font-size:8.8px!important}
.executive-date-display__copy strong{max-width:320px!important;font-size:13px!important}
.executive-date-display__icon{width:40px!important;height:40px!important;flex-basis:40px!important}
.executive-date-presets{height:52px!important;gap:9px!important}
.executive-date-preset{height:52px!important;min-width:86px!important;padding:0 18px!important;font-size:11.3px!important}
.executive-date-actions{height:52px!important;gap:9px!important}
.executive-date-action{width:52px!important;height:52px!important}

/* ---------- OPEN STATE: FILTER OWNS THE LEFT/CENTER HERO SPACE ---------- */
.ov-header-v16.date-control-open{
  height:520px!important;
  min-height:520px!important;
  overflow:hidden!important;
}
.ov-header-v16.date-control-open .ov-header__toolbar-top{
  left:30px!important;
  top:20px!important;
}
.ov-header-v16.date-control-open .executive-date-shell{
  width:1060px!important;
  max-width:calc(100vw - 620px)!important;
}

/* The custom tray is the primary interaction in open mode; remove the competing lower-left hero copy. */
.ov-header-v16.date-control-open .ov-header__copy-left{
  opacity:0!important;
  visibility:hidden!important;
  transform:translateY(10px)!important;
  pointer-events:none!important;
}
.ov-header-v16.date-control-open .ov-header__copy-right{
  top:30px!important;
  right:30px!important;
  z-index:20!important;
  opacity:.96!important;
}

.ov-header-v16.date-control-open .executive-date-popover{
  left:0!important;
  right:auto!important;
  top:calc(100% + 16px)!important;
  width:1080px!important;
  max-width:calc(100vw - 600px)!important;
  border-radius:22px!important;
  background:
    radial-gradient(circle at 10% -18%,rgba(229,182,72,.13),transparent 34%),
    radial-gradient(circle at 92% 118%,rgba(128,86,17,.08),transparent 30%),
    linear-gradient(180deg,rgba(11,18,26,.998),rgba(4,8,13,.998))!important;
  border-color:rgba(235,198,103,.64)!important;
  box-shadow:0 34px 86px rgba(0,0,0,.62),0 0 0 1px rgba(0,0,0,.36),inset 0 1px rgba(255,255,255,.06)!important;
}
.executive-date-popover__head{
  min-height:90px!important;
  padding:21px 27px 18px!important;
  gap:26px!important;
}
.executive-date-popover__head strong{font-size:20px!important;margin-bottom:7px!important}
.executive-date-popover__head span:not(.executive-date-popover__badge){
  max-width:650px!important;
  font-size:11px!important;
  line-height:1.65!important;
}
.executive-date-popover__badge{
  min-width:122px!important;
  height:42px!important;
  padding:0 18px!important;
  font-size:11px!important;
}
.executive-date-fields{
  gap:34px!important;
  padding:24px 27px 23px!important;
}
.executive-date-fields::after{
  width:42px!important;
  height:42px!important;
  top:61%!important;
  font-size:17px!important;
}
.executive-date-field-card{gap:10px!important}
.executive-date-field-label{font-size:12px!important;padding:0 6px!important}
.executive-date-picker{
  height:92px!important;
  padding:0 18px!important;
  gap:15px!important;
  border-radius:16px!important;
  background:radial-gradient(circle at 8% 0%,rgba(215,173,81,.085),transparent 38%),linear-gradient(180deg,#111c27,#09111a)!important;
  border-color:rgba(255,255,255,.10)!important;
}
.executive-date-picker__icon{
  width:54px!important;
  height:54px!important;
  flex-basis:54px!important;
  border-radius:14px!important;
}
.executive-date-picker__copy small{margin-bottom:9px!important;font-size:9.5px!important}
.executive-date-picker__copy strong{max-width:330px!important;font-size:15px!important}
.executive-date-popover__footer{
  min-height:84px!important;
  padding:15px 27px 17px!important;
  gap:22px!important;
}
.executive-date-popover__hint{max-width:470px!important;font-size:10px!important;line-height:1.65!important}
.executive-date-popover__buttons{gap:13px!important}
.executive-date-cancel,.executive-date-apply{height:48px!important;border-radius:13px!important;font-size:11px!important}
.executive-date-cancel{min-width:126px!important;padding:0 22px!important}
.executive-date-apply{min-width:216px!important;padding:0 28px!important}

/* Keep the vehicle visible as context without letting the image fight the filter. */
.ov-header-v16.date-control-open .ov-header__motif{
  background-position:center 50%!important;
  transform:scale(1.012)!important;
  filter:saturate(.96) brightness(.91)!important;
}

@media(max-width:1600px){
  .ov-header-v16:not(.date-control-open) .executive-date-shell,
  .ov-header-v16.date-control-open .executive-date-shell{width:960px!important;max-width:calc(100vw - 560px)!important}
  .executive-date-display{min-width:360px!important}
  .executive-date-preset{min-width:76px!important;padding:0 15px!important}
  .ov-header-v16.date-control-open .executive-date-popover{width:960px!important;max-width:calc(100vw - 540px)!important}
}

@media(max-width:1360px){
  .ov-header-v16:not(.date-control-open){height:236px!important;min-height:236px!important}
  .ov-header-v16.date-control-open{height:486px!important;min-height:486px!important}
  .ov-header-v16:not(.date-control-open) .executive-date-shell,
  .ov-header-v16.date-control-open .executive-date-shell{width:860px!important;max-width:calc(100vw - 500px)!important}
  .executive-date-display{min-width:310px!important}
  .executive-date-preset{min-width:68px!important;padding:0 13px!important}
  .executive-date-action{width:48px!important}
  .ov-header-v16.date-control-open .executive-date-popover{width:860px!important;max-width:calc(100vw - 480px)!important}
}

@media(prefers-reduced-motion:reduce){
  .ov-header-v16.date-control-open .ov-header__copy-left{transform:none!important}
}
CSS

  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v20.1.css';"
new="import './AdminDashboard.v20.2.css';"
if old not in s:
    raise SystemExit('V20_1_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v20.2.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V20.2 — DATE FILTER FINAL COMPOSITION" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v20.2-date-filter-build.log 2>&1 || {
  tail -n 100 /tmp/67-v20.2-date-filter-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v20.2.css"
echo "CLOSED_COMMAND_LANE_WIDENED=YES"
echo "OPEN_HERO_COPY_CONFLICT_REMOVED=YES"
echo "CUSTOM_PANEL_FINAL_WIDTH=YES"
echo "CUSTOM_PANEL_HIERARCHY_UPGRADED=YES"
echo "KPI_OVERLAP=NO_BY_LAYOUT"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_READY=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
