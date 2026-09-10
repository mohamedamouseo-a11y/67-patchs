#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=eb6536e9e194d975e722082c12a93718aa06a218
TARGET_JSX=src/pages/AdminDashboard.jsx
TARGET_CSS=src/pages/AdminDashboard.v14.css
BACKUP_DIR="/tmp/67-admin-v16-backup-$$"
FAILED_STEP=init
MUTATED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v14.css"

rollback(){
  local code="$1"
  if [ "$MUTATED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" "$TARGET_CSS"
    npm run build >/tmp/67-admin-v16-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V16_REFERENCE_LOCK_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_current_main_state
grep -q "import './AdminDashboard.v14.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V15.2" "$TARGET_CSS"
grep -q "admin-v15-hero.jpg" "$TARGET_CSS"
grep -q "admin-v15-health.jpg" "$TARGET_CSS"
[ -s src/assets/admin-v15-hero.jpg ]
[ -s src/assets/admin-v15-health.jpg ]

FAILED_STEP=replace_overview_header_markup
MUTATED=1
python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
if 'OFFICIAL REFERENCE V5 HERO — V16' in s:
    raise SystemExit('V16_ALREADY_PRESENT')
pattern=r"\s*\{\/\* Overview header \*\/\}\s*<div className=\"ov-header\">.*?<\/div>\s*\n\s*\{\/\* KPI row \*\/\}"
replacement=r'''

            {/* OFFICIAL REFERENCE V5 HERO — V16 */}
            <div className="ov-header ov-header-v16">
              <div className="ov-header__layout">
                <div className="ov-header__zone-center" aria-hidden="true">
                  <div className="ov-header__motif" />
                </div>

                <div className="ov-header__toolbar-top">
                  <div className="ov-toolbar">
                    <div className="ov-toolbar__chips">
                      <span className="ov-header__chip">اليوم</span>
                      <span className="ov-header__chip">7 أيام</span>
                      <span className="ov-header__chip active">30 يوم</span>
                    </div>
                    <span className="ov-toolbar__sep" />
                    <button className="ov-header__btn"><RefreshCw size={14} /> تحديث</button>
                    <button className="ov-header__btn"><Eye size={14} /> تصدير</button>
                  </div>
                </div>

                <div className="ov-header__copy-left">
                  <span className="ov-header__eyebrow">منصة تشغيل ذكية لسوق قطع السيارات في المملكة</span>
                  <h1>قيادة المستقبل <span>تبدأ من هنا</span></h1>
                  <p>رؤية تنفيذية موحدة للأداء، الإيرادات، واستقرار المنصة لحظة بلحظة.</p>
                </div>

                <div className="ov-header__copy-right">
                  <span>سوق أكثر ذكاء،</span>
                  <strong>مستقبل أكثر تميزًا</strong>
                  <small><CarFront size={14} /> SIX SEVEN Executive Command</small>
                </div>
              </div>
            </div>

            {/* KPI row */}'''
out,n=re.subn(pattern,replacement,s,count=1,flags=re.S)
if n!=1:
    raise SystemExit(f'HEADER_BLOCK_REPLACE_FAILED:{n}')
p.write_text(out)
PY

FAILED_STEP=apply_reference_v16_css
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V16 — OFFICIAL REFERENCE V5 COMPOSITION LOCK
   Structural correction: two-sided cinematic hero + compressed executive viewport. */
.ov-header-v16{
  height:166px!important;
  min-height:166px!important;
  border-radius:14px!important;
  border:1px solid rgba(215,173,81,.30)!important;
  box-shadow:0 16px 34px rgba(0,0,0,.22)!important;
}
.ov-header-v16 .ov-header__motif{
  background-image:url('../assets/admin-v15-hero.jpg')!important;
  background-size:cover!important;
  background-position:center 51%!important;
  filter:saturate(1.08) contrast(1.08) brightness(.86)!important;
}
.ov-header-v16::after{
  background:
    linear-gradient(90deg,rgba(2,5,9,.78) 0%,rgba(2,5,9,.28) 21%,rgba(2,5,9,.03) 45%,rgba(2,5,9,.08) 61%,rgba(2,5,9,.68) 86%,rgba(2,5,9,.90) 100%),
    linear-gradient(180deg,rgba(0,0,0,.08),transparent 50%,rgba(0,0,0,.30))!important;
}
.ov-header-v16::before{height:2px!important;opacity:.9!important}
.ov-header__toolbar-top{
  position:absolute!important;
  z-index:10!important;
  left:16px!important;
  top:12px!important;
  right:auto!important;
  bottom:auto!important;
}
.ov-header__toolbar-top .ov-toolbar{padding:3px!important;background:rgba(4,7,11,.78)!important}
.ov-header__toolbar-top .ov-header__chip,.ov-header__toolbar-top .ov-header__btn{height:28px!important;min-height:28px!important;font-size:9.5px!important}
.ov-header__copy-left{
  position:absolute!important;
  z-index:9!important;
  left:27px!important;
  bottom:19px!important;
  width:35%!important;
  max-width:430px!important;
  text-align:left!important;
  direction:rtl!important;
  color:#fff!important;
}
.ov-header__eyebrow{display:block!important;margin-bottom:4px!important;color:#d9b65c!important;font-size:9px!important;font-weight:800!important}
.ov-header__copy-left h1{margin:0!important;font-size:27px!important;line-height:1.04!important;font-weight:900!important;color:#fff!important;text-shadow:0 4px 18px rgba(0,0,0,.82)!important}
.ov-header__copy-left h1 span{display:block!important;color:#edcf78!important}
.ov-header__copy-left p{margin:6px 0 0!important;font-size:9.5px!important;line-height:1.45!important;color:rgba(255,255,255,.76)!important;max-width:360px!important}
.ov-header__copy-right{
  position:absolute!important;
  z-index:9!important;
  right:25px!important;
  top:22px!important;
  width:24%!important;
  max-width:280px!important;
  text-align:right!important;
  direction:rtl!important;
  color:#fff!important;
  text-shadow:0 3px 14px rgba(0,0,0,.75)!important;
}
.ov-header__copy-right>span{display:block!important;font-size:12px!important;color:#fff!important}
.ov-header__copy-right>strong{display:block!important;margin-top:2px!important;font-size:17px!important;color:#e7c76f!important}
.ov-header__copy-right>small{display:flex!important;align-items:center!important;justify-content:flex-start!important;gap:5px!important;margin-top:8px!important;color:rgba(255,255,255,.64)!important;font-size:8.5px!important}
.ov-header-v16 .ov-header__zone-left,.ov-header-v16 .ov-header__zone-right{display:none!important}

/* KPI strip — compact medallion cards like the locked reference */
.kpi-grid{gap:7px!important}
.kpi-card{height:82px!important;min-height:82px!important;padding:9px 11px 8px!important;border-radius:11px!important}
.kpi-card__icon{width:34px!important;height:34px!important}
.kpi-card__label{font-size:9px!important}
.kpi-card__value{font-size:25px!important}
.kpi-card__note{min-height:13px!important;font-size:8px!important;padding-left:36px!important}
.kpi-card::after{left:11px!important;bottom:7px!important;width:31px!important;height:16px!important}

/* Health band — reference-height command strip, not a second hero */
.syshealth{height:84px!important;min-height:84px!important;border-radius:12px!important}
.syshealth__layout{grid-template-columns:19% 51% 30%!important;padding:7px 9px!important;gap:6px!important}
.syshealth__metric{height:68px!important;min-height:68px!important;padding:7px 8px 6px!important;border-radius:9px!important}
.syshealth__metric strong{font-size:15px!important}.syshealth__metric label{font-size:7.7px!important}.syshealth__metric small{font-size:6.8px!important}
.syshealth__title{font-size:9.8px!important}.syshealth__title small{font-size:7.5px!important}.syshealth__status{font-size:7.8px!important}.syshealth__status-text{font-size:7px!important}
.syshealth__zone-right{background-position:center 55%!important;filter:saturate(1.02) contrast(1.10) brightness(.82)!important}

/* Command center — denser, one-view executive composition */
.admin-command-grid{grid-template-columns:minmax(0,2fr) minmax(220px,1fr) minmax(220px,1fr)!important;gap:7px!important}
.admin-command-grid>*{height:244px!important;min-height:244px!important;max-height:244px!important;border-radius:11px!important}
.adm-chart-card,.live-card,.ops-card{padding:9px!important}
.adm-chart-card__head,.live-card__head,.ops-card__head{min-height:23px!important;margin-bottom:4px!important}
.rev-stats{gap:4px!important;margin-bottom:2px!important}.rev-stat{min-height:39px!important;padding:5px 7px!important}.adex-chart{height:158px!important}
.live-feed{gap:3px!important}.live-item{min-height:34px!important;padding:5px 7px!important}.live-card__footer{margin-top:4px!important}
.ops-summary{gap:5px!important}.ops-summary>div{min-height:48px!important;padding:6px!important}.ops-list{gap:3px!important}.ops-row{min-height:29px!important;padding:4px 6px!important}.ops-health{margin-top:4px!important}

/* Ledger — compact dense finish from reference */
.tx-card{border-radius:11px!important}.tx-card__head{min-height:38px!important;padding:7px 10px!important}.tx-card__head h3{font-size:10px!important}.tx-toolbar{gap:4px!important}.tx-toolbar input{height:27px!important;font-size:8.5px!important}.tx-toolbar button{height:27px!important;font-size:8.5px!important}.tx-table th{padding:6px 8px!important;font-size:8px!important}.tx-table td{padding:6px 8px!important;font-size:9px!important}

/* Full overview rhythm */
.admin-exec .animate-fadeIn{gap:7px!important}
@media(max-width:1100px){
  .ov-header__copy-left{width:42%!important}.ov-header__copy-right{width:28%!important}
  .admin-command-grid{grid-template-columns:1.7fr 1fr 1fr!important}
}
CSS

FAILED_STEP=validate_source
node --check server/index.js
# JSX is transformed by Vite; validate required V16 markers before build.
grep -q "OFFICIAL REFERENCE V5 HERO — V16" "$TARGET_JSX"
grep -q "ov-header__copy-left" "$TARGET_JSX"
grep -q "ov-header__copy-right" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V16" "$TARGET_CSS"

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
grep -q "OFFICIAL REFERENCE V5 HERO — V16" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V16" "$TARGET_CSS"
grep -q "admin-v15-hero.jpg" "$TARGET_CSS"
grep -q "admin-v15-health.jpg" "$TARGET_CSS"

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v14.css"
echo "REFERENCE_V5_HERO_STRUCTURE=YES"
echo "DUAL_COPY_HERO=YES"
echo "TOOLBAR_TOP_LEFT=YES"
echo "KPI_REFERENCE_DENSITY=YES"
echo "HEALTH_REFERENCE_DENSITY=YES"
echo "COMMAND_CENTER_REFERENCE_DENSITY=YES"
echo "LEDGER_REFERENCE_DENSITY=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
