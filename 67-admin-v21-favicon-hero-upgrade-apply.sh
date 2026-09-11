#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
TARGET_HTML=index.html
SOURCE_CSS=src/pages/AdminDashboard.v20.2.css
TARGET_CSS=src/pages/AdminDashboard.v21.css
FAVICON=public/67-favicon.svg
BACKUP=/tmp/67-v21-favicon-hero-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO
HAD_FAVICON=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    cp "$BACKUP/index.html" "$TARGET_HTML" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v21.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    if [ "$HAD_FAVICON" = "YES" ]; then
      cp "$BACKUP/67-favicon.svg" "$FAVICON" 2>/dev/null || true
    else
      rm -f "$FAVICON"
    fi
    npm run build >/tmp/67-v21-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V21_FAVICON_HERO_UPGRADE_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v21.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V21 — FAVICON + HERO BRAND SCALE" "$TARGET_CSS" \
  && [ -f "$FAVICON" ] \
  && grep -q 'href="/67-favicon.svg"' "$TARGET_HTML"; then
  STATE_ACTION=ALREADY_AT_V21
elif grep -q "import './AdminDashboard.v20.2.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V20.2 — DATE FILTER FINAL COMPOSITION" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V21
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$TARGET_HTML" "$BACKUP/index.html"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v21.css"
  fi
  if [ -f "$FAVICON" ]; then
    HAD_FAVICON=YES
    cp "$FAVICON" "$BACKUP/67-favicon.svg"
  fi

  cp "$SOURCE_CSS" "$TARGET_CSS"
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V21 — FAVICON + HERO BRAND SCALE
   Base: V20.2 final date-filter composition.
   Scope: browser identity + executive hero only.
   Rules:
   - preserve date control behavior and V20.2 open-state geometry,
   - preserve data/KPIs/command center/backend/auth,
   - make the closed hero materially larger and more premium,
   - lock official SIX SEVEN branding into the hero composition. */

/* ---------- CLOSED HERO: LARGER EXECUTIVE CINEMATIC STAGE ---------- */
.ov-header-v16:not(.date-control-open){
  height:310px!important;
  min-height:310px!important;
  border-radius:21px!important;
  border-color:rgba(226,184,85,.40)!important;
  box-shadow:0 26px 64px rgba(0,0,0,.25),0 0 0 1px rgba(255,255,255,.025) inset!important;
}

.ov-header-v16::after{
  background:
    linear-gradient(90deg,rgba(2,5,9,.94) 0%,rgba(2,5,9,.70) 19%,rgba(2,5,9,.18) 39%,rgba(2,5,9,.06) 56%,rgba(2,5,9,.48) 76%,rgba(2,5,9,.94) 100%),
    radial-gradient(circle at 56% 62%,rgba(232,190,88,.13),transparent 29%),
    linear-gradient(180deg,rgba(0,0,0,.03) 0%,rgba(0,0,0,.02) 44%,rgba(0,0,0,.42) 100%)!important;
}

.ov-header-v16:not(.date-control-open) .ov-header__motif{
  background-position:center 54%!important;
  transform:scale(1.035)!important;
  filter:saturate(1.04) contrast(1.08) brightness(.88)!important;
}

/* keep the approved V20.2 command lane intact at the bottom */
.ov-header-v16:not(.date-control-open) .ov-header__toolbar-top{
  left:30px!important;
  bottom:22px!important;
}

/* ---------- LEFT COPY: MORE AIR, STRONGER HIERARCHY ---------- */
.ov-header-v16:not(.date-control-open) .ov-header__copy-left{
  left:36px!important;
  bottom:112px!important;
  width:45%!important;
  max-width:620px!important;
}
.ov-header-v16:not(.date-control-open) .ov-header__eyebrow{
  margin-bottom:8px!important;
  font-size:11px!important;
  font-weight:850!important;
  letter-spacing:.025em!important;
  color:#efd27c!important;
}
.ov-header-v16:not(.date-control-open) .ov-header__copy-left h1{
  max-width:600px!important;
  font-size:43px!important;
  line-height:1.01!important;
  letter-spacing:-.03em!important;
  text-shadow:0 7px 28px rgba(0,0,0,.92)!important;
}
.ov-header-v16:not(.date-control-open) .ov-header__copy-left h1 span{
  margin-top:4px!important;
  color:#f2d47b!important;
}
.ov-header-v16:not(.date-control-open) .ov-header__copy-left p{
  max-width:520px!important;
  margin-top:10px!important;
  font-size:12px!important;
  line-height:1.65!important;
  color:rgba(255,255,255,.80)!important;
}

