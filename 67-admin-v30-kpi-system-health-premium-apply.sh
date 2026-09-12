#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.6.3.css
TARGET_CSS=src/pages/AdminDashboard.v30.css
MARKER='SIX SEVEN ADMIN V30 — KPI + SYSTEM HEALTH PREMIUM POLISH'
BACKUP=/tmp/67-v30-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V29_6_3_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.6.3.css';" "$JSX" || { echo 'FAILED_STEP=V29_6_3_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v29.6.3.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.6.3.css';"
new="import './AdminDashboard.v30.css';"
if old not in s:
    raise SystemExit('V29_6_3_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V30 — KPI + SYSTEM HEALTH PREMIUM POLISH
   Visual-only upgrade for KPI signal cards and the system-health command center.
   Protected: Hero, Date Strip, Sidebar, Revenue, business logic, data, backend, auth. */

/* ---------------------------------------------------------
   KPI SIGNAL ROW — EXECUTIVE IVORY / GOLD MATERIAL SYSTEM
   --------------------------------------------------------- */
body .admin-exec .kpi-grid{
  gap:10px!important;
  margin:0!important;
  align-items:stretch!important;
}
body .admin-exec .kpi-grid .kpi-card{
  --v30-signal:#c89124;
  --v30-signal-soft:rgba(200,145,36,.11);
  box-sizing:border-box!important;
  position:relative!important;
  height:108px!important;
  min-height:108px!important;
  padding:12px 14px 11px!important;
  border-radius:15px!important;
  overflow:hidden!important;
  isolation:isolate!important;
  background:
    radial-gradient(circle at 88% 8%,var(--v30-signal-soft),transparent 27%),
    linear-gradient(180deg,#fffefb 0%,#fbf7ef 58%,#f5eee2 100%)!important;
  border:1px solid rgba(184,128,24,.26)!important;
  box-shadow:
    0 10px 26px rgba(74,49,8,.065),
    inset 0 1px rgba(255,255,255,.92)!important;
  transition:transform .18s ease,border-color .18s ease,box-shadow .18s ease!important;
}
body .admin-exec .kpi-grid .kpi-card:nth-child(1){--v30-signal:#c58a1f;--v30-signal-soft:rgba(197,138,31,.13)}
body .admin-exec .kpi-grid .kpi-card:nth-child(2){--v30-signal:#12ad76;--v30-signal-soft:rgba(18,173,118,.105)}
body .admin-exec .kpi-grid .kpi-card:nth-child(3){--v30-signal:#a9711c;--v30-signal-soft:rgba(169,113,28,.11)}
body .admin-exec .kpi-grid .kpi-card:nth-child(4){--v30-signal:#65798f;--v30-signal-soft:rgba(101,121,143,.11)}
body .admin-exec .kpi-grid .kpi-card::before{
  content:""!important;
  position:absolute!important;
  z-index:0!important;
  top:0!important;
  left:18px!important;
  right:18px!important;
  height:2px!important;
  border-radius:0 0 99px 99px!important;
  background:linear-gradient(90deg,transparent,var(--v30-signal),transparent)!important;
  opacity:.76!important;
}
body .admin-exec .kpi-grid .kpi-card::after{
  content:""!important;
  position:absolute!important;
  z-index:0!important;
  width:74px!important;
  height:74px!important;
  left:-24px!important;
  bottom:-34px!important;
  border-radius:50%!important;
  background:radial-gradient(circle,var(--v30-signal-soft),transparent 68%)!important;
  opacity:.82!important;
  clip-path:none!important;
}
body .admin-exec .kpi-grid .kpi-card>*{position:relative!important;z-index:2!important}
body .admin-exec .kpi-grid .kpi-card:hover{
  transform:translateY(-1px)!important;
  border-color:color-mix(in srgb,var(--v30-signal) 42%,transparent)!important;
  box-shadow:0 14px 30px rgba(65,43,7,.09),inset 0 1px rgba(255,255,255,.95)!important;
}
body .admin-exec .kpi-card__top{
  min-height:34px!important;
  display:flex!important;
  align-items:flex-start!important;
  justify-content:space-between!important;
  gap:10px!important;
}
body .admin-exec .kpi-card__label{
  padding-top:3px!important;
  font-size:9.6px!important;
  line-height:1.25!important;
  font-weight:850!important;
  color:#766f64!important;
  letter-spacing:-.01em!important;
}
body .admin-exec .kpi-card__icon{
  width:38px!important;
  height:38px!important;
  min-width:38px!important;
  border-radius:11px!important;
  display:grid!important;
  place-items:center!important;
  color:var(--v30-signal)!important;
  background:linear-gradient(145deg,rgba(255,255,255,.95),var(--v30-signal-soft))!important;
  border:1px solid color-mix(in srgb,var(--v30-signal) 25%,transparent)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.9),0 7px 16px rgba(92,59,8,.07)!important;
}
body .admin-exec .kpi-card__value{
  margin:0!important;
  font-size:29px!important;
  line-height:.98!important;
  font-weight:950!important;
  color:#07101b!important;
  letter-spacing:-.045em!important;
  font-variant-numeric:tabular-nums!important;
}
body .admin-exec .kpi-card__value small{
  margin-inline-start:3px!important;
  font-size:8.5px!important;
  font-weight:800!important;
  color:#8d8578!important;
  letter-spacing:0!important;
}
body .admin-exec .kpi-card__note{
  min-height:19px!important;
  padding:6px 0 0!important;
  margin:0!important;
  display:flex!important;
  align-items:center!important;
  gap:5px!important;
  border-top:1px solid rgba(124,94,39,.08)!important;
  color:var(--v30-signal)!important;
  font-size:8.1px!important;
  font-weight:720!important;
  white-space:nowrap!important;
  overflow:hidden!important;
}
body .admin-exec .kpi-card__note .muted{color:#7f786d!important;overflow:hidden!important;text-overflow:ellipsis!important}
body .admin-exec .kpi-microbar{
  display:inline-flex!important;
  align-items:flex-end!important;
  gap:2px!important;
  height:13px!important;
  min-width:24px!important;
  margin-inline-end:1px!important;
}
body .admin-exec .kpi-microbar>span{
  display:block!important;
  width:3px!important;
  border-radius:3px 3px 1px 1px!important;
  background:var(--v30-signal)!important;
  opacity:.72!important;
}
body .admin-exec .kpi-microbar>span:nth-child(1){height:4px!important;opacity:.32!important}
body .admin-exec .kpi-microbar>span:nth-child(2){height:7px!important;opacity:.43!important}
body .admin-exec .kpi-microbar>span:nth-child(3){height:9px!important;opacity:.55!important}
body .admin-exec .kpi-microbar>span:nth-child(4){height:11px!important;opacity:.66!important}
body .admin-exec .kpi-microbar>span:nth-child(5){height:13px!important;opacity:.82!important}

/* ---------------------------------------------------------
   SYSTEM HEALTH — DARK EXECUTIVE COMMAND CENTER
   --------------------------------------------------------- */
body .admin-exec .syshealth{
  position:relative!important;
  height:126px!important;
  min-height:126px!important;
  margin:0!important;
  border-radius:16px!important;
  overflow:hidden!important;
  isolation:isolate!important;
  background:
    radial-gradient(circle at 64% -20%,rgba(47,102,143,.16),transparent 35%),
    linear-gradient(104deg,#04080d 0%,#09121c 44%,#0d1925 72%,#071019 100%)!important;
  border:1px solid rgba(207,161,67,.22)!important;
  box-shadow:0 14px 34px rgba(0,0,0,.15),inset 0 1px rgba(255,255,255,.025)!important;
}
body .admin-exec .syshealth::before{
  content:""!important;
  position:absolute!important;
  z-index:6!important;
  left:28px!important;
  right:28px!important;
  top:0!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,rgba(224,186,90,.55),rgba(62,198,151,.28),transparent)!important;
}
body .admin-exec .syshealth__layout{
  position:relative!important;
  z-index:3!important;
  display:grid!important;
  grid-template-columns:minmax(220px,1.02fr) minmax(520px,2.2fr) minmax(260px,1.25fr)!important;
  direction:ltr!important;
  height:100%!important;
  gap:9px!important;
  padding:9px 11px!important;
}
body .admin-exec .syshealth__layout>*{direction:rtl!important;min-width:0!important}
body .admin-exec .syshealth__zone-left{
  box-sizing:border-box!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:center!important;
  padding:11px 12px!important;
  border:1px solid rgba(255,255,255,.055)!important;
  border-radius:12px!important;
  background:linear-gradient(180deg,rgba(9,15,22,.72),rgba(4,9,14,.68))!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
body .admin-exec .syshealth__head{display:flex!important;flex-direction:column!important;gap:7px!important}
body .admin-exec .syshealth__title{
  margin:0!important;
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  font-size:11.2px!important;
  line-height:1.25!important;
  font-weight:900!important;
  color:#f4f0e7!important;
}
body .admin-exec .syshealth__title .ico{
  width:30px!important;
  height:30px!important;
  min-width:30px!important;
  border-radius:9px!important;
  display:grid!important;
  place-items:center!important;
  color:#dfb957!important;
  background:linear-gradient(145deg,rgba(223,185,87,.16),rgba(223,185,87,.035))!important;
  border:1px solid rgba(223,185,87,.22)!important;
}
body .admin-exec .syshealth__title small{
  display:block!important;
  margin-top:2px!important;
  font-size:7.3px!important;
  font-weight:600!important;
  color:#7f8a96!important;
}
body .admin-exec .syshealth__status{
  width:max-content!important;
  max-width:100%!important;
  padding:4px 8px!important;
  border-radius:999px!important;
  display:inline-flex!important;
  align-items:center!important;
  gap:5px!important;
  color:#7de5bc!important;
  background:rgba(18,178,119,.08)!important;
  border:1px solid rgba(18,178,119,.17)!important;
  font-size:7.8px!important;
  font-weight:850!important;
}
body .admin-exec .syshealth__status-text{
  margin-top:7px!important;
  padding-top:7px!important;
  border-top:1px solid rgba(255,255,255,.045)!important;
  font-size:7.2px!important;
  line-height:1.45!important;
  color:#697581!important;
}
body .admin-exec .syshealth__status-text p{margin:0!important}
body .admin-exec .syshealth__zone-center{display:flex!important;align-items:stretch!important;min-width:0!important}
body .admin-exec .syshealth__metrics{width:100%!important;min-width:0!important}
body .admin-exec .syshealth__grid{
  width:100%!important;
  height:100%!important;
  display:grid!important;
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:7px!important;
}
body .admin-exec .syshealth__metric{
  position:relative!important;
  box-sizing:border-box!important;
  min-width:0!important;
  height:auto!important;
  min-height:0!important;
  padding:10px 10px 8px!important;
  border-radius:12px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:space-between!important;
  background:
    radial-gradient(circle at 82% 4%,rgba(67,121,163,.14),transparent 34%),
    linear-gradient(180deg,#152435 0%,#0d1925 100%)!important;
  border:1px solid rgba(134,165,190,.105)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.028),0 8px 20px rgba(0,0,0,.10)!important;
}
body .admin-exec .syshealth__metric::before{
  content:""!important;
  position:absolute!important;
  right:0!important;
  top:12px!important;
  bottom:12px!important;
  width:2px!important;
  border-radius:99px!important;
  background:linear-gradient(180deg,transparent,#d2aa4c,transparent)!important;
  opacity:.48!important;
}
body .admin-exec .syshealth__metric label{
  font-size:7.7px!important;
  line-height:1.25!important;
  font-weight:760!important;
  color:#8f9ba7!important;
}
body .admin-exec .syshealth__metric strong{
  margin:3px 0!important;
  font-size:20px!important;
  line-height:1!important;
  font-weight:950!important;
  letter-spacing:-.035em!important;
  color:#f7f9fb!important;
  font-variant-numeric:tabular-nums!important;
}
body .admin-exec .syshealth__metric small{
  font-size:6.8px!important;
  color:#63717f!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .syshealth__bar{
  height:3px!important;
  margin:2px 0 4px!important;
  border-radius:99px!important;
  overflow:hidden!important;
  background:#223242!important;
  box-shadow:inset 0 1px 2px rgba(0,0,0,.24)!important;
}
body .admin-exec .syshealth__bar span{
  display:block!important;
  height:100%!important;
  border-radius:99px!important;
  background:linear-gradient(90deg,#23c58a,#d9ad4d)!important;
  box-shadow:0 0 8px rgba(35,197,138,.15)!important;
}
body .admin-exec .syshealth__zone-right{
  position:relative!important;
  height:100%!important;
  border-radius:12px!important;
  overflow:hidden!important;
  background-image:
    linear-gradient(90deg,rgba(5,9,14,.62) 0%,rgba(5,9,14,.15) 36%,rgba(5,9,14,.05) 64%,rgba(5,9,14,.48) 100%),
    linear-gradient(180deg,rgba(0,0,0,.03),rgba(0,0,0,.27)),
    url('../assets/admin-v17-health.jpg')!important;
  background-size:cover!important;
  background-position:center 56%!important;
  background-repeat:no-repeat!important;
  border:1px solid rgba(211,166,72,.12)!important;
  box-shadow:inset 0 0 30px rgba(0,0,0,.22)!important;
}
body .admin-exec .syshealth__zone-right::after{
  content:"LIVE INFRASTRUCTURE"!important;
  position:absolute!important;
  left:10px!important;
  bottom:8px!important;
  padding:3px 6px!important;
  border-radius:999px!important;
  font-size:5.8px!important;
  font-weight:850!important;
  letter-spacing:.12em!important;
  color:#d8c58d!important;
  background:rgba(3,7,11,.65)!important;
  border:1px solid rgba(218,178,80,.13)!important;
  backdrop-filter:blur(8px)!important;
}
body .admin-exec .syshealth__road-accent{
  position:absolute!important;
  z-index:7!important;
  left:18px!important;
  right:18px!important;
  bottom:0!important;
  height:2px!important;
  background:linear-gradient(90deg,transparent,#9d1519 14%,#dd1d23 47%,#c1171c 78%,transparent)!important;
  opacity:.62!important;
  box-shadow:0 0 10px rgba(213,25,32,.16)!important;
}

@media(max-width:1450px){
  body .admin-exec .syshealth__layout{
    grid-template-columns:minmax(200px,.9fr) minmax(460px,2fr) minmax(220px,1fr)!important;
  }
  body .admin-exec .kpi-card__value{font-size:27px!important}
}

@media(max-width:1180px){
  body .admin-exec .kpi-grid{gap:7px!important}
  body .admin-exec .kpi-grid .kpi-card{padding:11px 11px 10px!important}
  body .admin-exec .syshealth__layout{grid-template-columns:1fr 2.25fr!important}
  body .admin-exec .syshealth__zone-right{display:none!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v30-build.log 2>&1 || {
  tail -n 180 /tmp/67-v30-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V30'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=KPI + SYSTEM HEALTH PREMIUM POLISH'
echo 'BASE_VERSION=V29.6.3'
echo 'TARGET_VERSION=V30'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v30.css'
echo 'KPI_PREMIUM_POLISH=YES'
echo 'KPI_SIGNAL_SYSTEM=YES'
echo 'KPI_CONTENT_CHANGED=NO'
echo 'SYSTEM_HEALTH_PREMIUM_POLISH=YES'
echo 'SYSTEM_HEALTH_CONTENT_CHANGED=NO'
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
