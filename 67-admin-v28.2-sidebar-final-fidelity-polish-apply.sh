#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V28.2
# MODULE: ADMIN DASHBOARD
# ELEMENT: LUXURY SIDEBAR — FINAL REFERENCE FIDELITY POLISH
# CURRENT APPROVED VERSION: V27.1
# BASE: V28.1
# TARGET: V28.2
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v28.1.css
TARGET_CSS=src/pages/AdminDashboard.v28.2.css
BACKUP=/tmp/67-v28.2-sidebar-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v28.2.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v28.2-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V28.2"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=LUXURY SIDEBAR — FINAL REFERENCE FIDELITY POLISH"
  echo "CURRENT_APPROVED_VERSION=V27.1"
  echo "BASE_VERSION=V28.1"
  echo "TARGET_VERSION=V28.2"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V28_2_FINAL_FIDELITY_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v28.2.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V28.2 — SIDEBAR FINAL FIDELITY POLISH" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V28_2
else
  grep -q "import './AdminDashboard.v28.1.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V28_1
  [ -f "$SOURCE_CSS" ] || fail V28_1_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V28.1 — SIDEBAR REFERENCE FIDELITY" "$SOURCE_CSS" || fail V28_1_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V28_2
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v28.2.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v28.1.css';"
new="import './AdminDashboard.v28.2.css';"
if old not in s:
    raise SystemExit('V28_1_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v28_2_sidebar_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V28.2 — SIDEBAR FINAL FIDELITY POLISH
   Final micro-polish after direct V28.1 vs approved reference comparison.
   Scope lock: SIDEBAR VISUALS ONLY.
   No structure, text, route, activeTab, logout, GitHub Module, auth, backend or data changes.
*/

:root{
  --v28-sidebar:286px!important;
  --v282-gold:#e2bb59;
  --v282-gold-soft:#f4d77d;
  --v282-gold-deep:#9a691b;
  --v282-line:rgba(226,187,89,.24);
}

.admin-sidebar{
  width:var(--v28-sidebar)!important;
  min-width:var(--v28-sidebar)!important;
  padding:12px 11px 11px!important;
  background:
    radial-gradient(circle at 92% 4%,rgba(239,199,96,.20),transparent 18%),
    radial-gradient(circle at 16% 84%,rgba(192,137,38,.045),transparent 25%),
    linear-gradient(rgba(226,187,89,.020) 1px,transparent 1px),
    linear-gradient(90deg,rgba(226,187,89,.020) 1px,transparent 1px),
    linear-gradient(180deg,#03070b 0%,#07101a 48%,#04070b 100%)!important;
  background-size:auto,auto,34px 34px,34px 34px,auto!important;
  border-left:1px solid rgba(232,196,101,.62)!important;
  box-shadow:
    -12px 0 34px rgba(0,0,0,.26),
    -1px 0 0 rgba(246,214,126,.12),
    inset 1px 0 rgba(255,255,255,.025),
    inset 0 0 78px rgba(210,166,56,.022)!important;
}
.admin-sidebar::before{
  left:5px!important;right:5px!important;height:2px!important;
  background:linear-gradient(90deg,transparent 0%,#8d6117 10%,#f2d477 50%,#8d6117 90%,transparent 100%)!important;
  box-shadow:0 0 21px rgba(235,193,78,.50)!important;
}
.admin-sidebar::after{
  content:""!important;
  position:absolute!important;
  width:236px!important;
  height:236px!important;
  right:-126px!important;
  bottom:86px!important;
  top:auto!important;
  border:1px solid rgba(224,182,75,.16)!important;
  border-left-color:transparent!important;
  border-top-color:transparent!important;
  border-radius:50%!important;
  background:transparent!important;
  box-shadow:0 0 28px rgba(211,164,54,.028)!important;
  pointer-events:none!important;
  z-index:-1!important;
}

.admin-sidebar__brand{
  min-height:142px!important;
  margin:0 0 6px!important;
  padding:15px 14px 17px!important;
  border-radius:19px!important;
  border-color:rgba(231,193,93,.42)!important;
  background:
    radial-gradient(circle at 78% 5%,rgba(243,204,104,.19),transparent 28%),
    linear-gradient(180deg,rgba(255,255,255,.042),rgba(255,255,255,.010))!important;
  box-shadow:
    inset 0 1px rgba(255,255,255,.05),
    0 14px 29px rgba(0,0,0,.22),
    0 0 27px rgba(218,174,68,.07)!important;
}
.admin-sidebar__official-logo{
  width:168px!important;
  max-width:168px!important;
  max-height:74px!important;
}
.admin-sidebar__brand-text h2{
  color:#f2d16f!important;
  text-shadow:0 0 14px rgba(220,174,62,.10)!important;
}
.admin-sidebar__brand::after{
  color:rgba(224,185,82,.55)!important;
  border-top-color:rgba(224,185,82,.10)!important;
}

.admin-sidebar__nav-group{
  margin:0 0 5px!important;
  padding:8px 6px 7px!important;
  border-radius:15px!important;
  border:1px solid rgba(222,184,83,.095)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.016),rgba(255,255,255,.004))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.012)!important;
}
.admin-sidebar__group-label{
  margin:0 7px 6px!important;
  padding:0 0 4px!important;
  color:#d0a541!important;
  font-size:8px!important;
  font-weight:900!important;
  opacity:.94!important;
}

