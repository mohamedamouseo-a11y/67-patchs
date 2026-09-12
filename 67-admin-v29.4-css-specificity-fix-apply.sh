#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
CSS=src/pages/AdminDashboard.v29.4.css
ASSET=src/assets/admin-v29.4-hero-highres.jpg
MARKER='SIX SEVEN ADMIN V29.4 — HERO HIGHRES SPECIFICITY FIX'

cd "$ROOT"
[ -f "$CSS" ] || { echo 'FAILED_STEP=V29_4_CSS_MISSING'; exit 1; }
[ -f "$ASSET" ] || { echo 'FAILED_STEP=HIGHRES_ASSET_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.4.css';" src/pages/AdminDashboard.jsx || { echo 'FAILED_STEP=V29_4_NOT_ACTIVE'; exit 1; }

if ! grep -q "$MARKER" "$CSS"; then
cat >> "$CSS" <<'CSSFIX'

/* SIX SEVEN ADMIN V29.4 — HERO HIGHRES SPECIFICITY FIX
   Runtime diagnosis proved that legacy !important background rules on .ov-header__motif
   still win in the browser. Force the high-resolution asset directly on the rendered
   motif with deliberately higher specificity. No layout, copy, date or logic changes.
*/
body .ov-header .ov-header__motif.ov-header__motif,
body .ov-header.date-control-open .ov-header__motif.ov-header__motif {
  background: url('../assets/admin-v29.4-hero-highres.jpg') 56% 52% / cover no-repeat !important;
  background-image: url('../assets/admin-v29.4-hero-highres.jpg') !important;
  background-size: cover !important;
  background-position: 56% 52% !important;
  background-repeat: no-repeat !important;
  inset: 0 !important;
  width: 100% !important;
  height: 100% !important;
  transform: none !important;
  filter: saturate(.96) contrast(1.035) brightness(.91) !important;
  image-rendering: auto !important;
}
CSSFIX
fi

grep -q "$MARKER" "$CSS"
npm run build >/tmp/67-v29.4-specificity-build.log 2>&1 || {
  tail -n 160 /tmp/67-v29.4-specificity-build.log || true
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

BUILT_ASSET=$(find dist/assets -maxdepth 1 -type f -name 'admin-v29.4-hero-highres-*.jpg' | head -n1 || true)
[ -n "$BUILT_ASSET" ] && [ -s "$BUILT_ASSET" ] || { echo 'FAILED_STEP=BUILT_HIGHRES_ASSET_MISSING'; exit 1; }

if grep -Rqs 'SIX SEVEN ADMIN V29.4 — HERO HIGHRES SPECIFICITY FIX' dist/assets; then
  BUILT_SPECIFICITY_FIX=YES
else
  BUILT_SPECIFICITY_FIX=NO
fi

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V29.4'
echo 'TASK=HERO HIGHRES CSS SPECIFICITY FIX'
echo 'STATUS=AWAITING_RUNTIME_VERIFICATION'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v29.4.css'
echo 'CSS_SPECIFICITY_FIX=YES'
echo 'HIGHRES_RULE_TARGET=DIRECT_OV_HEADER_MOTIF'
echo "BUILT_HIGHRES_ASSET=$BUILT_ASSET"
echo "BUILT_SPECIFICITY_FIX=$BUILT_SPECIFICITY_FIX"
echo 'HERO_LAYOUT_CHANGED=NO'
echo 'HERO_COPY_CHANGED=NO'
echo 'DATE_DOCK_CHANGED=NO'
echo 'DATE_POPOVER_CHANGED=NO'
echo 'DATE_LOGIC_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