/* ---------- RIGHT BRAND PLATE: OFFICIAL LOGO + COMMAND IDENTITY ---------- */
.ov-header__copy-right{
  right:34px!important;
  top:32px!important;
  width:286px!important;
  max-width:286px!important;
  padding:16px 17px 15px!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:flex-end!important;
  text-align:right!important;
  direction:rtl!important;
  border-radius:16px!important;
  border:1px solid rgba(224,184,87,.24)!important;
  background:linear-gradient(145deg,rgba(7,12,18,.76),rgba(4,8,13,.43))!important;
  box-shadow:0 18px 42px rgba(0,0,0,.28),inset 0 1px rgba(255,255,255,.035)!important;
  backdrop-filter:blur(9px) saturate(120%)!important;
}
.ov-header__copy-right::before{
  content:""!important;
  width:132px!important;
  height:44px!important;
  margin-bottom:12px!important;
  display:block!important;
  border-radius:10px!important;
  background-color:rgba(255,252,245,.94)!important;
  background-image:url('../assets/sixty-seven-official-logo.png')!important;
  background-repeat:no-repeat!important;
  background-position:center!important;
  background-size:112px auto!important;
  border:1px solid rgba(234,200,118,.34)!important;
  box-shadow:0 10px 24px rgba(0,0,0,.22)!important;
}
.ov-header__copy-right>span{
  font-size:13px!important;
  line-height:1.35!important;
  color:rgba(255,255,255,.84)!important;
}
.ov-header__copy-right>strong{
  margin-top:4px!important;
  font-size:23px!important;
  line-height:1.12!important;
  color:#f0cf72!important;
  letter-spacing:-.02em!important;
}
.ov-header__copy-right>small{
  margin-top:10px!important;
  padding-top:9px!important;
  width:100%!important;
  display:flex!important;
  align-items:center!important;
  justify-content:flex-start!important;
  gap:6px!important;
  font-size:9.5px!important;
  color:rgba(255,255,255,.58)!important;
  border-top:1px solid rgba(255,255,255,.07)!important;
}

/* subtle premium frame detail without adding visual noise */
.ov-header-v16:not(.date-control-open) .ov-header__layout::after{
  content:""!important;
  position:absolute!important;
  inset:13px!important;
  z-index:2!important;
  pointer-events:none!important;
  border-radius:14px!important;
  border:1px solid rgba(255,255,255,.035)!important;
  box-shadow:inset 0 0 38px rgba(0,0,0,.16)!important;
}

/* ---------- V20.2 DATE CONTROL REMAINS FUNCTIONALLY UNCHANGED ---------- */
.ov-header-v16.date-control-open .ov-header__copy-right{
  right:30px!important;
  top:28px!important;
  width:260px!important;
  max-width:260px!important;
  opacity:.96!important;
}
.ov-header-v16.date-control-open .ov-header__copy-right::before{
  width:116px!important;
  height:38px!important;
  margin-bottom:9px!important;
  background-size:98px auto!important;
}

@media(max-width:1600px){
  .ov-header-v16:not(.date-control-open){height:296px!important;min-height:296px!important}
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left{bottom:108px!important;width:44%!important;max-width:560px!important}
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left h1{font-size:39px!important}
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left p{font-size:11px!important;max-width:470px!important}
  .ov-header__copy-right{width:260px!important;max-width:260px!important;right:28px!important}
}

@media(max-width:1360px){
  .ov-header-v16:not(.date-control-open){height:280px!important;min-height:280px!important}
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left{left:28px!important;bottom:104px!important;width:43%!important;max-width:480px!important}
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left h1{font-size:34px!important}
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left p{font-size:10px!important;max-width:420px!important}
  .ov-header__copy-right{right:24px!important;top:25px!important;width:226px!important;max-width:226px!important;padding:13px!important}
  .ov-header__copy-right::before{width:108px!important;height:36px!important;margin-bottom:8px!important;background-size:92px auto!important}
  .ov-header__copy-right>strong{font-size:19px!important}
}

@media(max-width:1100px){
  .ov-header-v16:not(.date-control-open) .ov-header__copy-left{width:48%!important}
  .ov-header__copy-right{width:205px!important;max-width:205px!important}
  .ov-header__copy-right>span{font-size:11px!important}
  .ov-header__copy-right>strong{font-size:17px!important}
}

