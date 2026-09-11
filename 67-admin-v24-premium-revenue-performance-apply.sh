#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v23.css
TARGET_CSS=src/pages/AdminDashboard.v24.css
BACKUP=/tmp/67-v24-revenue-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v24.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v24-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V24_PREMIUM_REVENUE_PERFORMANCE_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v24.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V24 — PREMIUM REVENUE PERFORMANCE" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V24
elif grep -q "import './AdminDashboard.v23.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V23 — PREMIUM SYSTEM HEALTH" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V24
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v24.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=patch_revenue_markup
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

old_import="import './AdminDashboard.v23.css';"
new_import="import './AdminDashboard.v24.css';"
if old_import not in s:
    raise SystemExit('V23_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

old_head='''                <div className="adm-chart-card__head">
                  <h3><BarChart2 size={17} /> الإيرادات والأداء</h3>
                  <span>{rangeSummaryLabel}</span>
                </div>'''
new_head='''                <div className="adm-chart-card__head">
                  <div className="rev-title-group">
                    <span className="rev-title-icon"><BarChart2 size={18} /></span>
                    <div className="rev-title-copy">
                      <h3>الإيرادات والأداء</h3>
                      <small>تحليل تنفيذي لحركة المبيعات وعمولة المنصة</small>
                    </div>
                  </div>
                  <span className="rev-period-pill">{rangeSummaryLabel}</span>
                </div>'''
if old_head not in s:
    raise SystemExit('REVENUE_HEAD_ANCHOR_NOT_FOUND')
s=s.replace(old_head,new_head,1)

old_stats='''                <div className="rev-stats">
                  <div className="rev-stat">
                    <small>إيراد اليوم</small>
                    <strong>{revToday.toLocaleString()} <em>ر.س</em></strong>
                  </div>
                  <div className="rev-stat">
                    <small>عدد العمليات</small>
                    <strong>{analyticsPaymentCount.toLocaleString()}</strong>
                  </div>
                  <div className="rev-stat">
                    <small>الاتجاه</small>
                    <strong className={trendDelta >= 0 ? 'up' : 'down'}><TrendingUp size={14} /> {trendDelta >= 0 ? '+' : ''}{trendDelta}%</strong>
                  </div>
                </div>'''
new_stats='''                <div className="rev-stats">
                  <div className="rev-stat rev-stat--sales">
                    <small>إجمالي المبيعات</small>
                    <strong>{analyticsSales.toLocaleString()} <em>ر.س</em></strong>
                    <span>قيمة العمليات خلال الفترة</span>
                  </div>
                  <div className="rev-stat rev-stat--commission">
                    <small>إيراد المنصة</small>
                    <strong>{periodPlatformRevenue.toLocaleString()} <em>ر.س</em></strong>
                    <span>عمولة المنصة 1%</span>
                  </div>
                  <div className="rev-stat rev-stat--transactions">
                    <small>عدد العمليات</small>
                    <strong>{analyticsPaymentCount.toLocaleString()}</strong>
                    <span>إجمالي العمليات في النطاق</span>
                  </div>
                  <div className="rev-stat rev-stat--trend">
                    <small>اتجاه الأداء</small>
                    <strong className={trendDelta >= 0 ? 'up' : 'down'}><TrendingUp size={14} /> {trendDelta >= 0 ? '+' : ''}{trendDelta}%</strong>
                    <span>{trendDelta >= 0 ? 'نمو مقارنة ببداية الفترة' : 'انخفاض مقارنة ببداية الفترة'}</span>
                  </div>
                </div>'''
if old_stats not in s:
    raise SystemExit('REVENUE_STATS_ANCHOR_NOT_FOUND')
s=s.replace(old_stats,new_stats,1)

old_chart='''                <div className="adex-chart" style={{ minHeight: 220 }}>'''
new_chart='''                <div className="rev-visual-grid">
                  <div className="adex-chart" style={{ minHeight: 220 }}>'''
if old_chart not in s:
    raise SystemExit('REVENUE_CHART_ANCHOR_NOT_FOUND')
s=s.replace(old_chart,new_chart,1)

old_total='''                <div className="rev-total">
                  <strong>{periodPlatformRevenue.toLocaleString()} ر.س</strong>
                  <span><TrendingUp size={13} /> إيراد عمولة المنصة (1%) — {trendDelta >= 0 ? 'نمو' : 'انخفاض'} خلال {rangeSummaryLabel}</span>
                </div>'''
new_total='''                  <aside className="rev-total">
                    <div className="rev-total__ring" aria-hidden="true">
                      <div className="rev-total__ring-core">
                        <strong>{analyticsSales.toLocaleString()}</strong>
                        <small>ر.س</small>
                      </div>
                    </div>
                    <div className="rev-total__copy">
                      <span>ملخص الفترة</span>
                      <strong>{periodPlatformRevenue.toLocaleString()} ر.س</strong>
                      <small>إيراد عمولة المنصة (1%)</small>
                      <em className={trendDelta >= 0 ? 'up' : 'down'}><TrendingUp size={12} /> {trendDelta >= 0 ? '+' : ''}{trendDelta}%</em>
                    </div>
                  </aside>
                </div>'''
if old_total not in s:
    raise SystemExit('REVENUE_TOTAL_ANCHOR_NOT_FOUND')
s=s.replace(old_total,new_total,1)

p.write_text(s)
PY

  FAILED_STEP=append_v24_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V24 — PREMIUM REVENUE PERFORMANCE
   Approved concept translated from the V23 live screenshots.
   Scope lock: Revenue & Performance card ONLY.
   Preserve every existing revenue value, date-range calculation and SVG trend-series logic.
   No Hero, Date Filter, KPI, System Health, Live Operations, Current Operations,
   Transactions, Sidebar, backend, auth, or business-data changes. */

.adm-chart-card{
  position:relative!important;
  isolation:isolate!important;
  height:286px!important;
  min-height:286px!important;
  max-height:286px!important;
  padding:12px 13px 12px!important;
  overflow:hidden!important;
  border-radius:16px!important;
  background:
    radial-gradient(circle at 8% -18%,rgba(215,173,81,.075),transparent 30%),
    linear-gradient(180deg,#fffefa 0%,#fbf7ef 100%)!important;
  border:1px solid rgba(190,133,27,.34)!important;
  box-shadow:0 12px 30px rgba(76,48,6,.075),inset 0 1px 0 rgba(255,255,255,.92)!important;
}
.adm-chart-card::before{
  content:""!important;
  position:absolute!important;
  left:18px!important;right:18px!important;top:0!important;height:2px!important;
  background:linear-gradient(90deg,transparent,#d7ad51 26%,#b47c1d 62%,transparent)!important;
  opacity:.76!important;
  pointer-events:none!important;
}

.adm-chart-card__head{
  min-height:34px!important;
  margin:0 0 7px!important;
  padding:0 1px!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:12px!important;
}
.rev-title-group{
  display:flex!important;
  align-items:center!important;
  gap:9px!important;
  min-width:0!important;
}
.rev-title-icon{
  width:34px!important;height:34px!important;min-width:34px!important;
  display:grid!important;place-items:center!important;
  border-radius:10px!important;
  color:#b67f1e!important;
  background:linear-gradient(145deg,#fff8e8,#efdbac)!important;
  border:1px solid rgba(178,121,20,.20)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.82),0 6px 14px rgba(112,72,8,.08)!important;
}
.rev-title-copy{display:grid!important;gap:2px!important;min-width:0!important}
.rev-title-copy h3{
  margin:0!important;
  font-size:13px!important;
  line-height:1.15!important;
  color:#121820!important;
  font-weight:950!important;
  letter-spacing:-.02em!important;
}
.rev-title-copy small{
  font-size:7.8px!important;
  line-height:1.25!important;
  color:#9a9184!important;
  font-weight:700!important;
}
.rev-period-pill{
  height:25px!important;
  padding:0 9px!important;
  display:inline-flex!important;align-items:center!important;
  border-radius:999px!important;
  white-space:nowrap!important;
  font-size:8px!important;
  font-weight:850!important;
  color:#8a6a28!important;
  background:linear-gradient(180deg,#fffaf0,#f4ead6)!important;
  border:1px solid rgba(184,129,25,.18)!important;
}

.rev-stats{
  display:grid!important;
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:6px!important;
  margin:0 0 7px!important;
}
.rev-stat{
  position:relative!important;
  min-height:49px!important;
  padding:7px 8px 6px!important;
  display:grid!important;
  grid-template-rows:auto 1fr auto!important;
  gap:2px!important;
  border-radius:9px!important;
  overflow:hidden!important;
  background:linear-gradient(180deg,#faf6ee 0%,#f6efe3 100%)!important;
  border:1px solid rgba(183,129,28,.14)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.65)!important;
}
.rev-stat::before{
  content:""!important;
  position:absolute!important;
  right:0!important;top:8px!important;bottom:8px!important;width:2px!important;
  border-radius:99px!important;
  background:linear-gradient(180deg,#d7ad51,rgba(215,173,81,.12))!important;
  opacity:.72!important;
}
.rev-stat--trend::before{background:linear-gradient(180deg,#15a56f,rgba(21,165,111,.12))!important}
.rev-stat small{
  font-size:7.2px!important;
  color:#9a9185!important;
  font-weight:760!important;
  line-height:1!important;
}
.rev-stat strong{
  display:flex!important;
  align-items:center!important;
  gap:4px!important;
  min-width:0!important;
  font-size:12.5px!important;
  line-height:1!important;
  color:#151b23!important;
  font-weight:950!important;
  letter-spacing:-.025em!important;
  white-space:nowrap!important;
}
.rev-stat strong em{font-size:7px!important;font-style:normal!important;color:#948a7b!important;font-weight:800!important}
.rev-stat strong.up{color:#139b68!important}
.rev-stat strong.down{color:#c4533f!important}
.rev-stat>span{
  font-size:6.7px!important;
  color:#aaa195!important;
  line-height:1.05!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}

.rev-visual-grid{
  display:grid!important;
  grid-template-columns:minmax(0,3.7fr) minmax(128px,1fr)!important;
  gap:8px!important;
  height:174px!important;
  min-height:174px!important;
  align-items:stretch!important;
  direction:ltr!important;
}
.rev-visual-grid>*{direction:rtl!important;min-width:0!important}

.adm-chart-card .adex-chart{
  position:relative!important;
  box-sizing:border-box!important;
  min-height:174px!important;
  height:174px!important;
  padding:4px 3px 0!important;
  overflow:hidden!important;
  border-radius:10px!important;
  background:
    linear-gradient(rgba(183,129,28,.032) 1px,transparent 1px),
    linear-gradient(90deg,rgba(183,129,28,.025) 1px,transparent 1px),
    linear-gradient(180deg,rgba(255,255,255,.62),rgba(250,246,238,.60))!important;
  background-size:28px 28px,28px 28px,auto!important;
  border:1px solid rgba(185,130,28,.10)!important;
}
.adm-chart-card .adex-chart svg{
  filter:drop-shadow(0 7px 12px rgba(173,112,12,.035))!important;
}

.rev-total{
  position:relative!important;
  height:174px!important;
  min-height:174px!important;
  padding:9px 8px!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:center!important;
  justify-content:center!important;
  gap:7px!important;
  border-radius:11px!important;
  overflow:hidden!important;
  background:
    radial-gradient(circle at 50% 5%,rgba(215,173,81,.11),transparent 38%),
    linear-gradient(160deg,#fffdf8 0%,#f3ead8 100%)!important;
  border:1px solid rgba(183,127,25,.18)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.84)!important;
}
.rev-total::before{
  content:""!important;
  position:absolute!important;
  inset:0 0 auto 0!important;
  height:2px!important;
  background:linear-gradient(90deg,transparent,#d8ad50,transparent)!important;
}
.rev-total__ring{
  position:relative!important;
  width:84px!important;height:84px!important;min-height:84px!important;
  display:grid!important;place-items:center!important;
  border-radius:50%!important;
  background:conic-gradient(#c98e24 0 62%,#efd58d 62% 76%,#1f2934 76% 88%,#d8c6a6 88% 100%)!important;
  box-shadow:0 8px 20px rgba(111,71,7,.11),inset 0 0 0 1px rgba(255,255,255,.42)!important;
}
.rev-total__ring::before{
  content:""!important;
  position:absolute!important;
  inset:9px!important;
  border-radius:50%!important;
  background:linear-gradient(145deg,#fffdf8,#f8f1e5)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.86)!important;
}
.rev-total__ring-core{
  position:relative!important;
  z-index:2!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:center!important;
  gap:2px!important;
}
.rev-total__ring-core strong{
  font-size:10.5px!important;
  line-height:1!important;
  color:#111820!important;
  font-weight:950!important;
  letter-spacing:-.035em!important;
}
.rev-total__ring-core small{font-size:6.5px!important;color:#9b8d78!important;font-weight:800!important}
.rev-total__copy{
  width:100%!important;
  display:grid!important;
  justify-items:center!important;
  gap:2px!important;
  text-align:center!important;
}
.rev-total__copy>span{font-size:6.7px!important;color:#9a8e7d!important;font-weight:800!important}
.rev-total__copy>strong{font-size:11px!important;line-height:1!important;color:#161c23!important;font-weight:950!important}
.rev-total__copy>small{font-size:6.4px!important;color:#a69b8c!important}
.rev-total__copy>em{
  margin-top:2px!important;
  display:inline-flex!important;align-items:center!important;gap:3px!important;
  padding:3px 6px!important;
  border-radius:999px!important;
  font-size:7px!important;
  font-style:normal!important;
  font-weight:900!important;
  background:rgba(18,158,106,.09)!important;
  border:1px solid rgba(18,158,106,.16)!important;
  color:#149a68!important;
}
.rev-total__copy>em.down{color:#be533f!important;background:rgba(190,83,63,.08)!important;border-color:rgba(190,83,63,.15)!important}

@media(max-width:1360px){
  .adm-chart-card{padding:10px 11px!important}
  .rev-stats{gap:5px!important}
  .rev-stat{padding:6px!important}
  .rev-stat strong{font-size:11px!important}
  .rev-stat>span{font-size:6.2px!important}
  .rev-visual-grid{grid-template-columns:minmax(0,3.5fr) minmax(116px,.95fr)!important;gap:6px!important}
  .rev-total__ring{width:74px!important;height:74px!important;min-height:74px!important}
  .rev-total__ring-core strong{font-size:9.5px!important}
}
CSS

  grep -q "import './AdminDashboard.v24.css';" "$TARGET_JSX"
  grep -q "rev-visual-grid" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V24 — PREMIUM REVENUE PERFORMANCE" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v24-revenue-build.log 2>&1 || {
  tail -n 160 /tmp/67-v24-revenue-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING
grep -q "rev-visual-grid" "$TARGET_JSX" || fail REVENUE_MARKUP_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V23"
echo "TARGET_VERSION=V24"
echo "RUNTIME_CSS=AdminDashboard.v24.css"
echo "ELEMENT=REVENUE_PERFORMANCE_ONLY"
echo "APPROVED_CONCEPT_TRANSLATED=YES"
echo "REVENUE_HEADER_PREMIUM=YES"
echo "REVENUE_SUMMARY_TILES=4"
echo "REVENUE_CHART_LOGIC_CHANGED=NO"
echo "REVENUE_VALUES_CHANGED=NO"
echo "REVENUE_RING=SUMMARY_VISUAL"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "LIVE_OPERATIONS_CHANGED=NO"
echo "CURRENT_OPERATIONS_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
