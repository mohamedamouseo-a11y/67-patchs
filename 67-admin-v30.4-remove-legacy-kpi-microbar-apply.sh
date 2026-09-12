#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v30.3.css
TARGET_CSS=src/pages/AdminDashboard.v30.4.css
MARKER='SIX SEVEN ADMIN V30.4 — REMOVE LEGACY KPI MICROBAR DOM'
BACKUP=/tmp/67-v30.4-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V30_3_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v30.3.css';" "$JSX" || { echo 'FAILED_STEP=V30_3_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v30.3.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
import re

jsx = Path('/67/src/pages/AdminDashboard.jsx')
s = jsx.read_text()

old_import = "import './AdminDashboard.v30.3.css';"
new_import = "import './AdminDashboard.v30.4.css';"
if old_import not in s:
    raise SystemExit('V30_3_IMPORT_NOT_FOUND')

pattern = re.compile(
    r'<span\s+className=["\']kpi-microbar["\']>\s*'
    r'(?:<span\s*/>\s*){5}'
    r'</span>',
    re.MULTILINE,
)

matches = list(pattern.finditer(s))
if len(matches) != 4:
    raise SystemExit(f'LEGACY_MICROBAR_MATCH_COUNT_{len(matches)}_EXPECTED_4')

s = pattern.sub('', s)
s = s.replace(old_import, new_import, 1)

if 'className="kpi-microbar"' in s or "className='kpi-microbar'" in s:
    raise SystemExit('LEGACY_MICROBAR_STILL_PRESENT_AFTER_REMOVAL')

jsx.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V30.4 — REMOVE LEGACY KPI MICROBAR DOM
   Structural cleanup only. V30.1 CSS pseudo-signals remain the sole KPI signal renderer.
   No KPI visual redesign, no data/logic changes, no System Health changes. */
CSS

# Structural safety checks before build.
grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}
if grep -q 'className="kpi-microbar"' "$JSX"; then
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=LEGACY_MICROBAR_STILL_IN_JSX'
  exit 1
fi

npm run build >/tmp/67-v30.4-build.log 2>&1 || {
  tail -n 180 /tmp/67-v30.4-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V30.4'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=REMOVE LEGACY KPI MICROBAR DOM'
echo 'BASE_VERSION=V30.3'
echo 'TARGET_VERSION=V30.4'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v30.4.css'
echo 'LEGACY_KPI_MICROBAR_MARKUP_REMOVED=YES'
echo 'LEGACY_KPI_MICROBAR_EXPECTED_REMOVAL_COUNT=4'
echo 'KPI_SIGNAL_RENDER_MODE=CSS_PSEUDO_ONLY'
echo 'KPI_VISUAL_REDESIGN_CHANGED=NO'
echo 'SYSTEM_HEALTH_CHANGED=NO'
echo 'HERO_CHANGED=NO'
echo 'DATE_STRIP_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'REVENUE_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
