#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V28.1
# MODULE: ADMIN DASHBOARD
# ELEMENT: LUXURY SIDEBAR — REFERENCE FIDELITY FIX
# CURRENT APPROVED VERSION: V27.1
# BASE: V28
# TARGET: V28.1
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v28.css
TARGET_CSS=src/pages/AdminDashboard.v28.1.css
BACKUP=/tmp/67-v28.1-sidebar-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v28.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v28.1-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V28.1"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=LUXURY SIDEBAR — REFERENCE FIDELITY FIX"
  echo "CURRENT_APPROVED_VERSION=V27.1"
  echo "BASE_VERSION=V28"
  echo "TARGET_VERSION=V28.1"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V28_1_REFERENCE_FIDELITY_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v28.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V28.1 — SIDEBAR REFERENCE FIDELITY" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V28_1
else
  grep -q "import './AdminDashboard.v28.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V28
  [ -f "$SOURCE_CSS" ] || fail V28_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V28 — LUXURY SIDEBAR" "$SOURCE_CSS" || fail V28_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V28_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v28.1.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v28.css';"
new="import './AdminDashboard.v28.1.css';"
if old not in s:
    raise SystemExit('V28_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v28_1_sidebar_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V28.1 — SIDEBAR REFERENCE FIDELITY
   Correction over V28 after direct visual comparison against the approved sidebar reference.
   Scope lock: SIDEBAR ONLY.
   Preserve all labels, routes, activeTab logic, back button, logout behavior, GitHub Module,
   page modules, auth, data and backend exactly as V28/V27.1.
*/

.admin-sidebar{
  background:
    radial-gradient(circle at 95% 2%,rgba(238,199,103,.18),transparent 16%),
    radial-gradient(circle at 12% 86%,rgba(160,25,31,.055),transparent 20%),
    linear-gradient(rgba(217,182,94,.018) 1px,transparent 1px),
    linear-gradient(90deg,rgba(217,182,94,.018) 1px,transparent 1px),
    linear-gradient(180deg,#04080d 0%,#07111b 52%,#05080d 100%)!important;
  background-size:auto,auto,34px 34px,34px 34px,auto!important;
  border-left:1px solid rgba(228,191,91,.48)!important;
  box-shadow:-16px 0 34px rgba(0,0,0,.24),inset 1px 0 rgba(255,255,255,.025),inset 0 0 70px rgba(217,182,94,.018)!important;
}
.admin-sidebar::before{
  height:2px!important;
  left:8px!important;right:8px!important;
  background:linear-gradient(90deg,transparent 0%,#8e651c 12%,#f0d67d 50%,#8e651c 88%,transparent 100%)!important;
  box-shadow:0 0 18px rgba(232,193,89,.46)!important;
}

.admin-sidebar__brand{
  min-height:148px!important;
  margin:0 1px 5px!important;
  padding:17px 16px 18px!important;
  border-radius:20px!important;
  border:1px solid rgba(225,188,88,.34)!important;
  background:
    radial-gradient(circle at 77% 8%,rgba(242,202,95,.16),transparent 26%),
    linear-gradient(180deg,rgba(255,255,255,.045),rgba(255,255,255,.012))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.045),0 15px 30px rgba(0,0,0,.23),0 0 24px rgba(211,169,68,.055)!important;
}
.admin-sidebar__official-logo{
  width:176px!important;
  max-width:176px!important;
  max-height:78px!important;
  filter:drop-shadow(0 8px 18px rgba(0,0,0,.46)) brightness(1.07)!important;
}
.admin-sidebar__brand-text h2{font-size:15px!important;color:#f1d177!important}
.admin-sidebar__brand-text span{font-size:8.6px!important;color:#98a0a5!important}
.admin-sidebar__brand::after{
  color:rgba(222,185,86,.47)!important;
  letter-spacing:2.8px!important;
  font-size:6.4px!important;
  height:19px!important;
}

.admin-sidebar__nav-group{
  margin:0 1px 3px!important;
  padding:9px 7px 8px!important;
  border-radius:16px!important;
  border:1px solid rgba(255,255,255,.045)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.018),rgba(255,255,255,.005))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.012)!important;
}
.admin-sidebar__group-label{
  margin:0 7px 7px!important;
  padding:0 0 5px!important;
  color:#c59b3f!important;
  font-size:8.2px!important;
  letter-spacing:.04em!important;
  border-bottom:0!important;
  opacity:.88!important;
}

.admin-sidebar-button{
  min-height:45px!important;
  height:45px!important;
  margin:5px 0!important;
  padding:0 39px 0 10px!important;
  gap:9px!important;
  border-radius:10px!important;
  color:#d2d7dc!important;
  background:linear-gradient(180deg,rgba(15,24,34,.92),rgba(8,15,23,.96))!important;
  border:1px solid rgba(135,153,166,.26)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025),0 5px 12px rgba(0,0,0,.10)!important;
}
.admin-sidebar-button::before{
  content:'‹'!important;
  position:absolute!important;
  left:11px!important;
  top:50%!important;
  transform:translateY(-51%)!important;
  color:#8e9aa4!important;
  font-size:19px!important;
  font-family:Arial,sans-serif!important;
  font-weight:400!important;
  line-height:1!important;
}
.admin-sidebar-button::after{display:none!important}
.admin-sidebar-button .sb-ico{
  position:absolute!important;
  right:7px!important;
  top:6px!important;
  width:31px!important;
  height:31px!important;
  min-width:31px!important;
  padding:6px!important;
  border-radius:9px!important;
  color:#a8b0b7!important;
  background:linear-gradient(145deg,#111b26,#0b131c)!important;
  border:1px solid rgba(129,146,158,.20)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
.admin-sidebar-button span{
  display:block!important;
  width:100%!important;
  padding-right:2px!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.admin-sidebar-button:hover{
  transform:none!important;
  color:#f0e8d5!important;
  border-color:rgba(211,172,77,.36)!important;
  background:linear-gradient(180deg,rgba(29,31,29,.95),rgba(13,18,22,.97))!important;
}
.admin-sidebar-button:hover::before{color:#d8b85b!important}
.admin-sidebar-button:hover .sb-ico{
  color:#d7b759!important;
  border-color:rgba(220,183,82,.34)!important;
  background:linear-gradient(145deg,#171b1d,#0d1217)!important;
}
.admin-sidebar-button.active{
  color:#fff3bf!important;
  border:1px solid #e7bf59!important;
  background:linear-gradient(90deg,rgba(90,69,28,.56) 0%,rgba(43,36,24,.82) 60%,rgba(29,28,24,.95) 100%)!important;
  box-shadow:
    0 0 0 1px rgba(255,216,112,.30),
    0 0 16px rgba(235,190,74,.62),
    0 0 30px rgba(235,190,74,.18),
    inset 0 1px rgba(255,244,194,.17)!important;
}
.admin-sidebar-button.active::before{color:#f0c85f!important}
.admin-sidebar-button.active .sb-ico{
  color:#21170a!important;
  background:linear-gradient(145deg,#f4d980,#c8912e)!important;
  border-color:#ffe7a0!important;
  box-shadow:inset 0 1px #fff3bd,0 5px 13px rgba(202,148,47,.27)!important;
}
.admin-sidebar-button.active span{font-weight:950!important}

.admin-sidebar__footer{
  position:relative!important;
  margin-top:auto!important;
  padding:11px 7px 30px!important;
  border-top:0!important;
  border:1px solid rgba(210,171,73,.28)!important;
  border-radius:14px!important;
  background:linear-gradient(180deg,rgba(217,182,94,.035),rgba(255,255,255,.008))!important;
  box-shadow:0 0 20px rgba(207,164,61,.045),inset 0 1px rgba(255,255,255,.018)!important;
  overflow:visible!important;
}
.admin-sidebar__footer::before{
  content:''!important;
  position:absolute!important;
  right:-23px!important;
  top:-165px!important;
  width:230px!important;
  height:160px!important;
  border-right:1px solid rgba(224,183,77,.26)!important;
  border-bottom:1px solid rgba(224,183,77,.22)!important;
  border-radius:0 0 132px 0!important;
  box-shadow:13px 10px 24px rgba(216,175,77,.035)!important;
  pointer-events:none!important;
}
.admin-sidebar__footer::after{
  content:'معاً نحو حلول أفضل لقطاع السيارات'!important;
  position:absolute!important;
  left:12px!important;right:12px!important;bottom:6px!important;
  text-align:center!important;
  color:rgba(206,167,68,.66)!important;
  font-size:6.9px!important;
  letter-spacing:.01em!important;
  pointer-events:none!important;
}
.admin-sidebar__identity{
  min-height:56px!important;
  margin:0 0 8px!important;
  padding:8px 10px!important;
  gap:10px!important;
  border-radius:11px!important;
  background:linear-gradient(180deg,rgba(20,25,28,.92),rgba(10,14,18,.96))!important;
  border:1px solid rgba(211,171,72,.35)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
.admin-sidebar__identity::before{
  content:'⌄'!important;
  order:3!important;
  margin-right:auto!important;
  color:#e5bb52!important;
  font-size:16px!important;
  line-height:1!important;
}
.admin-sidebar__identity-avatar{
  width:39px!important;height:39px!important;min-width:39px!important;
  border-radius:50%!important;
  color:#1e1508!important;
  background:linear-gradient(145deg,#f2d77c,#b9781e)!important;
  border-color:#f5d271!important;
  box-shadow:0 0 14px rgba(210,160,44,.20)!important;
}
.admin-sidebar__identity-info strong{font-size:9.8px!important;color:#f0eee7!important}
.admin-sidebar__identity-info small{font-size:7.5px!important;color:#8c949a!important}
.admin-sidebar-button--logout{
  min-height:42px!important;
  height:42px!important;
  margin:0!important;
  padding:0 38px 0 10px!important;
  color:#dca2a5!important;
  background:linear-gradient(180deg,rgba(45,13,17,.28),rgba(23,8,11,.35))!important;
  border-color:rgba(176,48,56,.31)!important;
  box-shadow:none!important;
}
.admin-sidebar-button--logout::before{content:''!important}
.admin-sidebar-button--logout .sb-ico{
  color:#de4a51!important;
  background:rgba(97,20,25,.24)!important;
  border-color:rgba(190,54,62,.28)!important;
}

@media(max-width:1360px){
  .admin-sidebar-button{min-height:43px!important;height:43px!important;margin:4px 0!important}
  .admin-sidebar-button .sb-ico{top:5px!important}
  .admin-sidebar__brand{min-height:140px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V28.1 — SIDEBAR REFERENCE FIDELITY" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v28.1.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v28.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v28.1-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V28.1"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=LUXURY SIDEBAR — REFERENCE FIDELITY FIX"
echo "CURRENT_APPROVED_VERSION=V27.1"
echo "BASE_VERSION=V28"
echo "TARGET_VERSION=V28.1"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v28.1.css"
echo "ELEMENT=SIDEBAR_ONLY"
echo "REFERENCE_FIDELITY_FIX=YES"
echo "COMMAND_ROWS_UPGRADED=YES"
echo "CHEVRONS_ADDED_VISUALLY=YES"
echo "ACTIVE_GOLD_GLOW_UPGRADED=YES"
echo "FOOTER_DECORATIVE_CURVES_ADDED=YES"
echo "ACCOUNT_PANEL_UPGRADED=YES"
echo "LOGOUT_PANEL_UPGRADED=YES"
echo "NAVIGATION_LOGIC_CHANGED=NO"
echo "TAB_BEHAVIOR_CHANGED=NO"
echo "ROUTES_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
