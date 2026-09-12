#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V28.3
# MODULE: ADMIN DASHBOARD
# ELEMENT: SIDEBAR LUXURY ENHANCEMENT
# CURRENT APPROVED VERSION: V28.2
# BASE: V28.2
# TARGET: V28.3
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v28.2.css
TARGET_CSS=src/pages/AdminDashboard.v28.3.css
BACKUP=/tmp/67-v28.3-sidebar-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v28.3.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v28.3-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V28.3"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=SIDEBAR LUXURY ENHANCEMENT"
  echo "CURRENT_APPROVED_VERSION=V28.2"
  echo "BASE_VERSION=V28.2"
  echo "TARGET_VERSION=V28.3"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V28_3_SIDEBAR_LUXURY_ENHANCEMENT_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v28.3.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V28.3 — SIDEBAR LUXURY ENHANCEMENT" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V28_3
else
  grep -q "import './AdminDashboard.v28.2.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V28_2
  [ -f "$SOURCE_CSS" ] || fail V28_2_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V28.2 — SIDEBAR FINAL FIDELITY POLISH" "$SOURCE_CSS" || fail V28_2_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V28_3
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v28.3.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v28.2.css';"
new="import './AdminDashboard.v28.3.css';"
if old not in s:
    raise SystemExit('V28_2_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v28_3_sidebar_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V28.3 — SIDEBAR LUXURY ENHANCEMENT
   Luxury uplift over approved V28.2.
   Scope lock: SIDEBAR VISUALS ONLY.
   No navigation, route, activeTab, logout, GitHub Module, auth, backend, data or page-module changes.
   Priority: executive footer zone, Super Admin account card, premium sign-out action, richer overall luxury finish.
*/

:root{
  --v283-gold:#e6c362;
  --v283-gold-soft:#f8df92;
  --v283-gold-deep:#8f6318;
  --v283-ink:#04070b;
  --v283-panel:#0a1118;
  --v283-burgundy:#4c1016;
  --v283-burgundy-line:#8a2b33;
}

.admin-sidebar{
  background:
    radial-gradient(circle at 94% 3%,rgba(246,207,101,.23),transparent 17%),
    radial-gradient(circle at 10% 91%,rgba(184,129,33,.060),transparent 24%),
    linear-gradient(rgba(230,195,98,.022) 1px,transparent 1px),
    linear-gradient(90deg,rgba(230,195,98,.022) 1px,transparent 1px),
    linear-gradient(180deg,#03060a 0%,#071019 44%,#04070b 100%)!important;
  background-size:auto,auto,34px 34px,34px 34px,auto!important;
  border-left:1px solid rgba(242,207,118,.72)!important;
  box-shadow:
    -18px 0 48px rgba(0,0,0,.32),
    -1px 0 0 rgba(255,232,160,.14),
    inset 1px 0 rgba(255,255,255,.03),
    inset 0 0 92px rgba(216,170,55,.028)!important;
}
.admin-sidebar::before{
  left:3px!important;right:3px!important;height:2px!important;
  background:linear-gradient(90deg,transparent 0%,#7e5512 8%,#f4db85 50%,#7e5512 92%,transparent 100%)!important;
  box-shadow:0 0 24px rgba(242,201,87,.58)!important;
}
.admin-sidebar::after{
  width:250px!important;height:250px!important;
  right:-132px!important;bottom:74px!important;
  border-color:rgba(232,190,85,.22)!important;
  border-left-color:transparent!important;
  border-top-color:transparent!important;
  box-shadow:0 0 38px rgba(221,172,57,.040)!important;
}

.admin-sidebar__brand{
  border-color:rgba(240,203,105,.50)!important;
  background:
    radial-gradient(circle at 80% 6%,rgba(247,211,113,.22),transparent 30%),
    linear-gradient(180deg,rgba(255,255,255,.050),rgba(255,255,255,.010))!important;
  box-shadow:
    inset 0 1px rgba(255,255,255,.06),
    0 16px 32px rgba(0,0,0,.25),
    0 0 30px rgba(226,180,66,.085)!important;
}
.admin-sidebar__brand-text h2{
  color:#f5d87c!important;
  text-shadow:0 0 15px rgba(229,180,61,.15)!important;
}
.admin-sidebar__brand::after{
  color:rgba(233,195,92,.62)!important;
  letter-spacing:3px!important;
}

.admin-sidebar__nav-group{
  border-color:rgba(232,194,94,.13)!important;
  background:
    linear-gradient(180deg,rgba(255,255,255,.020),rgba(255,255,255,.004))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.014),0 8px 16px rgba(0,0,0,.045)!important;
}
.admin-sidebar__group-label{
  color:#d8ad46!important;
  text-shadow:0 0 10px rgba(214,167,55,.08)!important;
}
.admin-sidebar-button{
  color:#d2d7da!important;
  border-color:rgba(220,184,89,.24)!important;
  background:
    linear-gradient(180deg,rgba(17,26,35,.98),rgba(8,14,21,.99))!important;
  box-shadow:
    inset 0 1px rgba(255,255,255,.030),
    inset 0 -1px rgba(230,193,92,.025),
    0 5px 13px rgba(0,0,0,.13)!important;
}
.admin-sidebar-button::before{
  color:#d1ad4d!important;
  opacity:.90!important;
}
.admin-sidebar-button .sb-ico{
  color:#c6ad6e!important;
  border-color:rgba(225,188,92,.23)!important;
  background:linear-gradient(145deg,#151f29,#0b1219)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
.admin-sidebar-button:hover{
  color:#fff1ca!important;
  border-color:rgba(239,200,98,.48)!important;
  background:linear-gradient(180deg,rgba(44,36,22,.97),rgba(15,19,20,.99))!important;
  box-shadow:
    inset 0 1px rgba(255,246,203,.05),
    0 0 15px rgba(227,182,68,.13)!important;
}
.admin-sidebar-button.active{
  color:#fff6ca!important;
  border-color:#f4cf6b!important;
  background:
    linear-gradient(90deg,rgba(118,86,28,.74) 0%,rgba(62,46,21,.94) 58%,rgba(29,27,22,.99) 100%)!important;
  box-shadow:
    0 0 0 1px rgba(255,229,149,.34),
    0 0 20px rgba(242,198,79,.78),
    0 0 38px rgba(242,198,79,.22),
    inset 0 1px rgba(255,248,213,.24)!important;
}
.admin-sidebar-button.active .sb-ico{
  background:linear-gradient(145deg,#ffe59b,#ca922b)!important;
  border-color:#fff0b4!important;
  box-shadow:inset 0 1px #fff9d6,0 0 15px rgba(228,171,43,.36)!important;
}

/* Executive footer shell */
.admin-sidebar__footer{
  position:relative!important;
  margin-top:auto!important;
  padding:14px 8px 34px!important;
  border:1px solid rgba(237,197,91,.48)!important;
  border-radius:18px!important;
  background:
    radial-gradient(circle at 88% 14%,rgba(242,196,78,.12),transparent 31%),
    linear-gradient(180deg,rgba(25,24,20,.72),rgba(7,10,13,.97))!important;
  box-shadow:
    0 0 28px rgba(220,171,54,.085),
    inset 0 1px rgba(255,249,215,.035),
    inset 0 0 38px rgba(218,168,51,.025)!important;
  overflow:visible!important;
}
.admin-sidebar__footer::before{
  right:-13px!important;
  top:-194px!important;
  width:236px!important;
  height:188px!important;
  border-right:1px solid rgba(238,197,91,.42)!important;
  border-bottom:1px solid rgba(238,197,91,.34)!important;
  border-radius:0 0 150px 0!important;
  box-shadow:15px 13px 32px rgba(222,171,52,.060)!important;
}
.admin-sidebar__footer::after{
  content:'SIX SEVEN • EXECUTIVE CONTROL'!important;
  left:10px!important;right:10px!important;bottom:8px!important;
  color:rgba(226,183,73,.74)!important;
  font-size:6.5px!important;
  letter-spacing:1.6px!important;
  font-weight:800!important;
}

/* Super Admin executive card */
.admin-sidebar__identity{
  position:relative!important;
  min-height:68px!important;
  margin:0 0 10px!important;
  padding:10px 11px!important;
  gap:11px!important;
  border-radius:14px!important;
  border:1px solid rgba(241,202,103,.52)!important;
  background:
    radial-gradient(circle at 84% 22%,rgba(244,202,90,.16),transparent 28%),
    linear-gradient(180deg,rgba(24,29,31,.98),rgba(10,14,17,.99))!important;
  box-shadow:
    inset 0 1px rgba(255,255,255,.04),
    0 10px 22px rgba(0,0,0,.18),
    0 0 18px rgba(224,174,54,.09)!important;
  overflow:hidden!important;
}
.admin-sidebar__identity::after{
  content:'EXECUTIVE ACCESS'!important;
  position:absolute!important;
  left:12px!important;
  bottom:7px!important;
  color:rgba(229,188,87,.48)!important;
  font-size:5.7px!important;
  font-weight:900!important;
  letter-spacing:1.5px!important;
}
.admin-sidebar__identity::before{
  content:'⌄'!important;
  order:3!important;
  width:24px!important;
  height:24px!important;
  min-width:24px!important;
  display:grid!important;
  place-items:center!important;
  margin-right:auto!important;
  border-radius:50%!important;
  color:#f1c85f!important;
  background:rgba(223,178,68,.06)!important;
  border:1px solid rgba(227,185,79,.19)!important;
  font-size:14px!important;
  line-height:1!important;
}
.admin-sidebar__identity-avatar{
  width:44px!important;
  height:44px!important;
  min-width:44px!important;
  border-radius:50%!important;
  color:#211607!important;
  background:linear-gradient(145deg,#ffe398 0%,#dca43a 54%,#a86b16 100%)!important;
  border:1px solid #ffe9aa!important;
  box-shadow:
    0 0 0 3px rgba(225,176,58,.08),
    0 0 18px rgba(225,176,58,.32),
    inset 0 1px #fff7d0!important;
  font-size:10px!important;
  font-weight:950!important;
}
.admin-sidebar__identity-info{
  min-width:0!important;
  padding-bottom:8px!important;
}
.admin-sidebar__identity-info::before{
  content:'SYSTEM OWNER'!important;
  display:block!important;
  margin-bottom:2px!important;
  color:#d7ac49!important;
  font-size:5.8px!important;
  font-weight:900!important;
  letter-spacing:1.2px!important;
}
.admin-sidebar__identity-info strong{
  color:#fff8df!important;
  font-size:10.4px!important;
  font-weight:950!important;
  text-shadow:0 0 10px rgba(240,202,103,.10)!important;
}
.admin-sidebar__identity-info small{
  color:#9da4aa!important;
  font-size:7.7px!important;
}

/* Premium secure sign-out action */
.admin-sidebar-button--logout{
  position:relative!important;
  min-height:50px!important;
  height:50px!important;
  margin:0!important;
  padding:0 44px 0 12px!important;
  border-radius:12px!important;
  color:#f0b7b9!important;
  background:
    radial-gradient(circle at 88% 50%,rgba(178,48,58,.16),transparent 26%),
    linear-gradient(180deg,rgba(72,17,23,.58),rgba(28,8,12,.82))!important;
  border:1px solid rgba(180,55,64,.48)!important;
  box-shadow:
    inset 0 1px rgba(255,208,210,.035),
    0 8px 18px rgba(0,0,0,.16),
    0 0 16px rgba(125,27,35,.10)!important;
  font-size:10px!important;
  font-weight:900!important;
}
.admin-sidebar-button--logout::before{
  content:''!important;
  display:none!important;
}
.admin-sidebar-button--logout::after{
  content:'SECURE SIGN OUT'!important;
  display:block!important;
  position:absolute!important;
  left:12px!important;
  bottom:5px!important;
  color:rgba(207,109,114,.46)!important;
  font-size:5.4px!important;
  font-weight:900!important;
  letter-spacing:1px!important;
}
.admin-sidebar-button--logout .sb-ico{
  right:7px!important;
  top:7px!important;
  width:36px!important;
  height:36px!important;
  min-width:36px!important;
  padding:8px!important;
  border-radius:10px!important;
  color:#f0666c!important;
  background:linear-gradient(145deg,rgba(114,29,35,.45),rgba(48,12,17,.72))!important;
  border:1px solid rgba(200,69,77,.38)!important;
  box-shadow:inset 0 1px rgba(255,180,184,.04)!important;
}
.admin-sidebar-button--logout span{
  padding-bottom:7px!important;
}
.admin-sidebar-button--logout:hover{
  color:#ffd8d9!important;
  border-color:rgba(221,76,84,.68)!important;
  background:
    radial-gradient(circle at 88% 50%,rgba(211,55,65,.22),transparent 28%),
    linear-gradient(180deg,rgba(91,21,29,.72),rgba(34,8,13,.92))!important;
  box-shadow:
    inset 0 1px rgba(255,219,220,.05),
    0 0 20px rgba(177,43,51,.18)!important;
}

@media(max-width:1500px){
  .admin-sidebar__identity{min-height:64px!important}
  .admin-sidebar__identity-avatar{width:41px!important;height:41px!important;min-width:41px!important}
  .admin-sidebar-button--logout{height:47px!important;min-height:47px!important}
  .admin-sidebar-button--logout .sb-ico{width:33px!important;height:33px!important;min-width:33px!important;top:7px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V28.3 — SIDEBAR LUXURY ENHANCEMENT" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v28.3.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v28.3-build.log 2>&1 || {
  tail -n 180 /tmp/67-v28.3-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V28.3"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=SIDEBAR LUXURY ENHANCEMENT"
echo "CURRENT_APPROVED_VERSION=V28.2"
echo "BASE_VERSION=V28.2"
echo "TARGET_VERSION=V28.3"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v28.3.css"
echo "ELEMENT=SIDEBAR_ONLY"
echo "SUPER_ADMIN_PANEL_REDESIGNED=YES"
echo "LOGOUT_PANEL_REDESIGNED=YES"
echo "SIDEBAR_PREMIUM_LEVEL_UPGRADED=YES"
echo "FOOTER_EXECUTIVE_PANEL_UPGRADED=YES"
echo "LUXURY_GOLD_AMBIENCE_UPGRADED=YES"
echo "DECORATIVE_FRAME_REFINED=YES"
echo "DECORATIVE_CURVES_REFINED=YES"
echo "ACTIVE_ROW_PRESERVED=YES"
echo "INACTIVE_ROWS_PREMIUM_UPGRADED=YES"
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
