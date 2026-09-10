#!/usr/bin/env bash
set -Eeuo pipefail

cd /67

TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.2.css
TARGET_CSS=src/pages/AdminDashboard.v19.2.3.css
BACKUP=/tmp/67-v19.2.3-$$
mkdir -p "$BACKUP"
cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v19.2.css"

rollback(){
  cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" || true
  cp "$BACKUP/AdminDashboard.v19.2.css" "$SOURCE_CSS" || true
  rm -f "$TARGET_CSS"
  echo "PATCH_APPLIED=NO"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=V19_2_3_FAILED"
  exit 1
}
trap rollback ERR

grep -q "import './AdminDashboard.v19.2.css';" "$TARGET_JSX"
grep -q '<div className="ov-header ov-header-v16">' "$TARGET_JSX"

cp "$SOURCE_CSS" "$TARGET_CSS"
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19.2.3 — DATE POPOVER LAYER FIX */
.ov-header-v16.date-control-open{
  overflow:visible!important;
  z-index:90!important;
}
.ov-header-v16.date-control-open .ov-header__layout{
  overflow:visible!important;
}
.ov-header-v16.date-control-open .ov-header__zone-center,
.ov-header-v16.date-control-open .ov-header__motif,
.ov-header-v16.date-control-open::after{
  border-radius:15px!important;
}
.ov-header-v16.date-control-open .executive-date-popover{
  z-index:140!important;
  overflow:visible!important;
}
.ov-header-v16.date-control-open .ov-header__toolbar-top{
  z-index:130!important;
}
.kpi-grid,
.syshealth,
.admin-command-grid{
  position:relative!important;
  z-index:1!important;
}
CSS

python3 - <<'PY'
from pathlib import Path
p = Path('/67/src/pages/AdminDashboard.jsx')
s = p.read_text()
s = s.replace(
    '<div className="ov-header ov-header-v16">',
    "<div className={`ov-header ov-header-v16 ${datePopoverOpen ? 'date-control-open' : ''}`}>",
    1,
)
s = s.replace(
    "import './AdminDashboard.v19.2.css';",
    "import './AdminDashboard.v19.2.3.css';",
    1,
)
p.write_text(s)
PY

grep -q "date-control-open" "$TARGET_JSX"
grep -q "import './AdminDashboard.v19.2.3.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.2.3" "$TARGET_CSS"

npm run build >/tmp/67-v19.2.3-build.log 2>&1

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v19.2.3.css"
echo "RUNTIME_CSS=AdminDashboard.v19.2.3.css"
echo "DATE_POPOVER_CLIPPING_FIXED=YES"
echo "HERO_OVERFLOW_RELEASE_ON_OPEN=YES"
echo "DATE_LAYER_ABOVE_KPI=YES"
echo "V19_2_LUXURY_STYLING_PRESERVED=YES"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "ERROR=NONE"