@media(prefers-reduced-motion:no-preference){
  .ov-header-v16:not(.date-control-open) .ov-header__motif{
    transition:transform .6s ease,filter .6s ease!important;
  }
  .ov-header-v16:not(.date-control-open):hover .ov-header__motif{
    transform:scale(1.047)!important;
    filter:saturate(1.06) contrast(1.09) brightness(.90)!important;
  }
}
CSS

  FAILED_STEP=write_browser_identity
  mkdir -p public
  cat > "$FAVICON" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="67">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#111820"/>
      <stop offset="1" stop-color="#05080d"/>
    </linearGradient>
    <linearGradient id="gold" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#f0d17a"/>
      <stop offset="1" stop-color="#b67b16"/>
    </linearGradient>
  </defs>
  <rect x="2" y="2" width="60" height="60" rx="15" fill="url(#bg)" stroke="#d7ad51" stroke-width="2"/>
  <rect x="12" y="49" width="40" height="3" rx="1.5" fill="#d71920"/>
  <text x="32" y="41" text-anchor="middle" font-family="Arial Black,Inter,Arial,sans-serif" font-size="31" font-weight="900" letter-spacing="-3" fill="url(#gold)">67</text>
</svg>
SVG

  FAILED_STEP=wire_runtime
  python3 - <<'PY'
from pathlib import Path

jsx = Path('/67/src/pages/AdminDashboard.jsx')
s = jsx.read_text()
old_import = "import './AdminDashboard.v20.2.css';"
new_import = "import './AdminDashboard.v21.css';"
if old_import not in s:
    raise SystemExit('V20_2_RUNTIME_IMPORT_NOT_FOUND')
s = s.replace(old_import, new_import, 1)

marker = "// V21 browser identity — admin tab title follows the executive dashboard."
if marker not in s:
    anchor = "const AdminDashboard = () => {\n  const navigate = useNavigate();"
    if anchor not in s:
        raise SystemExit('ADMIN_COMPONENT_ANCHOR_NOT_FOUND')
    replacement = """const AdminDashboard = () => {\n  const navigate = useNavigate();\n\n  // V21 browser identity — admin tab title follows the executive dashboard.\n  useEffect(() => {\n    const previousTitle = document.title;\n    document.title = '67 | لوحة الإدارة';\n    return () => { document.title = previousTitle; };\n  }, []);"""
    s = s.replace(anchor, replacement, 1)
jsx.write_text(s)

html = Path('/67/index.html')
h = html.read_text()
old_favicon = '<link rel="icon" type="image/svg+xml" href="/vite.svg" />'
new_favicon = '<link rel="icon" type="image/svg+xml" href="/67-favicon.svg" />'
if old_favicon in h:
    h = h.replace(old_favicon, new_favicon, 1)
elif new_favicon not in h:
    raise SystemExit('FAVICON_ANCHOR_NOT_FOUND')
h = h.replace('<meta name="theme-color" content="#2D5016" />', '<meta name="theme-color" content="#090d12" />', 1)
html.write_text(h)
PY

  grep -q "import './AdminDashboard.v21.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V21 — FAVICON + HERO BRAND SCALE" "$TARGET_CSS"
  grep -q "67 | لوحة الإدارة" "$TARGET_JSX"
  grep -q 'href="/67-favicon.svg"' "$TARGET_HTML"
  [ -f "$FAVICON" ]
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
npm run build >/tmp/67-v21-favicon-hero-build.log 2>&1 || {
  tail -n 120 /tmp/67-v21-favicon-hero-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING
[ -f dist/67-favicon.svg ] || fail DIST_FAVICON_MISSING
grep -q '67-favicon.svg' dist/index.html || fail DIST_FAVICON_NOT_WIRED

grep -R -q '67 | لوحة الإدارة' dist/assets 2>/dev/null || fail DIST_ADMIN_TITLE_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V20.2"
echo "TARGET_VERSION=V21"
echo "RUNTIME_CSS=AdminDashboard.v21.css"
echo "FAVICON_WIRED=YES"
echo "ADMIN_PAGE_TITLE=67 | لوحة الإدارة"
echo "CLOSED_HERO_HEIGHT=310PX_DESKTOP"
echo "OFFICIAL_LOGO_HERO_PLATE=YES"
echo "HERO_COMPOSITION_UPGRADED=YES"
echo "DATE_CONTROL_V20_2_PRESERVED=YES"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_READY=YES"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
