#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V29
# MODULE: ADMIN DASHBOARD
# ELEMENT: MAIN DASHBOARD HERO — CINEMATIC RECOMPOSITION
# CURRENT APPROVED VERSION: V28.3
# BASE: V28.3
# TARGET: V29
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v28.3.css
TARGET_CSS=src/pages/AdminDashboard.v29.css
BACKUP=/tmp/67-v29-hero-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v29.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v29-hero-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V29"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=MAIN DASHBOARD HERO — CINEMATIC RECOMPOSITION"
  echo "CURRENT_APPROVED_VERSION=V28.3"
  echo "BASE_VERSION=V28.3"
  echo "TARGET_VERSION=V29"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V29_HERO_CINEMATIC_RECOMPOSITION_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v29.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V29 — MAIN HERO CINEMATIC RECOMPOSITION" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V29
else
  grep -q "import './AdminDashboard.v28.3.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V28_3
  [ -f "$SOURCE_CSS" ] || fail V28_3_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V28.3 — SIDEBAR LUXURY ENHANCEMENT" "$SOURCE_CSS" || fail V28_3_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V29
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v29.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v28.3.css';"
new="import './AdminDashboard.v29.css';"
if old not in s:
    raise SystemExit('V28_3_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v29_hero_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29 — MAIN HERO CINEMATIC RECOMPOSITION
   Scope lock: MAIN OVERVIEW HERO + DATE CONTROL VISUALS ONLY.
   Goal: remove the stretched/banner feeling and rebuild the hero as a cinematic premium composition.
   Preserve all date filtering logic, presets, refresh/export actions, hero text, data, sidebar, KPI and all other modules.
*/

.ov-header{
  position:relative!important;
  height:304px!important;
  min-height:304px!important;
  max-height:304px!important;
  border-radius:22px!important;
  overflow:hidden!important;
  isolation:isolate!important;
  border:1px solid rgba(229,190,89,.46)!important;
  background:#05080c!important;
  box-shadow:0 22px 50px rgba(0,0,0,.24),inset 0 1px rgba(255,255,255,.035)!important;
}

/* Preserve source image proportions: absolutely no 100% 100% stretching. */
.ov-header__motif{
  inset:-4%!important;
  width:108%!important;
  height:108%!important;
  background-image:url('../assets/admin-v17-hero.jpg')!important;
  background-size:cover!important;
  background-position:56% 54%!important;
  background-repeat:no-repeat!important;
  transform:scale(1.035)!important;
  transform-origin:center center!important;
  filter:saturate(.93) contrast(1.03) brightness(.91)!important;
}

.ov-header::after{
  content:""!important;
  position:absolute!important;
  inset:0!important;
  z-index:3!important;
  pointer-events:none!important;
  background:
    linear-gradient(90deg,rgba(3,6,10,.90) 0%,rgba(3,6,10,.56) 20%,rgba(3,6,10,.08) 43%,rgba(3,6,10,.04) 58%,rgba(3,6,10,.44) 79%,rgba(3,6,10,.88) 100%),
    radial-gradient(circle at 61% 56%,rgba(230,183,75,.12),transparent 29%),
    linear-gradient(180deg,rgba(0,0,0,.03),transparent 48%,rgba(0,0,0,.46))!important;
}
.ov-header::before{
  content:""!important;
  position:absolute!important;
  left:0!important;right:0!important;bottom:0!important;
  height:3px!important;
  z-index:10!important;
  background:linear-gradient(90deg,transparent 2%,#8f1217 15%,#d71920 36%,#d71920 69%,#8f1217 87%,transparent 98%)!important;
  box-shadow:0 0 15px rgba(215,25,32,.42)!important;
}

.ov-header__layout{
  position:relative!important;
  width:100%!important;
  height:100%!important;
  z-index:4!important;
  display:block!important;
}

/* Left-side primary message becomes a deliberate editorial block. */
.ov-header__copy-left{
  position:absolute!important;
  left:38px!important;
  top:48px!important;
  width:min(36%,470px)!important;
  max-width:470px!important;
  z-index:8!important;
  text-align:right!important;
  direction:rtl!important;
  padding:0!important;
}
.ov-header__copy-left::before{
  content:""!important;
  position:absolute!important;
  right:-17px!important;
  top:4px!important;
  width:3px!important;
  height:88px!important;
  border-radius:99px!important;
  background:linear-gradient(180deg,#f0cf75,#9d6c18)!important;
  box-shadow:0 0 14px rgba(226,180,68,.28)!important;
}
.ov-header__copy-left .ov-header__eyebrow{
  display:block!important;
  margin-bottom:8px!important;
  color:#e7c66d!important;
  font-size:10px!important;
  font-weight:850!important;
  letter-spacing:.02em!important;
  text-shadow:0 2px 10px rgba(0,0,0,.52)!important;
}
.ov-header__copy-left h1{
  margin:0 0 8px!important;
  max-width:430px!important;
  color:#fff!important;
  font-size:35px!important;
  line-height:1.08!important;
  font-weight:950!important;
  letter-spacing:-.035em!important;
  text-shadow:0 4px 18px rgba(0,0,0,.68)!important;
}
.ov-header__copy-left h1 span{
  color:#efd176!important;
  display:block!important;
}
.ov-header__copy-left p{
  margin:0!important;
  max-width:410px!important;
  color:rgba(255,255,255,.76)!important;
  font-size:10.5px!important;
  line-height:1.7!important;
  text-shadow:0 2px 10px rgba(0,0,0,.58)!important;
}

/* Right-side secondary message is lighter and no longer competes with the car. */
.ov-header__copy-right{
  position:absolute!important;
  right:34px!important;
  top:38px!important;
  width:280px!important;
  z-index:8!important;
  text-align:right!important;
  direction:rtl!important;
  padding:13px 15px!important;
  border-right:1px solid rgba(229,191,91,.36)!important;
  background:linear-gradient(90deg,transparent,rgba(3,6,10,.24))!important;
}
.ov-header__copy-right>span{
  display:block!important;
  margin-bottom:3px!important;
  color:#d5d0c5!important;
  font-size:10px!important;
  font-weight:750!important;
}
.ov-header__copy-right>strong{
  display:block!important;
  color:#f0ce71!important;
  font-size:19px!important;
  line-height:1.15!important;
  font-weight:950!important;
  text-shadow:0 3px 15px rgba(0,0,0,.62)!important;
}
.ov-header__copy-right>small{
  display:flex!important;
  align-items:center!important;
  justify-content:flex-start!important;
  gap:5px!important;
  margin-top:7px!important;
  color:rgba(255,255,255,.56)!important;
  font-size:7.2px!important;
  letter-spacing:.08em!important;
}

/* Floating date dock: compact, centered, detached from the image edges. */
.ov-header__toolbar-top{
  position:absolute!important;
  left:32px!important;
  right:auto!important;
  bottom:18px!important;
  top:auto!important;
  width:min(910px,66%)!important;
  z-index:12!important;
  padding:0!important;
}
.executive-date-shell{
  width:100%!important;
  min-height:54px!important;
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  padding:6px!important;
  border-radius:15px!important;
  background:linear-gradient(180deg,rgba(10,14,18,.92),rgba(5,8,11,.96))!important;
  border:1px solid rgba(231,192,91,.46)!important;
  box-shadow:0 15px 34px rgba(0,0,0,.36),inset 0 1px rgba(255,255,255,.035),0 0 18px rgba(210,166,55,.06)!important;
  backdrop-filter:blur(14px)!important;
}
.executive-date-display{
  min-width:390px!important;
  height:42px!important;
  padding:0 12px!important;
  border-radius:10px!important;
  color:#eee7d6!important;
  background:linear-gradient(180deg,rgba(91,73,37,.43),rgba(42,35,23,.54))!important;
  border:1px solid rgba(235,196,96,.44)!important;
  box-shadow:inset 0 1px rgba(255,244,205,.05)!important;
}
.executive-date-display__icon{
  width:32px!important;height:32px!important;min-width:32px!important;
  border-radius:8px!important;
  color:#f0c95f!important;
  background:rgba(223,178,67,.10)!important;
  border:1px solid rgba(232,190,83,.28)!important;
}
.executive-date-display__copy small{font-size:7px!important;color:#a8a095!important}
.executive-date-display__copy strong{font-size:10px!important;color:#f4efe2!important}
.executive-date-presets{display:flex!important;gap:5px!important}
.executive-date-preset{
  height:42px!important;
  min-width:74px!important;
  padding:0 12px!important;
  border-radius:9px!important;
  font-size:8.5px!important;
  font-weight:850!important;
  color:#b8bcc0!important;
  background:rgba(255,255,255,.026)!important;
  border:1px solid rgba(255,255,255,.08)!important;
}
.executive-date-preset.active{
  color:#ffe9a3!important;
  background:linear-gradient(180deg,rgba(132,94,27,.64),rgba(69,52,24,.82))!important;
  border-color:rgba(240,198,87,.72)!important;
  box-shadow:0 0 14px rgba(229,182,67,.15),inset 0 1px rgba(255,243,193,.07)!important;
}
.executive-date-actions{display:flex!important;gap:5px!important;margin-right:auto!important}
.executive-date-action{
  width:42px!important;height:42px!important;min-width:42px!important;
  border-radius:9px!important;
  color:#aeb5bb!important;
  background:rgba(255,255,255,.026)!important;
  border:1px solid rgba(255,255,255,.08)!important;
}
.executive-date-action:hover{color:#e8c66d!important;border-color:rgba(226,184,76,.35)!important;background:rgba(220,173,61,.08)!important}

/* Keep popover anchored to the new compact dock. */
.executive-date-popover{
  bottom:64px!important;
  top:auto!important;
  left:0!important;
  right:auto!important;
  width:min(690px,92vw)!important;
  border-color:rgba(222,181,76,.30)!important;
  box-shadow:0 20px 46px rgba(0,0,0,.34)!important;
}

@media(max-width:1500px){
  .ov-header{height:286px!important;min-height:286px!important;max-height:286px!important}
  .ov-header__copy-left{left:28px!important;top:43px!important;width:38%!important}
  .ov-header__copy-left h1{font-size:31px!important}
  .ov-header__copy-right{right:26px!important;top:34px!important;width:240px!important}
  .ov-header__toolbar-top{left:26px!important;width:min(820px,70%)!important}
  .executive-date-display{min-width:330px!important}
  .executive-date-preset{min-width:64px!important;padding:0 9px!important}
}

@media(max-width:1180px){
  .ov-header{height:270px!important;min-height:270px!important;max-height:270px!important}
  .ov-header__motif{background-position:58% 52%!important}
  .ov-header__copy-left{left:22px!important;top:38px!important;width:43%!important}
  .ov-header__copy-left h1{font-size:27px!important}
  .ov-header__copy-left p{font-size:9.5px!important}
  .ov-header__copy-right{right:20px!important;width:215px!important}
  .ov-header__copy-right>strong{font-size:17px!important}
  .ov-header__toolbar-top{left:20px!important;right:20px!important;width:auto!important}
  .executive-date-display{min-width:290px!important}
  .executive-date-preset{min-width:58px!important;font-size:8px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V29 — MAIN HERO CINEMATIC RECOMPOSITION" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v29.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v29-hero-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29-hero-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=MAIN DASHBOARD HERO — CINEMATIC RECOMPOSITION"
echo "CURRENT_APPROVED_VERSION=V28.3"
echo "BASE_VERSION=V28.3"
echo "TARGET_VERSION=V29"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v29.css"
echo "ELEMENT=HERO_AND_DATE_VISUALS_ONLY"
echo "HERO_STRETCH_CORRECTED=YES"
echo "HERO_IMAGE_ASPECT_PRESERVED=YES"
echo "HERO_CINEMATIC_CROP=YES"
echo "HERO_PRIMARY_COPY_RECOMPOSED=YES"
echo "HERO_SECONDARY_COPY_RECOMPOSED=YES"
echo "DATE_DOCK_COMPACTED=YES"
echo "DATE_LOGIC_CHANGED=NO"
echo "DATE_PRESET_BEHAVIOR_CHANGED=NO"
echo "DATE_CUSTOM_RANGE_BEHAVIOR_CHANGED=NO"
echo "REFRESH_ACTION_CHANGED=NO"
echo "EXPORT_ACTION_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "REVENUE_CHANGED=NO"
echo "LIVE_OPERATIONS_CHANGED=NO"
echo "CURRENT_OPERATIONS_CHANGED=NO"
echo "FINANCIAL_LEDGER_CHANGED=NO"
echo "SELLERS_TABLE_CHANGED=NO"
echo "CUSTOMERS_TABLE_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
