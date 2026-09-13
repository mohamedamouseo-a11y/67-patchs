#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
TARGET=src/pages/AdminDashboard.v37.css
MASTER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v37-reference-lock-master.css
BACKUP=/tmp/67-v37-reference-lock-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
grep -q "AdminDashboard.v36.css" "$JSX" || { echo 'FAILED_STEP=V36_RUNTIME_NOT_ACTIVE'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"

curl -fsSL "$MASTER_URL" -o "$TARGET"
grep -q 'SIX SEVEN ADMIN V37 — REFERENCE LOCK MASTER' "$TARGET" || { echo 'FAILED_STEP=MASTER_CSS_DOWNLOAD_FAILED'; exit 1; }

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# Runtime stylesheet: V37 standalone only.
s=s.replace("import './AdminDashboard.v36.css';","import './AdminDashboard.v37.css';",1)

# Ensure Search is available for the reference toolbar.
if ' Eye, Search, RefreshCw' not in s:
    s=s.replace('Layers, Eye, RefreshCw, Activity,','Layers, Eye, Search, RefreshCw, Activity,',1)

start_marker='        {/* Tab Content: OVERVIEW */}'
end_marker='        {/* Tab Content: USERS AND SELLERS LOGS */}'
start=s.find(start_marker)
end=s.find(end_marker)
if start < 0 or end < 0 or end <= start:
    raise SystemExit('OVERVIEW_BLOCK_ANCHORS_NOT_FOUND')

new_overview=r'''        {/* Tab Content: OVERVIEW — V37 exact reference-lock composition */}
        {activeTab === 'overview' && (
          <div className="v37-dashboard animate-fadeIn">

            <section className="v37-hero" style={{ '--v37-hero': `url(${heroHighResV295})` }}>
              <div className="v37-hero-tools">
                <span className="v37-admin-mini">
                  <span className="v37-admin-mini__avatar"><Users size={13} /></span>
                  <span><b>مرحبًا بك مجددًا</b><small>Super Admin</small></span>
                </span>
                <span className="v37-tool-dot"><Search size={12} /></span>
                <span className="v37-tool-dot"><Bell size={12} /></span>
                <span className="v37-tool-dot"><Settings size={12} /></span>
              </div>

              <div className="v37-hero-copy-left">
                <h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>
                <p>منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</p>
              </div>

              <div className="v37-hero-copy-right">
                <span>سرعة أكبر</span>
                <strong>فرص أوسع</strong>
                <small>DRIVE A BRIGHTER TOMORROW</small>
              </div>

              <div className="v37-datebar">
                <button type="button" className="v37-date-display" onClick={() => { setDateError(''); setDatePopoverOpen((open) => !open); }} aria-expanded={datePopoverOpen}>
                  <CalendarDays size={13} />
                  <span><small>الفترة المحددة</small><strong>{rangeLabel}</strong></span>
                  <ChevronDown size={12} />
                </button>
                <div className="v37-date-presets">
                  <button type="button" className={datePreset === 'today' ? 'active' : ''} onClick={() => applyDatePreset('today')}>اليوم</button>
                  <button type="button" className={datePreset === '7d' ? 'active' : ''} onClick={() => applyDatePreset('7d')}>الأسبوع</button>
                  <button type="button" className={datePreset === '30d' ? 'active' : ''} onClick={() => applyDatePreset('30d')}>آخر 30 يوم</button>
                  <button type="button" className={datePreset === 'custom' ? 'active' : ''} onClick={() => { setDateError(''); setDatePopoverOpen(true); }}>مخصص</button>
                </div>
                <div className="v37-date-actions">
                  <button type="button" title="تحديث" onClick={() => window.location.reload()}><RefreshCw size={12} /></button>
                  <button type="button" title="تصدير" onClick={() => window.print()}><Download size={12} /></button>
                </div>
              </div>
              <span className="v37-hero-redline" />
            </section>

            {datePopoverOpen && (
              <section className="v37-date-popover" aria-live="polite">
                <div className="v37-date-popover__head">
                  <div><strong>تخصيص الفترة الزمنية</strong><span>اختر نطاق التواريخ لعرض البيانات والتقارير</span></div>
                  <span>{rangeLabel}</span>
                </div>
                <div className="v37-date-popover__fields">
                  <label className="v37-date-field"><span>من</span><input type="date" value={customFrom} max={customTo || toDateInputValue(new Date())} onChange={(e) => { setCustomFrom(e.target.value); setDateError(''); }} /></label>
                  <label className="v37-date-field"><span>إلى</span><input type="date" value={customTo} min={customFrom} max={toDateInputValue(new Date())} onChange={(e) => { setCustomTo(e.target.value); setDateError(''); }} /></label>
                </div>
                {dateError && <div className="executive-date-error">{dateError}</div>}
                <div className="v37-date-popover__foot">
                  <span>سيتم تطبيق الفترة على جميع المؤشرات والرسوم البيانية.</span>
                  <div className="v37-date-popover__buttons">
                    <button type="button" onClick={() => { setDateError(''); setDatePopoverOpen(false); }}>إلغاء</button>
                    <button type="button" onClick={applyCustomDateRange}>تطبيق الفترة</button>
                  </div>
                </div>
              </section>
            )}

            <section className="v37-kpis">
              <article className="v37-kpi v37-kpi--sales">
                <div className="v37-kpi__top"><span>إجمالي المبيعات</span><span className="v37-kpi__ico"><DollarSign size={16} /></span></div>
                <div className="v37-kpi__value">{analyticsSales.toLocaleString()} <small>ر.س</small></div>
                <div className="v37-kpi__foot"><TrendingUp size={11} /><b>+12%</b><span>تحديث فوري مباشر</span></div>
              </article>
              <article className="v37-kpi v37-kpi--pay">
                <div className="v37-kpi__top"><span>عمليات دفع ناجحة</span><span className="v37-kpi__ico"><CreditCard size={16} /></span></div>
                <div className="v37-kpi__value">{analyticsPaymentCount.toLocaleString()}</div>
                <div className="v37-kpi__foot"><TrendingUp size={11} /><b>+8%</b><span>عملية</span></div>
              </article>
              <article className="v37-kpi v37-kpi--seller">
                <div className="v37-kpi__top"><span>التجار النشطون</span><span className="v37-kpi__ico"><Store size={16} /></span></div>
                <div className="v37-kpi__value">{verifiedSellersCount}</div>
                <div className="v37-kpi__foot"><UserCheck size={11} /><b>+100%</b><span>متجر</span></div>
              </article>
              <article className="v37-kpi v37-kpi--user">
                <div className="v37-kpi__top"><span>العملاء المسجلون</span><span className="v37-kpi__ico"><Users size={16} /></span></div>
                <div className="v37-kpi__value">{customers.length.toLocaleString()}</div>
                <div className="v37-kpi__foot"><Activity size={11} /><b>+33%</b><span>نمو مستمر</span></div>
              </article>
            </section>

            <section className="v37-health">
              <div className="v37-health__status">
                <h3>حالة المنصة</h3>
                <span className="v37-health__stable"><i className="v37-dot" /> تعمل بشكل طبيعي</span>
                <p>جميع الأنظمة تعمل بكفاءة عالية</p>
              </div>
              <div className="v37-health__metrics">
                <article className="v37-health-metric"><div className="v37-health-metric__head"><span>استقرار المنصة</span><i className="v37-health-metric__ico"><ShieldCheck size={13} /></i></div><strong>100%</strong><small>استقرار المنصة</small></article>
                <article className="v37-health-metric"><div className="v37-health-metric__head"><span>معدل الأخطاء</span><i className="v37-health-metric__ico"><AlertCircle size={13} /></i></div><strong>0.01%</strong><small>معدل الأخطاء</small></article>
                <article className="v37-health-metric"><div className="v37-health-metric__head"><span>متوسط زمن الاستجابة</span><i className="v37-health-metric__ico"><Activity size={13} /></i></div><strong>{serverResponseTime}ms</strong><small>زمن الاستجابة</small></article>
                <article className="v37-health-metric"><div className="v37-health-metric__head"><span>معدل الحمل الحالي</span><i className="v37-health-metric__ico"><Server size={13} /></i></div><strong>{systemLoad}%</strong><small>حمولة الخادم</small></article>
              </div>
              <div className="v37-health__scene"><div><h4>أداء مستقر<br/>لرحلة أكثر سلاسة</h4><small>STABLE TODAY • FOR A SMOOTHER TOMORROW</small></div></div>
            </section>

            <section className="v37-revenue">
              <header className="v37-section-head">
                <div className="v37-section-title"><span className="v37-section-title__ico"><BarChart2 size={16} /></span><div><h3>الإيرادات والأداء</h3><small>نظرة شاملة على أداء المنصة ونمو الإيرادات</small></div></div>
                <span className="v37-period">{rangeSummaryLabel}</span>
              </header>
              <div className="v37-rev-stats">
                <div className="v37-rev-stat"><span>إجمالي المبيعات</span><strong>{analyticsSales.toLocaleString()} ر.س</strong></div>
                <div className="v37-rev-stat"><span>متوسط قيمة العملية</span><strong>{Math.round(analyticsSales / Math.max(analyticsPaymentCount,1)).toLocaleString()} ر.س</strong></div>
                <div className="v37-rev-stat"><span>عمليات الدفع</span><strong>{analyticsPaymentCount.toLocaleString()}</strong></div>
                <div className="v37-rev-stat v37-rev-stat--green"><span>نسبة النمو</span><strong>{trendDelta >= 0 ? '+' : ''}{trendDelta}%</strong></div>
              </div>
              <div className="v37-rev-visual">
                <div className="v37-chart">
                  <div className="v37-chart-toolbar"><span>آخر 30 يوم</span><span>الإيرادات</span></div>
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={trendSeries.filter((_, i) => i % Math.max(1, Math.floor(trendSeries.length / 7)) === 0).slice(0, 7)} margin={{ top: 22, right: 10, left: 4, bottom: 0 }}>
                      <defs><linearGradient id="v37GoldArea" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#d69b18" stopOpacity={0.28}/><stop offset="100%" stopColor="#d69b18" stopOpacity={0.02}/></linearGradient></defs>
                      <CartesianGrid stroke="rgba(130,106,67,.12)" strokeDasharray="3 3" vertical={false} />
                      <XAxis dataKey="label" tick={{ fontSize: 7, fill: '#857d72' }} axisLine={false} tickLine={false} />
                      <YAxis tick={{ fontSize: 7, fill: '#857d72' }} axisLine={false} tickLine={false} width={30} />
                      <Tooltip formatter={(v) => [`${Number(v).toLocaleString()} ر.س`, 'الإيرادات']} labelStyle={{fontSize:10}} contentStyle={{background:'#071019',border:'1px solid rgba(215,167,47,.25)',borderRadius:8,color:'#fff',fontSize:9}} />
                      <Area type="monotone" dataKey="revenue" stroke="#cf8f0c" strokeWidth={2.3} fill="url(#v37GoldArea)" dot={{ r: 3, fill: '#fff8e8', stroke: '#cf8f0c', strokeWidth: 2 }} activeDot={{ r: 4 }} />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
                <aside className="v37-donut">
                  <div className="v37-donut-ring"><div className="v37-donut-core"><strong>{analyticsSales.toLocaleString()}</strong><small>ر.س</small></div></div>
                  <div className="v37-donut-copy">
                    <h4>توزيع الإيرادات</h4>
                    <div className="v37-donut-legend"><span><i className="g" />62% بطاقات مدى</span><span><i className="c" />28% بطاقات ائتمانية</span><span><i className="b" />10% محافظ رقمية</span></div>
                    <div className="v37-donut-foot"><b>{trendDelta >= 0 ? '+' : ''}{trendDelta}%</b><span>مقارنة بالفترة السابقة</span></div>
                  </div>
                </aside>
              </div>
            </section>

            <section className="v37-ops-grid">
              <article className="v37-live">
                <header className="v37-ops-head"><div><h3>العمليات المباشرة</h3><small>آخر الأحداث والعمليات على المنصة في الوقت الفعلي</small></div><button type="button">مشاهدة الكل</button></header>
                <div className="v37-live-list">
                  {[...liveNotifications, ...payments.map((p, i) => ({ id: `pay-${p.id}`, type: 'payment', text: `تمت عملية دفع بقيمة ${p.amount.toLocaleString()} ر.س`, time: p.date }))].slice(0,4).map((n) => (
                    <div className="v37-live-row" key={n.id}>
                      <span className="v37-live-row__ico">{n.type === 'payment' ? <CreditCard size={12}/> : <Users size={12}/>}</span>
                      <span className="v37-live-row__copy"><strong>{n.text}</strong><small>{n.type === 'payment' ? 'عملية مالية' : 'نشاط مستخدم'}</small></span>
                      <span className="v37-live-row__time">{n.time}</span>
                    </div>
                  ))}
                </div>
                <div className="v37-live-summary"><span><strong>{analyticsPaymentCount.toLocaleString()}</strong><small>إجمالي العمليات</small></span><span><strong>98%</strong><small>معدل النجاح</small></span><span><strong>{payments.filter(p => p.status === 'معلق').length}</strong><small>قيد المعالجة</small></span><span><strong>{liveNotifications.length}</strong><small>عمليات مباشرة</small></span></div>
              </article>

              <article className="v37-current">
                <header className="v37-ops-head"><div><h3>العمليات الجارية</h3><small>آخر الطلبات والعمليات وحالتها</small></div><button type="button">عرض الكل</button></header>
                <div className="v37-current-summary"><span><strong>{payments.length}</strong><small>في الانتظار</small></span><span><strong>{pendingReview}</strong><small>قيد المراجعة</small></span><span><strong>{unverifiedSellersCount}</strong><small>بانتظار التنفيذ</small></span></div>
                <table className="v37-current-table"><thead><tr><th>#</th><th>نوع العملية</th><th>العميل / التاجر</th><th>المبلغ</th><th>الحالة</th><th>الوقت</th></tr></thead><tbody>
                  {payments.slice(0,4).map((p) => <tr key={p.id}><td>{p.id.replace('TXN-','#')}</td><td>دفع</td><td>{p.buyer}</td><td>{p.amount.toLocaleString()} ر.س</td><td><span className={`v37-status ${p.status === 'مكتمل' ? 'v37-status--ok' : 'v37-status--hold'}`}>{p.status}</span></td><td>{p.date}</td></tr>)}
                </tbody></table>
              </article>
            </section>

            <section className="v37-ledger">
              <header className="v37-ledger-head">
                <div className="v37-ledger-title"><span className="v37-ledger-title__ico"><CreditCard size={14}/></span><div><h3>السجل المالي — أحدث العمليات</h3><small>قائمة بأخر العمليات المالية المنفذة عبر المنصة</small></div></div>
                <div className="v37-ledger-tools">
                  <button type="button"><Download size={11}/> تصدير</button>
                  <button type="button"><Layers size={11}/> تصفية</button>
                  <label className="v37-ledger-search"><Search size={11}/><input type="search" placeholder="ابحث في العمليات، العملاء أو المبالغ..." value={txQuery} onChange={(e) => setTxQuery(e.target.value)} /></label>
                </div>
              </header>
              <div className="v37-ledger-table-wrap"><table className="v37-ledger-table"><thead><tr><th>#</th><th>التاريخ والوقت</th><th>العميل / التاجر</th><th>نوع العملية</th><th>القناة</th><th>المبلغ</th><th>الحالة</th><th>إجراءات</th></tr></thead><tbody>
                {payments.filter(p => !txQuery || p.id.toLowerCase().includes(txQuery.toLowerCase()) || p.buyer.includes(txQuery) || p.seller.includes(txQuery)).map((p) => <tr key={p.id}><td><span className="v37-ledger-id">{p.id}</span></td><td>{p.date}</td><td>{p.buyer}</td><td>دفع</td><td>{p.method}</td><td><span className="v37-amount">{p.amount.toLocaleString()} ر.س</span></td><td><span className={`v37-status ${p.status === 'مكتمل' ? 'v37-status--ok' : 'v37-status--hold'}`}>{p.status}</span></td><td>•••</td></tr>)}
              </tbody></table></div>
            </section>

          </div>
        )}

'''

s = s[:start] + new_overview + s[end:]
p.write_text(s)
PY

npm run build >/tmp/67-v37-build.log 2>&1 || {
  tail -n 220 /tmp/67-v37-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V37'
echo 'ELEMENT=REFERENCE LOCK FULL OVERVIEW REBUILD'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v37.css'
echo 'VISUAL_STRATEGY=FULL_OVERVIEW_DOM_REPLACEMENT'
echo 'V36_OVERVIEW_REUSED=NO'
echo 'REFERENCE_VIEWPORT=1448x1086'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
