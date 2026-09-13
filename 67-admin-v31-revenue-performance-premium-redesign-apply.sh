#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v30.4.css
TARGET_CSS=src/pages/AdminDashboard.v31.css
MARKER='SIX SEVEN ADMIN V31 — REVENUE + PERFORMANCE PREMIUM REDESIGN'
BACKUP=/tmp/67-v31-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V30_4_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v30.4.css';" "$JSX" || { echo 'FAILED_STEP=V30_4_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v30.4.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v30.4.css';"
new="import './AdminDashboard.v31.css';"
if old not in s:
    raise SystemExit('V30_4_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V31 — REVENUE + PERFORMANCE PREMIUM REDESIGN
   Visual-only redesign of the Revenue & Performance executive analytics card.
   Protected: Hero, Date Strip, KPI row, System Health, Sidebar, Live Ops,
   Current Operations, data, chart calculations, backend and auth. */

/* =========================================================
   REVENUE EXECUTIVE CONTAINER
   ========================================================= */
body .admin-exec .adm-chart-card{
  box-sizing:border-box!important;
  position:relative!important;
  isolation:isolate!important;
  height:318px!important;
  min-height:318px!important;
  max-height:318px!important;
  padding:15px 16px 14px!important;
  overflow:hidden!important;
  border-radius:18px!important;
  background:
    radial-gradient(circle at 92% 5%,rgba(209,157,48,.11),transparent 28%),
    radial-gradient(circle at 8% 100%,rgba(20,177,119,.035),transparent 27%),
    linear-gradient(180deg,#fffefa 0%,#fbf7ef 57%,#f6efe3 100%)!important;
  border:1px solid rgba(184,128,24,.30)!important;
  box-shadow:
    0 16px 38px rgba(73,48,8,.075),
    inset 0 1px rgba(255,255,255,.96)!important;
}
body .admin-exec .adm-chart-card::before{
  content:""!important;
  position:absolute!important;
  z-index:0!important;
  top:0!important;
  right:22px!important;
  left:22px!important;
  height:2px!important;
  border-radius:0 0 99px 99px!important;
  background:linear-gradient(90deg,transparent,#b97e17 22%,#e0b95a 50%,#b97e17 78%,transparent)!important;
  opacity:.72!important;
}
body .admin-exec .adm-chart-card>*{position:relative!important;z-index:1!important}

/* =========================================================
   HEADER / PERIOD
   ========================================================= */
body .admin-exec .adm-chart-card__head{
  box-sizing:border-box!important;
  min-height:44px!important;
  margin:0 0 9px!important;
  padding:0 1px 8px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:14px!important;
  border-bottom:1px solid rgba(134,99,35,.10)!important;
}
body .admin-exec .rev-title-group{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:10px!important;
}
body .admin-exec .rev-title-icon{
  width:40px!important;
  height:40px!important;
  min-width:40px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:12px!important;
  color:#a86f0d!important;
  background:linear-gradient(145deg,#fff9e9,#f2d894)!important;
  border:1px solid rgba(172,113,14,.24)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.9),0 8px 18px rgba(121,78,8,.08)!important;
}
body .admin-exec .rev-title-copy{min-width:0!important}
body .admin-exec .rev-title-copy h3{
  margin:0!important;
  font-size:15px!important;
  line-height:1.2!important;
  font-weight:950!important;
  letter-spacing:-.025em!important;
  color:#10161f!important;
}
body .admin-exec .rev-title-copy small{
  display:block!important;
  margin-top:3px!important;
  font-size:8px!important;
  line-height:1.35!important;
  font-weight:650!important;
  color:#93897a!important;
}
body .admin-exec .rev-period-pill{
  box-sizing:border-box!important;
  flex:0 0 auto!important;
  min-height:28px!important;
  padding:0 11px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  color:#7b6847!important;
  background:linear-gradient(180deg,rgba(255,252,242,.98),rgba(246,236,214,.90))!important;
  border:1px solid rgba(181,127,25,.22)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.95)!important;
  font-size:7.6px!important;
  font-weight:850!important;
  white-space:nowrap!important;
}

/* =========================================================
   FOUR EXECUTIVE SUMMARY TILES
   ========================================================= */
body .admin-exec .rev-stats{
  box-sizing:border-box!important;
  display:grid!important;
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:8px!important;
  margin:0 0 9px!important;
}
body .admin-exec .rev-stat{
  --v31-rev-accent:#b9821e;
  --v31-rev-soft:rgba(185,130,30,.08);
  box-sizing:border-box!important;
  position:relative!important;
  min-width:0!important;
  height:58px!important;
  min-height:58px!important;
  padding:8px 10px 7px!important;
  border-radius:11px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:center!important;
  gap:2px!important;
  background:
    radial-gradient(circle at 92% 0%,var(--v31-rev-soft),transparent 35%),
    linear-gradient(180deg,#fffdf8,#f8f1e5)!important;
  border:1px solid rgba(178,124,20,.16)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.92)!important;
}
body .admin-exec .rev-stat:nth-child(1){--v31-rev-accent:#c08a20;--v31-rev-soft:rgba(192,138,32,.10)}
body .admin-exec .rev-stat:nth-child(2){--v31-rev-accent:#a87924;--v31-rev-soft:rgba(168,121,36,.09)}
body .admin-exec .rev-stat:nth-child(3){--v31-rev-accent:#6f8296;--v31-rev-soft:rgba(111,130,150,.085)}
body .admin-exec .rev-stat:nth-child(4){--v31-rev-accent:#11a971;--v31-rev-soft:rgba(17,169,113,.09)}
body .admin-exec .rev-stat::before{
  content:""!important;
  position:absolute!important;
  top:0!important;
  right:10px!important;
  left:10px!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,var(--v31-rev-accent),transparent)!important;
  opacity:.55!important;
}
body .admin-exec .rev-stat small{
  margin:0!important;
  font-size:7px!important;
  line-height:1.2!important;
  font-weight:760!important;
  color:#958b7e!important;
}
body .admin-exec .rev-stat strong{
  min-width:0!important;
  margin:0!important;
  font-size:13.5px!important;
  line-height:1.06!important;
  font-weight:950!important;
  color:#111821!important;
  font-variant-numeric:tabular-nums!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .rev-stat strong em{
  font-style:normal!important;
  font-size:6.8px!important;
  font-weight:750!important;
  color:#918779!important;
}
body .admin-exec .rev-stat strong.up{color:#0b9d68!important}
body .admin-exec .rev-stat strong.down{color:#b73535!important}
body .admin-exec .rev-stat span{
  min-width:0!important;
  font-size:6.2px!important;
  line-height:1.2!important;
  color:#aaa093!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}

/* =========================================================
   CHART + PERIOD SUMMARY COMPOSITION
   ========================================================= */
body .admin-exec .rev-visual-grid{
  box-sizing:border-box!important;
  display:grid!important;
  grid-template-columns:minmax(0,1fr) 222px!important;
  gap:10px!important;
  min-height:178px!important;
  height:178px!important;
  align-items:stretch!important;
}
body .admin-exec .adex-chart{
  box-sizing:border-box!important;
  position:relative!important;
  min-width:0!important;
  min-height:178px!important;
  height:178px!important;
  padding:8px 10px 4px!important;
  overflow:hidden!important;
  border-radius:13px!important;
  background:
    linear-gradient(rgba(142,111,55,.035) 1px,transparent 1px),
    linear-gradient(90deg,rgba(142,111,55,.025) 1px,transparent 1px),
    linear-gradient(180deg,rgba(255,255,255,.82),rgba(250,246,238,.92))!important;
  background-size:100% 34px,58px 100%,auto!important;
  border:1px solid rgba(178,124,20,.13)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.86)!important;
}
body .admin-exec .adex-chart::before{
  content:"أداء الإيرادات"!important;
  position:absolute!important;
  z-index:2!important;
  top:8px!important;
  right:10px!important;
  padding:3px 7px!important;
  border-radius:999px!important;
  color:#8a6c36!important;
  background:rgba(255,250,238,.86)!important;
  border:1px solid rgba(183,129,27,.12)!important;
  font-size:6.4px!important;
  font-weight:850!important;
  pointer-events:none!important;
}
body .admin-exec .adex-chart svg{
  width:100%!important;
  height:100%!important;
  display:block!important;
  overflow:visible!important;
}
body .admin-exec .adex-chart svg line{
  stroke:#e8e1d6!important;
  stroke-width:.8!important;
  opacity:.82!important;
}
body .admin-exec .adex-chart svg text{
  fill:#948a7b!important;
  font-family:inherit!important;
}
body .admin-exec .adex-chart svg #svgGoldFill stop:first-child{
  stop-color:#c88f25!important;
  stop-opacity:.30!important;
}
body .admin-exec .adex-chart svg #svgGoldFill stop:last-child{
  stop-color:#d4ae58!important;
  stop-opacity:.035!important;
}
body .admin-exec .adex-chart svg path[stroke="#b8862e"]{
  stroke:#b77d14!important;
  stroke-width:2.35!important;
  filter:drop-shadow(0 2px 2px rgba(148,92,10,.12))!important;
}
body .admin-exec .adex-chart svg circle{
  fill:#fff7de!important;
  stroke:#b77d14!important;
  stroke-width:1.7!important;
}
body .admin-exec .adex-chart svg rect[fill="#1c1e26"]{
  fill:#0d131b!important;
  stroke:rgba(207,161,67,.36)!important;
  filter:drop-shadow(0 6px 10px rgba(0,0,0,.16))!important;
}

/* =========================================================
   EXECUTIVE DONUT / PERIOD SUMMARY
   ========================================================= */
body .admin-exec .rev-total{
  box-sizing:border-box!important;
  min-width:0!important;
  height:178px!important;
  padding:12px 12px 10px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:center!important;
  justify-content:center!important;
  gap:7px!important;
  border-radius:14px!important;
  background:
    radial-gradient(circle at 50% 0%,rgba(210,166,69,.11),transparent 38%),
    linear-gradient(180deg,#111a25 0%,#0b121b 100%)!important;
  border:1px solid rgba(210,166,69,.22)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025),0 9px 22px rgba(0,0,0,.10)!important;
}
body .admin-exec .rev-total__ring{
  box-sizing:border-box!important;
  position:relative!important;
  width:94px!important;
  height:94px!important;
  min-width:94px!important;
  min-height:94px!important;
  padding:9px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:50%!important;
  background:conic-gradient(#d99b22 0 48%,#edc45d 48% 76%,#263544 76% 100%)!important;
  box-shadow:0 0 0 1px rgba(223,181,84,.13),0 10px 24px rgba(0,0,0,.18)!important;
}
body .admin-exec .rev-total__ring::after{
  content:""!important;
  position:absolute!important;
  inset:5px!important;
  border-radius:50%!important;
  border:1px solid rgba(255,255,255,.045)!important;
  pointer-events:none!important;
}
body .admin-exec .rev-total__ring-core{
  box-sizing:border-box!important;
  width:100%!important;
  height:100%!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:50%!important;
  background:radial-gradient(circle at 45% 35%,#182331,#0a1017 72%)!important;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.045)!important;
}
body .admin-exec .rev-total__ring-core strong{
  max-width:72px!important;
  font-size:11.5px!important;
  line-height:1!important;
  font-weight:950!important;
  color:#fff!important;
  font-variant-numeric:tabular-nums!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .rev-total__ring-core small{
  margin-top:3px!important;
  font-size:6.4px!important;
  color:#9f978b!important;
}
body .admin-exec .rev-total__copy{
  min-width:0!important;
  width:100%!important;
  display:grid!important;
  grid-template-columns:1fr auto!important;
  grid-template-areas:'label trend' 'value trend' 'caption trend'!important;
  align-items:center!important;
  column-gap:8px!important;
  text-align:right!important;
}
body .admin-exec .rev-total__copy>span{grid-area:label!important;font-size:6.6px!important;color:#8c96a1!important}
body .admin-exec .rev-total__copy>strong{
  grid-area:value!important;
  min-width:0!important;
  font-size:10.5px!important;
  line-height:1.1!important;
  color:#f0d27e!important;
  font-weight:900!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .rev-total__copy>small{
  grid-area:caption!important;
  min-width:0!important;
  margin-top:2px!important;
  font-size:5.8px!important;
  color:#66717d!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .rev-total__copy>em{
  grid-area:trend!important;
  min-width:48px!important;
  height:24px!important;
  margin:0!important;
  padding:0 7px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:3px!important;
  border-radius:999px!important;
  font-size:7px!important;
  font-style:normal!important;
  font-weight:900!important;
  border:1px solid rgba(20,177,119,.16)!important;
}
body .admin-exec .rev-total__copy>em.up{color:#6fe1b5!important;background:rgba(20,177,119,.09)!important}
body .admin-exec .rev-total__copy>em.down{color:#ff9b9b!important;background:rgba(192,60,60,.09)!important;border-color:rgba(192,60,60,.18)!important}

/* Protected neighboring cards remain untouched; only revenue card is sized here. */
@media(max-width:1500px){
  body .admin-exec .adm-chart-card{height:310px!important;min-height:310px!important;max-height:310px!important;padding:13px 14px!important}
  body .admin-exec .rev-visual-grid{grid-template-columns:minmax(0,1fr) 205px!important;height:172px!important;min-height:172px!important}
  body .admin-exec .adex-chart,
  body .admin-exec .rev-total{height:172px!important;min-height:172px!important}
  body .admin-exec .rev-total__ring{width:88px!important;height:88px!important;min-width:88px!important;min-height:88px!important}
}

@media(max-width:1180px){
  body .admin-exec .adm-chart-card{height:auto!important;min-height:388px!important;max-height:none!important}
  body .admin-exec .rev-stats{grid-template-columns:repeat(2,minmax(0,1fr))!important}
  body .admin-exec .rev-visual-grid{grid-template-columns:minmax(0,1fr) 190px!important;height:190px!important;min-height:190px!important}
  body .admin-exec .adex-chart,
  body .admin-exec .rev-total{height:190px!important;min-height:190px!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v31-build.log 2>&1 || {
  tail -n 220 /tmp/67-v31-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V31'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=REVENUE + PERFORMANCE PREMIUM REDESIGN'
echo 'BASE_VERSION=V30.4'
echo 'TARGET_VERSION=V31'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v31.css'
echo 'REVENUE_CONTAINER_PREMIUM=YES'
echo 'REVENUE_HEADER_PREMIUM=YES'
echo 'REVENUE_STATS_PREMIUM=YES'
echo 'REVENUE_CHART_PREMIUM=YES'
echo 'REVENUE_DONUT_PREMIUM=YES'
echo 'JSX_STRUCTURE_CHANGED=NO'
echo 'REVENUE_LOGIC_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'HERO_CHANGED=NO'
echo 'DATE_STRIP_CHANGED=NO'
echo 'KPI_CHANGED=NO'
echo 'SYSTEM_HEALTH_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'LIVE_OPS_CHANGED=NO'
echo 'CURRENT_OPERATIONS_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
