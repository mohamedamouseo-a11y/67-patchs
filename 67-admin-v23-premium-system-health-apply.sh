#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v22.2.css
TARGET_CSS=src/pages/AdminDashboard.v23.css
BACKUP=/tmp/67-v23-system-health-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v23.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v23-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V23_SYSTEM_HEALTH_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v23.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V23 — PREMIUM SYSTEM HEALTH" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V23
elif grep -q "import './AdminDashboard.v22.2.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V22.2 — KPI PREMIUM PROPORTION POLISH" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V23
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v23.css"
  fi

  cp "$SOURCE_CSS" "$TARGET_CSS"
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V23 — PREMIUM SYSTEM HEALTH
   Base: V22.2 approved KPI composition.
   Scope lock: System Health panel only.
   Goal: executive infrastructure command panel with stronger hierarchy,
   better legibility, premium dark materiality, and balanced automotive scene.
   No metric values, logic, backend, auth, KPI, hero, date control, command center,
   transaction, sidebar, or business data changes. */

.syshealth{
  position:relative!important;
  height:148px!important;
  min-height:148px!important;
  margin:1px 0!important;
  border-radius:16px!important;
  overflow:hidden!important;
  isolation:isolate!important;
  background:
    radial-gradient(circle at 31% 24%,rgba(32,192,135,.085),transparent 27%),
    radial-gradient(circle at 77% 72%,rgba(215,173,81,.085),transparent 30%),
    linear-gradient(108deg,#04080d 0%,#0a121c 47%,#101b27 100%)!important;
  border:1px solid rgba(215,173,81,.24)!important;
  box-shadow:0 16px 36px rgba(1,5,10,.19),inset 0 1px 0 rgba(255,255,255,.025)!important;
}
.syshealth::before{
  content:""!important;
  position:absolute!important;
  inset:0 0 auto 0!important;
  height:1px!important;
  z-index:4!important;
  pointer-events:none!important;
  background:linear-gradient(90deg,transparent 2%,rgba(215,173,81,.18) 16%,rgba(215,173,81,.78) 49%,rgba(215,25,32,.54) 78%,transparent 98%)!important;
}
.syshealth::after{
  content:""!important;
  position:absolute!important;
  inset:0!important;
  z-index:0!important;
  pointer-events:none!important;
  opacity:.38!important;
  background-image:
    linear-gradient(rgba(255,255,255,.012) 1px,transparent 1px),
    linear-gradient(90deg,rgba(255,255,255,.012) 1px,transparent 1px)!important;
  background-size:34px 34px!important;
  mask-image:linear-gradient(90deg,#000,rgba(0,0,0,.2) 72%,transparent)!important;
}

.syshealth__layout{
  position:relative!important;
  z-index:2!important;
  display:grid!important;
  grid-template-columns:22% 50% 28%!important;
  direction:ltr!important;
  height:100%!important;
  gap:10px!important;
  padding:11px!important;
}
.syshealth__layout>*{direction:rtl!important;min-width:0!important}

.syshealth__zone-left{
  position:relative!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:center!important;
  gap:0!important;
  padding:12px 13px!important;
  border-radius:13px!important;
  border:1px solid rgba(215,173,81,.10)!important;
  border-right:1px solid rgba(215,173,81,.10)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.032),rgba(255,255,255,.012))!important;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.02)!important;
}
.syshealth__head{
  display:flex!important;
  flex-direction:column!important;
  align-items:stretch!important;
  gap:8px!important;
}
.syshealth__title{
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  margin:0!important;
  font-size:13.5px!important;
  line-height:1.25!important;
  color:#f8f8f6!important;
  font-weight:900!important;
  letter-spacing:-.01em!important;
}
.syshealth__title .ico{
  width:34px!important;
  height:34px!important;
  min-width:34px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:10px!important;
  color:#d8ae53!important;
  background:linear-gradient(145deg,rgba(215,173,81,.18),rgba(215,173,81,.05))!important;
  border:1px solid rgba(215,173,81,.25)!important;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.05),0 8px 18px rgba(0,0,0,.16)!important;
}
.syshealth__title small{
  display:block!important;
  margin-top:3px!important;
  font-size:9px!important;
  line-height:1.25!important;
  color:#8f9aa6!important;
  font-weight:650!important;
}
.syshealth__status{
  width:max-content!important;
  max-width:100%!important;
  display:inline-flex!important;
  align-items:center!important;
  gap:6px!important;
  padding:5px 8px!important;
  border-radius:999px!important;
  color:#7ee7bd!important;
  font-size:9.2px!important;
  line-height:1!important;
  font-weight:850!important;
  background:rgba(18,185,120,.095)!important;
  border:1px solid rgba(18,185,120,.25)!important;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.025)!important;
}
.syshealth__status .neon-pulse-green{width:7px!important;height:7px!important;min-width:7px!important}
.syshealth__status-text{
  display:grid!important;
  gap:3px!important;
  margin-top:9px!important;
  font-size:8.6px!important;
  line-height:1.25!important;
  color:#737e89!important;
}
.syshealth__status-text p{margin:0!important}
.syshealth__status-text p:first-child{color:#aab3bc!important;font-weight:760!important}

.syshealth__zone-center{
  display:flex!important;
  align-items:stretch!important;
  min-width:0!important;
}
.syshealth__metrics{width:100%!important;height:100%!important}
.syshealth__grid{
  display:grid!important;
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:8px!important;
  height:100%!important;
}
.syshealth__metric{
  position:relative!important;
  box-sizing:border-box!important;
  height:126px!important;
  min-height:126px!important;
  padding:12px 12px 10px!important;
  border-radius:13px!important;
  overflow:hidden!important;
  display:grid!important;
  grid-template-rows:auto 1fr auto auto!important;
  align-items:center!important;
  gap:6px!important;
  background:
    linear-gradient(180deg,rgba(255,255,255,.034),transparent 35%),
    linear-gradient(160deg,#172638 0%,#111c29 68%,#0d1722 100%)!important;
  border:1px solid rgba(255,255,255,.075)!important;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.025),0 8px 18px rgba(0,0,0,.10)!important;
}
.syshealth__metric::before{
  content:""!important;
  position:absolute!important;
  inset:0 0 auto 0!important;
  height:2px!important;
  opacity:.72!important;
  background:linear-gradient(90deg,transparent 6%,#17b97b 35%,#d7ad51 78%,transparent 96%)!important;
}
.syshealth__metric label{
  font-size:9.5px!important;
  line-height:1.2!important;
  color:#9eabb8!important;
  font-weight:760!important;
  white-space:normal!important;
}
.syshealth__metric strong{
  align-self:end!important;
  margin:0!important;
  font-size:24px!important;
  line-height:1!important;
  color:#fff!important;
  font-weight:950!important;
  letter-spacing:-.035em!important;
  text-shadow:0 2px 12px rgba(0,0,0,.26)!important;
}
.syshealth__bar{
  height:5px!important;
  min-height:5px!important;
  border-radius:999px!important;
  overflow:hidden!important;
  background:#243444!important;
  box-shadow:inset 0 1px 2px rgba(0,0,0,.24)!important;
}
.syshealth__bar span{
  display:block!important;
  height:100%!important;
  border-radius:inherit!important;
  background:linear-gradient(90deg,#16bd7b 0%,#53d49f 44%,#d7ad51 100%)!important;
  box-shadow:0 0 10px rgba(22,189,123,.20)!important;
}
.syshealth__bar span.warn{background:linear-gradient(90deg,#d7ad51,#df7b37,#d54d3f)!important}
.syshealth__metric small{
  font-size:8.4px!important;
  line-height:1.2!important;
  color:#7e8995!important;
  font-weight:650!important;
  white-space:normal!important;
}

.syshealth__zone-right{
  position:relative!important;
  height:100%!important;
  min-width:0!important;
  border-radius:13px!important;
  overflow:hidden!important;
  background-image:
    linear-gradient(90deg,rgba(5,9,14,.66) 0%,rgba(5,9,14,.18) 27%,rgba(5,9,14,.02) 60%,rgba(5,9,14,.30) 100%),
    linear-gradient(180deg,rgba(0,0,0,.02),rgba(0,0,0,.22)),
    url('../assets/admin-v17-health.jpg')!important;
  background-size:cover!important;
  background-position:center 54%!important;
  background-repeat:no-repeat!important;
  border:1px solid rgba(215,173,81,.15)!important;
  box-shadow:inset 0 0 24px rgba(0,0,0,.20)!important;
}
.syshealth__zone-right::after{
  content:""!important;
  position:absolute!important;
  inset:0!important;
  pointer-events:none!important;
  background:
    radial-gradient(circle at 68% 58%,rgba(215,173,81,.13),transparent 28%),
    linear-gradient(180deg,transparent 55%,rgba(2,5,8,.25))!important;
}
.syshealth__center-scene,.syshealth__zone-right svg{display:none!important}
.syshealth__road-accent{
  position:absolute!important;
  left:0!important;
  right:0!important;
  bottom:0!important;
  z-index:3!important;
  height:3px!important;
  opacity:.76!important;
  background:linear-gradient(90deg,transparent 2%,#8c1015 17%,#d71920 46%,#d71920 73%,#7f0e13 90%,transparent 98%)!important;
  box-shadow:0 0 10px rgba(215,25,32,.20)!important;
}

@media(max-width:1600px){
  .syshealth{height:144px!important;min-height:144px!important}
  .syshealth__layout{grid-template-columns:21% 51% 28%!important;gap:8px!important;padding:10px!important}
  .syshealth__zone-left{padding:10px 11px!important}
  .syshealth__title{font-size:12.5px!important}
  .syshealth__metric{height:122px!important;min-height:122px!important;padding:11px 10px 9px!important}
  .syshealth__metric strong{font-size:22px!important}
  .syshealth__zone-right{background-position:center center!important}
}

@media(max-width:1360px){
  .syshealth{height:138px!important;min-height:138px!important}
  .syshealth__layout{grid-template-columns:23% 51% 26%!important;gap:7px!important;padding:9px!important}
  .syshealth__zone-left{padding:9px 10px!important}
  .syshealth__title{font-size:11.5px!important;gap:6px!important}
  .syshealth__title .ico{width:30px!important;height:30px!important;min-width:30px!important}
  .syshealth__title small{font-size:8px!important}
  .syshealth__status{font-size:8.2px!important;padding:4px 7px!important}
  .syshealth__status-text{font-size:7.6px!important;margin-top:7px!important}
  .syshealth__grid{gap:6px!important}
  .syshealth__metric{height:118px!important;min-height:118px!important;padding:9px 9px 8px!important;gap:5px!important}
  .syshealth__metric label{font-size:8.5px!important}
  .syshealth__metric strong{font-size:20px!important}
  .syshealth__metric small{font-size:7.5px!important}
  .syshealth__bar{height:4px!important;min-height:4px!important}
}

@media(max-width:1080px){
  .syshealth{height:auto!important;min-height:240px!important}
  .syshealth__layout{grid-template-columns:1fr 2fr!important;grid-template-areas:"left right" "center center"!important;height:auto!important}
  .syshealth__zone-left{grid-area:left!important}
  .syshealth__zone-right{grid-area:right!important;min-height:108px!important}
  .syshealth__zone-center{grid-area:center!important;min-height:120px!important}
  .syshealth__metric{height:112px!important;min-height:112px!important}
}
CSS

  FAILED_STEP=wire_runtime
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v22.2.css';"
new="import './AdminDashboard.v23.css';"
if old not in s:
    raise SystemExit('V22_2_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v23.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V23 — PREMIUM SYSTEM HEALTH" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v23-system-health-build.log 2>&1 || {
  tail -n 120 /tmp/67-v23-system-health-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V22.3"
echo "TARGET_VERSION=V23"
echo "RUNTIME_CSS=AdminDashboard.v23.css"
echo "ELEMENT=SYSTEM_HEALTH_ONLY"
echo "SYSTEM_HEALTH_PREMIUM=YES"
echo "SYSTEM_HEALTH_DESKTOP_HEIGHT=148PX"
echo "SYSTEM_HEALTH_VALUES_CHANGED=NO"
echo "SYSTEM_HEALTH_LOGIC_CHANGED=NO"
echo "KPI_V22_2_PRESERVED=YES"
echo "SESSION_V22_3_PRESERVED=YES"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "COMMAND_CENTER_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
