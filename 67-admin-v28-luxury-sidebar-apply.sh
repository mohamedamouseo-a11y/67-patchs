#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V28
# MODULE: ADMIN DASHBOARD
# ELEMENT: LUXURY SIDEBAR
# CURRENT APPROVED VERSION: V27.1
# BASE: V27.1
# TARGET: V28
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v27.1.css
TARGET_CSS=src/pages/AdminDashboard.v28.css
BACKUP=/tmp/67-v28-sidebar-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v28.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v28-sidebar-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V28"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=LUXURY SIDEBAR"
  echo "CURRENT_APPROVED_VERSION=V27.1"
  echo "BASE_VERSION=V27.1"
  echo "TARGET_VERSION=V28"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V28_LUXURY_SIDEBAR_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v28.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V28 — LUXURY SIDEBAR" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V28
else
  grep -q "import './AdminDashboard.v27.1.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V27_1
  [ -f "$SOURCE_CSS" ] || fail V27_1_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V27.1 — FINANCIAL LEDGER VISUAL IMPACT FIX" "$SOURCE_CSS" || fail V27_1_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V28
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v28.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v27.1.css';"
new="import './AdminDashboard.v28.css';"
if old not in s:
    raise SystemExit('V27_1_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v28_sidebar_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V28 — LUXURY SIDEBAR
   Scope lock: Sidebar visual presentation ONLY.
   Preserve navigation behavior, routes, activeTab logic, logout, GitHub Module,
   dashboard modules, data, auth and backend exactly as V27.1.
   Visual goal: unmistakably premium Saudi automotive executive command rail. */

:root{
  --v28-sidebar:300px;
  --v28-side-ink:#05080c;
  --v28-side-ink-2:#09101a;
  --v28-side-panel:#0e1722;
  --v28-side-gold:#d9b65e;
  --v28-side-gold-soft:#f0d58b;
  --v28-side-gold-deep:#9c6b16;
  --v28-side-red:#cf2027;
  --v28-side-green:#22c58a;
}

.admin-sidebar{
  width:var(--v28-sidebar)!important;
  min-width:var(--v28-sidebar)!important;
  padding:14px 13px 12px!important;
  gap:7px!important;
  overflow-x:hidden!important;
  background:
    radial-gradient(circle at 78% 9%,rgba(217,182,94,.12),transparent 24%),
    radial-gradient(circle at 12% 72%,rgba(174,26,31,.055),transparent 24%),
    linear-gradient(rgba(217,182,94,.022) 1px,transparent 1px),
    linear-gradient(90deg,rgba(217,182,94,.022) 1px,transparent 1px),
    linear-gradient(180deg,#04070b 0%,#08101a 48%,#04070b 100%)!important;
  background-size:auto,auto,34px 34px,34px 34px,auto!important;
  border-left:1px solid rgba(217,182,94,.30)!important;
  box-shadow:-18px 0 44px rgba(0,0,0,.20),inset 1px 0 rgba(255,255,255,.025)!important;
  isolation:isolate!important;
}
.admin-sidebar::before{
  content:""!important;
  position:absolute!important;
  top:0!important;left:16px!important;right:16px!important;height:2px!important;
  background:linear-gradient(90deg,transparent,#a87821 16%,#efd98f 50%,#a87821 84%,transparent)!important;
  box-shadow:0 0 18px rgba(217,182,94,.30)!important;
  z-index:3!important;
  pointer-events:none!important;
}
.admin-sidebar::after{
  content:""!important;
  position:absolute!important;
  width:210px!important;height:210px!important;
  right:-92px!important;top:170px!important;
  border-radius:50%!important;
  background:radial-gradient(circle,rgba(217,182,94,.075),transparent 68%)!important;
  filter:blur(3px)!important;
  pointer-events:none!important;
  z-index:-1!important;
}
.admin-sidebar::-webkit-scrollbar{width:5px!important}
.admin-sidebar::-webkit-scrollbar-track{background:transparent!important}
.admin-sidebar::-webkit-scrollbar-thumb{background:rgba(217,182,94,.24)!important;border-radius:99px!important}

.admin-sidebar__brand{
  position:relative!important;
  min-height:138px!important;
  margin:0 1px 3px!important;
  padding:18px 16px 14px!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:center!important;
  justify-content:center!important;
  gap:5px!important;
  overflow:hidden!important;
  border:1px solid rgba(217,182,94,.24)!important;
  border-radius:18px!important;
  background:
    radial-gradient(circle at 50% 16%,rgba(217,182,94,.13),transparent 35%),
    linear-gradient(180deg,rgba(255,255,255,.045),rgba(255,255,255,.012))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.045),0 16px 34px rgba(0,0,0,.22)!important;
}
.admin-sidebar__brand::after{
  content:"EXECUTIVE COMMAND"!important;
  position:absolute!important;
  left:0!important;right:0!important;bottom:0!important;
  height:18px!important;
  display:flex!important;align-items:center!important;justify-content:center!important;
  color:rgba(217,182,94,.36)!important;
  font-size:6.6px!important;font-weight:900!important;letter-spacing:2.4px!important;
  border-top:1px solid rgba(217,182,94,.08)!important;
  background:rgba(0,0,0,.12)!important;
}
.admin-sidebar__official-logo{
  width:168px!important;
  max-width:168px!important;
  max-height:72px!important;
  object-fit:contain!important;
  filter:drop-shadow(0 7px 17px rgba(0,0,0,.42)) brightness(1.05)!important;
}
.admin-sidebar__brand-text{padding-bottom:8px!important;text-align:center!important}
.admin-sidebar__brand-text h2{
  margin:1px 0 2px!important;
  font-size:14px!important;
  line-height:1.2!important;
  font-weight:950!important;
  color:#f0d58b!important;
  letter-spacing:.02em!important;
}
.admin-sidebar__brand-text span{
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:6px!important;
  font-size:8.8px!important;
  color:#8f999f!important;
}
.admin-sidebar .back-btn{
  top:10px!important;left:10px!important;
  width:29px!important;height:29px!important;padding:0!important;
  display:grid!important;place-items:center!important;
  color:#cfb978!important;
  background:linear-gradient(145deg,rgba(217,182,94,.10),rgba(255,255,255,.025))!important;
  border:1px solid rgba(217,182,94,.22)!important;
  border-radius:9px!important;
  box-shadow:inset 0 1px rgba(255,255,255,.04)!important;
}
.admin-sidebar .back-btn:hover{
  color:#fff2bf!important;
  border-color:rgba(217,182,94,.45)!important;
  background:rgba(217,182,94,.14)!important;
}

.admin-sidebar__nav-group{
  position:relative!important;
  margin:0 1px!important;
  padding:7px 6px 6px!important;
  border-radius:14px!important;
  border:1px solid rgba(255,255,255,.035)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.022),rgba(255,255,255,.008))!important;
}
.admin-sidebar__group-label{
  margin:0 7px 6px!important;
  padding:0 2px 4px!important;
  color:rgba(217,182,94,.58)!important;
  font-size:7.7px!important;
  font-weight:900!important;
  letter-spacing:.10em!important;
  border-bottom:1px solid rgba(217,182,94,.07)!important;
}
.admin-sidebar-button{
  position:relative!important;
  min-height:43px!important;
  height:43px!important;
  width:100%!important;
  padding:0 9px!important;
  margin:2px 0!important;
  gap:9px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:flex-start!important;
  border-radius:11px!important;
  border:1px solid transparent!important;
  color:#a9afb4!important;
  background:transparent!important;
  font-size:10.8px!important;
  font-weight:760!important;
  text-align:right!important;
  transition:transform .18s ease,border-color .18s ease,background .18s ease,color .18s ease!important;
}
.admin-sidebar-button .sb-ico{
  width:32px!important;
  height:32px!important;
  min-width:32px!important;
  padding:7px!important;
  border-radius:9px!important;
  color:#929ba3!important;
  background:linear-gradient(145deg,rgba(255,255,255,.05),rgba(255,255,255,.015))!important;
  border:1px solid rgba(255,255,255,.055)!important;
  transition:all .18s ease!important;
}
.admin-sidebar-button:hover{
  transform:translateX(-2px)!important;
  color:#ded8ca!important;
  border-color:rgba(217,182,94,.10)!important;
  background:rgba(217,182,94,.035)!important;
}
.admin-sidebar-button:hover .sb-ico{
  color:#d9bd72!important;
  border-color:rgba(217,182,94,.18)!important;
  background:rgba(217,182,94,.07)!important;
}
.admin-sidebar-button.active{
  color:#fff4c8!important;
  border:1px solid rgba(217,182,94,.46)!important;
  background:
    linear-gradient(90deg,rgba(217,182,94,.21) 0%,rgba(217,182,94,.075) 55%,rgba(217,182,94,.035) 100%)!important;
  box-shadow:inset -3px 0 0 #d9b65e,0 8px 20px rgba(0,0,0,.18),inset 0 1px rgba(255,255,255,.025)!important;
}
.admin-sidebar-button.active::after{
  content:""!important;
  position:absolute!important;
  left:9px!important;
  width:5px!important;height:5px!important;
  border-radius:50%!important;
  background:#d9b65e!important;
  box-shadow:0 0 9px rgba(217,182,94,.75)!important;
}
.admin-sidebar-button.active .sb-ico{
  color:#19140a!important;
  background:linear-gradient(145deg,#f1dc99,#bd8730)!important;
  border-color:#efd98f!important;
  box-shadow:inset 0 1px #fff2c3,0 6px 14px rgba(188,135,48,.20)!important;
}
.admin-sidebar-button.active span{font-weight:900!important}

.admin-sidebar__footer{
  margin-top:auto!important;
  padding:9px 7px 7px!important;
  border-top:1px solid rgba(217,182,94,.12)!important;
  border-radius:14px!important;
  background:linear-gradient(180deg,rgba(217,182,94,.035),rgba(255,255,255,.01))!important;
}
.admin-sidebar__identity{
  margin:0 0 6px!important;
  min-height:52px!important;
  padding:8px 9px!important;
  display:flex!important;
  align-items:center!important;
  gap:9px!important;
  border-radius:11px!important;
  background:rgba(255,255,255,.025)!important;
  border:1px solid rgba(217,182,94,.12)!important;
}
.admin-sidebar__identity-avatar{
  width:34px!important;height:34px!important;min-width:34px!important;
  display:grid!important;place-items:center!important;
  border-radius:10px!important;
  color:#151008!important;
  background:linear-gradient(145deg,#f0d58b,#b97f27)!important;
  border:1px solid #efd98f!important;
  font-size:9px!important;
  font-weight:950!important;
  box-shadow:0 6px 14px rgba(184,125,36,.16)!important;
}
.admin-sidebar__identity-info strong{
  display:block!important;
  color:#e7e2d7!important;
  font-size:9.6px!important;
  line-height:1.2!important;
  font-weight:900!important;
}
.admin-sidebar__identity-info small{
  display:block!important;
  margin-top:2px!important;
  color:#777f86!important;
  font-size:7.4px!important;
}
.admin-sidebar-button--logout{
  min-height:38px!important;
  height:38px!important;
  color:#c69a9b!important;
  border-color:rgba(198,54,60,.11)!important;
  background:rgba(164,26,31,.035)!important;
}
.admin-sidebar-button--logout .sb-ico{
  width:29px!important;height:29px!important;min-width:29px!important;
  color:#be7073!important;
  background:rgba(164,26,31,.07)!important;
  border-color:rgba(198,54,60,.10)!important;
}
.admin-sidebar-button--logout:hover{
  color:#ffd8d8!important;
  border-color:rgba(198,54,60,.26)!important;
  background:rgba(164,26,31,.10)!important;
}
.admin-sidebar-button--logout:hover .sb-ico{
  color:#f2a6a8!important;
  border-color:rgba(198,54,60,.22)!important;
  background:rgba(164,26,31,.13)!important;
}

.neon-pulse-green{
  width:6px!important;height:6px!important;
  background:var(--v28-side-green)!important;
  box-shadow:0 0 0 3px rgba(34,197,138,.08),0 0 10px rgba(34,197,138,.72)!important;
}

.admin-exec>div[style*="marginRight"]{
  margin-right:314px!important;
  transition:margin-right .2s ease!important;
}

@media(max-width:1500px){
  :root{--v28-sidebar:286px}
  .admin-sidebar{padding-left:11px!important;padding-right:11px!important}
  .admin-sidebar__brand{min-height:126px!important;padding-top:14px!important}
  .admin-sidebar__official-logo{width:154px!important}
  .admin-sidebar-button{height:40px!important;min-height:40px!important;font-size:10.1px!important}
  .admin-sidebar-button .sb-ico{width:30px!important;height:30px!important;min-width:30px!important;padding:7px!important}
  .admin-exec>div[style*="marginRight"]{margin-right:300px!important}
}

@media(max-width:1180px){
  :root{--v28-sidebar:268px}
  .admin-sidebar{padding:10px 9px!important}
  .admin-sidebar__brand{min-height:116px!important}
  .admin-sidebar__official-logo{width:142px!important}
  .admin-sidebar__group-label{font-size:7px!important}
  .admin-sidebar-button{height:38px!important;min-height:38px!important;font-size:9.6px!important}
  .admin-sidebar-button .sb-ico{width:28px!important;height:28px!important;min-width:28px!important;padding:6px!important}
  .admin-exec>div[style*="marginRight"]{margin-right:280px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V28 — LUXURY SIDEBAR" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v28.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v28-sidebar-build.log 2>&1 || {
  tail -n 180 /tmp/67-v28-sidebar-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V28"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=LUXURY SIDEBAR"
echo "CURRENT_APPROVED_VERSION=V27.1"
echo "BASE_VERSION=V27.1"
echo "TARGET_VERSION=V28"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v28.css"
echo "ELEMENT=SIDEBAR_ONLY"
echo "SIDEBAR_WIDTH_DESKTOP=300PX"
echo "SIDEBAR_BRAND_LUXURY_BLOCK=YES"
echo "SIDEBAR_GROUPED_COMMAND_RAIL=YES"
echo "SIDEBAR_ACTIVE_STATE_UPGRADED=YES"
echo "SIDEBAR_ICON_TILES_UPGRADED=YES"
echo "SIDEBAR_IDENTITY_FOOTER_UPGRADED=YES"
echo "SIDEBAR_LOGOUT_VISUAL_UPGRADED=YES"
echo "NAVIGATION_LOGIC_CHANGED=NO"
echo "TAB_BEHAVIOR_CHANGED=NO"
echo "LOGOUT_BEHAVIOR_CHANGED=NO"
echo "GITHUB_MODULE_BEHAVIOR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"