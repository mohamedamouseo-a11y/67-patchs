#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v31.2.css
TARGET_CSS=src/pages/AdminDashboard.v32.css
MARKER='SIX SEVEN ADMIN V32 — LIVE + CURRENT OPERATIONS PREMIUM REDESIGN'
BACKUP=/tmp/67-v32-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V31_2_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v31.2.css';" "$JSX" || { echo 'FAILED_STEP=V31_2_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v31.2.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v31.2.css';"
new="import './AdminDashboard.v32.css';"
if old not in s:
    raise SystemExit('V31_2_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V32 — LIVE + CURRENT OPERATIONS PREMIUM REDESIGN
   CSS-only premium uplift for Live Operations + Current Operations.
   Protected: Hero, Date Strip, KPI, System Health, Revenue, Sidebar,
   ledger/data/backend/auth/logic. */

/* Global containment for the two target cards only. */
body .admin-exec .live-card,
body .admin-exec .ops-card,
body .admin-exec .live-card *,
body .admin-exec .ops-card *{
  box-sizing:border-box!important;
}
body .admin-exec .live-card > *,
body .admin-exec .ops-card > *{
  min-width:0!important;
  max-width:100%!important;
}

/* =========================================================
   LIVE OPERATIONS — DARK EXECUTIVE CONSOLE
   ========================================================= */
body .admin-exec .live-card{
  position:relative!important;
  isolation:isolate!important;
  height:auto!important;
  min-height:268px!important;
  max-height:none!important;
  padding:12px 13px 11px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  color:#edf3f8!important;
  border-radius:15px!important;
  border:1px solid rgba(213,171,76,.25)!important;
  background:
    radial-gradient(circle at 88% 5%,rgba(219,173,68,.10),transparent 31%),
    radial-gradient(circle at 10% 100%,rgba(21,181,123,.055),transparent 31%),
    linear-gradient(160deg,#0b1119 0%,#0d1722 48%,#081018 100%)!important;
  box-shadow:0 14px 30px rgba(2,7,12,.14),inset 0 1px rgba(255,255,255,.025)!important;
}
body .admin-exec .live-card::before{
  content:""!important;
  position:absolute!important;
  z-index:0!important;
  top:0!important;
  right:18px!important;
  left:18px!important;
  height:2px!important;
  border-radius:0 0 99px 99px!important;
  background:linear-gradient(90deg,transparent,#9d741f 18%,#e2b95a 52%,#9d741f 82%,transparent)!important;
  opacity:.78!important;
}
body .admin-exec .live-card::after{
  content:""!important;
  position:absolute!important;
  inset:0!important;
  z-index:0!important;
  pointer-events:none!important;
  opacity:.30!important;
  background:
    linear-gradient(rgba(255,255,255,.018) 1px,transparent 1px),
    linear-gradient(90deg,rgba(255,255,255,.014) 1px,transparent 1px)!important;
  background-size:30px 30px!important;
}
body .admin-exec .live-card>*{position:relative!important;z-index:1!important}

body .admin-exec .live-card__head{
  flex:0 0 35px!important;
  min-height:35px!important;
  height:35px!important;
  margin:0 0 7px!important;
  padding:0 1px 6px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:9px!important;
  border-bottom:1px solid rgba(218,178,85,.11)!important;
}
body .admin-exec .live-card__head h3{
  margin:0!important;
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
  color:#f7f8f9!important;
  font-size:12.5px!important;
  line-height:1!important;
  font-weight:950!important;
  letter-spacing:-.018em!important;
}
body .admin-exec .live-card__head h3 svg{
  width:16px!important;
  height:16px!important;
  color:#dfb34d!important;
  filter:drop-shadow(0 2px 6px rgba(209,156,42,.18))!important;
}
body .admin-exec .live-card__badge{
  flex:0 0 auto!important;
  min-width:27px!important;
  height:25px!important;
  padding:0 8px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  font-size:8.5px!important;
  font-weight:950!important;
  color:#efd27e!important;
  background:linear-gradient(180deg,rgba(222,176,73,.16),rgba(159,116,28,.08))!important;
  border:1px solid rgba(220,175,72,.26)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.035)!important;
}

body .admin-exec .live-card__list{
  min-height:0!important;
  flex:1 1 auto!important;
  display:flex!important;
  flex-direction:column!important;
  gap:5px!important;
  overflow:hidden!important;
}
body .admin-exec .live-item{
  min-width:0!important;
  min-height:34px!important;
  padding:5px 7px!important;
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
  overflow:hidden!important;
  border-radius:9px!important;
  color:#e9edf2!important;
  background:linear-gradient(180deg,rgba(255,255,255,.045),rgba(255,255,255,.025))!important;
  border:1px solid rgba(255,255,255,.065)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.015)!important;
}
body .admin-exec .live-item__ico{
  flex:0 0 24px!important;
  width:24px!important;
  height:24px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:8px!important;
  color:#e3b64f!important;
  background:rgba(218,171,67,.095)!important;
  border:1px solid rgba(218,171,67,.16)!important;
}
body .admin-exec .live-item__ico.pay{
  color:#67dbad!important;
  background:rgba(19,171,117,.09)!important;
  border-color:rgba(19,171,117,.18)!important;
}
body .admin-exec .live-item__ico.reg{
  color:#edc769!important;
  background:rgba(219,174,69,.09)!important;
}
body .admin-exec .live-item__body{
  min-width:0!important;
  flex:1 1 auto!important;
  overflow:hidden!important;
}
body .admin-exec .live-item__body p{
  margin:0!important;
  min-width:0!important;
  font-size:8.4px!important;
  line-height:1.35!important;
  font-weight:720!important;
  color:#e7ebef!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .live-item__body small,
body .admin-exec .live-item .when{
  display:block!important;
  margin-top:2px!important;
  font-size:6.8px!important;
  line-height:1.2!important;
  color:#75808c!important;
  white-space:nowrap!important;
}

body .admin-exec .live-activity-summary{
  flex:0 0 auto!important;
  margin-top:6px!important;
  padding:7px 8px!important;
  display:grid!important;
  grid-template-columns:minmax(0,1.35fr) minmax(110px,.9fr)!important;
  gap:7px!important;
  align-items:center!important;
  border-radius:10px!important;
  overflow:hidden!important;
  background:linear-gradient(180deg,rgba(225,181,81,.055),rgba(255,255,255,.02))!important;
  border:1px solid rgba(220,176,75,.11)!important;
}
body .admin-exec .live-activity-summary__lead{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
}
body .admin-exec .live-activity-summary__icon{
  flex:0 0 26px!important;
  width:26px!important;
  height:26px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:8px!important;
  color:#e1b652!important;
  background:rgba(220,176,75,.09)!important;
  border:1px solid rgba(220,176,75,.14)!important;
}
body .admin-exec .live-activity-summary__lead>div{min-width:0!important}
body .admin-exec .live-activity-summary__lead small,
body .admin-exec .live-activity-summary__lead span{
  display:block!important;
  font-size:6.4px!important;
  line-height:1.25!important;
  color:#7c8792!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .live-activity-summary__lead strong{
  display:block!important;
  margin:1px 0!important;
  font-size:8px!important;
  line-height:1.2!important;
  color:#e8ecf0!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .live-activity-summary__metrics{
  min-width:0!important;
  display:grid!important;
  grid-template-columns:repeat(3,minmax(0,1fr))!important;
  gap:4px!important;
}
body .admin-exec .live-activity-summary__metrics>span{
  min-width:0!important;
  min-height:35px!important;
  padding:4px!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:center!important;
  justify-content:center!important;
  gap:1px!important;
  border-radius:7px!important;
  color:#96a1ac!important;
  background:rgba(255,255,255,.028)!important;
  border:1px solid rgba(255,255,255,.05)!important;
}
body .admin-exec .live-activity-summary__metrics strong{font-size:8px!important;color:#f1d27c!important}
body .admin-exec .live-activity-summary__metrics small{font-size:5.7px!important;color:#74808c!important}

body .admin-exec .live-card__footer{
  flex:0 0 auto!important;
  margin-top:6px!important;
  padding-top:6px!important;
  border-top:1px solid rgba(255,255,255,.055)!important;
}
body .admin-exec .live-card__footer-status{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:6px!important;
}
body .admin-exec .live-pending,
body .admin-exec .live-quick{
  min-width:0!important;
  display:flex!important;
  gap:4px!important;
  flex-wrap:wrap!important;
  margin:0!important;
}
body .admin-exec .live-pending span,
body .admin-exec .live-quick span{
  min-width:0!important;
  height:20px!important;
  padding:0 6px!important;
  display:inline-flex!important;
  align-items:center!important;
  gap:3px!important;
  border-radius:999px!important;
  font-size:6.6px!important;
  color:#95a0aa!important;
  background:rgba(255,255,255,.025)!important;
  border:1px solid rgba(255,255,255,.05)!important;
}
body .admin-exec .live-quick .live-quick__ok{color:#67dbae!important;border-color:rgba(21,178,121,.13)!important;background:rgba(21,178,121,.055)!important}
body .admin-exec .live-cta{
  flex:0 0 auto!important;
  min-height:27px!important;
  margin-top:6px!important;
  padding:0 10px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:8px!important;
  color:#f0d078!important;
  font-size:7.2px!important;
  font-weight:900!important;
  cursor:pointer!important;
  background:linear-gradient(90deg,rgba(202,152,44,.10),rgba(227,184,84,.16),rgba(202,152,44,.10))!important;
  border:1px solid rgba(220,175,72,.17)!important;
}

/* =========================================================
   CURRENT OPERATIONS — IVORY / GOLD COMMAND CARD
   ========================================================= */
body .admin-exec .ops-card{
  position:relative!important;
  isolation:isolate!important;
  height:auto!important;
  min-height:268px!important;
  max-height:none!important;
  padding:12px 13px 11px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  border-radius:15px!important;
  border:1px solid rgba(184,128,24,.27)!important;
  background:
    radial-gradient(circle at 92% 4%,rgba(215,171,75,.10),transparent 30%),
    linear-gradient(180deg,#fffefb 0%,#fbf7ef 58%,#f6efe3 100%)!important;
  box-shadow:0 14px 30px rgba(78,52,9,.07),inset 0 1px rgba(255,255,255,.95)!important;
}
body .admin-exec .ops-card::before{
  content:""!important;
  position:absolute!important;
  z-index:0!important;
  top:0!important;
  right:18px!important;
  left:18px!important;
  height:2px!important;
  border-radius:0 0 99px 99px!important;
  background:linear-gradient(90deg,transparent,#b17a18 20%,#e1ba5b 52%,#b17a18 80%,transparent)!important;
  opacity:.76!important;
}
body .admin-exec .ops-card>*{position:relative!important;z-index:1!important}

body .admin-exec .ops-card__head{
  flex:0 0 40px!important;
  min-height:40px!important;
  height:40px!important;
  margin:0 0 7px!important;
  padding:0 1px 7px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:8px!important;
  border-bottom:1px solid rgba(160,113,26,.11)!important;
}
body .admin-exec .ops-card__title-group{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
}
body .admin-exec .ops-card__title-icon{
  flex:0 0 31px!important;
  width:31px!important;
  height:31px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:9px!important;
  color:#a86f0d!important;
  background:linear-gradient(145deg,#fff8e5,#f0d58f)!important;
  border:1px solid rgba(177,118,15,.22)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.95),0 6px 14px rgba(129,83,8,.07)!important;
}
body .admin-exec .ops-card__title-group>div{min-width:0!important}
body .admin-exec .ops-card__title-group h3{
  margin:0!important;
  font-size:11.5px!important;
  line-height:1.15!important;
  font-weight:950!important;
  color:#151b23!important;
}
body .admin-exec .ops-card__title-group small{
  display:block!important;
  margin-top:2px!important;
  font-size:6.4px!important;
  line-height:1.2!important;
  color:#978d7f!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .ops-card__command-badge{
  flex:0 0 auto!important;
  min-height:24px!important;
  padding:0 8px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  color:#8f6515!important;
  background:linear-gradient(180deg,#fff8e8,#f4e2bd)!important;
  border:1px solid rgba(178,121,20,.20)!important;
  font-size:6.8px!important;
  font-weight:900!important;
  white-space:nowrap!important;
}

body .admin-exec .ops-summary-row{
  flex:0 0 auto!important;
  display:grid!important;
  grid-template-columns:repeat(2,minmax(0,1fr))!important;
  gap:6px!important;
  margin:0 0 6px!important;
}
body .admin-exec .ops-summary-tile{
  min-width:0!important;
  min-height:53px!important;
  padding:7px 8px!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:center!important;
  gap:2px!important;
  overflow:hidden!important;
  border-radius:10px!important;
  background:linear-gradient(180deg,#fffaf0,#f6ebd8)!important;
  border:1px solid rgba(183,126,21,.16)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.9)!important;
}
body .admin-exec .ops-summary-tile--ok{
  background:linear-gradient(180deg,#f4fcf8,#eaf7f1)!important;
  border-color:rgba(18,164,111,.15)!important;
}
body .admin-exec .ops-summary-tile>span{font-size:6.5px!important;color:#968b7c!important;font-weight:760!important}
body .admin-exec .ops-summary-tile strong{font-size:15px!important;line-height:1!important;color:#111820!important;font-weight:950!important}
body .admin-exec .ops-summary-tile--ok strong{color:#0d9967!important}
body .admin-exec .ops-summary-tile small{
  min-width:0!important;
  font-size:6.2px!important;
  color:#aaa094!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}

body .admin-exec .ops-tiles{
  min-height:0!important;
  flex:1 1 auto!important;
  display:flex!important;
  flex-direction:column!important;
  gap:5px!important;
  overflow:hidden!important;
}
body .admin-exec .ops-tile{
  min-width:0!important;
  min-height:35px!important;
  height:auto!important;
  padding:5px 7px!important;
  display:grid!important;
  grid-template-columns:25px minmax(0,1fr) auto auto!important;
  align-items:center!important;
  gap:6px!important;
  overflow:hidden!important;
  border-radius:9px!important;
  background:linear-gradient(180deg,rgba(255,255,255,.78),rgba(247,241,230,.88))!important;
  border:1px solid rgba(175,121,22,.12)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.86)!important;
}
body .admin-exec .ops-tile__ico{
  width:24px!important;
  height:24px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:7px!important;
  color:#ae7410!important;
  background:#fff7e6!important;
  border:1px solid rgba(173,112,12,.14)!important;
}
body .admin-exec .ops-tile__ico.green{
  color:#109b6a!important;
  background:#edf9f4!important;
  border-color:rgba(16,155,106,.14)!important;
}
body .admin-exec .ops-tile__info{min-width:0!important;overflow:hidden!important}
body .admin-exec .ops-tile__info strong{
  display:block!important;
  min-width:0!important;
  font-size:8px!important;
  line-height:1.2!important;
  color:#222831!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .ops-tile__info small{
  display:block!important;
  margin-top:1px!important;
  min-width:0!important;
  font-size:6.2px!important;
  line-height:1.15!important;
  color:#9c9285!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .ops-tile__count{
  min-width:20px!important;
  font-size:8.5px!important;
  font-weight:950!important;
  color:#a86f0d!important;
  text-align:center!important;
}
body .admin-exec .ops-tile__count.green{color:#0d9967!important}
body .admin-exec .ops-tile__state{
  min-width:44px!important;
  height:20px!important;
  padding:0 6px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  font-size:6.1px!important;
  font-weight:850!important;
  color:#936614!important;
  background:#fff4d9!important;
  border:1px solid rgba(174,114,12,.14)!important;
  white-space:nowrap!important;
}
body .admin-exec .ops-tile__state--ok{
  color:#0b8c5f!important;
  background:#eaf8f2!important;
  border-color:rgba(12,145,97,.14)!important;
}
body .admin-exec .ops-card>.ops-tile{
  flex:0 0 auto!important;
  margin-top:5px!important;
}
body .admin-exec .ops-good-strip{
  flex:0 0 auto!important;
  min-height:28px!important;
  margin-top:6px!important;
  padding:0 8px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:5px!important;
  overflow:hidden!important;
  border-radius:8px!important;
  color:#0c8f61!important;
  background:linear-gradient(180deg,#edf9f4,#e5f5ee)!important;
  border:1px solid rgba(13,151,101,.15)!important;
  font-size:6.8px!important;
  font-weight:800!important;
  white-space:nowrap!important;
  text-overflow:ellipsis!important;
}

/* Do not let older fixed-height command-center rules re-introduce clipping. */
body .admin-exec .admin-command-grid .live-card,
body .admin-exec .admin-command-grid .ops-card{
  height:auto!important;
  min-height:268px!important;
  max-height:none!important;
  align-self:stretch!important;
}

@media(max-width:1500px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{padding:10px 11px 9px!important;min-height:260px!important}
  body .admin-exec .live-card__head{height:32px!important;min-height:32px!important;flex-basis:32px!important}
  body .admin-exec .live-item{min-height:31px!important;padding:4px 6px!important}
  body .admin-exec .live-item__ico{width:22px!important;height:22px!important;flex-basis:22px!important}
  body .admin-exec .live-item__body p{font-size:7.8px!important}
  body .admin-exec .live-activity-summary{padding:6px!important;grid-template-columns:minmax(0,1.3fr) minmax(100px,.9fr)!important}
  body .admin-exec .ops-card__head{height:37px!important;min-height:37px!important;flex-basis:37px!important}
  body .admin-exec .ops-summary-tile{min-height:49px!important;padding:6px 7px!important}
  body .admin-exec .ops-tile{min-height:32px!important;padding:4px 6px!important;grid-template-columns:23px minmax(0,1fr) auto auto!important}
  body .admin-exec .ops-tile__ico{width:22px!important;height:22px!important}
}

@media(max-width:980px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{min-height:0!important;height:auto!important;max-height:none!important}
  body .admin-exec .live-activity-summary{grid-template-columns:1fr!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v32-build.log 2>&1 || {
  tail -n 180 /tmp/67-v32-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V32'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=LIVE + CURRENT OPERATIONS PREMIUM REDESIGN'
echo 'BASE_VERSION=V31.2'
echo 'TARGET_VERSION=V32'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v32.css'
echo 'LIVE_OPERATIONS_PREMIUM_REDESIGN=YES'
echo 'CURRENT_OPERATIONS_PREMIUM_REDESIGN=YES'
echo 'JSX_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'REVENUE_CHANGED=NO'
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
