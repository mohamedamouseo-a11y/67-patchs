#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v24.1.css
TARGET_CSS=src/pages/AdminDashboard.v25.css
BACKUP=/tmp/67-v25-live-ops-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v25.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v25-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V25_PREMIUM_LIVE_OPERATIONS_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v25.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V25 — PREMIUM LIVE OPERATIONS" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V25
else
  grep -q "import './AdminDashboard.v24.1.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V24_1
  [ -f "$SOURCE_CSS" ] || fail V24_1_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V24.1" "$SOURCE_CSS" || fail V24_1_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V25
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v25.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v24.1.css';"
new="import './AdminDashboard.v25.css';"
if old not in s:
    raise SystemExit('V24_1_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v25_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V25 — PREMIUM LIVE OPERATIONS
   Approved preview translation over V24.1.
   Scope lock: Live Operations card ONLY.
   Preserve all notification data, event order, counters, click behavior, revenue V24.1,
   Current Operations, Transactions, Hero, Date Filter, KPI, System Health, Sidebar,
   backend, auth and business logic. */

.live-card{
  position:relative!important;
  isolation:isolate!important;
  height:286px!important;
  min-height:286px!important;
  max-height:286px!important;
  padding:12px 13px 11px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  border-radius:16px!important;
  background:
    radial-gradient(circle at 96% -8%,rgba(215,173,81,.09),transparent 32%),
    linear-gradient(180deg,#fffefa 0%,#faf6ee 100%)!important;
  border:1px solid rgba(188,132,25,.28)!important;
  box-shadow:0 12px 28px rgba(76,48,6,.065),inset 0 1px 0 rgba(255,255,255,.92)!important;
}
.live-card::before{
  content:""!important;
  position:absolute!important;
  left:18px!important;right:18px!important;top:0!important;height:2px!important;
  z-index:2!important;
  background:linear-gradient(90deg,transparent,#d7ad51 24%,#b97b16 66%,transparent)!important;
  opacity:.78!important;
  pointer-events:none!important;
}
.live-card::after{
  content:""!important;
  position:absolute!important;
  width:150px!important;height:150px!important;
  left:-72px!important;bottom:-98px!important;
  border-radius:50%!important;
  background:radial-gradient(circle,rgba(27,180,123,.08),transparent 70%)!important;
  pointer-events:none!important;
  z-index:-1!important;
}

.live-card__head{
  min-height:34px!important;
  height:34px!important;
  margin:0 0 7px!important;
  padding:0 1px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:10px!important;
  flex:0 0 34px!important;
}
.live-card__head h3{
  margin:0!important;
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
  font-size:12.5px!important;
  line-height:1!important;
  color:#171d25!important;
  font-weight:950!important;
  letter-spacing:-.018em!important;
}
.live-card__head h3 svg{
  width:16px!important;height:16px!important;
  color:#c48a22!important;
  filter:drop-shadow(0 2px 5px rgba(166,105,12,.12))!important;
}
.live-card__badge{
  min-width:24px!important;
  height:24px!important;
  padding:0 7px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  color:#8b671f!important;
  background:linear-gradient(180deg,#fff8e7,#f1e4c8)!important;
  border:1px solid rgba(184,128,24,.18)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.85)!important;
  font-size:8.5px!important;
  line-height:1!important;
  font-weight:950!important;
}

.live-card__list{
  position:relative!important;
  display:flex!important;
  flex-direction:column!important;
  gap:4px!important;
  min-height:0!important;
  flex:1 1 auto!important;
  overflow:hidden!important;
  padding:1px 0!important;
}
.live-card__list::before{
  content:""!important;
  position:absolute!important;
  right:16px!important;
  top:16px!important;
  bottom:16px!important;
  width:1px!important;
  background:linear-gradient(180deg,rgba(20,164,109,.10),rgba(215,173,81,.16),rgba(20,164,109,.08))!important;
  pointer-events:none!important;
}

.live-item{
  position:relative!important;
  z-index:1!important;
  min-height:31px!important;
  height:31px!important;
  padding:4px 7px!important;
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  border-radius:9px!important;
  overflow:hidden!important;
  background:linear-gradient(180deg,#faf6ee 0%,#f5eee2 100%)!important;
  border:1px solid rgba(185,130,29,.13)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.72)!important;
}
.live-item:hover{
  border-color:rgba(185,130,29,.24)!important;
  background:linear-gradient(180deg,#fffaf1,#f7efe3)!important;
}
.live-item__ico{
  position:relative!important;
  z-index:2!important;
  width:24px!important;
  height:24px!important;
  min-width:24px!important;
  flex:0 0 24px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:7px!important;
  color:#a77722!important;
  background:linear-gradient(145deg,#fff8e6,#efdfba)!important;
  border:1px solid rgba(180,121,19,.16)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.82)!important;
}
.live-item__ico.pay{
  color:#0f9a67!important;
  background:linear-gradient(145deg,#eefbf6,#d9f1e7)!important;
  border-color:rgba(18,165,109,.18)!important;
}
.live-item__ico.reg{
  color:#b07b20!important;
  background:linear-gradient(145deg,#fff8e8,#f3e3bf)!important;
}
.live-item__ico svg{width:13px!important;height:13px!important;stroke-width:2.1!important}
.live-item__body{
  min-width:0!important;
  flex:1!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:10px!important;
}
.live-item__body p{
  margin:0!important;
  min-width:0!important;
  flex:1!important;
  font-size:8.8px!important;
  line-height:1.25!important;
  color:#282e36!important;
  font-weight:760!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.live-item__body small,.live-item .when{
  flex:0 0 auto!important;
  margin:0!important;
  font-size:7.2px!important;
  line-height:1!important;
  color:#a19a91!important;
  white-space:nowrap!important;
}

.live-compact-summary{
  flex:0 0 auto!important;
  display:grid!important;
  grid-template-columns:1fr 1fr!important;
  gap:5px!important;
  margin:5px 0 0!important;
}
.live-compact-summary__item{
  min-height:22px!important;
  padding:4px 6px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:4px!important;
  border-radius:7px!important;
  color:#6f756f!important;
  background:rgba(248,243,233,.9)!important;
  border:1px solid rgba(185,130,29,.10)!important;
  font-size:7.4px!important;
  font-weight:800!important;
}
.live-compact-summary__item svg{color:#159a69!important;width:11px!important;height:11px!important}

.live-pending,.live-quick{
  flex:0 0 auto!important;
  display:flex!important;
  align-items:center!important;
  gap:5px!important;
  flex-wrap:nowrap!important;
  margin:5px 0 0!important;
  min-width:0!important;
}
.live-pending span,.live-quick span{
  min-width:0!important;
  height:22px!important;
  padding:0 7px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:4px!important;
  border-radius:7px!important;
  font-size:7.2px!important;
  line-height:1!important;
  font-weight:800!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.live-pending span{
  color:#8b6b2e!important;
  background:#faf4e7!important;
  border:1px solid rgba(190,135,28,.13)!important;
}
.live-pending span strong{font-weight:950!important;color:#6e5119!important}
.live-quick span{
  color:#12885f!important;
  background:#edf9f4!important;
  border:1px solid rgba(20,160,107,.14)!important;
}
.live-pending svg,.live-quick svg{width:11px!important;height:11px!important;flex:0 0 auto!important}

.live-cta{
  flex:0 0 24px!important;
  min-height:24px!important;
  height:24px!important;
  margin:5px 0 0!important;
  padding:0 9px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:8px!important;
  color:#9a6a16!important;
  background:linear-gradient(180deg,#fffaf0,#f5ead6)!important;
  border:1px solid rgba(185,128,22,.15)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.82)!important;
  font-size:7.8px!important;
  line-height:1!important;
  font-weight:900!important;
  cursor:pointer!important;
  transition:transform .15s ease,border-color .15s ease,background .15s ease!important;
}
.live-cta:hover{
  transform:translateY(-1px)!important;
  border-color:rgba(185,128,22,.30)!important;
  background:linear-gradient(180deg,#fff9e8,#f2e2c4)!important;
}

@media(max-width:1360px){
  .live-card{padding:10px 11px!important}
  .live-card__head{height:32px!important;min-height:32px!important;flex-basis:32px!important}
  .live-card__head h3{font-size:11.5px!important}
  .live-item{height:29px!important;min-height:29px!important;padding:3px 6px!important}
  .live-item__ico{width:22px!important;height:22px!important;min-width:22px!important;flex-basis:22px!important}
  .live-item__body p{font-size:8.2px!important}
  .live-item__body small{font-size:6.8px!important}
  .live-pending span,.live-quick span{height:20px!important;font-size:6.8px!important}
  .live-cta{height:22px!important;min-height:22px!important;flex-basis:22px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V25 — PREMIUM LIVE OPERATIONS" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v25.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v25-build.log 2>&1 || {
  tail -n 160 /tmp/67-v25-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V24.1"
echo "TARGET_VERSION=V25"
echo "RUNTIME_CSS=AdminDashboard.v25.css"
echo "ELEMENT=LIVE_OPERATIONS_ONLY"
echo "APPROVED_CONCEPT_TRANSLATED=YES"
echo "LIVE_OPERATIONS_PREMIUM=YES"
echo "LIVE_EVENT_ROWS_RESTYLED=YES"
echo "LIVE_NOTIFICATION_DATA_CHANGED=NO"
echo "LIVE_NOTIFICATION_LOGIC_CHANGED=NO"
echo "LIVE_CTA_BEHAVIOR_CHANGED=NO"
echo "REVENUE_V24_1_PRESERVED=YES"
echo "CURRENT_OPERATIONS_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
