#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v30.1.css
TARGET_CSS=src/pages/AdminDashboard.v30.2.css
MARKER='SIX SEVEN ADMIN V30.2 — KPI INTERNAL BOUNDS FIX'
BACKUP=/tmp/67-v30.2-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V30_1_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v30.1.css';" "$JSX" || { echo 'FAILED_STEP=V30_1_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v30.1.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v30.1.css';"
new="import './AdminDashboard.v30.2.css';"
if old not in s:
    raise SystemExit('V30_1_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V30.2 — KPI INTERNAL BOUNDS FIX
   Geometry-only containment correction for the V30/V30.1 KPI cards.
   Keeps the premium visual system and CSS signal bars intact while ensuring
   every real KPI child remains inside the 108px card bounds. */

body .admin-exec .kpi-grid .kpi-card{
  box-sizing:border-box!important;
  overflow:hidden!important;
}

body .admin-exec .kpi-grid .kpi-card > *,
body .admin-exec .kpi-grid .kpi-card__top,
body .admin-exec .kpi-grid .kpi-card__value,
body .admin-exec .kpi-grid .kpi-card__note{
  box-sizing:border-box!important;
  min-width:0!important;
  max-width:100%!important;
}

/* Primary overflow correction: V30 note used content-box min-height plus
   padding/border, which could make the real rendered box exceed the card. */
body .admin-exec .kpi-grid .kpi-card__note{
  height:19px!important;
  min-height:19px!important;
  max-height:19px!important;
  padding:4px 0 0!important;
  margin:0!important;
  overflow:hidden!important;
  flex:0 0 19px!important;
  line-height:1.05!important;
}

body .admin-exec .kpi-grid .kpi-card__top{
  height:32px!important;
  min-height:32px!important;
  max-height:32px!important;
  flex:0 0 32px!important;
  overflow:hidden!important;
}

body .admin-exec .kpi-grid .kpi-card__value{
  min-height:28px!important;
  max-height:30px!important;
  overflow:hidden!important;
  flex:0 0 auto!important;
}

/* Keep generated five-step CSS signal safely inside the note box. */
body .admin-exec .kpi-grid .kpi-card .kpi-card__note::before{
  box-sizing:border-box!important;
  height:13px!important;
  max-height:13px!important;
  background:
    linear-gradient(var(--v30-signal),var(--v30-signal)) 0 9px/3px 4px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 6px 7px/3px 6px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 12px 5px/3px 8px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 18px 2px/3px 11px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 24px 0/3px 13px no-repeat!important;
}

body .admin-exec .kpi-grid .kpi-card__note > svg{
  width:13px!important;
  height:13px!important;
  max-width:13px!important;
  max-height:13px!important;
  flex:0 0 13px!important;
}

body .admin-exec .kpi-grid .kpi-card__note .muted{
  min-width:0!important;
  max-width:100%!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  white-space:nowrap!important;
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v30.2-build.log 2>&1 || {
  tail -n 180 /tmp/67-v30.2-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V30.2'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=KPI INTERNAL BOUNDS FIX'
echo 'BASE_VERSION=V30.1'
echo 'TARGET_VERSION=V30.2'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v30.2.css'
echo 'KPI_INTERNAL_BOX_SIZING_FIXED=YES'
echo 'KPI_NOTE_CONTENT_BOX_OVERFLOW_FIXED=YES'
echo 'KPI_CSS_SIGNALS_PRESERVED=YES'
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
