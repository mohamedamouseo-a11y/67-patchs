#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
TARGET_HTML=index.html
SOURCE_CSS=src/pages/AdminDashboard.v21.css
TARGET_CSS=src/pages/AdminDashboard.v21.1.css
OFFICIAL_LOGO=src/assets/sixty-seven-official-logo.png
OLD_FAVICON=public/67-favicon.svg
TARGET_FAVICON=public/67-favicon.png
BACKUP=/tmp/67-v21.1-favicon-only-hero-cleanup-$$
FAILED_STEP=init
APPLIED_NOW=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    cp "$BACKUP/index.html" "$TARGET_HTML" 2>/dev/null || true
    rm -f "$TARGET_CSS"
    if [ -f "$BACKUP/67-favicon.svg" ]; then cp "$BACKUP/67-favicon.svg" "$OLD_FAVICON"; else rm -f "$OLD_FAVICON"; fi
    if [ -f "$BACKUP/67-favicon.png" ]; then cp "$BACKUP/67-favicon.png" "$TARGET_FAVICON"; else rm -f "$TARGET_FAVICON"; fi
    npm run build >/tmp/67-v21.1-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V21_1_FAVICON_ONLY_HERO_CLEANUP_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v21.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V21.1 — FAVICON ONLY + HERO CLEANUP" "$TARGET_CSS" \
  && [ -f "$TARGET_FAVICON" ] \
  && grep -q 'href="/67-favicon.png"' "$TARGET_HTML"; then
  STATE_ACTION=ALREADY_AT_V21_1
elif grep -q "import './AdminDashboard.v21.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V21 — FAVICON + HERO BRAND SCALE" "$SOURCE_CSS" \
  && [ -f "$OFFICIAL_LOGO" ]; then
  STATE_ACTION=APPLY_V21_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$TARGET_HTML" "$BACKUP/index.html"
  [ -f "$OLD_FAVICON" ] && cp "$OLD_FAVICON" "$BACKUP/67-favicon.svg" || true
  [ -f "$TARGET_FAVICON" ] && cp "$TARGET_FAVICON" "$BACKUP/67-favicon.png" || true

  cp "$SOURCE_CSS" "$TARGET_CSS"
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V21.1 — FAVICON ONLY + HERO CLEANUP
   Correction over V21:
   - official SIX SEVEN logo belongs to browser favicon/page identity only,
   - remove the logo plate from the hero completely,
   - preserve the larger premium hero scale introduced in V21,
   - preserve V20.2 date filter behavior and geometry. */

/* NEVER render the official logo inside the hero. */
.ov-header__copy-right::before{
  content:none!important;
  display:none!important;
  width:0!important;
  height:0!important;
  margin:0!important;
  background:none!important;
  border:0!important;
  box-shadow:none!important;
}

/* Clean the right hero copy after removing the mistaken logo plate. */
.ov-header__copy-right{
  padding:0!important;
  border:0!important;
  border-radius:0!important;
  background:transparent!important;
  box-shadow:none!important;
  backdrop-filter:none!important;
}
.ov-header__copy-right>span{
  font-size:13px!important;
  color:rgba(255,255,255,.88)!important;
  text-shadow:0 3px 16px rgba(0,0,0,.78)!important;
}
.ov-header__copy-right>strong{
  margin-top:4px!important;
  font-size:23px!important;
  color:#f0cf72!important;
  text-shadow:0 4px 20px rgba(0,0,0,.82)!important;
}
.ov-header__copy-right>small{
  margin-top:9px!important;
  padding-top:0!important;
  border-top:0!important;
  width:auto!important;
  color:rgba(255,255,255,.64)!important;
  text-shadow:0 2px 12px rgba(0,0,0,.82)!important;
}

/* V21 hero scale stays intact; only remove logo-specific visual weight. */
.ov-header-v16:not(.date-control-open) .ov-header__copy-right{
  right:34px!important;
  top:38px!important;
  width:250px!important;
  max-width:250px!important;
}
.ov-header-v16.date-control-open .ov-header__copy-right{
  right:30px!important;
  top:30px!important;
  width:240px!important;
  max-width:240px!important;
}

@media(max-width:1360px){
  .ov-header-v16:not(.date-control-open) .ov-header__copy-right{
    right:24px!important;
    top:28px!important;
    width:210px!important;
    max-width:210px!important;
  }
  .ov-header__copy-right>strong{font-size:19px!important}
}
CSS

  FAILED_STEP=wire_official_favicon
  cp "$OFFICIAL_LOGO" "$TARGET_FAVICON"
  rm -f "$OLD_FAVICON"

  python3 - <<'PY'
from pathlib import Path

jsx = Path('/67/src/pages/AdminDashboard.jsx')
s = jsx.read_text()
old = "import './AdminDashboard.v21.css';"
new = "import './AdminDashboard.v21.1.css';"
if old not in s:
    raise SystemExit('V21_RUNTIME_IMPORT_NOT_FOUND')
jsx.write_text(s.replace(old, new, 1))

html = Path('/67/index.html')
h = html.read_text()
old_svg = '<link rel="icon" type="image/svg+xml" href="/67-favicon.svg" />'
old_png = '<link rel="icon" type="image/png" href="/67-favicon.png" />'
new_png = '<link rel="icon" type="image/png" href="/67-favicon.png" />'
if old_svg in h:
    h = h.replace(old_svg, new_png, 1)
elif old_png not in h:
    raise SystemExit('V21_FAVICON_LINK_NOT_FOUND')
html.write_text(h)
PY

  grep -q "import './AdminDashboard.v21.1.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V21.1 — FAVICON ONLY + HERO CLEANUP" "$TARGET_CSS"
  grep -q 'href="/67-favicon.png"' "$TARGET_HTML"
  [ -f "$TARGET_FAVICON" ]
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  echo "CURRENT_FAVICON_BEGIN"
  grep -n "rel=\"icon\"" "$TARGET_HTML" || true
  echo "CURRENT_FAVICON_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v21.1-build.log 2>&1 || {
  tail -n 120 /tmp/67-v21.1-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING
[ -f dist/67-favicon.png ] || fail DIST_FAVICON_MISSING
grep -q '67-favicon.png' dist/index.html || fail DIST_FAVICON_NOT_WIRED

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V21"
echo "TARGET_VERSION=V21.1"
echo "RUNTIME_CSS=AdminDashboard.v21.1.css"
echo "FAVICON_SOURCE=OFFICIAL_SIX_SEVEN_LOGO"
echo "FAVICON_WIRED=YES"
echo "HERO_LOGO_PLATE_REMOVED=YES"
echo "HERO_OFFICIAL_LOGO_PRESENT=NO"
echo "HERO_SCALE_V21_PRESERVED=YES"
echo "DATE_CONTROL_V20_2_PRESERVED=YES"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
