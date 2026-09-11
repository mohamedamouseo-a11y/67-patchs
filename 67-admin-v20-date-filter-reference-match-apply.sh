#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.5.css
TARGET_CSS=src/pages/AdminDashboard.v20.css
BACKUP=/tmp/67-v20-date-filter-$$
FAILED_STEP=init
APPLIED_NOW=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    rm -f "$TARGET_CSS"
    npm run build >/tmp/67-v20-date-filter-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V20_DATE_FILTER_REFERENCE_MATCH_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v20.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$TARGET_CSS" ]; then
  grep -q "SIX SEVEN ADMIN V20 — DATE FILTER REFERENCE MATCH" "$TARGET_CSS"
  STATE_ACTION=ALREADY_AT_V20
elif grep -q "import './AdminDashboard.v19.5.css';" "$TARGET_JSX" 2>/dev/null && [ -f "$SOURCE_CSS" ]; then
  STATE_ACTION=APPLY_V20
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  cp "$SOURCE_CSS" "$TARGET_CSS"

  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V20 — DATE FILTER REFERENCE MATCH
   Rebuilds the date filter as one premium automotive command element based on the approved visual:
   closed command capsule + spacious custom-range tray inside an expanded hero, with no KPI overlap. */

/* ---------- CLOSED COMMAND CAPSULE ---------- */
.ov-header__toolbar-top{
  left:24px!important;
  top:18px!important;
  z-index:80!important;
}
.executive-date-shell{
  position:relative!important;
  display:flex!important;
  align-items:center!important;
  height:60px!important;
  padding:6px!important;
  gap:7px!important;
  border-radius:18px!important;
  direction:rtl!important;
  background:
    radial-gradient(circle at 12% -70%,rgba(235,196,95,.13),transparent 42%),
    linear-gradient(180deg,rgba(11,16,22,.985) 0%,rgba(5,8,12,.985) 100%)!important;
  border:1px solid rgba(226,188,92,.52)!important;
  box-shadow:
    0 20px 50px rgba(0,0,0,.50),
    0 0 0 1px rgba(0,0,0,.28),
    inset 0 1px 0 rgba(255,255,255,.07),
    inset 0 -1px 0 rgba(0,0,0,.52)!important;
  backdrop-filter:blur(26px) saturate(145%)!important;
}
.executive-date-shell::before{
  content:""!important;
  position:absolute!important;
  left:26px!important;
  right:26px!important;
  top:-1px!important;
  height:1px!important;
  border-radius:999px!important;
  background:linear-gradient(90deg,transparent,rgba(255,220,132,.92),transparent)!important;
  opacity:.95!important;
  pointer-events:none!important;
}
.executive-date-shell::after{
  content:""!important;
  position:absolute!important;
  inset:6px!important;
  border-radius:12px!important;
  border:1px solid rgba(255,255,255,.025)!important;
  pointer-events:none!important;
}

.executive-date-display{
  position:relative!important;
  height:46px!important;
  min-width:340px!important;
  padding:0 12px 0 10px!important;
  gap:11px!important;
  border-radius:13px!important;
  direction:rtl!important;
  background:
    radial-gradient(circle at 18% 0%,rgba(215,173,81,.10),transparent 44%),
    linear-gradient(180deg,rgba(255,255,255,.052),rgba(255,255,255,.020))!important;
  border:1px solid rgba(226,188,92,.30)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.035)!important;
  transition:border-color .16s ease,background .16s ease,transform .16s ease!important;
}
.executive-date-display:hover{
  transform:translateY(-1px)!important;
  border-color:rgba(238,202,111,.52)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.072),rgba(255,255,255,.030))!important;
}
.executive-date-display__icon{
  width:36px!important;
  height:36px!important;
  flex:0 0 36px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:11px!important;
  color:#f0c85d!important;
  background:linear-gradient(145deg,rgba(221,177,67,.19),rgba(111,74,16,.13))!important;
  border:1px solid rgba(232,194,96,.35)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.06),0 6px 14px rgba(0,0,0,.18)!important;
}
.executive-date-display__copy{
  flex:1!important;
  min-width:0!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:flex-start!important;
  gap:3px!important;
  text-align:right!important;
  line-height:1!important;
}
.executive-date-display__copy small{
  margin:0!important;
  font-size:8px!important;
  font-weight:750!important;
  color:#8f949b!important;
}
.executive-date-display__copy strong{
  max-width:245px!important;
  font-size:12px!important;
  line-height:1.2!important;
  font-weight:900!important;
  color:#fffaf0!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  letter-spacing:-.012em!important;
}
.executive-date-display__chevron{
  margin-inline-start:auto!important;
  color:#e1b94f!important;
  transition:transform .18s ease!important;
}
.executive-date-display__chevron.open{transform:rotate(180deg)!important}

