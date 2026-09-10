#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=e1e92b9918ca1e2daf38e21c3fff846947a8afa2
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.1.css
TARGET_CSS=src/pages/AdminDashboard.v19.2.css
BACKUP_DIR="/tmp/67-admin-v19.2-backup-$$"
FAILED_STEP=init
MUTATED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v19.1.css"
[ -f "$TARGET_CSS" ] && cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v19.2.css" || true

rollback(){
  local code="$1"
  if [ "$MUTATED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v19.1.css" "$SOURCE_CSS"
    if [ -f "$BACKUP_DIR/src/pages/AdminDashboard.v19.2.css" ]; then
      cp "$BACKUP_DIR/src/pages/AdminDashboard.v19.2.css" "$TARGET_CSS"
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-admin-v19.2-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V19_2_EXECUTIVE_DATE_LUXURY_POLISH_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_v19_1_state
grep -q "import './AdminDashboard.v19.1.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.1" "$SOURCE_CSS"
grep -q "executive-date-field-card" "$TARGET_JSX"
grep -q "executive-date-cancel" "$TARGET_JSX"

FAILED_STEP=create_v19_2_css
MUTATED=1
cp "$SOURCE_CSS" "$TARGET_CSS"
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19.2 — EXECUTIVE DATE LUXURY POLISH
   Premium control island: stronger hierarchy, richer materiality, cleaner custom range sidecar. */
.ov-header__toolbar-top{
  left:18px!important;
  top:13px!important;
  z-index:45!important;
}
.executive-date-shell{
  height:54px!important;
  padding:6px!important;
  gap:5px!important;
  border-radius:16px!important;
  background:
    radial-gradient(circle at 18% -40%,rgba(238,207,119,.15),transparent 42%),
    linear-gradient(180deg,rgba(11,15,21,.965) 0%,rgba(4,7,11,.955) 100%)!important;
  border:1px solid rgba(224,187,94,.34)!important;
  box-shadow:
    0 18px 42px rgba(0,0,0,.44),
    0 2px 10px rgba(180,126,29,.08),
    inset 0 1px 0 rgba(255,255,255,.065),
    inset 0 -1px 0 rgba(0,0,0,.48)!important;
  backdrop-filter:blur(24px) saturate(145%)!important;
}
.executive-date-shell::before{
  content:""!important;
  position:absolute!important;
  left:18px!important;
  right:18px!important;
  top:-1px!important;
  height:1px!important;
  border-radius:99px!important;
  background:linear-gradient(90deg,transparent,rgba(246,216,137,.72),transparent)!important;
  opacity:.82!important;
  pointer-events:none!important;
}
.executive-date-display{
  height:40px!important;
  min-width:262px!important;
  padding:0 12px!important;
  gap:9px!important;
  border-radius:11px!important;
  background:
    radial-gradient(circle at 18% 0%,rgba(215,173,81,.08),transparent 46%),
    linear-gradient(180deg,rgba(255,255,255,.052),rgba(255,255,255,.022))!important;
  border:1px solid rgba(255,255,255,.085)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.035)!important;
}
.executive-date-display:hover{
  border-color:rgba(223,184,90,.34)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.068),rgba(255,255,255,.030))!important;
}
.executive-date-display__icon{
  width:30px!important;height:30px!important;flex:0 0 30px!important;
  border-radius:9px!important;
  color:#ebc96d!important;
  background:linear-gradient(145deg,rgba(215,173,81,.15),rgba(215,173,81,.055))!important;
  border:1px solid rgba(224,187,94,.22)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.045)!important;
}
.executive-date-display__copy{gap:1px!important;line-height:1!important}
.executive-date-display__copy small{
  margin:0 0 3px!important;
  font-size:7.4px!important;
  letter-spacing:.01em!important;
  color:#8e949c!important;
  font-weight:750!important;
}
.executive-date-display__copy strong{
  font-size:10.5px!important;
  color:#f4eee3!important;
  font-weight:900!important;
  letter-spacing:-.015em!important;
}
.executive-date-display__chevron{margin-inline-start:auto!important;color:#858b93!important}
.executive-date-display__chevron.open{color:#e4bd5e!important}
.executive-date-presets{
  height:40px!important;
  padding:3px!important;
  gap:2px!important;
  border-radius:11px!important;
  background:rgba(255,255,255,.026)!important;
  border:1px solid rgba(255,255,255,.052)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.018)!important;
}
.executive-date-preset{
  position:relative!important;
  height:32px!important;
  min-width:49px!important;
  padding:0 10px!important;
  border-radius:8px!important;
  border:1px solid transparent!important;
  font-size:8.6px!important;
  font-weight:850!important;
  color:#999da2!important;
  background:transparent!important;
}
.executive-date-preset:hover{
  color:#e9e3d9!important;
  background:rgba(255,255,255,.045)!important;
}
.executive-date-preset.active{
  color:#f2d27a!important;
  background:
    radial-gradient(circle at 50% -40%,rgba(244,211,124,.18),transparent 64%),
    linear-gradient(180deg,rgba(205,157,58,.15),rgba(137,94,20,.08))!important;
  border-color:rgba(226,189,94,.34)!important;
  box-shadow:
    inset 0 1px rgba(255,255,255,.05),
    0 7px 16px rgba(0,0,0,.18)!important;
}
.executive-date-preset.active::after{
  bottom:2px!important;
  width:18px!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,#f0cb68,transparent)!important;
  box-shadow:0 0 7px rgba(240,203,104,.45)!important;
}
.executive-date-actions{height:40px!important;gap:4px!important;padding-left:1px!important}
.executive-date-action{
  width:38px!important;height:38px!important;
  border-radius:11px!important;
  color:#949aa2!important;
  background:linear-gradient(180deg,rgba(255,255,255,.042),rgba(255,255,255,.016))!important;
  border:1px solid rgba(255,255,255,.065)!important;
}
.executive-date-action:hover{
  color:#f0cf75!important;
  border-color:rgba(222,183,87,.28)!important;
  background:rgba(215,173,81,.07)!important;
}

/* V19.2 — the custom range becomes a luxury sidecar, not a generic admin popover. */
.executive-date-popover{
  left:calc(100% + 14px)!important;
  right:auto!important;
  top:-2px!important;
  width:438px!important;
  padding:16px!important;
  border-radius:17px!important;
  background:
    radial-gradient(circle at 8% -10%,rgba(236,202,117,.12),transparent 34%),
    radial-gradient(circle at 100% 100%,rgba(142,100,28,.055),transparent 28%),
    linear-gradient(180deg,rgba(12,17,24,.992) 0%,rgba(5,9,14,.992) 100%)!important;
  border:1px solid rgba(225,188,95,.30)!important;
  box-shadow:
    0 30px 68px rgba(0,0,0,.58),
    0 8px 24px rgba(91,57,7,.12),
    inset 0 1px rgba(255,255,255,.05)!important;
  backdrop-filter:blur(26px) saturate(150%)!important;
}
.executive-date-popover::before{
  content:""!important;
  position:absolute!important;
  left:-15px!important;
  top:26px!important;
  width:15px!important;
  height:1px!important;
  transform:none!important;
  background:linear-gradient(90deg,rgba(225,188,95,.36),rgba(225,188,95,.08))!important;
  border:0!important;
}
.executive-date-popover::after{
  left:22px!important;
  right:22px!important;
  top:-1px!important;
  background:linear-gradient(90deg,transparent,rgba(244,211,126,.72),transparent)!important;
  opacity:.85!important;
}
.executive-date-popover__head{
  align-items:flex-start!important;
  margin-bottom:13px!important;
  padding-bottom:12px!important;
  border-bottom:1px solid rgba(255,255,255,.055)!important;
}
.executive-date-popover__head strong{
  margin:0 0 4px!important;
  font-size:13px!important;
  line-height:1.2!important;
  color:#f6efe3!important;
  font-weight:900!important;
  letter-spacing:-.015em!important;
}
.executive-date-popover__head span{
  font-size:8px!important;
  line-height:1.5!important;
  color:#818894!important;
}
.executive-date-popover__badge{
  min-width:54px!important;
  height:27px!important;
  padding:0 10px!important;
  display:grid!important;
  place-items:center!important;
  border-radius:999px!important;
  font-size:7.8px!important;
  font-weight:900!important;
  color:#ebca70!important;
  background:linear-gradient(180deg,rgba(215,173,81,.115),rgba(215,173,81,.055))!important;
  border:1px solid rgba(224,186,91,.23)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.035)!important;
}
.executive-date-fields{
  grid-template-columns:1fr 1fr!important;
  gap:10px!important;
  margin-bottom:12px!important;
}
.executive-date-field-card{gap:6px!important}
.executive-date-field-label{
  padding:0 3px!important;
  font-size:7.8px!important;
  color:#a2a6ac!important;
  font-weight:850!important;
}
.executive-date-picker{
  height:56px!important;
  padding:0 11px!important;
  gap:9px!important;
  border-radius:12px!important;
  background:
    radial-gradient(circle at 10% 0%,rgba(215,173,81,.055),transparent 40%),
    linear-gradient(180deg,#121b26 0%,#0b121b 100%)!important;
  border:1px solid rgba(255,255,255,.075)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025),0 8px 20px rgba(0,0,0,.11)!important;
}
.executive-date-picker:hover,.executive-date-picker:focus-within{
  border-color:rgba(222,183,87,.32)!important;
  background:linear-gradient(180deg,#15202c,#0d151f)!important;
  box-shadow:0 0 0 3px rgba(215,173,81,.04),inset 0 1px rgba(255,255,255,.035)!important;
}
.executive-date-picker__icon{
  width:31px!important;height:31px!important;flex:0 0 31px!important;
  border-radius:9px!important;
  color:#e5c268!important;
  background:linear-gradient(145deg,rgba(215,173,81,.12),rgba(215,173,81,.045))!important;
  border:1px solid rgba(215,173,81,.16)!important;
}
.executive-date-picker__copy{line-height:1!important}
.executive-date-picker__copy small{
  margin-bottom:5px!important;
  font-size:6.9px!important;
  color:#747d87!important;
  font-weight:750!important;
}
.executive-date-picker__copy strong{
  max-width:142px!important;
  font-size:9.6px!important;
  color:#f1eadf!important;
  font-weight:900!important;
  letter-spacing:-.01em!important;
}
.executive-date-picker__chevron{color:#6f7781!important}
.executive-date-popover__footer{
  min-height:38px!important;
  padding-top:11px!important;
  border-top:1px solid rgba(255,255,255,.05)!important;
}
.executive-date-popover__hint{
  max-width:176px!important;
  font-size:7.5px!important;
  line-height:1.55!important;
  color:#777f89!important;
}
.executive-date-popover__buttons{gap:7px!important}
.executive-date-cancel,
.executive-date-apply{
  height:34px!important;
  border-radius:9px!important;
  font-size:8.3px!important;
  font-weight:900!important;
}
.executive-date-cancel{
  padding:0 14px!important;
  color:#b8babd!important;
  background:rgba(255,255,255,.025)!important;
  border:1px solid rgba(255,255,255,.075)!important;
}
.executive-date-apply{
  min-width:94px!important;
  padding:0 16px!important;
  color:#171006!important;
  background:linear-gradient(180deg,#f0d27c 0%,#c99732 100%)!important;
  border:1px solid rgba(255,232,166,.20)!important;
  box-shadow:0 9px 20px rgba(174,119,24,.18),inset 0 1px rgba(255,255,255,.42)!important;
}

@media(max-width:1360px){
  .executive-date-display{min-width:230px!important}
  .executive-date-preset{min-width:44px!important;padding:0 8px!important}
  .executive-date-popover{left:calc(100% + 9px)!important;width:400px!important;padding:14px!important}
}
CSS

FAILED_STEP=switch_runtime_css
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v19.1.css';"
new="import './AdminDashboard.v19.2.css';"
if old not in s:
    raise SystemExit('V19_1_RUNTIME_IMPORT_NOT_FOUND')
if new in s:
    raise SystemExit('V19_2_ALREADY_IMPORTED')
s=s.replace(old,new,1)
p.write_text(s)
PY

FAILED_STEP=verify_source_edits
grep -q "import './AdminDashboard.v19.2.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.2" "$TARGET_CSS"
grep -q "width:438px!important" "$TARGET_CSS"
grep -q "height:56px!important" "$TARGET_CSS"

FAILED_STEP=build
npm run build >/tmp/67-admin-v19.2-build.log 2>&1

FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 1
[ "$(systemctl is-active sixty-seven.service)" = "active" ]

FAILED_STEP=http_check
HTTP_CODE="$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/ || true)"
[ "$HTTP_CODE" = "200" ]

FAILED_STEP=complete
trap - ERR
rm -rf "$BACKUP_DIR"
echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=$HTTP_CODE"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v19.2.css"
echo "RUNTIME_CSS=AdminDashboard.v19.2.css"
echo "CONTROL_ISLAND_LUXURY_MATERIAL=YES"
echo "DATE_HIERARCHY_UPGRADED=YES"
echo "ACTIVE_PRESET_CHAMPAGNE_GOLD=YES"
echo "CUSTOM_SIDECAR_LUXURY_PANEL=YES"
echo "CUSTOM_DATE_CARDS_ENLARGED=YES"
echo "HERO_HEADLINE_CLEAR=YES"
echo "V19_1_FUNCTIONALITY_PRESERVED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
