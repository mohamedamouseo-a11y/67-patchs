#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v30.css
TARGET_CSS=src/pages/AdminDashboard.v30.1.css
MARKER='SIX SEVEN ADMIN V30.1 — KPI CSS SIGNAL FIX'
BACKUP=/tmp/67-v30.1-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V30_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v30.css';" "$JSX" || { echo 'FAILED_STEP=V30_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v30.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v30.css';"
new="import './AdminDashboard.v30.1.css';"
if old not in s:
    raise SystemExit('V30_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V30.1 — KPI CSS SIGNAL FIX
   Runtime-safe visual signal bars rendered from CSS only.
   No JSX/data/logic/backend changes. Avoids dependency on .kpi-microbar DOM markup. */

/* Prevent duplication if legacy markup appears in a future bundle. */
body .admin-exec .kpi-microbar{
  display:none!important;
}

/* Dedicated 5-step executive signal bars in every KPI note. */
body .admin-exec .kpi-grid .kpi-card .kpi-card__note::before{
  content:""!important;
  display:inline-block!important;
  flex:0 0 27px!important;
  width:27px!important;
  height:14px!important;
  margin-inline-end:2px!important;
  background:
    linear-gradient(var(--v30-signal),var(--v30-signal)) 0 10px/3px 4px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 6px 8px/3px 6px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 12px 6px/3px 8px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 18px 3px/3px 11px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 24px 0/3px 14px no-repeat!important;
  border-radius:2px!important;
  opacity:.78!important;
  filter:drop-shadow(0 1px 2px color-mix(in srgb,var(--v30-signal) 18%,transparent))!important;
}

/* Keep note alignment clean with the generated signal. */
body .admin-exec .kpi-grid .kpi-card .kpi-card__note{
  display:flex!important;
  align-items:center!important;
  gap:5px!important;
  padding-inline-start:0!important;
  overflow:hidden!important;
}
body .admin-exec .kpi-grid .kpi-card .kpi-card__note>svg{
  flex:0 0 auto!important;
}
body .admin-exec .kpi-grid .kpi-card .kpi-card__note .muted{
  min-width:0!important;
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

npm run build >/tmp/67-v30.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v30.1-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V30.1'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=KPI CSS SIGNAL FIX'
echo 'BASE_VERSION=V30'
echo 'TARGET_VERSION=V30.1'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v30.1.css'
echo 'KPI_SIGNAL_RENDER_MODE=CSS_PSEUDO'
echo 'KPI_SIGNAL_DEPENDS_ON_DOM_MICROBAR=NO'
echo 'KPI_DOM_MICROBAR_HIDDEN_TO_PREVENT_DUPLICATION=YES'
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