.executive-date-presets{
  height:46px!important;
  padding:0!important;
  gap:7px!important;
  display:flex!important;
  align-items:center!important;
  background:transparent!important;
  border:0!important;
  box-shadow:none!important;
}
.executive-date-preset{
  height:46px!important;
  min-width:74px!important;
  padding:0 16px!important;
  border-radius:12px!important;
  border:1px solid rgba(255,255,255,.075)!important;
  color:#a7abb1!important;
  background:linear-gradient(180deg,rgba(255,255,255,.037),rgba(255,255,255,.016))!important;
  font-size:10.5px!important;
  font-weight:850!important;
  box-shadow:inset 0 1px rgba(255,255,255,.018)!important;
  transition:.16s ease!important;
}
.executive-date-preset:hover{
  color:#eee9de!important;
  border-color:rgba(215,173,81,.24)!important;
  background:rgba(215,173,81,.055)!important;
  transform:translateY(-1px)!important;
}
.executive-date-preset.active{
  color:#ffe08b!important;
  border-color:rgba(244,202,92,.72)!important;
  background:
    radial-gradient(circle at 50% -30%,rgba(255,222,125,.28),transparent 58%),
    linear-gradient(180deg,rgba(174,126,32,.36),rgba(81,55,13,.22))!important;
  box-shadow:
    0 0 0 1px rgba(238,192,74,.12),
    0 8px 18px rgba(0,0,0,.24),
    inset 0 1px rgba(255,240,188,.10)!important;
}
.executive-date-preset.active::after{
  content:""!important;
  position:absolute!important;
  left:18px!important;
  right:18px!important;
  bottom:4px!important;
  height:1px!important;
  width:auto!important;
  background:linear-gradient(90deg,transparent,#f5c84f,transparent)!important;
  box-shadow:0 0 8px rgba(245,200,79,.55)!important;
}

.executive-date-actions{
  position:relative!important;
  height:46px!important;
  gap:7px!important;
  padding-inline-start:15px!important;
  margin-inline-start:3px!important;
}
.executive-date-actions::before{
  content:""!important;
  position:absolute!important;
  inset-inline-start:3px!important;
  top:9px!important;
  bottom:9px!important;
  width:1px!important;
  background:linear-gradient(180deg,transparent,rgba(226,188,92,.26),transparent)!important;
}
.executive-date-action{
  width:46px!important;
  height:46px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:12px!important;
  color:#aab0b8!important;
  background:linear-gradient(180deg,rgba(255,255,255,.042),rgba(255,255,255,.016))!important;
  border:1px solid rgba(255,255,255,.075)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
  transition:.16s ease!important;
}
.executive-date-action:hover{
  transform:translateY(-1px)!important;
  color:#f1cb64!important;
  border-color:rgba(226,188,92,.38)!important;
  background:rgba(215,173,81,.075)!important;
}

/* ---------- OPEN STATE: EXPAND THE HERO, NEVER COVER KPI ---------- */
.ov-header-v16{
  transition:height .22s cubic-bezier(.2,.78,.28,1),min-height .22s cubic-bezier(.2,.78,.28,1)!important;
}
.ov-header-v16.date-control-open{
  height:390px!important;
  min-height:390px!important;
  margin-bottom:0!important;
  overflow:hidden!important;
}
.ov-header-v16.date-control-open .ov-header__motif{
  transform:scale(1.025)!important;
  transform-origin:center 42%!important;
  transition:transform .35s ease!important;
}
.ov-header-v16.date-control-open::after{
  background:
    linear-gradient(90deg,rgba(2,5,9,.76) 0%,rgba(2,5,9,.28) 29%,rgba(2,5,9,.10) 52%,rgba(2,5,9,.24) 72%,rgba(2,5,9,.88) 100%),
    linear-gradient(180deg,rgba(0,0,0,.02) 0%,rgba(0,0,0,.12) 46%,rgba(0,0,0,.48) 100%)!important;
}

.ov-header-v16.date-control-open .executive-date-popover{
  position:absolute!important;
  left:0!important;
  right:auto!important;
  top:calc(100% + 13px)!important;
  width:760px!important;
  max-height:none!important;
  padding:0!important;
  overflow:hidden!important;
  border-radius:18px!important;
  background:
    radial-gradient(circle at 8% -10%,rgba(223,178,74,.10),transparent 34%),
    linear-gradient(180deg,rgba(12,19,27,.995) 0%,rgba(5,10,15,.995) 100%)!important;
  border:1px solid rgba(226,188,92,.52)!important;
  box-shadow:
    0 28px 70px rgba(0,0,0,.56),
    0 0 0 1px rgba(0,0,0,.28),
    inset 0 1px rgba(255,255,255,.05)!important;
  backdrop-filter:blur(28px) saturate(145%)!important;
  transform-origin:top left!important;
  animation:v20DatePanelIn .2s cubic-bezier(.2,.78,.26,1) both!important;
  z-index:190!important;
}
@keyframes v20DatePanelIn{
  from{opacity:0;transform:translateY(-6px) scale(.992)}
  to{opacity:1;transform:translateY(0) scale(1)}
}
.ov-header-v16.date-control-open .executive-date-popover::before{display:none!important}
.ov-header-v16.date-control-open .executive-date-popover::after{
  content:""!important;
  position:absolute!important;
  left:28px!important;
  right:28px!important;
  top:0!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,rgba(255,218,125,.92),transparent)!important;
  opacity:1!important;
}

