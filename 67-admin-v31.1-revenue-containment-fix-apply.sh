#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v31.css
TARGET_CSS=src/pages/AdminDashboard.v31.1.css
MARKER='SIX SEVEN ADMIN V31.1 — REVENUE CONTAINMENT FIX'
BACKUP=/tmp/67-v31.1-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V31_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v31.css';" "$JSX" || { echo 'FAILED_STEP=V31_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v31.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v31.css';"
new="import './AdminDashboard.v31.1.css';"
if old not in s:
    raise SystemExit('V31_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V31.1 — REVENUE CONTAINMENT FIX
   Geometry-only refinement of V31 Revenue & Performance.
   Preserve design language, data, chart/donut logic and all neighboring modules. */

body .admin-exec .adm-chart-card{
  height:318px!important;
  min-height:318px!important;
  max-height:318px!important;
  padding:13px 16px 12px!important;
  overflow:hidden!important;
}

/* Reduce vertical stack by ~14px so all children fit inside the fixed card. */
body .admin-exec .adm-chart-card__head{
  min-height:39px!important;
  height:39px!important;
  margin:0 0 7px!important;
  padding:0 1px 6px!important;
  box-sizing:border-box!important;
  overflow:hidden!important;
}
body .admin-exec .rev-title-icon{
  width:36px!important;
  height:36px!important;
  min-width:36px!important;
  border-radius:11px!important;
}
body .admin-exec .rev-title-copy h3{font-size:14px!important}
body .admin-exec .rev-title-copy small{margin-top:2px!important;font-size:7.5px!important}
body .admin-exec .rev-period-pill{min-height:25px!important;height:25px!important;padding:0 10px!important}

body .admin-exec .rev-stats{
  gap:8px!important;
  margin:0 0 7px!important;
}
body .admin-exec .rev-stat{
  height:54px!important;
  min-height:54px!important;
  max-height:54px!important;
  padding:7px 10px 6px!important;
}
body .admin-exec .rev-stat strong{font-size:13px!important}
body .admin-exec .rev-stat span{font-size:6px!important}

body .admin-exec .rev-visual-grid{
  min-height:173px!important;
  height:173px!important;
  max-height:173px!important;
  grid-template-columns:minmax(0,1fr) 216px!important;
  gap:9px!important;
  overflow:hidden!important;
  align-items:stretch!important;
}

body .admin-exec .adex-chart{
  min-height:173px!important;
  height:173px!important;
  max-height:173px!important;
  padding:7px 9px 3px!important;
  overflow:hidden!important;
}
body .admin-exec .adex-chart svg{
  max-width:100%!important;
  max-height:100%!important;
  overflow:hidden!important;
}

body .admin-exec .rev-total{
  box-sizing:border-box!important;
  min-width:0!important;
  width:100%!important;
  max-width:216px!important;
  min-height:173px!important;
  height:173px!important;
  max-height:173px!important;
  padding:9px 10px 8px!important;
  gap:5px!important;
  overflow:hidden!important;
  justify-content:center!important;
}
body .admin-exec .rev-total__ring{
  width:84px!important;
  height:84px!important;
  min-width:84px!important;
  min-height:84px!important;
  max-width:84px!important;
  max-height:84px!important;
  padding:8px!important;
  flex:0 0 84px!important;
}
body .admin-exec .rev-total__ring-core{
  width:100%!important;
  height:100%!important;
  min-width:0!important;
  min-height:0!important;
  overflow:hidden!important;
}
body .admin-exec .rev-total__ring-core strong{
  max-width:64px!important;
  font-size:10.5px!important;
}
body .admin-exec .rev-total__copy{
  box-sizing:border-box!important;
  width:100%!important;
  min-width:0!important;
  max-width:100%!important;
  max-height:54px!important;
  overflow:hidden!important;
  column-gap:6px!important;
}
body .admin-exec .rev-total__copy>strong{font-size:10px!important}
body .admin-exec .rev-total__copy>small{font-size:5.5px!important}
body .admin-exec .rev-total__copy>em{
  min-width:44px!important;
  height:22px!important;
  padding:0 6px!important;
  font-size:6.6px!important;
}

/* Hard containment guarantees for all direct Revenue card children. */
body .admin-exec .adm-chart-card > *,
body .admin-exec .rev-visual-grid > *,
body .admin-exec .rev-total > *{
  box-sizing:border-box!important;
  min-width:0!important;
}

@media(max-width:1500px){
  body .admin-exec .adm-chart-card{
    height:310px!important;
    min-height:310px!important;
    max-height:310px!important;
    padding:12px 14px 10px!important;
  }
  body .admin-exec .adm-chart-card__head{height:37px!important;min-height:37px!important;margin-bottom:6px!important;padding-bottom:5px!important}
  body .admin-exec .rev-stat{height:52px!important;min-height:52px!important;max-height:52px!important}
  body .admin-exec .rev-stats{margin-bottom:6px!important}
  body .admin-exec .rev-visual-grid{height:171px!important;min-height:171px!important;max-height:171px!important;grid-template-columns:minmax(0,1fr) 196px!important}
  body .admin-exec .adex-chart{height:171px!important;min-height:171px!important;max-height:171px!important}
  body .admin-exec .rev-total{height:171px!important;min-height:171px!important;max-height:171px!important;max-width:196px!important;padding:8px 9px 7px!important}
  body .admin-exec .rev-total__ring{width:80px!important;height:80px!important;min-width:80px!important;min-height:80px!important;max-width:80px!important;max-height:80px!important;flex-basis:80px!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v31.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v31.1-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V31.1'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=REVENUE + PERFORMANCE CONTAINMENT FIX'
echo 'BASE_VERSION=V31'
echo 'TARGET_VERSION=V31.1'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v31.1.css'
echo 'REVENUE_VERTICAL_STACK_COMPACTED=YES'
echo 'REVENUE_DONUT_CONTAINMENT_FIX=YES'
echo 'REVENUE_CHART_CONTAINMENT_FIX=YES'
echo 'REVENUE_DATA_CHANGED=NO'
echo 'REVENUE_LOGIC_CHANGED=NO'
echo 'HERO_CHANGED=NO'
echo 'DATE_STRIP_CHANGED=NO'
echo 'KPI_CHANGED=NO'
echo 'SYSTEM_HEALTH_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
