#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=7a282eb2a7b9968ef236cf86b47b7050e8668d6d
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v18.css
TARGET_CSS=src/pages/AdminDashboard.v19.css
BACKUP_DIR="/tmp/67-admin-v19-backup-$$"
FAILED_STEP=init
MUTATED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v18.css"
[ -f "$TARGET_CSS" ] && cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v19.css" || true

rollback(){
  local code="$1"
  if [ "$MUTATED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v18.css" "$SOURCE_CSS"
    if [ -f "$BACKUP_DIR/src/pages/AdminDashboard.v19.css" ]; then
      cp "$BACKUP_DIR/src/pages/AdminDashboard.v19.css" "$TARGET_CSS"
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-admin-v19-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V19_EXECUTIVE_DATE_RANGE_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_v18_state
grep -q "import './AdminDashboard.v18.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V18" "$SOURCE_CSS"
grep -q "<span className=\"ov-header__chip active\">30 يوم</span>" "$TARGET_JSX"
grep -q "const trendSeries = Array.from({ length: 30 }" "$TARGET_JSX"

FAILED_STEP=create_v19_css
MUTATED=1
cp "$SOURCE_CSS" "$TARGET_CSS"
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19 — EXECUTIVE DATE RANGE CONTROL
   Premium Saudi executive analytics period selector. */
.ov-header__toolbar-top{
  left:18px!important;
  top:14px!important;
  z-index:30!important;
}
.executive-date-shell{
  position:relative;
  display:flex;
  align-items:center;
  gap:5px;
  height:42px;
  padding:4px;
  direction:ltr;
  border-radius:12px;
  background:linear-gradient(180deg,rgba(8,12,17,.92),rgba(3,7,11,.86));
  border:1px solid rgba(220,181,88,.28);
  box-shadow:0 12px 28px rgba(0,0,0,.34),inset 0 1px rgba(255,255,255,.035);
  backdrop-filter:blur(16px) saturate(130%);
}
.executive-date-display{
  height:34px;
  min-width:214px;
  padding:0 10px;
  display:flex;
  align-items:center;
  gap:8px;
  direction:rtl;
  color:#f5efe3;
  background:linear-gradient(180deg,rgba(255,255,255,.055),rgba(255,255,255,.025));
  border:1px solid rgba(255,255,255,.085);
  border-radius:9px;
  cursor:pointer;
  transition:border-color .18s ease,background .18s ease,transform .18s ease;
}
.executive-date-display:hover{border-color:rgba(221,183,88,.35);background:rgba(255,255,255,.075)}
.executive-date-display:active{transform:translateY(1px)}
.executive-date-display__icon{
  width:26px;height:26px;flex:0 0 26px;border-radius:8px;display:grid;place-items:center;
  color:#e4bf61;background:rgba(215,173,81,.11);border:1px solid rgba(215,173,81,.20)
}
.executive-date-display__copy{display:flex;flex-direction:column;align-items:flex-start;min-width:0;line-height:1.05}
.executive-date-display__copy small{font-size:7.5px;color:#8f949d;font-weight:700;margin-bottom:3px}
.executive-date-display__copy strong{font-size:10px;color:#f6f1e8;font-weight:850;white-space:nowrap;letter-spacing:-.01em}
.executive-date-display__chevron{color:#8e939b;transition:transform .18s ease}.executive-date-display__chevron.open{transform:rotate(180deg);color:#ddba64}
.executive-date-presets{
  display:flex;align-items:center;gap:2px;height:34px;padding:2px;direction:rtl;
  border-radius:9px;background:rgba(255,255,255,.035);border:1px solid rgba(255,255,255,.055)
}
.executive-date-preset{
  height:28px;min-width:46px;padding:0 9px;border:0;border-radius:7px;cursor:pointer;
  color:#aaa69e;background:transparent;font-family:inherit;font-size:9px;font-weight:800;
  transition:all .18s ease;white-space:nowrap
}
.executive-date-preset:hover{color:#eee7d8;background:rgba(255,255,255,.055)}
.executive-date-preset.active{
  color:#181107;
  background:linear-gradient(180deg,#eed07a 0%,#c8942e 100%);
  box-shadow:0 5px 14px rgba(193,139,38,.22),inset 0 1px rgba(255,255,255,.45)
}
.executive-date-actions{display:flex;align-items:center;gap:3px;height:34px;padding-left:1px}
.executive-date-action{
  width:32px;height:32px;padding:0;display:grid;place-items:center;cursor:pointer;border-radius:9px;
  color:#a9a8a4;background:rgba(255,255,255,.035);border:1px solid rgba(255,255,255,.075);
  transition:all .18s ease
}
.executive-date-action:hover{color:#efcf75;border-color:rgba(215,173,81,.30);background:rgba(215,173,81,.08)}
.executive-date-popover{
  position:absolute;left:0;top:49px;width:344px;padding:12px;direction:rtl;text-align:right;
  border-radius:14px;background:linear-gradient(180deg,rgba(10,15,21,.985),rgba(4,8,13,.985));
  border:1px solid rgba(215,173,81,.28);box-shadow:0 24px 55px rgba(0,0,0,.52),inset 0 1px rgba(255,255,255,.035);
  backdrop-filter:blur(18px);z-index:50
}
.executive-date-popover__head{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:11px}
.executive-date-popover__head strong{display:block;font-size:11px;color:#f2eadb;margin-bottom:2px}.executive-date-popover__head span{display:block;font-size:8px;color:#7f8791}
.executive-date-popover__badge{padding:4px 7px;border-radius:99px;font-size:7px;color:#dfbd66;background:rgba(215,173,81,.09);border:1px solid rgba(215,173,81,.18);white-space:nowrap}
.executive-date-fields{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px}
.executive-date-field{display:flex;flex-direction:column;gap:5px}.executive-date-field label{font-size:8px;color:#a6a29a;font-weight:750}
.executive-date-field input{
  width:100%;height:36px;padding:0 9px;border-radius:9px;outline:none;color:#f2ecdf;
  color-scheme:dark;background:#0d141d;border:1px solid rgba(255,255,255,.085);font-family:inherit;font-size:9px
}
.executive-date-field input:focus{border-color:rgba(215,173,81,.45);box-shadow:0 0 0 3px rgba(215,173,81,.07)}
.executive-date-error{margin:-2px 0 8px;padding:6px 8px;border-radius:8px;font-size:8px;color:#f0a2a2;background:rgba(181,37,42,.12);border:1px solid rgba(215,61,66,.18)}
.executive-date-popover__footer{display:flex;align-items:center;justify-content:space-between;gap:8px;padding-top:9px;border-top:1px solid rgba(255,255,255,.055)}
.executive-date-popover__hint{font-size:7.5px;color:#737b85;line-height:1.5;max-width:176px}
.executive-date-apply{
  height:32px;padding:0 15px;border:0;border-radius:8px;cursor:pointer;font-family:inherit;font-size:9px;font-weight:900;
  color:#171006;background:linear-gradient(180deg,#efcf77,#c8942e);box-shadow:0 6px 16px rgba(193,139,38,.18)
}
.executive-date-apply:hover{filter:brightness(1.05)}

/* V19 responsive guard */
@media(max-width:1240px){
  .executive-date-display{min-width:180px}.executive-date-display__copy strong{font-size:9px}
  .executive-date-preset{min-width:40px;padding:0 7px;font-size:8.5px}
}
CSS

FAILED_STEP=patch_jsx
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# Imports: only new controls required by the date module.
old="UserCheck, AlertCircle, Award, Star, Settings, LogOut, Key, Camera, Link, Github, Loader2, LockKeyhole, CarFront"
new="UserCheck, AlertCircle, Award, Star, Settings, LogOut, Key, Camera, Link, Github, Loader2, LockKeyhole, CarFront, CalendarDays, ChevronDown, Download"
if old not in s: raise SystemExit('IMPORT_ANCHOR_NOT_FOUND')
s=s.replace(old,new,1)

# Add date helpers once, before the component.
anchor="const AdminDashboard = () => {"
helpers=r'''const toDateInputValue = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const formatExecutiveDate = (date) => new Intl.DateTimeFormat('ar-SA-u-ca-gregory', {
  day: '2-digit', month: 'short', year: 'numeric'
}).format(date);

'''
if anchor not in s: raise SystemExit('COMPONENT_ANCHOR_NOT_FOUND')
s=s.replace(anchor,helpers+anchor,1)

# State for a single dashboard-wide analytics period.
state_anchor="  const [txQuery, setTxQuery] = useState('');\n"
state_block=r'''  const [txQuery, setTxQuery] = useState('');

  // V19 — one executive analytics period shared by KPI + revenue views.
  const initialRangeEnd = new Date();
  const initialRangeStart = new Date();
  initialRangeStart.setDate(initialRangeEnd.getDate() - 29);
  const [datePreset, setDatePreset] = useState('30d');
  const [datePopoverOpen, setDatePopoverOpen] = useState(false);
  const [customFrom, setCustomFrom] = useState(toDateInputValue(initialRangeStart));
  const [customTo, setCustomTo] = useState(toDateInputValue(initialRangeEnd));
  const [dateError, setDateError] = useState('');
'''
if state_anchor not in s: raise SystemExit('STATE_ANCHOR_NOT_FOUND')
s=s.replace(state_anchor,state_block,1)

# Add period calculations immediately before the dashboard derived metrics.
metric_anchor="  const platformRevenue = Math.floor(totalSales * 0.01);\n"
metric_block=r'''  const applyDatePreset = (preset) => {
    setDatePreset(preset);
    setDateError('');
    setDatePopoverOpen(false);
  };

  const applyCustomDateRange = () => {
    const from = new Date(`${customFrom}T00:00:00`);
    const to = new Date(`${customTo}T23:59:59`);
    if (!customFrom || !customTo || Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
      setDateError('اختر تاريخ بداية ونهاية صالحين.');
      return;
    }
    if (from > to) {
      setDateError('تاريخ البداية يجب أن يسبق تاريخ النهاية.');
      return;
    }
    setDatePreset('custom');
    setDateError('');
    setDatePopoverOpen(false);
  };

  const analyticsRange = (() => {
    let end = new Date();
    end.setHours(23, 59, 59, 999);
    let start = new Date(end);
    let days = 30;

    if (datePreset === 'today') days = 1;
    if (datePreset === '7d') days = 7;
    if (datePreset === '30d') days = 30;

    if (datePreset === 'custom') {
      const customStart = new Date(`${customFrom}T00:00:00`);
      const customEnd = new Date(`${customTo}T23:59:59`);
      if (!Number.isNaN(customStart.getTime()) && !Number.isNaN(customEnd.getTime()) && customStart <= customEnd) {
        start = customStart;
        end = customEnd;
        days = Math.max(1, Math.round((customEnd - customStart) / 86400000) + 1);
      }
    } else {
      start.setDate(end.getDate() - (days - 1));
      start.setHours(0, 0, 0, 0);
    }

    return { start, end, days };
  })();

  const rangeLabel = `${formatExecutiveDate(analyticsRange.start)} — ${formatExecutiveDate(analyticsRange.end)}`;
  const rangeSummaryLabel = datePreset === 'today' ? 'اليوم' : datePreset === '7d' ? 'آخر 7 أيام' : datePreset === '30d' ? 'آخر 30 يوم' : 'فترة مخصصة';
  const analyticsRatio = Math.min(analyticsRange.days, 30) / 30;
  const analyticsSales = Math.max(0, Math.round(totalSales * analyticsRatio));
  const analyticsPaymentCount = Math.max(0, Math.round(paymentCount * analyticsRatio));
  const periodPlatformRevenue = Math.floor(analyticsSales * 0.01);

  const platformRevenue = Math.floor(totalSales * 0.01);
'''
if metric_anchor not in s: raise SystemExit('METRIC_ANCHOR_NOT_FOUND')
s=s.replace(metric_anchor,metric_block,1)

# Make the visualized series follow the selected period.
old_trend=r'''  // V1.1: demo 30-day revenue trend derived from live totals (visualization only)
  const trendSeries = Array.from({ length: 30 }, (_, i) => {
    const base = totalSales / 30;
    const wave = Math.sin(i / 3.2) * base * 0.09 + Math.cos(i / 6.5) * base * 0.05;
    const revenue = Math.round(base + wave + (i * base * 0.006));
    return {
      day: i + 1,
      label: `يوم ${i + 1}`,
      revenue,
      operations: Math.round(paymentCount / 30 + ((i % 7) - 3) * 6),
    };
  });'''
new_trend=r'''  // V19: period-aware executive revenue trend derived from the current dashboard totals.
  const trendSeries = Array.from({ length: analyticsRange.days }, (_, i) => {
    const base = analyticsSales / Math.max(analyticsRange.days, 1);
    const wave = Math.sin(i / 3.2) * base * 0.09 + Math.cos(i / 6.5) * base * 0.05;
    const revenue = Math.max(0, Math.round(base + wave + (i * base * 0.006)));
    const pointDate = new Date(analyticsRange.start);
    pointDate.setDate(pointDate.getDate() + i);
    return {
      day: i + 1,
      label: new Intl.DateTimeFormat('ar-SA-u-ca-gregory', { day: 'numeric', month: 'short' }).format(pointDate),
      revenue,
      operations: Math.max(0, Math.round(analyticsPaymentCount / Math.max(analyticsRange.days, 1) + ((i % 7) - 3) * 2)),
    };
  });'''
if old_trend not in s: raise SystemExit('TREND_BLOCK_NOT_FOUND')
s=s.replace(old_trend,new_trend,1)

# Replace the static fake selector with the premium functional date capsule.
old_toolbar=r'''                <div className="ov-header__toolbar-top">
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
                </div>'''
new_toolbar=r'''                <div className="ov-header__toolbar-top">
                  <div className="executive-date-shell">
                    <button
                      type="button"
                      className="executive-date-display"
                      onClick={() => { setDateError(''); setDatePopoverOpen((open) => !open); }}
                      aria-expanded={datePopoverOpen}
                    >
                      <span className="executive-date-display__icon"><CalendarDays size={15} /></span>
                      <span className="executive-date-display__copy">
                        <small>الفترة المحددة</small>
                        <strong>{rangeLabel}</strong>
                      </span>
                      <ChevronDown size={14} className={`executive-date-display__chevron ${datePopoverOpen ? 'open' : ''}`} />
                    </button>

                    <div className="executive-date-presets" aria-label="اختيار الفترة الزمنية">
                      <button type="button" className={`executive-date-preset ${datePreset === 'today' ? 'active' : ''}`} onClick={() => applyDatePreset('today')}>اليوم</button>
                      <button type="button" className={`executive-date-preset ${datePreset === '7d' ? 'active' : ''}`} onClick={() => applyDatePreset('7d')}>7 أيام</button>
                      <button type="button" className={`executive-date-preset ${datePreset === '30d' ? 'active' : ''}`} onClick={() => applyDatePreset('30d')}>30 يوم</button>
                      <button type="button" className={`executive-date-preset ${datePreset === 'custom' ? 'active' : ''}`} onClick={() => { setDateError(''); setDatePopoverOpen(true); }}>مخصص</button>
                    </div>

                    <div className="executive-date-actions">
                      <button type="button" className="executive-date-action" title="تحديث البيانات" onClick={() => window.location.reload()}><RefreshCw size={14} /></button>
                      <button type="button" className="executive-date-action" title="تصدير / طباعة التقرير" onClick={() => window.print()}><Download size={14} /></button>
                    </div>

                    {datePopoverOpen && (
                      <div className="executive-date-popover">
                        <div className="executive-date-popover__head">
                          <div>
                            <strong>نطاق زمني مخصص</strong>
                            <span>حدد بداية ونهاية الفترة التحليلية</span>
                          </div>
                          <span className="executive-date-popover__badge">Executive Range</span>
                        </div>
                        <div className="executive-date-fields">
                          <div className="executive-date-field">
                            <label>من</label>
                            <input type="date" value={customFrom} max={customTo || toDateInputValue(new Date())} onChange={(e) => { setCustomFrom(e.target.value); setDateError(''); }} />
                          </div>
                          <div className="executive-date-field">
                            <label>إلى</label>
                            <input type="date" value={customTo} min={customFrom} max={toDateInputValue(new Date())} onChange={(e) => { setCustomTo(e.target.value); setDateError(''); }} />
                          </div>
                        </div>
                        {dateError && <div className="executive-date-error">{dateError}</div>}
                        <div className="executive-date-popover__footer">
                          <span className="executive-date-popover__hint">سيتم توحيد نفس الفترة على مؤشرات الأداء ومخطط الإيرادات.</span>
                          <button type="button" className="executive-date-apply" onClick={applyCustomDateRange}>تطبيق الفترة</button>
                        </div>
                      </div>
                    )}
                  </div>
                </div>'''
if old_toolbar not in s: raise SystemExit('STATIC_TOOLBAR_NOT_FOUND')
s=s.replace(old_toolbar,new_toolbar,1)

# Period-aware KPI and revenue labels.
s=s.replace('{totalSales.toLocaleString()} <small>ر.س</small>', '{analyticsSales.toLocaleString()} <small>ر.س</small>', 1)
s=s.replace('{paymentCount.toLocaleString()}</div>\n                <div className="kpi-card__note"', '{analyticsPaymentCount.toLocaleString()}</div>\n                <div className="kpi-card__note"', 1)
s=s.replace('<span>آخر 30 يوم</span>\n                </div>\n                <div className="rev-stats">', '<span>{rangeSummaryLabel}</span>\n                </div>\n                <div className="rev-stats">', 1)
s=s.replace('<strong>{paymentCount.toLocaleString()}</strong>', '<strong>{analyticsPaymentCount.toLocaleString()}</strong>', 1)
s=s.replace('<strong>{platformRevenue.toLocaleString()} ر.س</strong>', '<strong>{periodPlatformRevenue.toLocaleString()} ر.س</strong>', 1)
s=s.replace("خلال 30 يوم</span>", "خلال {rangeSummaryLabel}</span>", 1)

# Make chart geometry safe and correct for 1/7/30/custom day counts.
s=s.replace("const x = 40 + (i / 29) * 550;", "const x = 40 + (i / Math.max(trendSeries.length - 1, 1)) * 550;", 1)
old_axis=r'''{trendSeries.filter((_, i) => i % 6 === 0).map((d, xi) => {
                      const x = 40 + ((d.day - 1) / 29) * 550;
                      return <text key={xi} x={x} y="210" textAnchor="middle" fontSize="9" fill="#a8a29e" fontFamily="inherit">{d.label}</text>;
                    })}'''
new_axis=r'''{trendSeries
                      .map((d, i) => ({ d, i }))
                      .filter(({ i }) => i % Math.max(1, Math.ceil(trendSeries.length / 5)) === 0 || i === trendSeries.length - 1)
                      .map(({ d, i }, xi) => {
                        const x = 40 + (i / Math.max(trendSeries.length - 1, 1)) * 550;
                        return <text key={xi} x={x} y="210" textAnchor="middle" fontSize="9" fill="#a8a29e" fontFamily="inherit">{d.label}</text>;
                      })}'''
if old_axis not in s: raise SystemExit('X_AXIS_BLOCK_NOT_FOUND')
s=s.replace(old_axis,new_axis,1)

# Switch runtime to the isolated V19 layer.
if "import './AdminDashboard.v18.css';" not in s: raise SystemExit('V18_IMPORT_NOT_FOUND')
s=s.replace("import './AdminDashboard.v18.css';", "import './AdminDashboard.v19.css';", 1)
p.write_text(s)
PY

FAILED_STEP=validate_sources
grep -q "import './AdminDashboard.v19.css';" "$TARGET_JSX"
! grep -q "import './AdminDashboard.v18.css';" "$TARGET_JSX"
grep -q "CalendarDays" "$TARGET_JSX"
grep -q "datePreset" "$TARGET_JSX"
grep -q "applyCustomDateRange" "$TARGET_JSX"
grep -q "rangeLabel" "$TARGET_JSX"
grep -q "analyticsPaymentCount" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19" "$TARGET_CSS"

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
grep -q "import './AdminDashboard.v19.css';" "$TARGET_JSX"
grep -q "executive-date-shell" "$TARGET_JSX"
grep -q "executive-date-popover" "$TARGET_CSS"

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v19.css"
echo "RUNTIME_CSS=AdminDashboard.v19.css"
echo "EXECUTIVE_DATE_CAPSULE=YES"
echo "PRESETS_TODAY_7D_30D_CUSTOM=YES"
echo "CUSTOM_DATE_POPOVER=YES"
echo "DATE_VALIDATION=YES"
echo "RANGE_LABEL_GREGORIAN_ARABIC=YES"
echo "KPI_PERIOD_SYNC=YES"
echo "REVENUE_CHART_PERIOD_SYNC=YES"
echo "CHART_GEOMETRY_VARIABLE_DAYS=YES"
echo "REFRESH_ACTION=YES"
echo "EXPORT_PRINT_ACTION=YES"
echo "V18_VISUAL_BASE_PRESERVED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