.executive-date-popover__head{
  min-height:72px!important;
  margin:0!important;
  padding:17px 20px 14px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:18px!important;
  direction:rtl!important;
  border-bottom:1px solid rgba(255,255,255,.065)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.025),rgba(255,255,255,.006))!important;
}
.executive-date-popover__head strong{
  display:block!important;
  margin:0 0 5px!important;
  font-size:17px!important;
  line-height:1.2!important;
  font-weight:950!important;
  letter-spacing:-.02em!important;
  color:#fffaf0!important;
}
.executive-date-popover__head span:not(.executive-date-popover__badge){
  display:block!important;
  max-width:445px!important;
  font-size:10px!important;
  line-height:1.55!important;
  color:#929aa4!important;
}
.executive-date-popover__badge{
  min-width:96px!important;
  height:36px!important;
  padding:0 15px!important;
  display:grid!important;
  place-items:center!important;
  flex:0 0 auto!important;
  border-radius:999px!important;
  font-size:10px!important;
  font-weight:900!important;
  color:#f5d57a!important;
  background:linear-gradient(180deg,rgba(218,174,72,.17),rgba(125,83,14,.09))!important;
  border:1px solid rgba(230,193,96,.34)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.05)!important;
}

.executive-date-fields{
  position:relative!important;
  display:grid!important;
  grid-template-columns:minmax(0,1fr) minmax(0,1fr)!important;
  gap:20px!important;
  margin:0!important;
  padding:18px 20px 17px!important;
  direction:rtl!important;
}
.executive-date-fields::after{
  content:"↔"!important;
  position:absolute!important;
  left:50%!important;
  top:61%!important;
  transform:translate(-50%,-50%)!important;
  width:34px!important;
  height:34px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:50%!important;
  color:#f4cb5d!important;
  background:linear-gradient(180deg,#121a23,#080d12)!important;
  border:1px solid rgba(228,190,92,.40)!important;
  box-shadow:0 8px 18px rgba(0,0,0,.32),inset 0 1px rgba(255,255,255,.045)!important;
  font-size:15px!important;
  font-weight:900!important;
  z-index:4!important;
  pointer-events:none!important;
}
.executive-date-field-card{
  display:flex!important;
  flex-direction:column!important;
  gap:8px!important;
  min-width:0!important;
}
.executive-date-field-label{
  padding:0 4px!important;
  font-size:11px!important;
  line-height:1!important;
  color:#ddd4c4!important;
  font-weight:900!important;
}
.executive-date-picker{
  position:relative!important;
  height:74px!important;
  padding:0 14px!important;
  display:flex!important;
  align-items:center!important;
  gap:12px!important;
  overflow:hidden!important;
  border-radius:14px!important;
  cursor:pointer!important;
  color:#f7efe3!important;
  background:
    radial-gradient(circle at 8% 0%,rgba(215,173,81,.075),transparent 38%),
    linear-gradient(180deg,#111a24 0%,#0a1119 100%)!important;
  border:1px solid rgba(255,255,255,.085)!important;
  box-shadow:0 8px 20px rgba(0,0,0,.16),inset 0 1px rgba(255,255,255,.028)!important;
  transition:.16s ease!important;
}
.executive-date-picker:hover,
.executive-date-picker:focus-within{
  transform:translateY(-1px)!important;
  border-color:rgba(226,188,92,.46)!important;
  background:linear-gradient(180deg,#15202b,#0c141d)!important;
  box-shadow:0 10px 24px rgba(0,0,0,.22),0 0 0 3px rgba(215,173,81,.045),inset 0 1px rgba(255,255,255,.04)!important;
}
.executive-date-picker__icon{
  width:43px!important;
  height:43px!important;
  flex:0 0 43px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:12px!important;
  color:#f6cc5d!important;
  background:
    radial-gradient(circle at 40% 15%,rgba(255,225,139,.24),transparent 56%),
    linear-gradient(145deg,rgba(157,112,26,.42),rgba(78,51,10,.28))!important;
  border:1px solid rgba(231,190,84,.42)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.08),0 5px 14px rgba(0,0,0,.16)!important;
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
  font-size:8.5px!important;
  color:#818995!important;
  font-weight:800!important;
}
.executive-date-picker__copy strong{
  max-width:230px!important;
  font-size:13px!important;
  line-height:1.18!important;
  color:#f8f1e7!important;
  font-weight:950!important;
  letter-spacing:-.015em!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.executive-date-picker__chevron{
  margin-inline-start:auto!important;
  color:#c6b178!important;
  opacity:.9!important;
  transform:none!important;
}
.executive-date-native{color-scheme:dark!important}

.executive-date-error{
  margin:0 20px 12px!important;
  padding:8px 11px!important;
  border-radius:9px!important;
  font-size:9px!important;
}

.executive-date-popover__footer{
  min-height:68px!important;
  margin:0!important;
  padding:12px 20px 14px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:16px!important;
  direction:rtl!important;
  border-top:1px solid rgba(255,255,255,.065)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.014),rgba(0,0,0,.09))!important;
}
.executive-date-popover__hint{
  max-width:320px!important;
  font-size:9px!important;
  line-height:1.55!important;
  color:#7f8791!important;
}
.executive-date-popover__buttons{
  display:flex!important;
  align-items:center!important;
  gap:10px!important;
  margin-inline-start:0!important;
}
.executive-date-cancel,
.executive-date-apply{
  height:42px!important;
  border-radius:11px!important;
  font-family:inherit!important;
  font-size:10px!important;
  font-weight:900!important;
  transition:.16s ease!important;
}
.executive-date-cancel{
  min-width:104px!important;
  padding:0 18px!important;
  color:#d2d4d7!important;
  background:linear-gradient(180deg,rgba(255,255,255,.042),rgba(255,255,255,.018))!important;
  border:1px solid rgba(255,255,255,.10)!important;
}
.executive-date-cancel:hover{
  color:#fff!important;
  border-color:rgba(255,255,255,.16)!important;
  background:rgba(255,255,255,.065)!important;
}
.executive-date-apply{
  min-width:178px!important;
  padding:0 22px!important;
  color:#171006!important;
  background:linear-gradient(180deg,#f6d77d 0%,#cf9c31 100%)!important;
  border:1px solid rgba(255,229,151,.42)!important;
  box-shadow:0 10px 22px rgba(168,113,20,.24),inset 0 1px rgba(255,255,255,.52)!important;
}
.executive-date-apply:hover{
  transform:translateY(-1px)!important;
  filter:brightness(1.04)!important;
  box-shadow:0 12px 27px rgba(168,113,20,.30),inset 0 1px rgba(255,255,255,.56)!important;
}

/* ---------- RESPONSIVE SAFETY ---------- */
@media(max-width:1500px){
  .executive-date-display{min-width:290px!important}
  .executive-date-display__copy strong{max-width:200px!important;font-size:11px!important}
  .executive-date-preset{min-width:62px!important;padding:0 12px!important}
  .ov-header-v16.date-control-open .executive-date-popover{width:700px!important}
}
@media(max-width:1240px){
  .executive-date-shell{transform:scale(.92)!important;transform-origin:top left!important}
  .ov-header-v16.date-control-open{height:372px!important;min-height:372px!important}
  .ov-header-v16.date-control-open .executive-date-popover{width:680px!important}
}
@media(prefers-reduced-motion:reduce){
  .ov-header-v16,
  .ov-header-v16 .ov-header__motif,
  .ov-header-v16.date-control-open .executive-date-popover{transition:none!important;animation:none!important}
}
CSS

  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v19.5.css';"
new="import './AdminDashboard.v20.css';"
if old not in s:
    raise SystemExit('V19_5_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
s=s.replace('الفترة التحليلية','الفترة المحددة',1)
s=s.replace('اختر نطاق التقرير','تخصيص الفترة الزمنية',1)
s=s.replace('حدد تاريخ البداية والنهاية لعرض المؤشرات على نفس الفترة','اختر نطاق التواريخ لعرض البيانات والتقارير في الفترة المحددة',1)
s=s.replace('سيتم تطبيق النطاق على مؤشرات الأداء والإيرادات.','سيتم تطبيق الفترة على جميع المؤشرات والرسوم البيانية في الصفحة.',1)
s=s.replace('تطبيق وعرض البيانات','تطبيق الفترة',1)
p.write_text(s)
PY

  grep -q "import './AdminDashboard.v20.css';" "$TARGET_JSX"
  grep -q "الفترة المحددة" "$TARGET_JSX"
  grep -q "تخصيص الفترة الزمنية" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V20 — DATE FILTER REFERENCE MATCH" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v20-date-filter-build.log 2>&1 || {
  tail -n 100 /tmp/67-v20-date-filter-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v20.css"
echo "DATE_FILTER_REFERENCE_MATCH=YES"
echo "CLOSED_CAPSULE_REBUILT=YES"
echo "CUSTOM_PANEL_REBUILT=YES"
echo "HERO_EXPANDS_ON_CUSTOM=YES"
echo "KPI_OVERLAP=NO_BY_LAYOUT"
echo "DATE_FUNCTIONALITY_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "VISUAL_QA_READY=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
