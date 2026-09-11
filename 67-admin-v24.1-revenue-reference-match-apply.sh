#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v24.css
TARGET_CSS=src/pages/AdminDashboard.v24.1.css
BACKUP=/tmp/67-v24.1-revenue-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v24.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v24.1-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V24_1_REVENUE_REFERENCE_MATCH_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v24.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V24.1 — REVENUE REFERENCE MATCH" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V24_1
elif grep -q "import './AdminDashboard.v24.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V24 — PREMIUM REVENUE PERFORMANCE" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V24_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v24.1.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v24.css';"
new="import './AdminDashboard.v24.1.css';"
if old not in s:
    raise SystemExit('V24_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_reference_match_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V24.1 — REVENUE REFERENCE MATCH
   Correction over V24 after real 1920x1080 visual QA.
   Approved composition target:
   - Revenue & Performance owns the FULL FIRST ROW of the command area.
   - chart is the dominant 75% visual; summary ring is a deliberate 25% sidecar.
   - four summary tiles are materially larger and readable.
   - Live Operations and Current Operations keep their content/functionality and move to row 2.
   - no value, trend-series, date-range, backend, auth, KPI, hero, system-health,
     transactions, sidebar, or business-data logic changes. */

/* ---------- COMMAND GRID: REVENUE OWNS ROW 1 ---------- */
.admin-command-grid{
  display:grid!important;
  grid-template-columns:repeat(2,minmax(0,1fr))!important;
  grid-template-areas:
    "revenue revenue"
    "live ops"!important;
  gap:10px!important;
  align-items:stretch!important;
  margin:0!important;
}
.adm-chart-card{grid-area:revenue!important}
.live-card{grid-area:live!important}
.ops-card{grid-area:ops!important}

/* Preserve the neighboring modules themselves; only their row placement changes. */
.live-card,.ops-card{
  height:286px!important;
  min-height:286px!important;
  max-height:286px!important;
}

/* ---------- REVENUE CARD SCALE / MATERIAL ---------- */
.adm-chart-card{
  height:360px!important;
  min-height:360px!important;
  max-height:360px!important;
  padding:16px 18px 16px!important;
  border-radius:18px!important;
  overflow:hidden!important;
  background:
    radial-gradient(circle at 7% -12%,rgba(215,173,81,.095),transparent 28%),
    radial-gradient(circle at 92% 115%,rgba(170,112,20,.045),transparent 30%),
    linear-gradient(180deg,#fffefa 0%,#faf6ed 100%)!important;
  border:1px solid rgba(190,133,27,.38)!important;
  box-shadow:0 16px 38px rgba(77,49,6,.085),inset 0 1px 0 rgba(255,255,255,.95)!important;
}
.adm-chart-card::before{
  left:26px!important;
  right:26px!important;
  height:2px!important;
  background:linear-gradient(90deg,transparent,#d8ae52 22%,#c28a25 58%,#e1c16e 80%,transparent)!important;
  opacity:.9!important;
}

/* ---------- HEADER: EXECUTIVE, NOT UTILITY ---------- */
.adm-chart-card__head{
  min-height:44px!important;
  height:44px!important;
  margin:0 0 10px!important;
  padding:0 2px!important;
  gap:16px!important;
}
.rev-title-group{gap:11px!important}
.rev-title-icon{
  width:40px!important;
  height:40px!important;
  min-width:40px!important;
  border-radius:12px!important;
  color:#ad771b!important;
  background:linear-gradient(145deg,#fff9e9,#ecd5a0)!important;
  border-color:rgba(178,121,20,.24)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.88),0 8px 18px rgba(112,72,8,.10)!important;
}
.rev-title-icon svg{width:20px!important;height:20px!important}
.rev-title-copy{gap:4px!important}
.rev-title-copy h3{
  font-size:16px!important;
  line-height:1.1!important;
  color:#10161e!important;
  font-weight:950!important;
}
.rev-title-copy small{
  font-size:9px!important;
  line-height:1.25!important;
  color:#91887b!important;
}
.rev-period-pill{
  height:30px!important;
  padding:0 12px!important;
  font-size:9px!important;
  color:#82601f!important;
  background:linear-gradient(180deg,#fffaf0,#f3e6cc)!important;
  border-color:rgba(184,129,25,.22)!important;
}

/* ---------- FOUR SUMMARY TILES ---------- */
.rev-stats{
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:9px!important;
  margin:0 0 11px!important;
}
.rev-stat{
  min-height:66px!important;
  height:66px!important;
  padding:9px 11px 8px!important;
  gap:4px!important;
  border-radius:11px!important;
  background:linear-gradient(180deg,#fbf7ef 0%,#f6eee0 100%)!important;
  border-color:rgba(183,129,28,.18)!important;
}
.rev-stat::before{
  top:10px!important;
  bottom:10px!important;
  width:3px!important;
}
.rev-stat small{
  font-size:8.5px!important;
  line-height:1!important;
  color:#8e8578!important;
  font-weight:800!important;
}
.rev-stat strong{
  font-size:17px!important;
  line-height:1!important;
  gap:5px!important;
}
.rev-stat strong em{font-size:8px!important}
.rev-stat>span{
  font-size:7.8px!important;
  line-height:1.15!important;
  color:#a39a8d!important;
}

/* ---------- 75 / 25 VISUAL COMPOSITION ---------- */
.rev-visual-grid{
  grid-template-columns:minmax(0,3fr) minmax(250px,1fr)!important;
  gap:12px!important;
  height:213px!important;
  min-height:213px!important;
  align-items:stretch!important;
}
.adm-chart-card .adex-chart{
  min-height:213px!important;
  height:213px!important;
  padding:6px 6px 1px!important;
  border-radius:12px!important;
  background:
    linear-gradient(rgba(183,129,28,.035) 1px,transparent 1px),
    linear-gradient(90deg,rgba(183,129,28,.026) 1px,transparent 1px),
    linear-gradient(180deg,rgba(255,255,255,.78),rgba(249,245,237,.70))!important;
  background-size:34px 34px,34px 34px,auto!important;
  border-color:rgba(185,130,28,.13)!important;
}

/* Let the existing SVG breathe inside the larger reference-match chart. */
.adm-chart-card .adex-chart>svg{
  width:100%!important;
  height:100%!important;
  display:block!important;
}

/* ---------- DONUT / SUMMARY SIDECAR ---------- */
.rev-total{
  height:213px!important;
  min-height:213px!important;
  padding:14px 12px!important;
  gap:10px!important;
  border-radius:13px!important;
  background:
    radial-gradient(circle at 50% 4%,rgba(215,173,81,.14),transparent 36%),
    linear-gradient(160deg,#fffdf8 0%,#f2e6cf 100%)!important;
  border-color:rgba(183,127,25,.22)!important;
}
.rev-total__ring{
  width:118px!important;
  height:118px!important;
  min-width:118px!important;
  min-height:118px!important;
  border-radius:50%!important;
  display:grid!important;
  place-items:center!important;
  background:conic-gradient(#c78d24 0 56%,#e4bf68 56% 78%,#202a35 78% 91%,#f0dfb5 91% 100%)!important;
  box-shadow:0 10px 24px rgba(127,83,10,.15),inset 0 1px rgba(255,255,255,.4)!important;
}
.rev-total__ring::before{
  content:""!important;
  position:absolute!important;
  width:84px!important;
  height:84px!important;
  border-radius:50%!important;
  background:linear-gradient(180deg,#fffdf8,#f5eddd)!important;
  box-shadow:inset 0 1px 4px rgba(90,58,8,.08)!important;
}
.rev-total__ring-core{
  position:relative!important;
  z-index:2!important;
  display:grid!important;
  place-items:center!important;
  gap:2px!important;
  text-align:center!important;
}
.rev-total__ring-core strong{
  font-size:16px!important;
  line-height:1!important;
  color:#111821!important;
  font-weight:950!important;
  letter-spacing:-.04em!important;
}
.rev-total__ring-core small{
  font-size:7.5px!important;
  color:#9b8d78!important;
  font-weight:800!important;
}
.rev-total__copy{
  display:grid!important;
  place-items:center!important;
  gap:3px!important;
  text-align:center!important;
}
.rev-total__copy>span{
  font-size:7.8px!important;
  color:#9b8f7e!important;
  font-weight:780!important;
}
.rev-total__copy>strong{
  font-size:14px!important;
  line-height:1!important;
  color:#161c23!important;
  font-weight:950!important;
}
.rev-total__copy>small{
  font-size:7.3px!important;
  color:#9f9587!important;
}
.rev-total__copy>em{
  margin-top:3px!important;
  min-height:21px!important;
  padding:0 7px!important;
  display:inline-flex!important;
  align-items:center!important;
  gap:4px!important;
  border-radius:999px!important;
  font-size:8px!important;
  font-style:normal!important;
  font-weight:900!important;
  color:#138e62!important;
  background:rgba(18,185,120,.08)!important;
  border:1px solid rgba(18,185,120,.18)!important;
}
.rev-total__copy>em.down{
  color:#b95843!important;
  background:rgba(185,88,67,.08)!important;
  border-color:rgba(185,88,67,.18)!important;
}

/* ---------- RESPONSIVE REFERENCE GUARDS ---------- */
@media(max-width:1500px){
  .adm-chart-card{height:350px!important;min-height:350px!important;max-height:350px!important;padding:14px 15px!important}
  .adm-chart-card__head{height:40px!important;min-height:40px!important;margin-bottom:8px!important}
  .rev-title-copy h3{font-size:14px!important}
  .rev-stats{gap:7px!important;margin-bottom:9px!important}
  .rev-stat{height:61px!important;min-height:61px!important;padding:8px 9px 7px!important}
  .rev-stat strong{font-size:15px!important}
  .rev-visual-grid{grid-template-columns:minmax(0,3fr) minmax(215px,1fr)!important;height:208px!important;min-height:208px!important;gap:9px!important}
  .adm-chart-card .adex-chart,.rev-total{height:208px!important;min-height:208px!important}
  .rev-total__ring{width:108px!important;height:108px!important;min-width:108px!important;min-height:108px!important}
  .rev-total__ring::before{width:77px!important;height:77px!important}
}

@media(max-width:1100px){
  .admin-command-grid{
    grid-template-columns:1fr!important;
    grid-template-areas:"revenue" "live" "ops"!important;
  }
  .adm-chart-card{height:auto!important;min-height:350px!important;max-height:none!important}
  .rev-visual-grid{grid-template-columns:minmax(0,2.35fr) minmax(180px,1fr)!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V24.1 — REVENUE REFERENCE MATCH" "$TARGET_CSS"
  grep -q 'grid-template-areas:' "$TARGET_CSS"
  grep -q '"revenue revenue"' "$TARGET_CSS"
  grep -q 'grid-template-columns:minmax(0,3fr) minmax(250px,1fr)' "$TARGET_CSS"
  grep -q "import './AdminDashboard.v24.1.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v24.1-build.log 2>&1 || {
  tail -n 160 /tmp/67-v24.1-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V24"
echo "TARGET_VERSION=V24.1"
echo "RUNTIME_CSS=AdminDashboard.v24.1.css"
echo "ELEMENT=REVENUE_PERFORMANCE_REFERENCE_MATCH"
echo "REVENUE_FULL_WIDTH_ROW=YES"
echo "REVENUE_CHART_SHARE=75_PERCENT_APPROX"
echo "REVENUE_RING_SHARE=25_PERCENT_APPROX"
echo "REVENUE_SUMMARY_TILES=4"
echo "LIVE_OPERATIONS_CONTENT_CHANGED=NO"
echo "CURRENT_OPERATIONS_CONTENT_CHANGED=NO"
echo "LIVE_AND_CURRENT_OPERATIONS_MOVED_TO_ROW_2=YES"
echo "REVENUE_CHART_LOGIC_CHANGED=NO"
echo "REVENUE_VALUES_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
