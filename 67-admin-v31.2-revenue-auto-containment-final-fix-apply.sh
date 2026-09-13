#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v31.1.css
TARGET_CSS=src/pages/AdminDashboard.v31.2.css
MARKER='SIX SEVEN ADMIN V31.2 — REVENUE AUTO CONTAINMENT FINAL FIX'
BACKUP=/tmp/67-v31.2-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V31_1_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v31.1.css';" "$JSX" || { echo 'FAILED_STEP=V31_1_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v31.1.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v31.1.css';"
new="import './AdminDashboard.v31.2.css';"
if old not in s:
    raise SystemExit('V31_1_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V31.2 — REVENUE AUTO CONTAINMENT FINAL FIX
   Final geometry containment for Revenue & Performance.
   Preserve V31.1 visual language, chart data, donut logic and all neighboring modules. */

body .admin-exec .adm-chart-card{
  box-sizing:border-box!important;
  height:auto!important;
  min-height:318px!important;
  max-height:none!important;
  padding:13px 16px 13px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
}

/* Hard width/box containment for every real descendant. */
body .admin-exec .adm-chart-card,
body .admin-exec .adm-chart-card *,
body .admin-exec .adm-chart-card *::before,
body .admin-exec .adm-chart-card *::after{
  box-sizing:border-box!important;
}

body .admin-exec .adm-chart-card > *,
body .admin-exec .rev-stats > *,
body .admin-exec .rev-visual-grid > *,
body .admin-exec .rev-total > *,
body .admin-exec .rev-total__copy > *{
  min-width:0!important;
  max-width:100%!important;
}

/* Keep the compact V31.1 proportions but let the parent own final height naturally. */
body .admin-exec .adm-chart-card__head{
  flex:0 0 39px!important;
  height:39px!important;
  min-height:39px!important;
  max-height:39px!important;
  overflow:hidden!important;
}

body .admin-exec .rev-stats{
  flex:0 0 auto!important;
  width:100%!important;
  max-width:100%!important;
  overflow:hidden!important;
}

body .admin-exec .rev-stat{
  min-width:0!important;
  max-width:100%!important;
  overflow:hidden!important;
}

body .admin-exec .rev-stat > *{
  min-width:0!important;
  max-width:100%!important;
}

body .admin-exec .rev-visual-grid{
  flex:0 0 173px!important;
  width:100%!important;
  max-width:100%!important;
  height:173px!important;
  min-height:173px!important;
  max-height:173px!important;
  overflow:hidden!important;
}

body .admin-exec .adex-chart{
  width:100%!important;
  max-width:100%!important;
  min-width:0!important;
  overflow:hidden!important;
}
body .admin-exec .adex-chart > svg,
body .admin-exec .adex-chart svg{
  width:100%!important;
  max-width:100%!important;
  height:100%!important;
  max-height:100%!important;
  overflow:hidden!important;
}

body .admin-exec .rev-total{
  width:100%!important;
  max-width:216px!important;
  min-width:0!important;
  overflow:hidden!important;
}
body .admin-exec .rev-total__ring,
body .admin-exec .rev-total__ring-core,
body .admin-exec .rev-total__copy{
  max-width:100%!important;
  overflow:hidden!important;
}
body .admin-exec .rev-total__copy > span,
body .admin-exec .rev-total__copy > strong,
body .admin-exec .rev-total__copy > small,
body .admin-exec .rev-total__copy > em{
  min-width:0!important;
  max-width:100%!important;
}

/* Prevent decorative content from extending the measurable card box. */
body .admin-exec .adm-chart-card::before{
  left:22px!important;
  right:22px!important;
  max-width:calc(100% - 44px)!important;
}
body .admin-exec .adex-chart::before{
  max-width:calc(100% - 20px)!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  white-space:nowrap!important;
}

@media(max-width:1500px){
  body .admin-exec .adm-chart-card{
    height:auto!important;
    min-height:310px!important;
    max-height:none!important;
    padding:12px 14px 11px!important;
  }
  body .admin-exec .adm-chart-card__head{
    flex-basis:37px!important;
    height:37px!important;
    min-height:37px!important;
    max-height:37px!important;
  }
  body .admin-exec .rev-visual-grid{
    flex-basis:171px!important;
    height:171px!important;
    min-height:171px!important;
    max-height:171px!important;
  }
  body .admin-exec .rev-total{max-width:196px!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v31.2-build.log 2>&1 || {
  tail -n 180 /tmp/67-v31.2-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V31.2'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=REVENUE AUTO CONTAINMENT FINAL FIX'
echo 'BASE_VERSION=V31.1'
echo 'TARGET_VERSION=V31.2'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v31.2.css'
echo 'REVENUE_CARD_AUTO_HEIGHT=YES'
echo 'REVENUE_FIXED_MAX_HEIGHT_REMOVED=YES'
echo 'REVENUE_DESCENDANT_BOX_CONTAINMENT=YES'
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
