#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.5.css
TARGET_CSS=src/pages/AdminDashboard.v29.6.css
MARKER='SIX SEVEN ADMIN V29.6 — EXTERNAL DATE PANEL'
BACKUP=/tmp/67-v29.6-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V29_5_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.5.css';" "$JSX" || { echo 'FAILED_STEP=V29_5_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v29.5.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.5.css';"
new="import './AdminDashboard.v29.6.css';"
if old not in s:
    raise SystemExit('V29_5_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.6 — EXTERNAL DATE PANEL
   User-requested behavior: the luxury date-range panel opens completely OUTSIDE
   the hero frame. The trigger stays in the hero toolbar, while the panel floats
   below the hero without changing hero height or document layout.
*/

/* The hero may expose only the popup layer while open; its own geometry stays locked. */
body .admin-exec .ov-header,
body .admin-exec .ov-header.date-control-open{
  height:172px!important;
  min-height:172px!important;
  transform:none!important;
}
body .admin-exec .ov-header.date-control-open{
  overflow:visible!important;
  z-index:80!important;
}
body .admin-exec .ov-header:not(.date-control-open){
  overflow:hidden!important;
}

/* Keep the toolbar and anchor stable at the bottom edge of the hero. */
body .admin-exec .executive-date-shell{
  position:relative!important;
  z-index:120!important;
}
body .admin-exec .ov-header__toolbar-top{
  z-index:110!important;
}

/* External floating panel: place it below the complete hero frame, not inside it. */
body .admin-exec .executive-date-popover{
  position:fixed!important;
  top:var(--v296-date-panel-top, 300px)!important;
  left:var(--v296-date-panel-left, 80px)!important;
  right:auto!important;
  margin:0!important;
  width:min(500px,calc(100vw - 340px))!important;
  max-height:min(470px,calc(100vh - var(--v296-date-panel-top,300px) - 18px))!important;
  overflow:auto!important;
  z-index:9999!important;
  transform:none!important;
  animation:none!important;
  isolation:isolate!important;
}

/* Remove the old sidecar pointer; the panel is now a detached executive surface. */
body .admin-exec .executive-date-popover::before{
  content:""!important;
  position:absolute!important;
  inset:0 auto 0 0!important;
  width:3px!important;
  height:auto!important;
  background:linear-gradient(180deg,transparent,#e2b94f 28%,#9c6712 72%,transparent)!important;
  border:0!important;
  transform:none!important;
}
body .admin-exec .executive-date-popover::after{
  left:24px!important;
  right:24px!important;
  top:0!important;
}

/* Ensure the detached panel cannot cause the hero artwork to move or rescale. */
body .admin-exec .ov-header.date-control-open .ov-header__zone-center,
body .admin-exec .ov-header.date-control-open .ov-header__motif,
body .admin-exec .ov-header.date-control-open .ov-header__layout{
  transform:none!important;
  scale:1!important;
  animation:none!important;
  transition:none!important;
}

@media(max-width:1360px){
  body .admin-exec .executive-date-popover{
    width:min(440px,calc(100vw - 300px))!important;
  }
}
CSS

# Add runtime positioning logic using the existing popover state and shell. This computes
# viewport coordinates from the HERO bottom edge so the panel is always outside the frame.
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
needle="  useEffect(() => {\n    let mounted = true;\n    const img = new Image();"
if needle not in s:
    raise SystemExit('V29_5_HERO_EFFECT_ANCHOR_NOT_FOUND')

anchor="  useEffect(() => {\n    let mounted = true;\n    const img = new Image();"
insert="""  useEffect(() => {\n    if (!datePopoverOpen) return;\n    const positionExternalDatePanel = () => {\n      const hero = document.querySelector('.ov-header');\n      const shell = document.querySelector('.executive-date-shell');\n      const root = document.documentElement;\n      if (!hero || !shell) return;\n      const heroRect = hero.getBoundingClientRect();\n      const shellRect = shell.getBoundingClientRect();\n      const panelWidth = window.innerWidth <= 1360 ? 440 : 500;\n      const sidebarReserve = window.innerWidth >= 900 ? 300 : 16;\n      const preferredLeft = Math.max(16, Math.min(shellRect.left, window.innerWidth - sidebarReserve - panelWidth - 16));\n      const top = Math.round(heroRect.bottom + 12);\n      root.style.setProperty('--v296-date-panel-top', `${top}px`);\n      root.style.setProperty('--v296-date-panel-left', `${Math.round(preferredLeft)}px`);\n    };\n    positionExternalDatePanel();\n    requestAnimationFrame(positionExternalDatePanel);\n    window.addEventListener('resize', positionExternalDatePanel);\n    window.addEventListener('scroll', positionExternalDatePanel, { passive: true });\n    return () => {\n      window.removeEventListener('resize', positionExternalDatePanel);\n      window.removeEventListener('scroll', positionExternalDatePanel);\n    };\n  }, [datePopoverOpen]);\n\n""" + anchor
s=s.replace(anchor,insert,1)
p.write_text(s)
PY

grep -q "$MARKER" "$TARGET_CSS" || { cp "$BACKUP/AdminDashboard.jsx" "$JSX"; rm -f "$TARGET_CSS"; echo 'FAILED_STEP=CSS_MARKER_MISSING'; exit 1; }

npm run build >/tmp/67-v29.6-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.6-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V29.6'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=EXTERNAL LUXURY DATE PANEL'
echo 'BASE_VERSION=V29.5'
echo 'TARGET_VERSION=V29.6'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v29.6.css'
echo 'DATE_PANEL_EXTERNAL_TO_HERO=YES'
echo 'DATE_PANEL_POSITION_MODE=FIXED_VIEWPORT_ANCHORED_TO_HERO_BOTTOM'
echo 'DATE_TRIGGER_POSITION_CHANGED=NO'
echo 'HERO_HEIGHT_CHANGED=NO'
echo 'HERO_IMAGE_CHANGED=NO'
echo 'HERO_COPY_CHANGED=NO'
echo 'DATE_LOGIC_CHANGED=NO'
echo 'KPI_LAYOUT_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
