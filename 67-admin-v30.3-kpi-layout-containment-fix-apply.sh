#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v30.2.css
TARGET_CSS=src/pages/AdminDashboard.v30.3.css
MARKER='SIX SEVEN ADMIN V30.3 — KPI LAYOUT CONTAINMENT FIX'
BACKUP=/tmp/67-v30.3-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V30_2_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v30.2.css';" "$JSX" || { echo 'FAILED_STEP=V30_2_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v30.2.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v30.2.css';"
new="import './AdminDashboard.v30.3.css';"
if old not in s:
    raise SystemExit('V30_2_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V30.3 — KPI LAYOUT CONTAINMENT FIX
   Final KPI geometry correction. Replace the inherited flex/space-between
   behavior with an explicit 3-row grid so header, primary value and note
   always stay inside the fixed 108px executive card. Preserve V30 premium
   materials and V30.1 CSS-only five-step signals. No JSX/data/logic changes. */

body .admin-exec .kpi-grid .kpi-card{
  box-sizing:border-box!important;
  height:108px!important;
  min-height:108px!important;
  max-height:108px!important;
  padding:11px 14px 10px!important;
  display:grid!important;
  grid-template-rows:32px minmax(0,34px) 21px!important;
  grid-template-columns:minmax(0,1fr)!important;
  align-content:stretch!important;
  justify-content:stretch!important;
  row-gap:0!important;
  overflow:hidden!important;
}

body .admin-exec .kpi-grid .kpi-card > *{
  box-sizing:border-box!important;
  min-width:0!important;
  width:100%!important;
  max-width:100%!important;
  margin:0!important;
}

body .admin-exec .kpi-grid .kpi-card__top{
  grid-row:1!important;
  height:32px!important;
  min-height:32px!important;
  max-height:32px!important;
  display:flex!important;
  align-items:flex-start!important;
  justify-content:space-between!important;
  gap:10px!important;
  overflow:hidden!important;
}

body .admin-exec .kpi-grid .kpi-card__label{
  min-width:0!important;
  max-width:calc(100% - 48px)!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  white-space:nowrap!important;
}

body .admin-exec .kpi-grid .kpi-card__icon{
  flex:0 0 38px!important;
  width:38px!important;
  height:38px!important;
  min-width:38px!important;
  min-height:38px!important;
  max-width:38px!important;
  max-height:38px!important;
  transform:translateY(-1px)!important;
}

body .admin-exec .kpi-grid .kpi-card__value{
  grid-row:2!important;
  box-sizing:border-box!important;
  display:flex!important;
  align-items:center!important;
  justify-content:flex-start!important;
  min-width:0!important;
  width:100%!important;
  max-width:100%!important;
  height:34px!important;
  min-height:34px!important;
  max-height:34px!important;
  padding:0!important;
  margin:0!important;
  overflow:hidden!important;
  white-space:nowrap!important;
  text-overflow:clip!important;
  font-size:clamp(23px,1.42vw,27px)!important;
  line-height:1!important;
  letter-spacing:-.035em!important;
  font-variant-numeric:tabular-nums!important;
}

body .admin-exec .kpi-grid .kpi-card__value small{
  flex:0 0 auto!important;
  min-width:0!important;
  margin-inline-start:4px!important;
  font-size:8px!important;
  line-height:1!important;
}

body .admin-exec .kpi-grid .kpi-card__note{
  grid-row:3!important;
  box-sizing:border-box!important;
  position:relative!important;
  inset:auto!important;
  width:100%!important;
  min-width:0!important;
  max-width:100%!important;
  height:21px!important;
  min-height:21px!important;
  max-height:21px!important;
  padding:5px 0 0!important;
  margin:0!important;
  display:flex!important;
  align-items:center!important;
  justify-content:flex-start!important;
  gap:5px!important;
  border-top:1px solid rgba(124,94,39,.08)!important;
  overflow:hidden!important;
  line-height:1!important;
  transform:none!important;
}

body .admin-exec .kpi-grid .kpi-card .kpi-card__note::before{
  box-sizing:border-box!important;
  flex:0 0 27px!important;
  width:27px!important;
  min-width:27px!important;
  max-width:27px!important;
  height:13px!important;
  min-height:13px!important;
  max-height:13px!important;
  margin:0 0 0 1px!important;
  align-self:center!important;
  background:
    linear-gradient(var(--v30-signal),var(--v30-signal)) 0 9px/3px 4px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 6px 7px/3px 6px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 12px 5px/3px 8px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 18px 2px/3px 11px no-repeat,
    linear-gradient(var(--v30-signal),var(--v30-signal)) 24px 0/3px 13px no-repeat!important;
}

body .admin-exec .kpi-grid .kpi-card__note > svg{
  box-sizing:border-box!important;
  flex:0 0 12px!important;
  width:12px!important;
  min-width:12px!important;
  max-width:12px!important;
  height:12px!important;
  min-height:12px!important;
  max-height:12px!important;
  margin:0!important;
}

body .admin-exec .kpi-grid .kpi-card__note .muted{
  box-sizing:border-box!important;
  flex:1 1 auto!important;
  min-width:0!important;
  max-width:100%!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  white-space:nowrap!important;
  line-height:1!important;
}

/* Explicitly neutralize any inherited positioning that can move KPI children
   outside the card despite overflow:hidden. */
body .admin-exec .kpi-grid .kpi-card__top,
body .admin-exec .kpi-grid .kpi-card__value,
body .admin-exec .kpi-grid .kpi-card__note{
  top:auto!important;
  right:auto!important;
  bottom:auto!important;
  left:auto!important;
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v30.3-build.log 2>&1 || {
  tail -n 180 /tmp/67-v30.3-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V30.3'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=KPI LAYOUT CONTAINMENT FIX'
echo 'BASE_VERSION=V30.2'
echo 'TARGET_VERSION=V30.3'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v30.3.css'
echo 'KPI_LAYOUT_MODE=EXPLICIT_3_ROW_GRID'
echo 'KPI_VALUE_RESPONSIVE_FONT=YES'
echo 'KPI_NOTE_CONTAINMENT=YES'
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
