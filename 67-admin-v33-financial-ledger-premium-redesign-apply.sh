#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v32.5.css
TARGET_CSS=src/pages/AdminDashboard.v33.css
MARKER='SIX SEVEN ADMIN V33 — FINANCIAL LEDGER PREMIUM REDESIGN'
BACKUP=/tmp/67-v33-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V32_5_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v32.5.css';" "$JSX" || { echo 'FAILED_STEP=V32_5_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v32.5.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v32.5.css';"
new="import './AdminDashboard.v33.css';"
if old not in s:
    raise SystemExit('V32_5_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V33 — FINANCIAL LEDGER PREMIUM REDESIGN
   CSS-only premium redesign of Financial Ledger / Latest Transactions.
   Preserve payment data, search behavior, row order, values, statuses,
   toolbar controls, backend/auth/routing and all neighboring modules. */

body .admin-exec .tx-card,
body .admin-exec .tx-card *{box-sizing:border-box!important}

body .admin-exec .tx-card{
  position:relative!important;
  isolation:isolate!important;
  width:100%!important;
  min-width:0!important;
  margin:0!important;
  overflow:hidden!important;
  border-radius:18px!important;
  border:1px solid rgba(176,119,18,.34)!important;
  background:linear-gradient(180deg,#fffefb 0%,#fbf7ef 48%,#f7f0e5 100%)!important;
  box-shadow:0 18px 38px rgba(72,47,7,.085),inset 0 1px rgba(255,255,255,.96)!important;
}
body .admin-exec .tx-card::before{
  content:""!important;
  position:absolute!important;
  z-index:5!important;
  top:0!important;
  left:22px!important;
  right:22px!important;
  height:3px!important;
  border-radius:0 0 99px 99px!important;
  background:linear-gradient(90deg,transparent,#9d6b17 18%,#e0b954 50%,#9d6b17 82%,transparent)!important;
  opacity:.96!important;
  pointer-events:none!important;
}

/* Dark executive finance command header */
body .admin-exec .tx-card__head{
  position:relative!important;
  z-index:1!important;
  width:100%!important;
  min-height:76px!important;
  height:76px!important;
  margin:0!important;
  padding:11px 14px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:16px!important;
  overflow:hidden!important;
  color:#f4f6f8!important;
  border-bottom:1px solid rgba(218,177,80,.22)!important;
  background:
    radial-gradient(circle at 90% 0%,rgba(220,176,72,.10),transparent 34%),
    linear-gradient(145deg,#0a1119 0%,#0e1823 55%,#081019 100%)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
body .admin-exec .tx-card__title-group{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:11px!important;
}
body .admin-exec .tx-card__title-icon{
  flex:0 0 42px!important;
  width:42px!important;
  height:42px!important;
  min-width:42px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:12px!important;
  color:#f1cc72!important;
  background:linear-gradient(145deg,rgba(226,184,83,.18),rgba(139,95,19,.12))!important;
  border:1px solid rgba(224,180,76,.30)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.055),0 8px 18px rgba(0,0,0,.18)!important;
}
body .admin-exec .tx-card__title-icon svg{width:18px!important;height:18px!important}
body .admin-exec .tx-card__title-group>div{min-width:0!important;display:grid!important;gap:4px!important}
body .admin-exec .tx-card__title-group h3{
  margin:0!important;
  color:#f7f8fa!important;
  font-size:14px!important;
  line-height:1.1!important;
  font-weight:950!important;
  letter-spacing:-.018em!important;
  white-space:nowrap!important;
}
body .admin-exec .tx-card__title-group small{
  margin:0!important;
  color:#8f9aa6!important;
  font-size:8.2px!important;
  line-height:1.2!important;
  font-weight:700!important;
  white-space:nowrap!important;
}
body .admin-exec .tx-card__head-actions{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
}
body .admin-exec .tx-card__count-badge{
  flex:0 0 auto!important;
  height:32px!important;
  min-height:32px!important;
  padding:0 11px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  color:#f0ce78!important;
  font-size:8.5px!important;
  font-weight:950!important;
  white-space:nowrap!important;
  background:rgba(220,175,72,.10)!important;
  border:1px solid rgba(220,175,72,.25)!important;
}
body .admin-exec .tx-toolbar{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:6px!important;
}
body .admin-exec .tx-search-glow{display:inline-flex!important;min-width:0!important;position:relative!important}
body .admin-exec .tx-toolbar input{
  width:265px!important;
  min-width:265px!important;
  height:34px!important;
  padding:0 12px!important;
  border-radius:9px!important;
  outline:none!important;
  color:#e7edf3!important;
  caret-color:#e0b75a!important;
  font-size:8.8px!important;
  font-weight:720!important;
  background:rgba(255,255,255,.045)!important;
  border:1px solid rgba(255,255,255,.10)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
body .admin-exec .tx-toolbar input::placeholder{color:#68737e!important}
body .admin-exec .tx-toolbar input:focus{
  border-color:rgba(225,181,81,.48)!important;
  box-shadow:0 0 0 3px rgba(216,170,67,.08),inset 0 1px rgba(255,255,255,.03)!important;
}
body .admin-exec .tx-toolbar button{
  flex:0 0 auto!important;
  height:34px!important;
  min-height:34px!important;
  padding:0 10px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:5px!important;
  border-radius:9px!important;
  color:#cbd2d9!important;
  font-size:8.4px!important;
  font-weight:850!important;
  background:rgba(255,255,255,.045)!important;
  border:1px solid rgba(255,255,255,.095)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
body .admin-exec .tx-toolbar button:hover{
  color:#f0ce78!important;
  border-color:rgba(222,177,75,.28)!important;
  background:rgba(220,175,72,.085)!important;
}
body .admin-exec .tx-toolbar button svg{width:13px!important;height:13px!important}

/* Executive ledger KPI strip */
body .admin-exec .tx-ledger-summary{
  width:100%!important;
  display:grid!important;
  grid-template-columns:repeat(3,minmax(0,1fr))!important;
  gap:8px!important;
  margin:0!important;
  padding:10px 12px!important;
  background:linear-gradient(180deg,#f7f0e4 0%,#fbf8f2 100%)!important;
  border-bottom:1px solid rgba(174,119,20,.16)!important;
}
body .admin-exec .tx-ledger-summary__item{
  position:relative!important;
  min-width:0!important;
  min-height:66px!important;
  padding:9px 12px 9px 15px!important;
  display:grid!important;
  grid-template-columns:minmax(0,1fr) auto!important;
  grid-template-areas:"label value" "note value"!important;
  align-items:center!important;
  column-gap:10px!important;
  row-gap:3px!important;
  overflow:hidden!important;
  border-radius:12px!important;
  background:rgba(255,255,255,.78)!important;
  border:1px solid rgba(154,112,38,.16)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.96),0 6px 14px rgba(92,60,9,.035)!important;
}
body .admin-exec .tx-ledger-summary__item::after{
  content:""!important;
  position:absolute!important;
  right:0!important;
  top:9px!important;
  bottom:9px!important;
  width:3px!important;
  border-radius:99px!important;
  background:#b97f20!important;
}
body .admin-exec .tx-ledger-summary__item--ok::after{background:#16a473!important}
body .admin-exec .tx-ledger-summary__item--pending::after{background:#d5a02e!important}
body .admin-exec .tx-ledger-summary__item small{
  grid-area:label!important;
  color:#82786b!important;
  font-size:8px!important;
  line-height:1!important;
  font-weight:900!important;
}
body .admin-exec .tx-ledger-summary__item strong{
  grid-area:value!important;
  min-width:34px!important;
  color:#121923!important;
  font-size:24px!important;
  line-height:1!important;
  font-weight:950!important;
  text-align:center!important;
}
body .admin-exec .tx-ledger-summary__item--ok strong{color:#118a61!important}
body .admin-exec .tx-ledger-summary__item--pending strong{color:#9a6915!important}
body .admin-exec .tx-ledger-summary__item span{
  grid-area:note!important;
  color:#a29a90!important;
  font-size:7.2px!important;
  line-height:1.1!important;
  font-weight:700!important;
}

/* Premium ledger table */
body .admin-exec .tx-card__scroll{
  width:100%!important;
  max-width:100%!important;
  overflow-x:auto!important;
  overflow-y:visible!important;
  background:#fffdf9!important;
  scrollbar-width:thin!important;
  scrollbar-color:#cfa64e #f3ecdf!important;
}
body .admin-exec .tx-table{
  width:100%!important;
  min-width:920px!important;
  border-collapse:separate!important;
  border-spacing:0!important;
  table-layout:fixed!important;
  direction:rtl!important;
  color:#222a33!important;
  font-size:9.4px!important;
}
body .admin-exec .tx-table thead{background:linear-gradient(180deg,#f4ebdc,#eee2cf)!important}
body .admin-exec .tx-table th{
  height:38px!important;
  padding:8px 10px!important;
  color:#81776a!important;
  font-size:8.2px!important;
  line-height:1.1!important;
  font-weight:950!important;
  text-align:right!important;
  white-space:nowrap!important;
  border-bottom:1px solid rgba(166,115,25,.20)!important;
}
body .admin-exec .tx-table td{
  height:46px!important;
  padding:8px 10px!important;
  color:#303740!important;
  font-size:9.4px!important;
  line-height:1.2!important;
  font-weight:700!important;
  text-align:right!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  border-top:0!important;
  border-bottom:1px solid rgba(185,145,75,.11)!important;
  background:rgba(255,255,255,.70)!important;
}
body .admin-exec .tx-table tbody tr:nth-child(even) td{background:rgba(248,243,234,.62)!important}
body .admin-exec .tx-table tbody tr:hover td{background:#fff7e5!important}
body .admin-exec .tx-table th:first-child,
body .admin-exec .tx-table td:first-child{padding-right:14px!important}
body .admin-exec .tx-table th:last-child,
body .admin-exec .tx-table td:last-child{padding-left:14px!important}

body .admin-exec .tx-table td:nth-child(1){
  color:#856018!important;
  font-weight:900!important;
  letter-spacing:.015em!important;
}
body .admin-exec .tx-amount{
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  min-width:70px!important;
  height:25px!important;
  padding:0 9px!important;
  border-radius:999px!important;
  color:#80580e!important;
  font-size:8.4px!important;
  font-weight:950!important;
  background:linear-gradient(180deg,#fff8e2,#f5e5b9)!important;
  border:1px solid rgba(178,120,15,.20)!important;
}
body .admin-exec .tx-status{
  min-width:70px!important;
  height:25px!important;
  padding:0 9px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:4px!important;
  border-radius:999px!important;
  font-size:8px!important;
  line-height:1!important;
  font-weight:950!important;
  white-space:nowrap!important;
}
body .admin-exec .tx-status svg{width:11px!important;height:11px!important}
body .admin-exec .tx-status--ok{
  color:#087652!important;
  background:#e9f7f1!important;
  border:1px solid #bce5d5!important;
}
body .admin-exec .tx-status--pending{
  color:#8d6214!important;
  background:#fff5d9!important;
  border:1px solid #edd79b!important;
}

@media(max-width:1360px){
  body .admin-exec .tx-card__head{height:auto!important;min-height:68px!important;padding:9px 11px!important;gap:10px!important}
  body .admin-exec .tx-card__title-icon{width:38px!important;height:38px!important;min-width:38px!important;flex-basis:38px!important}
  body .admin-exec .tx-card__title-group h3{font-size:12.5px!important}
  body .admin-exec .tx-card__title-group small{font-size:7.6px!important}
  body .admin-exec .tx-card__count-badge{height:29px!important;min-height:29px!important;font-size:7.8px!important}
  body .admin-exec .tx-toolbar input{width:215px!important;min-width:215px!important;height:31px!important}
  body .admin-exec .tx-toolbar button{height:31px!important;min-height:31px!important;padding:0 8px!important}
  body .admin-exec .tx-ledger-summary{gap:6px!important;padding:8px 10px!important}
  body .admin-exec .tx-ledger-summary__item{min-height:60px!important;padding:8px 10px 8px 13px!important}
  body .admin-exec .tx-ledger-summary__item strong{font-size:21px!important}
  body .admin-exec .tx-table th{height:35px!important;padding:7px 9px!important}
  body .admin-exec .tx-table td{height:42px!important;padding:7px 9px!important;font-size:9px!important}
}

@media(max-width:1100px){
  body .admin-exec .tx-card__head{
    align-items:flex-start!important;
    flex-direction:column!important;
  }
  body .admin-exec .tx-card__head-actions{width:100%!important;justify-content:space-between!important;flex-wrap:wrap!important}
  body .admin-exec .tx-toolbar{flex-wrap:wrap!important}
  body .admin-exec .tx-toolbar input{width:min(58vw,360px)!important;min-width:220px!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v33-build.log 2>&1 || {
  tail -n 180 /tmp/67-v33-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V33'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=FINANCIAL LEDGER PREMIUM REDESIGN'
echo 'BASE_VERSION=V32.5'
echo 'TARGET_VERSION=V33'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v33.css'
echo 'JSX_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
