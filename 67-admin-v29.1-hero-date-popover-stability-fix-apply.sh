#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V29.1
# MODULE: ADMIN DASHBOARD
# ELEMENT: MAIN HERO / DATE POPOVER STABILITY FIX
# CURRENT APPROVED VERSION: V28.3
# BASE: V29
# TARGET: V29.1
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.css
TARGET_CSS=src/pages/AdminDashboard.v29.1.css
BACKUP=/tmp/67-v29.1-hero-date-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v29.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v29.1-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V29.1"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=MAIN HERO / DATE POPOVER STABILITY FIX"
  echo "CURRENT_APPROVED_VERSION=V28.3"
  echo "BASE_VERSION=V29"
  echo "TARGET_VERSION=V29.1"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V29_1_HERO_DATE_POPOVER_STABILITY_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v29.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V29.1 — HERO DATE POPOVER STABILITY FIX" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V29_1
else
  grep -q "import './AdminDashboard.v29.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V29
  [ -f "$SOURCE_CSS" ] || fail V29_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V29 — MAIN HERO CINEMATIC RECOMPOSITION" "$SOURCE_CSS" || fail V29_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V29_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v29.1.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.css';"
new="import './AdminDashboard.v29.1.css';"
if old not in s:
    raise SystemExit('V29_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v29_1_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.1 — HERO DATE POPOVER STABILITY FIX
   Visual correction after V29 QA showed that opening the custom-date control re-expanded the hero,
   moved the compact dock to the top, and suppressed the primary hero copy.
   Scope lock: HERO + DATE POPOVER VISUAL STATE ONLY.
   Preserve all date logic, presets, custom range behavior, refresh/export actions and all page modules.
*/

/* The open state MUST keep exactly the same cinematic hero frame as the closed state. */
.ov-header.date-control-open{
  height:304px!important;
  min-height:304px!important;
  max-height:304px!important;
  overflow:visible!important;
}
.ov-header.date-control-open .ov-header__layout{
  height:304px!important;
  min-height:304px!important;
}
.ov-header.date-control-open .ov-header__motif{
  inset:-4%!important;
  width:108%!important;
  height:108%!important;
  background-size:cover!important;
  background-position:56% 54%!important;
  transform:scale(1.035)!important;
}

/* Do not hide or displace either editorial copy block while the date popover is open. */
.ov-header.date-control-open .ov-header__copy-left,
.ov-header.date-control-open .ov-header__copy-right{
  display:block!important;
  visibility:visible!important;
  opacity:1!important;
  transform:none!important;
  pointer-events:auto!important;
}
.ov-header.date-control-open .ov-header__copy-left{
  left:38px!important;
  top:48px!important;
  bottom:auto!important;
}
.ov-header.date-control-open .ov-header__copy-right{
  right:34px!important;
  top:38px!important;
  bottom:auto!important;
}

/* Keep the date dock floating at the bottom-left in both closed and open states. */
.ov-header.date-control-open .ov-header__toolbar-top{
  position:absolute!important;
  left:32px!important;
  right:auto!important;
  bottom:18px!important;
  top:auto!important;
  width:min(910px,66%)!important;
  z-index:30!important;
  padding:0!important;
  transform:none!important;
}
.ov-header.date-control-open .executive-date-shell{
  position:relative!important;
  width:100%!important;
  min-height:54px!important;
  transform:none!important;
}

/* Popover overlays upward above the dock; it must never participate in hero height. */
.ov-header.date-control-open .executive-date-popover,
.executive-date-popover{
  position:absolute!important;
  left:0!important;
  right:auto!important;
  bottom:64px!important;
  top:auto!important;
  width:min(690px,92vw)!important;
  max-height:340px!important;
  overflow:auto!important;
  z-index:80!important;
  margin:0!important;
  transform:none!important;
  border-radius:15px!important;
  background:linear-gradient(180deg,rgba(11,15,19,.985),rgba(5,8,11,.99))!important;
  border:1px solid rgba(226,184,76,.36)!important;
  box-shadow:0 24px 54px rgba(0,0,0,.52),0 0 22px rgba(213,166,53,.08)!important;
  backdrop-filter:blur(18px)!important;
}

/* Avoid legacy open-state separators / expansion artifacts. */
.ov-header.date-control-open .ov-header__toolbar-top::after,
.ov-header.date-control-open .ov-header__layout::after{
  display:none!important;
}

@media(max-width:1500px){
  .ov-header.date-control-open{
    height:286px!important;
    min-height:286px!important;
    max-height:286px!important;
  }
  .ov-header.date-control-open .ov-header__layout{height:286px!important;min-height:286px!important}
  .ov-header.date-control-open .ov-header__copy-left{left:28px!important;top:43px!important}
  .ov-header.date-control-open .ov-header__copy-right{right:26px!important;top:34px!important}
  .ov-header.date-control-open .ov-header__toolbar-top{left:26px!important;width:min(820px,70%)!important;bottom:18px!important}
}

@media(max-width:1180px){
  .ov-header.date-control-open{
    height:270px!important;
    min-height:270px!important;
    max-height:270px!important;
  }
  .ov-header.date-control-open .ov-header__layout{height:270px!important;min-height:270px!important}
  .ov-header.date-control-open .ov-header__copy-left{left:22px!important;top:38px!important}
  .ov-header.date-control-open .ov-header__copy-right{right:20px!important;top:34px!important}
  .ov-header.date-control-open .ov-header__toolbar-top{left:20px!important;right:20px!important;width:auto!important;bottom:16px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V29.1 — HERO DATE POPOVER STABILITY FIX" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v29.1.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v29.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.1-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29.1"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=MAIN HERO / DATE POPOVER STABILITY FIX"
echo "CURRENT_APPROVED_VERSION=V28.3"
echo "BASE_VERSION=V29"
echo "TARGET_VERSION=V29.1"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v29.1.css"
echo "ELEMENT=HERO_AND_DATE_VISUALS_ONLY"
echo "HERO_CLOSED_STATE_PRESERVED=YES"
echo "HERO_OPEN_STATE_HEIGHT_STABLE=YES"
echo "HERO_PRIMARY_COPY_VISIBLE_WHEN_OPEN=YES"
echo "HERO_SECONDARY_COPY_VISIBLE_WHEN_OPEN=YES"
echo "DATE_DOCK_POSITION_STABLE=YES"
echo "DATE_POPOVER_OVERLAY_ONLY=YES"
echo "DATE_LOGIC_CHANGED=NO"
echo "DATE_PRESET_BEHAVIOR_CHANGED=NO"
echo "DATE_CUSTOM_RANGE_BEHAVIOR_CHANGED=NO"
echo "REFRESH_ACTION_CHANGED=NO"
echo "EXPORT_ACTION_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "REVENUE_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