.admin-sidebar-button{
  min-height:43px!important;
  height:43px!important;
  margin:4px 0!important;
  padding:0 36px 0 28px!important;
  border-radius:10px!important;
  color:#cbd1d5!important;
  background:linear-gradient(180deg,rgba(16,24,33,.96),rgba(8,14,21,.98))!important;
  border:1px solid rgba(200,167,82,.20)!important;
  box-shadow:
    inset 0 1px rgba(255,255,255,.024),
    0 5px 12px rgba(0,0,0,.11)!important;
}
.admin-sidebar-button::before{
  left:9px!important;
  color:#c6a348!important;
  opacity:.82!important;
  font-size:18px!important;
}
.admin-sidebar-button .sb-ico{
  right:6px!important;
  top:5px!important;
  width:31px!important;height:31px!important;min-width:31px!important;
  color:#b9a166!important;
  background:linear-gradient(145deg,#121b24,#0b1219)!important;
  border:1px solid rgba(217,181,84,.18)!important;
}
.admin-sidebar-button span{
  color:inherit!important;
  text-overflow:clip!important;
}
.admin-sidebar-button:hover{
  color:#f0e7cf!important;
  border-color:rgba(225,187,88,.38)!important;
  background:linear-gradient(180deg,rgba(34,31,23,.96),rgba(14,18,20,.98))!important;
  box-shadow:inset 0 1px rgba(255,246,207,.035),0 0 12px rgba(220,177,71,.09)!important;
}
.admin-sidebar-button:hover .sb-ico{
  color:#dfbb58!important;
  border-color:rgba(227,189,88,.34)!important;
}

.admin-sidebar-button.active{
  color:#fff4c2!important;
  border-color:#efc65f!important;
  background:
    linear-gradient(90deg,rgba(107,79,28,.66) 0%,rgba(53,41,22,.90) 58%,rgba(30,28,23,.97) 100%)!important;
  box-shadow:
    0 0 0 1px rgba(255,224,135,.30),
    0 0 18px rgba(237,193,76,.72),
    0 0 34px rgba(237,193,76,.20),
    inset 0 1px rgba(255,246,202,.20)!important;
}
.admin-sidebar-button.active::before{
  color:#ffd875!important;
  opacity:1!important;
  text-shadow:0 0 9px rgba(242,199,87,.55)!important;
}
.admin-sidebar-button.active .sb-ico{
  color:#241808!important;
  background:linear-gradient(145deg,#f8df8b,#c9912a)!important;
  border-color:#ffe8a1!important;
  box-shadow:inset 0 1px #fff7ca,0 0 13px rgba(221,166,49,.30)!important;
}

.admin-sidebar__footer{
  padding:10px 6px 28px!important;
  border-color:rgba(225,184,78,.34)!important;
  background:
    radial-gradient(circle at 86% 20%,rgba(221,174,63,.07),transparent 34%),
    linear-gradient(180deg,rgba(217,182,94,.035),rgba(255,255,255,.007))!important;
  box-shadow:0 0 22px rgba(215,169,57,.055),inset 0 1px rgba(255,255,255,.018)!important;
}
.admin-sidebar__footer::before{
  right:-16px!important;
  top:-178px!important;
  width:226px!important;
  height:170px!important;
  border-right-color:rgba(229,188,80,.34)!important;
  border-bottom-color:rgba(229,188,80,.29)!important;
  border-radius:0 0 142px 0!important;
  box-shadow:13px 12px 28px rgba(220,174,65,.045)!important;
}
.admin-sidebar__footer::after{
  color:rgba(215,174,68,.78)!important;
  font-size:6.8px!important;
}
.admin-sidebar__identity{
  min-height:54px!important;
  margin-bottom:7px!important;
  border-color:rgba(222,181,75,.40)!important;
  background:linear-gradient(180deg,rgba(22,26,27,.94),rgba(10,13,16,.98))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.028),0 0 12px rgba(215,168,55,.045)!important;
}
.admin-sidebar__identity-avatar{
  width:38px!important;height:38px!important;min-width:38px!important;
  box-shadow:0 0 15px rgba(218,166,43,.24)!important;
}
.admin-sidebar-button--logout{
  min-height:41px!important;
  height:41px!important;
  color:#dfa2a5!important;
  border-color:rgba(181,50,57,.34)!important;
  background:linear-gradient(180deg,rgba(48,13,17,.31),rgba(24,8,10,.39))!important;
}

.admin-exec>div[style*="marginRight"]{
  margin-right:300px!important;
}

@media(max-width:1500px){
  :root{--v28-sidebar:278px!important}
  .admin-sidebar{padding-left:10px!important;padding-right:10px!important}
  .admin-sidebar__brand{min-height:132px!important}
  .admin-sidebar__official-logo{width:158px!important}
  .admin-sidebar-button{height:41px!important;min-height:41px!important;font-size:10px!important}
  .admin-exec>div[style*="marginRight"]{margin-right:291px!important}
}

@media(max-width:1180px){
  :root{--v28-sidebar:264px!important}
  .admin-sidebar__brand{min-height:120px!important}
  .admin-sidebar__official-logo{width:148px!important}
  .admin-sidebar-button{height:39px!important;min-height:39px!important;font-size:9.4px!important}
  .admin-exec>div[style*="marginRight"]{margin-right:276px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V28.2 — SIDEBAR FINAL FIDELITY POLISH" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v28.2.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v28.2-build.log 2>&1 || {
  tail -n 180 /tmp/67-v28.2-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V28.2"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=LUXURY SIDEBAR — FINAL REFERENCE FIDELITY POLISH"
echo "CURRENT_APPROVED_VERSION=V27.1"
echo "BASE_VERSION=V28.1"
echo "TARGET_VERSION=V28.2"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v28.2.css"
echo "ELEMENT=SIDEBAR_ONLY"
echo "FINAL_FIDELITY_POLISH=YES"
echo "SIDEBAR_WIDTH_DESKTOP=286PX"
echo "MAIN_CONTENT_MARGIN_DESKTOP=300PX"
echo "INACTIVE_COMMAND_ROWS_GOLD_PRESENCE=UPGRADED"
echo "ACTIVE_GOLD_GLOW_REFINED=YES"
echo "OUTER_FRAME_REFINED=YES"
echo "DECORATIVE_CURVES_REFINED=YES"
echo "ACCOUNT_PANEL_REFINED=YES"
echo "LOGOUT_PANEL_REFINED=YES"
echo "NAVIGATION_LOGIC_CHANGED=NO"
echo "TAB_BEHAVIOR_CHANGED=NO"
echo "BACK_BUTTON_BEHAVIOR_CHANGED=NO"
echo "LOGOUT_BEHAVIOR_CHANGED=NO"
echo "GITHUB_MODULE_BEHAVIOR_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
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
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"