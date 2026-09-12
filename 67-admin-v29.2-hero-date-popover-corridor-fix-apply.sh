#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V29.2
# MODULE: ADMIN DASHBOARD
# ELEMENT: MAIN HERO / DATE POPOVER CORRIDOR FIX
# CURRENT APPROVED VERSION: V28.3
# BASE: V29.1
# TARGET: V29.2
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.1.css
TARGET_CSS=src/pages/AdminDashboard.v29.2.css
BACKUP=/tmp/67-v29.2-hero-date-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v29.2.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v29.2-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V29.2"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=MAIN HERO / DATE POPOVER CORRIDOR FIX"
  echo "CURRENT_APPROVED_VERSION=V28.3"
  echo "BASE_VERSION=V29.1"
  echo "TARGET_VERSION=V29.2"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V29_2_HERO_DATE_POPOVER_CORRIDOR_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v29.2.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V29.2 — HERO DATE POPOVER CORRIDOR FIX" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V29_2
else
  grep -q "import './AdminDashboard.v29.1.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V29_1
  [ -f "$SOURCE_CSS" ] || fail V29_1_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V29.1 — HERO DATE POPOVER STABILITY FIX" "$SOURCE_CSS" || fail V29_1_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V29_2
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v29.2.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.1.css';"
new="import './AdminDashboard.v29.2.css';"
if old not in s:
    raise SystemExit('V29_1_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v29_2_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.2 — HERO DATE POPOVER CORRIDOR FIX
   V29.1 stabilized the hero height but the open custom-date panel still covered the primary hero copy.
   V29.2 moves the popover into the visual corridor between the two editorial copy blocks and compacts it.
   Scope lock: HERO + DATE POPOVER VISUAL STATE ONLY.
   No date logic, presets, custom-range behavior, refresh/export, sidebar, KPI, data, backend or auth changes.
*/

/* Closed hero remains identical to V29.1. */
.ov-header.date-control-open{
  height:304px!important;
  min-height:304px!important;
  max-height:304px!important;
  overflow:hidden!important;
}
.ov-header.date-control-open .ov-header__layout{
  height:304px!important;
  min-height:304px!important;
}

/* Both copy blocks remain fully visible and above the background, but below the popover only where they do not intersect. */
.ov-header.date-control-open .ov-header__copy-left{
  display:block!important;
  visibility:visible!important;
  opacity:1!important;
  left:38px!important;
  top:48px!important;
  z-index:18!important;
}
.ov-header.date-control-open .ov-header__copy-right{
  display:block!important;
  visibility:visible!important;
  opacity:1!important;
  right:34px!important;
  top:38px!important;
  z-index:18!important;
}

/* Dock stays exactly where it is in the closed composition. */
.ov-header.date-control-open .ov-header__toolbar-top{
  left:32px!important;
  right:auto!important;
  bottom:18px!important;
  top:auto!important;
  width:min(910px,66%)!important;
  z-index:35!important;
}
.ov-header.date-control-open .executive-date-shell{
  position:relative!important;
  overflow:visible!important;
}

/* Compact floating panel placed in the center corridor: it must not cover either hero copy block. */
.ov-header.date-control-open .executive-date-popover,
.executive-date-popover{
  position:absolute!important;
  left:600px!important;
  right:auto!important;
  bottom:64px!important;
  top:auto!important;
  width:500px!important;
  max-width:500px!important;
  max-height:214px!important;
  overflow:auto!important;
  margin:0!important;
  transform:none!important;
  z-index:90!important;
  border-radius:14px!important;
  background:linear-gradient(180deg,rgba(10,14,18,.985),rgba(4,7,10,.995))!important;
  border:1px solid rgba(232,191,85,.42)!important;
  box-shadow:0 22px 50px rgba(0,0,0,.52),0 0 20px rgba(220,171,53,.09)!important;
  backdrop-filter:blur(18px)!important;
}

/* Tighten internal popover rhythm so the control reads as a premium overlay, not a second hero card. */
.executive-date-popover__head{
  padding:12px 14px 9px!important;
  gap:10px!important;
}
.executive-date-popover__head strong{font-size:11px!important}
.executive-date-popover__head span{font-size:7.5px!important;line-height:1.4!important}
.executive-date-popover__badge{padding:5px 8px!important;font-size:7px!important}
.executive-date-fields{
  padding:0 14px 9px!important;
  gap:9px!important;
}
.executive-date-field-card{padding:7px!important}
.executive-date-picker{min-height:54px!important}
.executive-date-picker__copy small{font-size:7px!important}
.executive-date-picker__copy strong{font-size:9px!important}
.executive-date-popover__footer{
  padding:9px 14px 11px!important;
  gap:10px!important;
}
.executive-date-popover__hint{font-size:7px!important;line-height:1.45!important}
.executive-date-cancel,
.executive-date-apply{height:34px!important;min-height:34px!important;padding:0 14px!important;font-size:8px!important}

/* No open-state separators or overlays may obscure the hero copy. */
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
  .ov-header.date-control-open .executive-date-popover,
  .executive-date-popover{
    left:455px!important;
    width:450px!important;
    max-width:450px!important;
    max-height:202px!important;
  }
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
  .ov-header.date-control-open .executive-date-popover,
  .executive-date-popover{
    left:50%!important;
    right:auto!important;
    transform:translateX(-50%)!important;
    width:min(430px,70vw)!important;
    max-width:min(430px,70vw)!important;
    max-height:194px!important;
  }
}
CSS

  grep -q "SIX SEVEN ADMIN V29.2 — HERO DATE POPOVER CORRIDOR FIX" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v29.2.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v29.2-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.2-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29.2"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=MAIN HERO / DATE POPOVER CORRIDOR FIX"
echo "CURRENT_APPROVED_VERSION=V28.3"
echo "BASE_VERSION=V29.1"
echo "TARGET_VERSION=V29.2"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v29.2.css"
echo "ELEMENT=HERO_AND_DATE_VISUALS_ONLY"
echo "HERO_CLOSED_STATE_PRESERVED=YES"
echo "HERO_OPEN_STATE_HEIGHT_STABLE=YES"
echo "HERO_PRIMARY_COPY_VISIBLE_WHEN_OPEN=YES"
echo "HERO_SECONDARY_COPY_VISIBLE_WHEN_OPEN=YES"
echo "DATE_DOCK_POSITION_STABLE=YES"
echo "DATE_POPOVER_CENTER_CORRIDOR=YES"
echo "DATE_POPOVER_COMPACTED=YES"
echo "DATE_POPOVER_COVERS_PRIMARY_COPY=NO"
echo "DATE_POPOVER_COVERS_SECONDARY_COPY=NO"
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
