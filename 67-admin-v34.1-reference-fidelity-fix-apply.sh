#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v34.css
TARGET_CSS=src/pages/AdminDashboard.v34.1.css
BACKUP=/tmp/67-v34-1-$$
MARKER='SIX SEVEN ADMIN V34.1 — REFERENCE FIDELITY FIX'

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V34_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v34.css';" "$JSX" || { echo 'FAILED_STEP=V34_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v34.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v34.css';"
new="import './AdminDashboard.v34.1.css';"
if old not in s:
    raise SystemExit('V34_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V34.1 — REFERENCE FIDELITY FIX
   Second-pass visual correction against the approved generated reference.
   No data, API, auth, routing, permissions, calculations or business logic changes.
*/

/* ===== GLOBAL DENSITY / REFERENCE SCALE ===== */
body .admin-exec,
body .admin-exec *{box-sizing:border-box}
body .admin-exec>div[style*="marginRight"]{
  margin-right:244px!important;
  padding:12px 14px 18px!important;
  max-width:none!important;
}
body .admin-exec .animate-fadeIn{gap:9px!important}

/* ===== SIDEBAR: preserve reference visual weight ===== */
body .admin-exec .admin-sidebar{
  width:230px!important;
  min-width:230px!important;
  padding:10px 11px 11px!important;
  overflow-y:auto!important;
  overflow-x:hidden!important;
}
body .admin-exec .admin-sidebar__brand{
  min-height:112px!important;
  padding:7px 10px 10px!important;
}
body .admin-exec .admin-sidebar__official-logo{width:132px!important;max-height:62px!important}
body .admin-exec .admin-sidebar__group-label{font-size:8px!important;margin:8px 8px 3px!important}
body .admin-exec .admin-sidebar-button{
  min-height:40px!important;
  padding:8px 10px!important;
  font-size:10.5px!important;
  line-height:1.25!important;
  flex-shrink:0!important;
  pointer-events:auto!important;
  opacity:1!important;
  visibility:visible!important;
}
body .admin-exec .admin-sidebar__nav-group{position:relative!important;z-index:3!important;flex-shrink:0!important}
body .admin-exec .admin-sidebar__footer{padding-top:132px!important;position:relative!important;z-index:2!important}
body .admin-exec .admin-sidebar__footer::before{height:116px!important;top:5px!important}
body .admin-exec .admin-sidebar__identity{min-height:58px!important}

/* ===== HERO: reference composition / no clipping ===== */
body .admin-exec .ov-header{
  height:168px!important;
  min-height:168px!important;
  max-height:168px!important;
  overflow:hidden!important;
  box-sizing:border-box!important;
}
body .admin-exec .ov-header__layout{height:100%!important;overflow:hidden!important}
body .admin-exec .ov-header__motif{
  inset:0!important;
  background-size:cover!important;
  background-position:center 52%!important;
  transform:none!important;
  transition:none!important;
}
body .admin-exec .ov-header__motif.hero-image-pending{opacity:0!important;visibility:hidden!important}
body .admin-exec .ov-header__motif.hero-image-ready{opacity:1!important;visibility:visible!important}
body .admin-exec .ov-header__copy-left{
  left:24px!important;
  top:16px!important;
  width:340px!important;
  max-width:340px!important;
  min-width:0!important;
  overflow:visible!important;
  text-align:left!important;
}
body .admin-exec .ov-header__copy-left::before{margin-bottom:9px!important;font-size:7.5px!important}
body .admin-exec .ov-header__copy-left h1{
  width:100%!important;
  max-width:340px!important;
  margin:0 0 5px!important;
  font-size:25px!important;
  line-height:1.05!important;
  letter-spacing:-.02em!important;
  white-space:normal!important;
  overflow:visible!important;
  text-overflow:clip!important;
}
body .admin-exec .ov-header__copy-left p{
  max-width:330px!important;
  font-size:8.5px!important;
  line-height:1.45!important;
  white-space:normal!important;
  overflow:visible!important;
}
body .admin-exec .ov-header__copy-right{
  right:28px!important;
  top:27px!important;
  width:205px!important;
  max-width:205px!important;
}
body .admin-exec .ov-header__copy-right>span{font-size:12px!important}
body .admin-exec .ov-header__copy-right>strong{font-size:16px!important}
body .admin-exec .ov-header__copy-right>small{font-size:6.5px!important}
body .admin-exec .ov-header__toolbar-top{left:16px!important;right:16px!important;bottom:8px!important}
body .admin-exec .executive-date-shell{
  width:min(760px,72%)!important;
  max-width:760px!important;
  min-width:590px!important;
  height:36px!important;
  overflow:hidden!important;
}

/* ===== KPI: larger typography + clean internal containment ===== */
body .admin-exec .kpi-grid{gap:8px!important}
body .admin-exec .kpi-card{
  height:92px!important;
  min-height:92px!important;
  max-height:92px!important;
  padding:10px 12px 9px!important;
  overflow:hidden!important;
}
body .admin-exec .kpi-card__top{min-height:30px!important}
body .admin-exec .kpi-card__label{font-size:9px!important;line-height:1.1!important}
body .admin-exec .kpi-card__icon{width:31px!important;height:31px!important;flex:0 0 31px!important}
body .admin-exec .kpi-card__value{font-size:23px!important;line-height:1!important;margin-top:0!important}
body .admin-exec .kpi-card__value small{font-size:7.5px!important}
body .admin-exec .kpi-card__note{font-size:7.5px!important;line-height:1.15!important;min-height:14px!important;overflow:visible!important}
body .admin-exec .kpi-card::after{width:72px!important;height:15px!important;bottom:8px!important}

/* ===== SYSTEM HEALTH: readable reference proportions ===== */
body .admin-exec .syshealth{
  height:104px!important;
  min-height:104px!important;
  max-height:104px!important;
  overflow:hidden!important;
}
body .admin-exec .syshealth__layout{
  grid-template-columns:19% 51% 30%!important;
  gap:7px!important;
  padding:8px 10px!important;
}
body .admin-exec .syshealth__zone-left{padding-right:8px!important;overflow:visible!important}
body .admin-exec .syshealth__title{font-size:10.2px!important;line-height:1.25!important;overflow:visible!important}
body .admin-exec .syshealth__title small{font-size:7.6px!important;line-height:1.2!important}
body .admin-exec .syshealth__status{font-size:7.8px!important}
body .admin-exec .syshealth__status-text{font-size:7px!important;line-height:1.2!important;overflow:visible!important}
body .admin-exec .syshealth__metric{
  height:86px!important;
  min-height:86px!important;
  max-height:86px!important;
  padding:8px!important;
  overflow:hidden!important;
}
body .admin-exec .syshealth__metric label{font-size:7.7px!important;line-height:1.15!important}
body .admin-exec .syshealth__metric strong{font-size:16px!important;line-height:1!important}
body .admin-exec .syshealth__metric small{font-size:6.7px!important;line-height:1.15!important}
body .admin-exec .syshealth__zone-right{background-position:center 56%!important}

/* ===== REVENUE: reference chart + dark donut balance ===== */
body .admin-exec .admin-command-grid{
  grid-template-columns:1fr!important;
  grid-template-areas:"revenue" "opsrow"!important;
  gap:8px!important;
}
body .admin-exec .adm-chart-card{
  grid-area:revenue!important;
  width:100%!important;
  height:276px!important;
  min-height:276px!important;
  max-height:276px!important;
  padding:10px 12px 11px!important;
  overflow:hidden!important;
}
body .admin-exec .adm-chart-card__head{min-height:31px!important;margin-bottom:6px!important}
body .admin-exec .rev-title-copy h3{font-size:11px!important;line-height:1.1!important}
body .admin-exec .rev-title-copy small{font-size:7px!important;line-height:1.15!important}
body .admin-exec .rev-period-pill{font-size:7px!important;min-height:21px!important;padding:0 8px!important}
body .admin-exec .rev-stats{grid-template-columns:repeat(4,minmax(0,1fr))!important;gap:6px!important;margin-bottom:7px!important}
body .admin-exec .rev-stat{height:46px!important;min-height:46px!important;padding:6px 8px!important;overflow:hidden!important}
body .admin-exec .rev-stat small{font-size:6.9px!important;line-height:1!important}
body .admin-exec .rev-stat strong{font-size:11px!important;line-height:1.05!important}
body .admin-exec .rev-stat span{font-size:5.9px!important;line-height:1!important}
body .admin-exec .rev-visual-grid{
  height:174px!important;
  min-height:174px!important;
  max-height:174px!important;
  display:grid!important;
  grid-template-columns:minmax(0,1fr) 215px!important;
  gap:8px!important;
  overflow:hidden!important;
}
body .admin-exec .adex-chart{
  height:174px!important;
  min-height:174px!important;
  max-height:174px!important;
  padding:4px 5px!important;
  overflow:hidden!important;
}
body .admin-exec .adex-chart svg{width:100%!important;height:100%!important;max-width:100%!important;max-height:100%!important}
body .admin-exec .rev-total{
  display:grid!important;
  visibility:visible!important;
  opacity:1!important;
  width:215px!important;
  min-width:215px!important;
  max-width:215px!important;
  height:174px!important;
  min-height:174px!important;
  max-height:174px!important;
  padding:11px 10px!important;
  overflow:hidden!important;
  border-radius:11px!important;
  background:linear-gradient(180deg,#0d1824,#09131d)!important;
  border:1px solid rgba(219,169,49,.20)!important;
}
body .admin-exec .rev-total__ring{width:92px!important;height:92px!important;margin:auto!important}
body .admin-exec .rev-total__ring-core strong{font-size:13px!important}
body .admin-exec .rev-total__ring-core small{font-size:6.5px!important}
body .admin-exec .rev-total__copy{max-width:100%!important;overflow:visible!important}
body .admin-exec .rev-total__copy span{font-size:6.8px!important}
body .admin-exec .rev-total__copy strong{font-size:10px!important}
body .admin-exec .rev-total__copy small{font-size:5.8px!important}

/* ===== OPERATIONS: equal premium two-column row ===== */
body .admin-exec .live-card,
body .admin-exec .ops-card{
  width:calc(50% - 4px)!important;
  height:264px!important;
  min-height:264px!important;
  max-height:264px!important;
  margin-top:0!important;
}
body .admin-exec .live-card{grid-column:auto!important;grid-row:auto!important;justify-self:start!important}
body .admin-exec .ops-card{grid-column:auto!important;grid-row:auto!important;justify-self:end!important}
body .admin-exec .admin-command-grid{
  display:flex!important;
  flex-wrap:wrap!important;
  align-items:stretch!important;
}
body .admin-exec .adm-chart-card{flex:0 0 100%!important}
body .admin-exec .live-card,
body .admin-exec .ops-card{flex:0 0 calc(50% - 4px)!important}
body .admin-exec .live-card{order:2!important}
body .admin-exec .ops-card{order:3!important}
body .admin-exec .live-card__head,
body .admin-exec .ops-card__head{min-height:30px!important}
body .admin-exec .live-card__head h3,
body .admin-exec .ops-card__head h3{font-size:10px!important}
body .admin-exec .live-item__body p{font-size:7.8px!important}
body .admin-exec .live-item__body small,
body .admin-exec .live-item .when{font-size:6.2px!important}
body .admin-exec .ops-card__title-group h3{font-size:9px!important}
body .admin-exec .ops-card__title-group small{font-size:6px!important}
body .admin-exec .ops-summary-tile strong{font-size:11px!important}
body .admin-exec .ops-summary-tile span{font-size:6px!important}
body .admin-exec .ops-tile__info strong{font-size:6.7px!important}
body .admin-exec .ops-tile__info small{font-size:5.6px!important}

/* ===== FINANCIAL LEDGER: reference light toolbar, not dark V33 banner ===== */
body .admin-exec .tx-card{
  margin-top:0!important;
  border-radius:13px!important;
  overflow:hidden!important;
  background:#fffdf8!important;
  border:1px solid rgba(184,128,20,.24)!important;
  box-shadow:0 8px 20px rgba(78,51,8,.055)!important;
}
body .admin-exec .tx-card__head{
  min-height:58px!important;
  padding:8px 12px!important;
  background:linear-gradient(180deg,#fffefa,#fbf5e9)!important;
  color:#111820!important;
  border-bottom:1px solid rgba(184,128,20,.16)!important;
}
body .admin-exec .tx-card__title-group h3{color:#111820!important;font-size:10.5px!important}
body .admin-exec .tx-card__title-group small{color:#8c857a!important;font-size:6.5px!important}
body .admin-exec .tx-card__title-icon{background:#fff5d8!important;color:#b3790f!important;border-color:rgba(184,128,20,.23)!important}
body .admin-exec .tx-card__count-badge{background:#fff2cf!important;color:#9b6b12!important;border-color:rgba(184,128,20,.22)!important}
body .admin-exec .tx-card__head-actions{background:transparent!important}
body .admin-exec .tx-search-glow,
body .admin-exec .tx-card__head input{
  background:#fff!important;
  color:#26313d!important;
  border-color:rgba(145,130,103,.25)!important;
  box-shadow:none!important;
}
body .admin-exec .tx-card__head button{
  background:#fff8e9!important;
  color:#9b6b12!important;
  border-color:rgba(184,128,20,.21)!important;
}
body .admin-exec .tx-ledger-summary{padding:8px 12px!important;gap:7px!important;background:#fffdf8!important}
body .admin-exec .tx-ledger-summary__item{height:48px!important;min-height:48px!important;border-radius:8px!important}
body .admin-exec .tx-table-wrap{padding:0 12px 10px!important;background:#fffdf8!important}
body .admin-exec .tx-table{background:#fff!important}
body .admin-exec .tx-table thead th{background:#f7ecd6!important;color:#625a4e!important;font-size:6.7px!important}
body .admin-exec .tx-table tbody td{font-size:6.8px!important;color:#2a3138!important}

/* ===== RESPONSIVE SAFETY ===== */
@media (max-width:1500px){
  body .admin-exec .admin-sidebar{width:224px!important;min-width:224px!important}
  body .admin-exec>div[style*="marginRight"]{margin-right:238px!important}
  body .admin-exec .ov-header__copy-left{width:315px!important;max-width:315px!important}
  body .admin-exec .ov-header__copy-left h1{font-size:23px!important;max-width:315px!important}
  body .admin-exec .executive-date-shell{min-width:545px!important;width:66%!important}
  body .admin-exec .rev-visual-grid{grid-template-columns:minmax(0,1fr) 198px!important}
  body .admin-exec .rev-total{width:198px!important;min-width:198px!important;max-width:198px!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v34-1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v34-1-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V34.1'
echo 'ELEMENT=REFERENCE FIDELITY FIX'
echo 'BASE_VERSION=V34'
echo 'TARGET_VERSION=V34.1'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v34.1.css'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
