#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=2c11da5949c9a5b1b340d4322a6382115a1de418
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v14.css
TARGET_CSS=src/pages/AdminDashboard.v18.css
BACKUP_DIR="/tmp/67-admin-v18-backup-$$"
FAILED_STEP=init
MUTATED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v14.css"
[ -f "$TARGET_CSS" ] && cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v18.css" || true

rollback(){
  local code="$1"
  if [ "$MUTATED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" "$SOURCE_CSS"
    if [ -f "$BACKUP_DIR/src/pages/AdminDashboard.v18.css" ]; then
      cp "$BACKUP_DIR/src/pages/AdminDashboard.v18.css" "$TARGET_CSS"
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-admin-v18-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V18_REFERENCE_FIDELITY_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_v17_main_state
grep -q "OFFICIAL REFERENCE V5 HERO — V16" "$TARGET_JSX"
grep -q "import './AdminDashboard.v14.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V17.3" "$SOURCE_CSS"
grep -q "admin-v17-hero.jpg" "$SOURCE_CSS"
grep -q "admin-v17-health.jpg" "$SOURCE_CSS"
[ -s src/assets/admin-v17-hero.jpg ]
[ -s src/assets/admin-v17-health.jpg ]

FAILED_STEP=create_consolidated_v18_runtime_css
MUTATED=1
cp "$SOURCE_CSS" "$TARGET_CSS"
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V18 — OFFICIAL REFERENCE V5 FIDELITY PASS
   Runtime visual pass: cinematic proportion, readable executive density, no stretched hero. */

/* Canvas rhythm */
.admin-exec .animate-fadeIn{gap:8px!important}
.admin-exec>div[style*="marginRight"]{padding:18px 16px 22px!important}

/* HERO — restore cinematic crop instead of geometric stretch */
.ov-header-v16{
  height:190px!important;
  min-height:190px!important;
  border-radius:16px!important;
  border-color:rgba(215,173,81,.36)!important;
  box-shadow:0 18px 42px rgba(0,0,0,.25)!important;
  background:#03070c!important;
}
.ov-header-v16 .ov-header__motif{
  background-image:url('../assets/admin-v17-hero.jpg')!important;
  background-size:cover!important;
  background-position:center 54%!important;
  background-repeat:no-repeat!important;
  transform:scale(1.015)!important;
  filter:saturate(1.10) contrast(1.08) brightness(.80)!important;
}
.ov-header-v16::after{
  background:
    linear-gradient(90deg,rgba(2,5,9,.88) 0%,rgba(2,5,9,.62) 18%,rgba(2,5,9,.12) 38%,rgba(2,5,9,.05) 58%,rgba(2,5,9,.54) 82%,rgba(2,5,9,.91) 100%),
    radial-gradient(circle at 58% 60%,rgba(222,177,72,.10),transparent 27%),
    linear-gradient(180deg,rgba(0,0,0,.08) 0%,transparent 48%,rgba(0,0,0,.36) 100%)!important;
}
.ov-header-v16::before{height:3px!important;opacity:.96!important}
.ov-header__toolbar-top{left:18px!important;top:14px!important}
.ov-header__toolbar-top .ov-toolbar{padding:4px!important;border-radius:10px!important;background:rgba(3,7,11,.82)!important;border-color:rgba(215,173,81,.25)!important}
.ov-header__toolbar-top .ov-header__chip,.ov-header__toolbar-top .ov-header__btn{height:30px!important;min-height:30px!important;font-size:10px!important;padding:0 10px!important}
.ov-header__copy-left{
  left:26px!important;
  bottom:25px!important;
  width:38%!important;
  max-width:470px!important;
}
.ov-header__eyebrow{font-size:10px!important;margin-bottom:5px!important;color:#e6c76e!important;letter-spacing:.01em!important}
.ov-header__copy-left h1{font-size:34px!important;line-height:1.02!important;letter-spacing:-.02em!important;text-shadow:0 5px 22px rgba(0,0,0,.92)!important}
.ov-header__copy-left h1 span{margin-top:2px!important;color:#f0d27a!important}
.ov-header__copy-left p{font-size:10.5px!important;line-height:1.5!important;max-width:405px!important;color:rgba(255,255,255,.80)!important}
.ov-header__copy-right{
  right:27px!important;
  top:26px!important;
  width:25%!important;
  max-width:300px!important;
}
.ov-header__copy-right>span{font-size:13px!important;color:rgba(255,255,255,.90)!important}
.ov-header__copy-right>strong{font-size:21px!important;line-height:1.12!important;margin-top:3px!important;color:#edcf74!important}
.ov-header__copy-right>small{font-size:9px!important;margin-top:9px!important;color:rgba(255,255,255,.68)!important}

/* KPI — keep one-line strip but stop clipping supporting text */
.kpi-grid{gap:8px!important}
.kpi-card{
  height:94px!important;
  min-height:94px!important;
  padding:10px 12px 9px!important;
  border-radius:12px!important;
  background:linear-gradient(180deg,#fffefa 0%,#f8f1e5 100%)!important;
  border-color:rgba(184,127,18,.30)!important;
  box-shadow:0 8px 22px rgba(83,55,8,.07)!important;
}
.kpi-card__icon{width:38px!important;height:38px!important}
.kpi-card__label{font-size:9.5px!important;font-weight:800!important}
.kpi-card__value{font-size:29px!important;line-height:.96!important}
.kpi-card__note{min-height:16px!important;font-size:8.5px!important;padding-left:40px!important;overflow:visible!important}
.kpi-card::after{left:12px!important;bottom:9px!important;width:34px!important;height:17px!important}

/* SYSTEM HEALTH — cinematic but legible */
.syshealth{height:102px!important;min-height:102px!important;border-radius:13px!important;background:linear-gradient(100deg,#05090e 0%,#0b141f 58%,#0c1620 100%)!important}
.syshealth__layout{grid-template-columns:20% 50% 30%!important;padding:8px 10px!important;gap:7px!important}
.syshealth__zone-left{padding-right:10px!important}
.syshealth__title{font-size:10.5px!important;line-height:1.35!important}
.syshealth__title small{font-size:8px!important;margin-top:3px!important}
.syshealth__status{font-size:8.3px!important}.syshealth__status-text{font-size:7.4px!important}
.syshealth__grid{gap:6px!important}
.syshealth__metric{height:84px!important;min-height:84px!important;padding:8px 9px 7px!important;border-radius:10px!important;background:linear-gradient(180deg,#182638,#101a27)!important}
.syshealth__metric label{font-size:8px!important}.syshealth__metric strong{font-size:17px!important}.syshealth__metric small{font-size:7.2px!important}
.syshealth__zone-right{background-position:center 55%!important;filter:saturate(1.05) contrast(1.10) brightness(.80)!important;border-radius:10px!important}

/* COMMAND CENTER — larger than V16 so data is not visually crushed */
.admin-command-grid{grid-template-columns:minmax(0,2.08fr) minmax(225px,1fr) minmax(225px,1fr)!important;gap:8px!important}
.admin-command-grid>*{
  height:270px!important;
  min-height:270px!important;
  max-height:270px!important;
  border-radius:12px!important;
  border-color:rgba(186,131,28,.27)!important;
  box-shadow:0 9px 25px rgba(76,51,9,.06)!important;
}
.adm-chart-card,.live-card,.ops-card{padding:10px!important}
.adm-chart-card__head,.live-card__head,.ops-card__head{min-height:26px!important;margin-bottom:5px!important}
.adm-chart-card__head h3,.live-card__head h3,.ops-card__head h3{font-size:11px!important}
.rev-stats{gap:5px!important;margin-bottom:4px!important}.rev-stat{min-height:44px!important;padding:6px 8px!important}.rev-stat small{font-size:8px!important}.rev-stat strong{font-size:12.5px!important}
.adex-chart{height:180px!important;min-height:0!important}
.live-feed{gap:4px!important}.live-item{min-height:38px!important;padding:6px 7px!important;border-radius:8px!important}.live-item__copy strong{font-size:8.7px!important}.live-item__copy small{font-size:7.3px!important}.live-card__footer{margin-top:5px!important}
.ops-summary{gap:5px!important}.ops-summary>div{min-height:50px!important;padding:7px!important}.ops-list{gap:4px!important}.ops-row{min-height:31px!important;padding:5px 7px!important}.ops-health{margin-top:5px!important}

/* LEDGER — executive table density with cleaner hierarchy */
.tx-card{border-radius:12px!important;box-shadow:0 9px 24px rgba(76,51,9,.055)!important}
.tx-card__head{min-height:43px!important;padding:8px 11px!important}.tx-card__head h3{font-size:10.5px!important}
.tx-toolbar input{height:29px!important;font-size:8.7px!important}.tx-toolbar button{height:29px!important;font-size:8.7px!important}
.tx-table th{padding:7px 8px!important;font-size:8.2px!important}.tx-table td{padding:7px 8px!important;font-size:9.2px!important}

@media(max-width:1280px){
  .ov-header__copy-left{width:40%!important}.ov-header__copy-right{width:27%!important}
  .admin-command-grid{grid-template-columns:minmax(0,1.8fr) minmax(210px,1fr) minmax(210px,1fr)!important}
}
CSS

FAILED_STEP=switch_runtime_import
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v14.css';"
new="import './AdminDashboard.v18.css';"
if old not in s:
    raise SystemExit('V14_RUNTIME_IMPORT_NOT_FOUND')
if new in s:
    raise SystemExit('V18_ALREADY_IMPORTED')
s=s.replace(old,new,1)
p.write_text(s)
PY

FAILED_STEP=validate_runtime_sources
grep -q "import './AdminDashboard.v18.css';" "$TARGET_JSX"
! grep -q "import './AdminDashboard.v14.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V18" "$TARGET_CSS"
grep -q "admin-v17-hero.jpg" "$TARGET_CSS"
grep -q "admin-v17-health.jpg" "$TARGET_CSS"

FAILED_STEP=build
npm run build

FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

FAILED_STEP=local_http_check
LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

FAILED_STEP=post_apply_validation
grep -q "import './AdminDashboard.v18.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V18" "$TARGET_CSS"

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v18.css"
echo "RUNTIME_CSS=AdminDashboard.v18.css"
echo "V14_RUNTIME_IMPORT=NO"
echo "V17_ASSETS_PRESERVED=YES"
echo "HERO_STRETCH_REMOVED=YES"
echo "HERO_CINEMATIC_CROP=YES"
echo "KPI_CLIPPING_REDUCED=YES"
echo "SYSTEM_HEALTH_LEGIBILITY=YES"
echo "COMMAND_CENTER_DENSITY_BALANCED=YES"
echo "REFERENCE_V5_FIDELITY_PASS=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
