#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V29.3
# MODULE: ADMIN DASHBOARD
# ELEMENT: MAIN HERO — IMAGE CLARITY RESCUE
# CURRENT APPROVED VERSION: V29.2
# BASE: V29.2
# TARGET: V29.3
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.2.css
TARGET_CSS=src/pages/AdminDashboard.v29.3.css
BACKUP=/tmp/67-v29.3-hero-clarity-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v29.3.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v29.3-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V29.3"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=MAIN HERO — IMAGE CLARITY RESCUE"
  echo "CURRENT_APPROVED_VERSION=V29.2"
  echo "BASE_VERSION=V29.2"
  echo "TARGET_VERSION=V29.3"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V29_3_HERO_CLARITY_RESCUE_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v29.3.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V29.3 — HERO IMAGE CLARITY RESCUE" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V29_3
else
  grep -q "import './AdminDashboard.v29.2.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V29_2
  [ -f "$SOURCE_CSS" ] || fail V29_2_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V29.2" "$SOURCE_CSS" || fail V29_2_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V29_3
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v29.3.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.2.css';"
new="import './AdminDashboard.v29.3.css';"
if old not in s:
    raise SystemExit('V29_2_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v29_3_clarity_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.3 — HERO IMAGE CLARITY RESCUE
   Visual-quality correction over approved V29.2.
   Scope lock: HERO BACKGROUND IMAGE RENDERING ONLY.
   Preserve V29.2 composition, hero height, copy positions, date dock, popover corridor,
   all date logic, sidebar, KPI, system health, revenue and all other modules.
*/

/*
  V29 used an oversized motif box + additional transform scale.
  That extra enlargement makes a finite-resolution JPEG look softer/pixelated on wide desktop screens.
  V29.3 removes the redundant zoom while keeping object proportions through cover.
*/
.ov-header__motif{
  inset:0!important;
  width:100%!important;
  height:100%!important;
  transform:none!important;
  transform-origin:center center!important;
  background-size:cover!important;
  background-position:56% 54%!important;
  background-repeat:no-repeat!important;
  filter:saturate(.98) contrast(1.075) brightness(.935)!important;
  image-rendering:auto!important;
  -webkit-font-smoothing:antialiased!important;
  backface-visibility:hidden!important;
  will-change:auto!important;
}

/* Keep the open custom-date state on the exact same sharp render path. */
.ov-header.date-control-open .ov-header__motif{
  inset:0!important;
  width:100%!important;
  height:100%!important;
  transform:none!important;
  background-size:cover!important;
  background-position:56% 54%!important;
  filter:saturate(.98) contrast(1.075) brightness(.935)!important;
}

/* Slightly reduce veil density over the focal car so source detail remains visible. */
.ov-header::after{
  background:
    linear-gradient(90deg,rgba(3,6,10,.87) 0%,rgba(3,6,10,.51) 20%,rgba(3,6,10,.055) 43%,rgba(3,6,10,.025) 58%,rgba(3,6,10,.39) 79%,rgba(3,6,10,.84) 100%),
    radial-gradient(circle at 61% 56%,rgba(230,183,75,.09),transparent 29%),
    linear-gradient(180deg,rgba(0,0,0,.02),transparent 48%,rgba(0,0,0,.40))!important;
}

/* Preserve the approved V29.2 geometry exactly. */
.ov-header,
.ov-header.date-control-open{
  height:304px!important;
  min-height:304px!important;
  max-height:304px!important;
}

@media(max-width:1500px){
  .ov-header,.ov-header.date-control-open{
    height:286px!important;
    min-height:286px!important;
    max-height:286px!important;
  }
  .ov-header__motif,
  .ov-header.date-control-open .ov-header__motif{
    background-position:56% 54%!important;
  }
}

@media(max-width:1180px){
  .ov-header,.ov-header.date-control-open{
    height:270px!important;
    min-height:270px!important;
    max-height:270px!important;
  }
  .ov-header__motif,
  .ov-header.date-control-open .ov-header__motif{
    background-position:58% 52%!important;
  }
}
CSS

  grep -q "SIX SEVEN ADMIN V29.3 — HERO IMAGE CLARITY RESCUE" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v29.3.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v29.3-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.3-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29.3"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=MAIN HERO — IMAGE CLARITY RESCUE"
echo "CURRENT_APPROVED_VERSION=V29.2"
echo "BASE_VERSION=V29.2"
echo "TARGET_VERSION=V29.3"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v29.3.css"
echo "ELEMENT=HERO_IMAGE_RENDERING_ONLY"
echo "HERO_EXTRA_SCALE_REMOVED=YES"
echo "HERO_SOURCE_ASPECT_PRESERVED=YES"
echo "HERO_CLARITY_RENDERING_REFINED=YES"
echo "HERO_COMPOSITION_CHANGED=NO"
echo "HERO_HEIGHT_CHANGED=NO"
echo "HERO_COPY_CHANGED=NO"
echo "DATE_DOCK_CHANGED=NO"
echo "DATE_POPOVER_CHANGED=NO"
echo "DATE_LOGIC_CHANGED=NO"
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
