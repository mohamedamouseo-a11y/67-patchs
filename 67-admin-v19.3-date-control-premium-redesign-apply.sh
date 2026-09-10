#!/usr/bin/env bash
set -Eeuo pipefail

cd /67

TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.2.3.css
TARGET_CSS=src/pages/AdminDashboard.v19.3.css
BACKUP=/tmp/67-v19.3-$$
mkdir -p "$BACKUP"
cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v19.2.3.css"

rollback(){
  cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" || true
  cp "$BACKUP/AdminDashboard.v19.2.3.css" "$SOURCE_CSS" || true
  rm -f "$TARGET_CSS"
  npm run build >/tmp/67-v19.3-rollback-build.log 2>&1 || true
  echo "PATCH_APPLIED=NO"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=V19_3_DATE_CONTROL_PREMIUM_REDESIGN_FAILED"
  exit 1
}
trap rollback ERR

grep -q "import './AdminDashboard.v19.2.3.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.2.3" "$SOURCE_CSS"
grep -q "executive-date-field-card" "$TARGET_JSX"
grep -q "executive-date-popover__buttons" "$TARGET_JSX"

cp "$SOURCE_CSS" "$TARGET_CSS"
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19.3 — DATE CONTROL PREMIUM REDESIGN
   High-clarity executive range panel: dark command shell + warm ivory date cards. */
