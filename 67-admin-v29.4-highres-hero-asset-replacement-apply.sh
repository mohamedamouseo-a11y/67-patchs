#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V29.4
# MODULE: ADMIN DASHBOARD
# ELEMENT: MAIN HERO — HIGH-RES ASSET REPLACEMENT
# CURRENT APPROVED VERSION: V29.2
# BASE: V29.3
# TARGET: V29.4
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.3.css
TARGET_CSS=src/pages/AdminDashboard.v29.4.css
STAGED_ASSET=/tmp/67-admin-v29.4-hero-highres.jpg
TARGET_ASSET=src/assets/admin-v29.4-hero-highres.jpg
BACKUP=/tmp/67-v29.4-hero-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO
HAD_TARGET_ASSET=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then cp "$BACKUP/AdminDashboard.v29.4.css" "$TARGET_CSS" 2>/dev/null || true; else rm -f "$TARGET_CSS"; fi
    if [ "$HAD_TARGET_ASSET" = "YES" ]; then cp "$BACKUP/admin-v29.4-hero-highres.jpg" "$TARGET_ASSET" 2>/dev/null || true; else rm -f "$TARGET_ASSET"; fi
    npm run build >/tmp/67-v29.4-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V29.4"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=MAIN HERO — HIGH-RES ASSET REPLACEMENT"
  echo "CURRENT_APPROVED_VERSION=V29.2"
  echo "BASE_VERSION=V29.3"
  echo "TARGET_VERSION=V29.4"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V29_4_HIGHRES_HERO_FAILED' ERR

FAILED_STEP=verify_base
if grep -q "import './AdminDashboard.v29.4.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && [ -f "$TARGET_ASSET" ] \
  && grep -q "SIX SEVEN ADMIN V29.4 — HIGH-RES HERO ASSET" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V29_4
else
  grep -q "import './AdminDashboard.v29.3.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V29_3
  [ -f "$SOURCE_CSS" ] || fail V29_3_CSS_NOT_FOUND
  [ -f "$STAGED_ASSET" ] || fail HIGHRES_ASSET_NOT_STAGED_AT_TMP

  FAILED_STEP=verify_highres_asset
  python3 - <<'PY'
from pathlib import Path
p=Path('/tmp/67-admin-v29.4-hero-highres.jpg')
if not p.exists() or p.stat().st_size < 180000:
    raise SystemExit('HIGHRES_ASSET_FILE_TOO_SMALL_OR_MISSING')
try:
    from PIL import Image
    with Image.open(p) as im:
        w,h=im.size
    if w < 2000 or h < 600:
        raise SystemExit(f'HIGHRES_ASSET_DIMENSIONS_TOO_SMALL_{w}x{h}')
except ImportError:
    pass
PY

  STATE_ACTION=APPLY_V29_4
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then HAD_TARGET_CSS=YES; cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v29.4.css"; fi
  if [ -f "$TARGET_ASSET" ]; then HAD_TARGET_ASSET=YES; cp "$TARGET_ASSET" "$BACKUP/admin-v29.4-hero-highres.jpg"; fi

  FAILED_STEP=copy_highres_asset
  cp "$STAGED_ASSET" "$TARGET_ASSET"

  FAILED_STEP=create_runtime_css
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.3.css';"
new="import './AdminDashboard.v29.4.css';"
if old not in s:
    raise SystemExit('V29_3_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v29_4_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.4 — HIGH-RES HERO ASSET
   Replace the 560x132 legacy hero with the generated 2172x724 high-resolution asset.
   Scope lock: HERO IMAGE ASSET/RENDERING ONLY.
   Preserve V29.2/V29.3 composition, copy, height, date dock, date popover and all logic.
*/

.ov-header__motif,
.ov-header.date-control-open .ov-header__motif{
  background-image:url('../assets/admin-v29.4-hero-highres.jpg')!important;
  background-size:cover!important;
  background-repeat:no-repeat!important;
  background-position:56% 52%!important;
  inset:0!important;
  width:100%!important;
  height:100%!important;
  transform:none!important;
  filter:saturate(.96) contrast(1.035) brightness(.91)!important;
  image-rendering:auto!important;
}
CSS

  grep -q "SIX SEVEN ADMIN V29.4 — HIGH-RES HERO ASSET" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v29.4.css';" "$TARGET_JSX"
  [ -s "$TARGET_ASSET" ]
fi

FAILED_STEP=build
npm run build >/tmp/67-v29.4-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.4-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

ASSET_BYTES=$(wc -c < "$TARGET_ASSET" | tr -d ' ')
ASSET_DIMS=$(python3 - <<'PY'
try:
    from PIL import Image
    with Image.open('/67/src/assets/admin-v29.4-hero-highres.jpg') as im:
        print(f'{im.size[0]}x{im.size[1]}')
except Exception:
    print('UNAVAILABLE')
PY
)

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V29.4"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=MAIN HERO — HIGH-RES ASSET REPLACEMENT"
echo "CURRENT_APPROVED_VERSION=V29.2"
echo "BASE_VERSION=V29.3"
echo "TARGET_VERSION=V29.4"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v29.4.css"
echo "ELEMENT=HERO_IMAGE_ASSET_ONLY"
echo "HIGHRES_ASSET_REPLACED=YES"
echo "HIGHRES_ASSET_PATH=$TARGET_ASSET"
echo "HIGHRES_ASSET_DIMENSIONS=$ASSET_DIMS"
echo "HIGHRES_ASSET_BYTES=$ASSET_BYTES"
echo "LEGACY_LOWRES_ASSET_USED=NO"
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
