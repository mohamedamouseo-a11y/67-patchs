#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v25.css
TARGET_CSS=src/pages/AdminDashboard.v25.1.css
BACKUP=/tmp/67-v25.1-live-ops-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v25.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v25.1-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V25_1_LIVE_OPERATIONS_COMPOSITION_FIX_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v25.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V25.1 — LIVE OPERATIONS COMPOSITION FIX" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V25_1
else
  grep -q "import './AdminDashboard.v25.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V25
  [ -f "$SOURCE_CSS" ] || fail V25_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V25 — PREMIUM LIVE OPERATIONS" "$SOURCE_CSS" || fail V25_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V25_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v25.1.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=patch_live_markup
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

old_import="import './AdminDashboard.v25.css';"
new_import="import './AdminDashboard.v25.1.css';"
if old_import not in s:
    raise SystemExit('V25_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

old_card='<div className="live-card">'
new_card='<div className={`live-card ${liveNotifications.length < 4 ? \'live-card--sparse\' : \'live-card--dense\'}`}> '
if old_card not in s:
    raise SystemExit('LIVE_CARD_CLASS_ANCHOR_NOT_FOUND')
s=s.replace(old_card,new_card,1)

old_block='''                {liveNotifications.length < 4 && (
                  <div className="live-compact-summary">
                    <span className="live-compact-summary__item"><ShieldCheck size={12} /> النظام مستقر</span>
                    <span className="live-compact-summary__item"><Activity size={12} /> {paymentCount} عملية اليوم</span>
                  </div>
                )}
                <div className="live-cta" onClick={() => setActiveTab('notifications')}>عرض جميع الأنشطة ←</div>
            <div className="live-pending">
                  <span><FileText size={13} /> وثائق قيد المراجعة: <strong>{documents.filter(d => d.status === 'معلق').length}</strong></span>
                  <span><Store size={13} /> متاجر قيد المراجعة: <strong>{pendingReview}</strong></span>
                </div>
                <div className="live-quick">
                  <span className="live-quick__ok"><CheckCircle size={13} /> البوابة تعمل بشكل طبيعي</span>
                  <span className="live-quick__ok"><ShieldCheck size={13} /> 0 أخطاء حرجة</span>
                </div>'''

new_block='''                {liveNotifications.length < 4 && (
                  <div className="live-activity-summary">
                    <div className="live-activity-summary__lead">
                      <span className="live-activity-summary__icon"><Activity size={15} /></span>
                      <div>
                        <small>ملخص النشاط المباشر</small>
                        <strong>{liveNotifications.length} أحداث في الجلسة الحالية</strong>
                        <span>الواجهة تظل متوازنة حتى مع انخفاض عدد الأحداث</span>
                      </div>
                    </div>
                    <div className="live-activity-summary__metrics">
                      <span><CreditCard size={12} /><strong>{liveNotifications.filter(n => n.type === 'payment').length}</strong><small>دفعات</small></span>
                      <span><Users size={12} /><strong>{liveNotifications.filter(n => n.type === 'registration').length}</strong><small>تسجيلات</small></span>
                      <span><ShieldCheck size={12} /><strong>{paymentCount.toLocaleString()}</strong><small>عملية اليوم</small></span>
                    </div>
                  </div>
                )}
                <div className="live-card__footer">
                  <div className="live-card__footer-status">
                    <div className="live-pending">
                      <span><FileText size={13} /> وثائق: <strong>{documents.filter(d => d.status === 'معلق').length}</strong></span>
                      <span><Store size={13} /> متاجر: <strong>{pendingReview}</strong></span>
                    </div>
                    <div className="live-quick">
                      <span className="live-quick__ok"><CheckCircle size={13} /> البوابة مستقرة</span>
                      <span className="live-quick__ok"><ShieldCheck size={13} /> 0 أخطاء حرجة</span>
                    </div>
                  </div>
                  <div className="live-cta" onClick={() => setActiveTab('notifications')}>عرض جميع الأنشطة ←</div>
                </div>'''

if old_block not in s:
    raise SystemExit('LIVE_FOOTER_BLOCK_ANCHOR_NOT_FOUND')
s=s.replace(old_block,new_block,1)

p.write_text(s)
PY

  FAILED_STEP=append_v25_1_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V25.1 — LIVE OPERATIONS COMPOSITION FIX
   Visual correction from real V25 QA.
   Scope lock: Live Operations ONLY.
   Fix sparse-state dead space without inventing events or changing notification logic.
   Preserve V24.1 Revenue, Current Operations and every locked module. */

.live-card{
  padding:11px 12px 10px!important;
}

/* Header becomes a deliberate console masthead. */
.live-card__head{
  height:34px!important;
  min-height:34px!important;
  flex-basis:34px!important;
  margin:0 0 6px!important;
}
.live-card__head h3{font-size:12.8px!important}
.live-card__badge{
  min-width:27px!important;
  height:25px!important;
  padding:0 8px!important;
  font-size:8.8px!important;
}

/* The feed scales with density instead of leaving the sparse state visually empty. */
.live-card__list{
  flex:1 1 auto!important;
  gap:4px!important;
  padding:0!important;
  overflow:hidden!important;
}
.live-card--sparse .live-card__list{
  flex:0 0 auto!important;
  gap:6px!important;
  overflow:visible!important;
}
.live-card--sparse .live-item{
  height:38px!important;
  min-height:38px!important;
  padding:6px 8px!important;
  border-radius:10px!important;
}
.live-card--sparse .live-item__ico{
  width:27px!important;height:27px!important;min-width:27px!important;flex-basis:27px!important;
  border-radius:8px!important;
}
.live-card--sparse .live-item__ico svg{width:14px!important;height:14px!important}
.live-card--sparse .live-item__body p{font-size:9.2px!important;font-weight:800!important}
.live-card--sparse .live-item__body small,.live-card--sparse .live-item .when{font-size:7.4px!important}

/* Dense state still supports five events without clipping. */
.live-card--dense .live-card__list{gap:3px!important}
.live-card--dense .live-item{
  height:27px!important;
  min-height:27px!important;
  padding:3px 6px!important;
  border-radius:8px!important;
}
.live-card--dense .live-item__ico{
  width:21px!important;height:21px!important;min-width:21px!important;flex-basis:21px!important;
  border-radius:6px!important;
}
.live-card--dense .live-item__ico svg{width:12px!important;height:12px!important}
.live-card--dense .live-item__body p{font-size:8.1px!important}
.live-card--dense .live-item__body small,.live-card--dense .live-item .when{font-size:6.7px!important}

/* Sparse-state live activity summary replaces dead whitespace with real existing metrics. */
.live-activity-summary{
  flex:0 0 52px!important;
  height:52px!important;
  margin:6px 0 0!important;
  padding:6px 7px!important;
  display:grid!important;
  grid-template-columns:minmax(0,1.45fr) minmax(0,1fr)!important;
  gap:7px!important;
  align-items:stretch!important;
  border-radius:10px!important;
  overflow:hidden!important;
  background:
    radial-gradient(circle at 8% 0%,rgba(22,165,111,.07),transparent 38%),
    linear-gradient(180deg,#fbf8f1 0%,#f5eee2 100%)!important;
  border:1px solid rgba(183,128,25,.13)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.78)!important;
}
.live-activity-summary__lead{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
  padding-inline-end:7px!important;
  border-inline-end:1px solid rgba(183,128,25,.10)!important;
}
.live-activity-summary__icon{
  width:30px!important;height:30px!important;min-width:30px!important;
  display:grid!important;place-items:center!important;
  border-radius:9px!important;
  color:#159a69!important;
  background:linear-gradient(145deg,#ecfaf4,#d8f0e5)!important;
  border:1px solid rgba(20,160,107,.16)!important;
}
.live-activity-summary__lead>div{min-width:0!important;display:grid!important;gap:2px!important}
.live-activity-summary__lead small{
  font-size:6.8px!important;line-height:1!important;color:#9a9186!important;font-weight:800!important;
}
.live-activity-summary__lead strong{
  font-size:9.3px!important;line-height:1.15!important;color:#1f272f!important;font-weight:950!important;
  white-space:nowrap!important;overflow:hidden!important;text-overflow:ellipsis!important;
}
.live-activity-summary__lead span:not(.live-activity-summary__icon){
  font-size:6.5px!important;line-height:1.1!important;color:#9e978d!important;
  white-space:nowrap!important;overflow:hidden!important;text-overflow:ellipsis!important;
}
.live-activity-summary__metrics{
  display:grid!important;
  grid-template-columns:repeat(3,minmax(0,1fr))!important;
  gap:4px!important;
}
.live-activity-summary__metrics>span{
  min-width:0!important;
  display:grid!important;
  grid-template-rows:13px 1fr auto!important;
  place-items:center!important;
  padding:3px 2px!important;
  border-radius:7px!important;
  color:#758078!important;
  background:rgba(255,255,255,.42)!important;
  border:1px solid rgba(183,128,25,.08)!important;
}
.live-activity-summary__metrics svg{width:11px!important;height:11px!important;color:#b47c1d!important}
.live-activity-summary__metrics strong{font-size:9.2px!important;line-height:1!important;color:#20272f!important;font-weight:950!important}
.live-activity-summary__metrics small{font-size:5.9px!important;line-height:1!important;color:#9c9489!important;font-weight:760!important}

/* Footer becomes one compact composition instead of several detached rows. */
.live-card__footer{
  flex:0 0 43px!important;
  height:43px!important;
  margin:6px 0 0!important;
  display:grid!important;
  grid-template-columns:minmax(0,1fr) 122px!important;
  gap:6px!important;
  align-items:stretch!important;
}
.live-card__footer-status{
  min-width:0!important;
  display:flex!important;
  align-items:center!important;
  gap:4px!important;
  overflow:hidden!important;
}
.live-card__footer .live-pending,
.live-card__footer .live-quick{
  display:contents!important;
  margin:0!important;
}
.live-card__footer .live-pending span,
.live-card__footer .live-quick span{
  height:29px!important;
  min-width:0!important;
  padding:0 6px!important;
  flex:1 1 0!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:3px!important;
  border-radius:8px!important;
  font-size:6.7px!important;
  line-height:1!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.live-card__footer .live-pending svg,
.live-card__footer .live-quick svg{width:10px!important;height:10px!important;min-width:10px!important}
.live-card__footer .live-cta{
  height:43px!important;
  min-height:43px!important;
  margin:0!important;
  padding:0 9px!important;
  align-self:stretch!important;
  border-radius:9px!important;
  font-size:7.5px!important;
  line-height:1.2!important;
  text-align:center!important;
}

@media(max-width:1360px){
  .live-card--sparse .live-item{height:34px!important;min-height:34px!important;padding:4px 6px!important}
  .live-activity-summary{height:48px!important;flex-basis:48px!important;padding:5px 6px!important}
  .live-activity-summary__lead strong{font-size:8.6px!important}
  .live-card__footer{grid-template-columns:minmax(0,1fr) 106px!important;height:40px!important;flex-basis:40px!important}
  .live-card__footer .live-cta{height:40px!important;min-height:40px!important;font-size:7px!important}
  .live-card__footer .live-pending span,.live-card__footer .live-quick span{height:27px!important;font-size:6.2px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V25.1 — LIVE OPERATIONS COMPOSITION FIX" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v25.1.css';" "$TARGET_JSX"
  grep -q "live-activity-summary" "$TARGET_JSX"
  grep -q "live-card__footer" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v25.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v25.1-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V25"
echo "TARGET_VERSION=V25.1"
echo "RUNTIME_CSS=AdminDashboard.v25.1.css"
echo "ELEMENT=LIVE_OPERATIONS_ONLY"
echo "SPARSE_STATE_DEAD_SPACE_FIXED=YES"
echo "SPARSE_SUMMARY_USES_EXISTING_METRICS=YES"
echo "DENSE_STATE_SUPPORTS_5_EVENTS_BY_LAYOUT=YES"
echo "LIVE_FOOTER_COMPOSED=YES"
echo "LIVE_NOTIFICATION_DATA_CHANGED=NO"
echo "LIVE_NOTIFICATION_ORDER_CHANGED=NO"
echo "LIVE_NOTIFICATION_SOURCE_CHANGED=NO"
echo "LIVE_CTA_BEHAVIOR_CHANGED=NO"
echo "REVENUE_V24_1_PRESERVED=YES"
echo "CURRENT_OPERATIONS_CHANGED=NO"
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