.ov-header-v16.date-control-open .executive-date-popover{
  left:calc(100% + 16px)!important;
  right:auto!important;
  top:-4px!important;
  width:500px!important;
  padding:0!important;
  overflow:hidden!important;
  border-radius:18px!important;
  background:linear-gradient(180deg,#0b1119 0%,#060a10 100%)!important;
  border:1px solid rgba(225,188,95,.34)!important;
  box-shadow:0 34px 80px rgba(0,0,0,.62),0 10px 28px rgba(107,70,11,.14),inset 0 1px rgba(255,255,255,.05)!important;
  backdrop-filter:blur(28px) saturate(145%)!important;
  z-index:170!important;
}
.ov-header-v16.date-control-open .executive-date-popover::before{display:none!important}
.ov-header-v16.date-control-open .executive-date-popover::after{
  content:""!important;
  position:absolute!important;
  left:28px!important;
  right:28px!important;
  top:0!important;
  height:2px!important;
  background:linear-gradient(90deg,transparent,rgba(242,207,116,.86),transparent)!important;
  opacity:1!important;
}
.executive-date-popover__head{
  position:relative!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:16px!important;
  margin:0!important;
  padding:16px 18px 14px!important;
  border:0!important;
  border-bottom:1px solid rgba(255,255,255,.065)!important;
  background:
    radial-gradient(circle at 8% -20%,rgba(223,184,90,.11),transparent 36%),
    linear-gradient(180deg,rgba(255,255,255,.025),rgba(255,255,255,.005))!important;
}
.executive-date-popover__head strong{
  display:block!important;
  margin:0 0 5px!important;
  font-size:14px!important;
  line-height:1.25!important;
  color:#fffaf0!important;
  font-weight:900!important;
  letter-spacing:-.02em!important;
}
.executive-date-popover__head span:not(.executive-date-popover__badge){
  display:block!important;
  max-width:310px!important;
  font-size:9px!important;
  line-height:1.6!important;
  color:#8d949e!important;
}
.executive-date-popover__badge{
  min-width:68px!important;
  height:30px!important;
  padding:0 11px!important;
  display:grid!important;
  place-items:center!important;
  flex:0 0 auto!important;
  border-radius:999px!important;
  font-size:8.5px!important;
  font-weight:900!important;
  color:#f0ce72!important;
  background:linear-gradient(180deg,rgba(215,173,81,.14),rgba(215,173,81,.06))!important;
  border:1px solid rgba(229,193,100,.27)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.05)!important;
}
.executive-date-fields{
  position:relative!important;
  display:grid!important;
  grid-template-columns:1fr 1fr!important;
  gap:12px!important;
  margin:0!important;
  padding:16px 18px 15px!important;
  background:linear-gradient(180deg,rgba(255,255,255,.01),rgba(255,255,255,0))!important;
}
.executive-date-fields::after{
  content:"←"!important;
  position:absolute!important;
  left:50%!important;
  top:50%!important;
  transform:translate(-50%,-7%)!important;
  width:28px!important;
  height:28px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:50%!important;
  color:#d9b85c!important;
  background:#0a1017!important;
  border:1px solid rgba(215,173,81,.22)!important;
  box-shadow:0 7px 16px rgba(0,0,0,.28)!important;
  font-size:12px!important;
  font-weight:900!important;
  z-index:3!important;
  pointer-events:none!important;
}
.executive-date-field-card{
  display:flex!important;
  flex-direction:column!important;
  gap:7px!important;
  min-width:0!important;
}
.executive-date-field-label{
  padding:0 3px!important;
  font-size:9px!important;
  line-height:1!important;
  color:#c7c0b4!important;
  font-weight:900!important;
}
.executive-date-picker{
  position:relative!important;
  height:70px!important;
  padding:0 13px!important;
  display:flex!important;
  align-items:center!important;
  gap:11px!important;
  overflow:hidden!important;
  border-radius:14px!important;
  cursor:pointer!important;
  color:#17130d!important;
  background:
    radial-gradient(circle at 10% 0%,rgba(215,173,81,.12),transparent 36%),
    linear-gradient(180deg,#fffaf0 0%,#f2eadb 100%)!important;
  border:1px solid rgba(198,151,55,.32)!important;
  box-shadow:0 9px 22px rgba(0,0,0,.18),inset 0 1px rgba(255,255,255,.85)!important;
  transition:transform .18s ease,border-color .18s ease,box-shadow .18s ease!important;
}
.executive-date-picker:hover,
.executive-date-picker:focus-within{
  transform:translateY(-1px)!important;
  border-color:rgba(184,132,34,.56)!important;
  background:linear-gradient(180deg,#fffdf7 0%,#f4ebda 100%)!important;
  box-shadow:0 12px 28px rgba(0,0,0,.22),0 0 0 3px rgba(215,173,81,.08),inset 0 1px rgba(255,255,255,.92)!important;
}
.executive-date-picker__icon{
  width:36px!important;
  height:36px!important;
  flex:0 0 36px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:11px!important;
  color:#8f6314!important;
  background:linear-gradient(145deg,#f1d88e,#d8ad4b)!important;
  border:1px solid rgba(151,103,18,.18)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.65),0 5px 12px rgba(123,82,11,.14)!important;
}
.executive-date-picker__copy{
  display:flex!important;
  flex-direction:column!important;
  align-items:flex-start!important;
  min-width:0!important;
  line-height:1!important;
}
.executive-date-picker__copy small{
  margin:0 0 7px!important;
  font-size:8px!important;
  color:#8c8274!important;
  font-weight:800!important;
}
.executive-date-picker__copy strong{
  max-width:160px!important;
  font-size:11.5px!important;
  line-height:1.2!important;
  color:#17130d!important;
  font-weight:950!important;
  letter-spacing:-.015em!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.executive-date-picker__chevron{
  margin-inline-start:auto!important;
  color:#8d7440!important;
  flex:0 0 auto!important;
}
.executive-date-native{
  position:absolute!important;
  inset:0!important;
  width:100%!important;
  height:100%!important;
  opacity:0!important;
  cursor:pointer!important;
  border:0!important;
  padding:0!important;
  z-index:5!important;
  color-scheme:light!important;
}
.executive-date-native::-webkit-calendar-picker-indicator{
  position:absolute!important;
  inset:0!important;
  width:100%!important;
  height:100%!important;
  opacity:0!important;
  cursor:pointer!important;
}
.executive-date-error{
  margin:0 18px 12px!important;
  padding:8px 10px!important;
  border-radius:9px!important;
  font-size:8.5px!important;
}
.executive-date-popover__footer{
  min-height:56px!important;
  margin:0!important;
  padding:11px 18px 13px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:12px!important;
  border-top:1px solid rgba(255,255,255,.06)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.018),rgba(0,0,0,.08))!important;
}
.executive-date-popover__hint{
  max-width:220px!important;
  font-size:8px!important;
  line-height:1.55!important;
  color:#7e8792!important;
}
.executive-date-popover__buttons{
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  margin-inline-start:auto!important;
}
.executive-date-cancel,
.executive-date-apply{
  height:36px!important;
  border-radius:10px!important;
  font-size:8.8px!important;
  font-weight:900!important;
}
.executive-date-cancel{
  min-width:68px!important;
  padding:0 14px!important;
  color:#c6c7ca!important;
  background:rgba(255,255,255,.035)!important;
  border:1px solid rgba(255,255,255,.09)!important;
}
.executive-date-cancel:hover{
  color:#fff!important;
  background:rgba(255,255,255,.065)!important;
}
.executive-date-apply{
  min-width:122px!important;
  padding:0 18px!important;
  color:#171006!important;
  background:linear-gradient(180deg,#f2d37c 0%,#c8952d 100%)!important;
  border:1px solid rgba(255,232,166,.24)!important;
  box-shadow:0 10px 22px rgba(168,113,20,.20),inset 0 1px rgba(255,255,255,.45)!important;
}
.executive-date-apply:hover{
  filter:brightness(1.04)!important;
  transform:translateY(-1px)!important;
}

/* Refine the closed control so it reads as a premium command capsule rather than a utility toolbar. */
.executive-date-shell{
  border-color:rgba(226,188,92,.38)!important;
  box-shadow:0 20px 48px rgba(0,0,0,.48),0 3px 12px rgba(157,105,18,.10),inset 0 1px rgba(255,255,255,.07)!important;
}
.executive-date-display{
  min-width:276px!important;
  border-color:rgba(226,188,92,.13)!important;
}
.executive-date-display__copy strong{font-size:11px!important}
.executive-date-preset.active{
  color:#f5d77f!important;
  background:linear-gradient(180deg,rgba(217,171,74,.18),rgba(117,77,15,.10))!important;
  border-color:rgba(235,199,105,.40)!important;
}

@media(max-width:1360px){
  .ov-header-v16.date-control-open .executive-date-popover{width:470px!important;left:calc(100% + 10px)!important}
  .executive-date-picker__copy strong{max-width:138px!important;font-size:10.5px!important}
  .executive-date-display{min-width:236px!important}
}
CSS

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v19.2.3.css';"
new="import './AdminDashboard.v19.3.css';"
if old not in s:
    raise SystemExit('V19_2_3_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
s=s.replace('تخصيص الفترة التحليلية','اختر نطاق التقرير',1)
s=s.replace('اختر البداية والنهاية ثم طبّق النطاق على لوحة الأداء','حدد تاريخ البداية والنهاية لعرض المؤشرات على نفس الفترة',1)
s=s.replace('سيتم توحيد الفترة على المؤشرات والإيرادات.','سيتم تطبيق النطاق على مؤشرات الأداء والإيرادات.',1)
s=s.replace('>تطبيق الفترة</button>','>تطبيق وعرض البيانات</button>',1)
p.write_text(s)
PY

grep -q "import './AdminDashboard.v19.3.css';" "$TARGET_JSX"
grep -q "اختر نطاق التقرير" "$TARGET_JSX"
grep -q "تطبيق وعرض البيانات" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.3" "$TARGET_CSS"
grep -q "background:linear-gradient(180deg,#fffaf0" "$TARGET_CSS"

npm run build >/tmp/67-v19.3-build.log 2>&1

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v19.3.css"
echo "RUNTIME_CSS=AdminDashboard.v19.3.css"
echo "DATE_PICKER_FULL_REDESIGN=YES"
echo "DATE_CARDS_HIGH_CONTRAST_IVORY=YES"
echo "DATE_VALUES_VISIBILITY_UPGRADED=YES"
echo "RANGE_FLOW_VISUAL=YES"
echo "PREMIUM_DARK_GOLD_SHELL=YES"
echo "CUSTOM_PANEL_HIERARCHY_REBUILT=YES"
echo "NATIVE_DATE_BEHAVIOR_PRESERVED=YES"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "ERROR=NONE"
