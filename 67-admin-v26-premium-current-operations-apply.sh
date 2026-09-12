#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v25.1.css
TARGET_CSS=src/pages/AdminDashboard.v26.css
BACKUP=/tmp/67-v26-current-ops-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v26.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v26-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V26_PREMIUM_CURRENT_OPERATIONS_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v26.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V26 — PREMIUM CURRENT OPERATIONS" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V26
else
  grep -q "import './AdminDashboard.v25.1.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V25_1
  [ -f "$SOURCE_CSS" ] || fail V25_1_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V25.1" "$SOURCE_CSS" || fail V25_1_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V26
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v26.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=patch_current_operations_markup
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

old_import="import './AdminDashboard.v25.1.css';"
new_import="import './AdminDashboard.v26.css';"
if old_import not in s:
    raise SystemExit('V25_1_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

old='''            <div className="ops-card">
              <div className="ops-card__head">
                <h3><ShieldAlert size={17} /> العمليات الجارية</h3>
              </div>
              <div className="ops-summary-row">
                <div className="ops-summary-tile">
                  <strong>{pendingReview + documents.filter(d => d.status === 'معلق').length}</strong>
                  <small>مطلوب إجراء</small>
                </div>
                <div className="ops-summary-tile ops-summary-tile--ok">
                  <strong>{verifiedSellersCount}</strong>
                  <small>نشط</small>
                </div>
              </div>
              <div className="ops-tiles">
                <div className="ops-tile">
                  <span className="ops-tile__ico amber"><Store size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>{pendingReview} متاجر قيد المراجعة</strong>
                    <small>تتطلب تفعيل إداري</small>
                  </div>
                </div>
                <div className="ops-tile">
                  <span className="ops-tile__ico amber"><FileText size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>{documents.filter(d => d.status === 'معلق').length} وثائق معلقة</strong>
                    <small>سجلات تجارية وهويات</small>
                  </div>
                </div>
                <div className="ops-tile">
                  <span className="ops-tile__ico green"><CheckCircle size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>{verifiedSellersCount} متجر نشط</strong>
                    <small>يعملون بكفاءة كاملة</small>
                  </div>
                </div>
              </div>
              {liveNotifications.filter(n => n.type === 'payment').length > 0 && (
                <div className="ops-tile">
                  <span className="ops-tile__ico green"><CreditCard size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>{liveNotifications.filter(n => n.type === 'payment').length} عمليات دفع أخيرة</strong>
                    <small>خلال الجلسة الحالية</small>
                  </div>
                </div>
              )}
              <div className="ops-good-strip">
                <ShieldCheck size={14} /> النظام يعمل بشكل طبيعي — لا توجد أخطاء حرجة
              </div>
            </div>'''

new='''            <div className="ops-card">
              <div className="ops-card__head">
                <div className="ops-card__title-group">
                  <span className="ops-card__title-icon"><ShieldAlert size={16} /></span>
                  <div>
                    <h3>العمليات الجارية</h3>
                    <small>الطلبات والمراجعات التي تحتاج متابعة إدارية</small>
                  </div>
                </div>
                <span className="ops-card__command-badge">
                  {pendingReview + documents.filter(d => d.status === 'معلق').length} مطلوب إجراء
                </span>
              </div>
              <div className="ops-summary-row">
                <div className="ops-summary-tile">
                  <span>مطلوب إجراء</span>
                  <strong>{pendingReview + documents.filter(d => d.status === 'معلق').length}</strong>
                  <small>مراجعات ووثائق معلقة</small>
                </div>
                <div className="ops-summary-tile ops-summary-tile--ok">
                  <span>نشط</span>
                  <strong>{verifiedSellersCount}</strong>
                  <small>متاجر تعمل بكفاءة</small>
                </div>
              </div>
              <div className="ops-tiles">
                <div className="ops-tile">
                  <span className="ops-tile__ico amber"><Store size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>متاجر قيد المراجعة</strong>
                    <small>تتطلب تفعيل إداري</small>
                  </div>
                  <span className="ops-tile__count amber">{pendingReview}</span>
                  <span className="ops-tile__state">مراجعة</span>
                </div>
                <div className="ops-tile">
                  <span className="ops-tile__ico amber"><FileText size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>وثائق معلقة</strong>
                    <small>سجلات تجارية وهويات</small>
                  </div>
                  <span className="ops-tile__count amber">{documents.filter(d => d.status === 'معلق').length}</span>
                  <span className="ops-tile__state">معلقة</span>
                </div>
                <div className="ops-tile">
                  <span className="ops-tile__ico green"><CheckCircle size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>متاجر نشطة</strong>
                    <small>تعمل بكفاءة كاملة</small>
                  </div>
                  <span className="ops-tile__count green">{verifiedSellersCount}</span>
                  <span className="ops-tile__state ops-tile__state--ok">نشط</span>
                </div>
              </div>
              {liveNotifications.filter(n => n.type === 'payment').length > 0 && (
                <div className="ops-tile ops-tile--payment">
                  <span className="ops-tile__ico green"><CreditCard size={15} /></span>
                  <div className="ops-tile__info">
                    <strong>عمليات دفع أخيرة</strong>
                    <small>خلال الجلسة الحالية</small>
                  </div>
                  <span className="ops-tile__count green">{liveNotifications.filter(n => n.type === 'payment').length}</span>
                  <span className="ops-tile__state ops-tile__state--ok">حديث</span>
                </div>
              )}
              <div className="ops-good-strip">
                <ShieldCheck size={14} /> النظام يعمل بشكل طبيعي — لا توجد أخطاء حرجة
              </div>
            </div>'''

if old not in s:
    raise SystemExit('CURRENT_OPERATIONS_BLOCK_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v26_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V26 — PREMIUM CURRENT OPERATIONS
   Approved preview translated over V25.1.
   Scope lock: Current Operations card ONLY.
   Preserve all counters, source data, conditional payment row, Live Operations V25.1,
   Revenue V24.1, Transactions, Hero, Date Filter, KPI, System Health, Sidebar,
   backend, auth and business logic. */

.ops-card{
  position:relative!important;
  isolation:isolate!important;
  height:286px!important;
  min-height:286px!important;
  max-height:286px!important;
  padding:12px 13px 11px!important;
  overflow:hidden!important;
  display:flex!important;
  flex-direction:column!important;
  border-radius:16px!important;
  background:
    radial-gradient(circle at 96% -10%,rgba(215,173,81,.09),transparent 32%),
    linear-gradient(180deg,#fffefa 0%,#faf6ee 100%)!important;
  border:1px solid rgba(188,132,25,.28)!important;
  box-shadow:0 12px 28px rgba(76,48,6,.065),inset 0 1px 0 rgba(255,255,255,.92)!important;
}
.ops-card::before{
  content:""!important;
  position:absolute!important;
  left:18px!important;right:18px!important;top:0!important;height:2px!important;
  background:linear-gradient(90deg,transparent,#d7ad51 26%,#b97b16 64%,transparent)!important;
  opacity:.78!important;
  pointer-events:none!important;
}

.ops-card__head{
  min-height:38px!important;
  height:38px!important;
  margin:0 0 7px!important;
  padding:0 1px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:10px!important;
  flex:0 0 38px!important;
}
.ops-card__title-group{
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  min-width:0!important;
}
.ops-card__title-icon{
  width:30px!important;height:30px!important;min-width:30px!important;
  display:grid!important;place-items:center!important;
  border-radius:9px!important;
  color:#b47d1e!important;
  background:linear-gradient(145deg,#fff8e7,#f0dfb7)!important;
  border:1px solid rgba(184,127,23,.17)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.82)!important;
}
.ops-card__title-group>div{display:grid!important;gap:2px!important;min-width:0!important}
.ops-card__title-group h3{
  margin:0!important;
  font-size:12.4px!important;
  line-height:1!important;
  color:#171d25!important;
  font-weight:950!important;
  letter-spacing:-.018em!important;
}
.ops-card__title-group small{
  font-size:7.4px!important;
  line-height:1.15!important;
  color:#9a9287!important;
  font-weight:700!important;
  white-space:nowrap!important;
}
.ops-card__command-badge{
  height:24px!important;
  padding:0 8px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  color:#8b661f!important;
  background:linear-gradient(180deg,#fff8e7,#f1e4c8)!important;
  border:1px solid rgba(184,128,24,.18)!important;
  font-size:7.8px!important;
  font-weight:900!important;
  white-space:nowrap!important;
}

.ops-summary-row{
  display:grid!important;
  grid-template-columns:1fr 1fr!important;
  gap:6px!important;
  margin:0 0 7px!important;
  flex:0 0 54px!important;
}
.ops-summary-tile{
  position:relative!important;
  min-height:54px!important;
  height:54px!important;
  padding:7px 9px!important;
  display:grid!important;
  grid-template-columns:auto 1fr!important;
  grid-template-areas:"label value" "sub value"!important;
  align-items:center!important;
  gap:1px 8px!important;
  border-radius:10px!important;
  overflow:hidden!important;
  background:linear-gradient(180deg,#faf6ee,#f5eee2)!important;
  border:1px solid rgba(185,130,29,.14)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.72)!important;
}
.ops-summary-tile::before{
  content:""!important;
  position:absolute!important;
  right:0!important;top:8px!important;bottom:8px!important;width:2px!important;
  border-radius:99px!important;
  background:linear-gradient(180deg,#d7ad51,rgba(215,173,81,.1))!important;
}
.ops-summary-tile--ok::before{background:linear-gradient(180deg,#18a66f,rgba(24,166,111,.1))!important}
.ops-summary-tile>span{
  grid-area:label!important;
  font-size:7px!important;
  color:#9c9489!important;
  font-weight:800!important;
}
.ops-summary-tile strong{
  grid-area:value!important;
  justify-self:end!important;
  font-size:17px!important;
  line-height:1!important;
  color:#9b6b16!important;
  font-weight:950!important;
}
.ops-summary-tile--ok strong{color:#149b68!important}
.ops-summary-tile small{
  grid-area:sub!important;
  font-size:6.6px!important;
  line-height:1.05!important;
  color:#aaa197!important;
  white-space:nowrap!important;
}

.ops-tiles{
  display:flex!important;
  flex-direction:column!important;
  gap:4px!important;
  min-height:0!important;
  flex:1 1 auto!important;
}
.ops-tile{
  position:relative!important;
  min-height:34px!important;
  height:34px!important;
  padding:4px 7px!important;
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
  border-radius:9px!important;
  overflow:hidden!important;
  background:linear-gradient(180deg,#faf6ee,#f5eee2)!important;
  border:1px solid rgba(185,130,29,.13)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.72)!important;
}
.ops-tile::after{
  content:"›"!important;
  margin-inline-start:2px!important;
  width:18px!important;height:18px!important;
  display:grid!important;place-items:center!important;
  border-radius:50%!important;
  color:#a77b31!important;
  background:#fff9ec!important;
  border:1px solid rgba(185,130,29,.12)!important;
  font-size:12px!important;
  font-weight:900!important;
  flex:0 0 18px!important;
}
.ops-tile__ico{
  width:24px!important;height:24px!important;min-width:24px!important;
  display:grid!important;place-items:center!important;
  border-radius:7px!important;
  box-shadow:inset 0 1px rgba(255,255,255,.82)!important;
}
.ops-tile__ico.amber{
  color:#ad791e!important;
  background:linear-gradient(145deg,#fff8e7,#f1dfb8)!important;
  border:1px solid rgba(183,124,20,.16)!important;
}
.ops-tile__ico.green{
  color:#119766!important;
  background:linear-gradient(145deg,#eefbf6,#daf1e7)!important;
  border:1px solid rgba(18,160,106,.16)!important;
}
.ops-tile__ico svg{width:13px!important;height:13px!important;stroke-width:2.1!important}
.ops-tile__info{
  min-width:0!important;
  flex:1!important;
  display:grid!important;
  gap:2px!important;
}
.ops-tile__info strong{
  font-size:8.5px!important;
  line-height:1!important;
  color:#262d35!important;
  font-weight:850!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.ops-tile__info small{
  font-size:6.8px!important;
  line-height:1!important;
  color:#9e968c!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.ops-tile__count{
  min-width:28px!important;
  text-align:center!important;
  font-size:10px!important;
  line-height:1!important;
  font-weight:950!important;
}
.ops-tile__count.amber{color:#a56f17!important}
.ops-tile__count.green{color:#109866!important}
.ops-tile__state{
  height:20px!important;
  padding:0 6px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  color:#90661c!important;
  background:#fff7e6!important;
  border:1px solid rgba(185,130,29,.12)!important;
  font-size:6.6px!important;
  font-weight:850!important;
  white-space:nowrap!important;
}
.ops-tile__state--ok{
  color:#12885f!important;
  background:#edf9f4!important;
  border-color:rgba(20,160,107,.13)!important;
}
.ops-card>.ops-tile{
  flex:0 0 34px!important;
  margin:4px 0 0!important;
}

.ops-good-strip{
  flex:0 0 25px!important;
  min-height:25px!important;
  height:25px!important;
  margin:5px 0 0!important;
  padding:0 8px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:5px!important;
  border-radius:8px!important;
  color:#12885f!important;
  background:linear-gradient(180deg,#effaf6,#e6f6ef)!important;
  border:1px solid rgba(20,160,107,.14)!important;
  font-size:7.4px!important;
  line-height:1!important;
  font-weight:850!important;
}
.ops-good-strip svg{width:12px!important;height:12px!important;flex:0 0 auto!important}

@media(max-width:1360px){
  .ops-card{padding:10px 11px!important}
  .ops-card__head{height:34px!important;min-height:34px!important;flex-basis:34px!important}
  .ops-card__title-group h3{font-size:11.5px!important}
  .ops-card__title-group small{font-size:6.8px!important}
  .ops-card__command-badge{height:22px!important;font-size:7px!important}
  .ops-summary-row{flex-basis:50px!important}
  .ops-summary-tile{height:50px!important;min-height:50px!important;padding:6px 8px!important}
  .ops-summary-tile strong{font-size:15px!important}
  .ops-tile{height:31px!important;min-height:31px!important;padding:3px 6px!important}
  .ops-card>.ops-tile{flex-basis:31px!important}
  .ops-tile__ico{width:22px!important;height:22px!important;min-width:22px!important}
  .ops-tile__info strong{font-size:8px!important}
  .ops-tile__info small{font-size:6.4px!important}
  .ops-good-strip{height:23px!important;min-height:23px!important;flex-basis:23px!important;font-size:6.9px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V26 — PREMIUM CURRENT OPERATIONS" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v26.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v26-build.log 2>&1 || {
  tail -n 160 /tmp/67-v26-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V25.1"
echo "TARGET_VERSION=V26"
echo "RUNTIME_CSS=AdminDashboard.v26.css"
echo "ELEMENT=CURRENT_OPERATIONS_ONLY"
echo "APPROVED_CONCEPT_TRANSLATED=YES"
echo "CURRENT_OPERATIONS_PREMIUM=YES"
echo "CURRENT_SUMMARY_REDESIGNED=YES"
echo "CURRENT_ACTION_ROWS_REDESIGNED=YES"
echo "CURRENT_VALUES_CHANGED=NO"
echo "CURRENT_LOGIC_CHANGED=NO"
echo "LIVE_OPERATIONS_V25_1_PRESERVED=YES"
echo "REVENUE_V24_1_PRESERVED=YES"
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
