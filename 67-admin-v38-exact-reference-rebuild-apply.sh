#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
TARGET=src/pages/AdminDashboard.v38.css
MASTER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v38-exact-reference-master.css
BACKUP=/tmp/67-v38-reference-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
grep -q "AdminDashboard.v37.css" "$JSX" || { echo 'FAILED_STEP=V37_RUNTIME_NOT_ACTIVE'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"

curl -fsSL "$MASTER_URL" -o "$TARGET"
grep -q 'SIX SEVEN ADMIN V38 — EXACT REFERENCE LOCK MASTER' "$TARGET" || { echo 'FAILED_STEP=MASTER_CSS_DOWNLOAD_FAILED'; exit 1; }

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# Runtime stylesheet -> V38 only.
s=s.replace("import './AdminDashboard.v37.css';","import './AdminDashboard.v38.css';",1)

# Ensure Search icon is imported.
if ' Eye, Search, RefreshCw' not in s:
    s=s.replace('Layers, Eye, RefreshCw, Activity,','Layers, Eye, Search, RefreshCw, Activity,',1)

# Lock main canvas directly in JSX to eliminate the 96px V37 gap.
s=s.replace("<div style={{ flex: 1, marginRight: '278px', padding: '20px 18px', minHeight: '100vh', overflowY: 'auto' }}>",
            "<div style={{ flex: 1, marginRight: '200px', padding: '0 8px 14px 14px', minHeight: '100vh', overflowY: 'visible' }}>",1)
s=s.replace("<div style={{ flex: 1, marginRight: '200px', padding: '0 8px 14px 14px', minHeight: '100vh', overflowY: 'auto' }}>",
            "<div style={{ flex: 1, marginRight: '200px', padding: '0 8px 14px 14px', minHeight: '100vh', overflowY: 'visible' }}>",1)

start_marker='        {/* Tab Content: OVERVIEW'
end_marker='        {/* Tab Content: USERS AND SELLERS LOGS */}'
start=s.find(start_marker)
end=s.find(end_marker)
if start < 0 or end < 0 or end <= start:
    raise SystemExit('OVERVIEW_BLOCK_ANCHORS_NOT_FOUND')

new_overview=r'''        {/* Tab Content: OVERVIEW — V38 exact user reference rebuild */}
        {activeTab === 'overview' && (
          <div className="v38-dashboard animate-fadeIn">

            <section className="v38-hero" style={{ '--v38-hero': `url(${heroHighResV295})` }}>
              <div className="v38-hero-tools">
                <span className="v38-admin-mini">
                  <span className="v38-admin-mini__avatar"><Users size={13} /></span>
                  <span><b>مرحبًا بك مجددًا</b><small>Super Admin</small></span>
                </span>
                <span className="v38-tool-dot"><Search size={12} /></span>
                <span className="v38-tool-dot"><Bell size={12} /></span>
                <span className="v38-tool-dot"><Settings size={12} /></span>
              </div>

              <div className="v38-hero-copy-left">
                <h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>
                <p>منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</p>
              </div>

              <div className="v38-hero-copy-right">
                <span>سرعة أكبر</span>
                <strong>فرص أوسع</strong>
                <small>DRIVE A BRIGHTER TOMORROW</small>
              </div>

              <div className="v38-datebar">
                <button type="button" className="v38-date-display" onClick={() => { setDateError(''); setDatePopoverOpen((open) => !open); }} aria-expanded={datePopoverOpen}>
                  <CalendarDays size={13} />
                  <span><small>الفترة المحددة</small><strong>{rangeLabel}</strong></span>
                  <ChevronDown size={12} />
                </button>
                <div className="v38-date-presets">
                  <button type="button" className={datePreset === 'today' ? 'active' : ''} onClick={() => applyDatePreset('today')}>اليوم</button>
                  <button type="button" className={datePreset === '7d' ? 'active' : ''} onClick={() => applyDatePreset('7d')}>الأسبوع</button>
                  <button type="button" className={datePreset === '30d' ? 'active' : ''} onClick={() => applyDatePreset('30d')}>آخر 30 يوم</button>
                  <button type="button" className={datePreset === 'custom' ? 'active' : ''} onClick={() => { setDateError(''); setDatePopoverOpen(true); }}>مخصص</button>
                </div>
                <div className="v38-date-actions">
                  <button type="button" title="تحديث" onClick={() => window.location.reload()}><RefreshCw size={12} /></button>
                  <button type="button" title="تصدير" onClick={() => window.print()}><Download size={12} /></button>
                </div>
              </div>
              <span className="v38-hero-redline" />
            </section>

            {datePopoverOpen && (
              <section className="v38-date-popover" role="dialog" aria-label="تخصيص الفترة الزمنية">
                <div className="v38-date-popover__head">
                  <div><strong>تخصيص الفترة الزمنية</strong><small>اختر نطاق التواريخ لعرض البيانات والتقارير في الفترة المحددة</small></div>
                  <span className="v38-date-popover__badge">{rangeLabel}</span>
                </div>
                <div className="v38-date-popover__fields">
                  <label className="v38-date-field"><span>من</span><input aria-label="تاريخ بداية الفترة" type="date" value={customFrom} max={customTo || toDateInputValue(new Date())} onChange={(e) => { setCustomFrom(e.target.value); setDateError(''); }} /></label>
                  <label className="v38-date-field"><span>إلى</span><input aria-label="تاريخ نهاية الفترة" type="date" value={customTo} min={customFrom} max={toDateInputValue(new Date())} onChange={(e) => { setCustomTo(e.target.value); setDateError(''); }} /></label>
                </div>
                {dateError && <div className="executive-date-error">{dateError}</div>}
                <div className="v38-date-popover__foot">
                  <span>سيتم تطبيق الفترة على جميع المؤشرات والرسوم البيانية.</span>
                  <div className="v38-date-popover__buttons">
                    <button type="button" className="v38-date-close" onClick={() => { setDateError(''); setDatePopoverOpen(false); }}>إلغاء</button>
                    <button type="button" className="v38-date-apply" onClick={applyCustomDateRange}>تطبيق الفترة</button>
                  </div>
                </div>
              </section>
            )}

            <section className="v38-kpis">
              <article className="v38-kpi v38-kpi--sales">
                <div className="v38-kpi__top"><span>إجمالي المبيعات</span><span className="v38-kpi__ico"><DollarSign size={16} /></span></div>
                <div className="v38-kpi__value">{analyticsSales.toLocaleString()} <small>ر.س</small></div>
                <div className="v38-kpi__foot"><TrendingUp size={11} /><b>+12%</b><span>تحديث فوري مباشر</span></div>
              </article>
              <article className="v38-kpi v38-kpi--pay">
                <div className="v38-kpi__top"><span>عمليات دفع ناجحة</span><span className="v38-kpi__ico"><CreditCard size={16} /></span></div>
                <div className="v38-kpi__value">{analyticsPaymentCount.toLocaleString()}</div>
                <div className="v38-kpi__foot"><TrendingUp size={11} /><b>+8%</b><span>عملية</span></div>
              </article>
              <article className="v38-kpi v38-kpi--seller">
                <div className="v38-kpi__top"><span>التجار النشطون</span><span className="v38-kpi__ico"><Store size={16} /></span></div>
                <div className="v38-kpi__value">{verifiedSellersCount}</div>
                <div className="v38-kpi__foot"><UserCheck size={11} /><b>+100%</b><span>متجر</span></div>
              </article>
              <article className="v38-kpi v38-kpi--user">
                <div className="v38-kpi__top"><span>العملاء المسجلون</span><span className="v38-kpi__ico"><Users size={16} /></span></div>
                <div className="v38-kpi__value">{customers.length.toLocaleString()}</div>
                <div className="v38-kpi__foot"><Activity size={11} /><b>+33%</b><span>نمو مستمر</span></div>
              </article>
            </section>

            <section className="v38-health">
              <div className="v38-health__status">
                <h3>حالة المنصة</h3>
                <span className="v38-health__stable"><i className="v38-dot" /> تعمل بشكل طبيعي</span>
                <p>جميع الأنظمة تعمل بكفاءة عالية</p>
              </div>
              <div className="v38-health__metrics">
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>استقرار المنصة</span><i className="v38-health-metric__ico"><ShieldCheck size={13} /></i></div><strong>100%</strong><small>استقرار المنصة</small></article>
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>معدل الأخطاء</span><i className="v38-health-metric__ico"><AlertCircle size={13} /></i></div><strong>0.01%</strong><small>معدل الأخطاء</small></article>
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>متوسط زمن الاستجابة</span><i className="v38-health-metric__ico"><Activity size={13} /></i></div><strong>{serverResponseTime}ms</strong><small>زمن الاستجابة</small></article>
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>معدل الحمل الحالي</span><i className="v38-health-metric__ico"><Server size={13} /></i></div><strong>{systemLoad}%</strong><small>حمولة الخادم</small></article>
              </div>
              <div className="v38-health__scene"><div><h4>أداء مستقر<br/>لرحلة أكثر سلاسة</h4><small>STABLE TODAY • FOR A SMOOTHER TOMORROW</small></div></div>
            </section>

            <section className="v38-revenue">
              <header className="v38-section-head">
                <div className="v38-section-title"><span className="v38-section-title__ico"><BarChart2 size={16} /></span><div><h3>الإيرادات والأداء</h3><small>نظرة شاملة على أداء المنصة ونمو الإيرادات</small></div></div>
                <span className="v38-period">{rangeSummaryLabel}</span>
              </header>
              <div className="v38-rev-stats">
                <div className="v38-rev-stat"><span>إجمالي المبيعات</span><strong>{analyticsSales.toLocaleString()} ر.س</strong></div>
                <div className="v38-rev-stat"><span>متوسط قيمة العملية</span><strong>{Math.round(analyticsSales / Math.max(analyticsPaymentCount,1)).toLocaleString()} ر.س</strong></div>
                <div className="v38-rev-stat"><span>عمليات الدفع</span><strong>{analyticsPaymentCount.toLocaleString()}</strong></div>
                <div className="v38-rev-stat v38-rev-stat--green"><span>نسبة النمو</span><strong>{trendDelta >= 0 ? '+' : ''}{trendDelta}%</strong></div>
              </div>
              <div className="v38-rev-visual">
                <div className="v38-chart">
                  <div className="v38-chart-toolbar"><span>آخر 30 يوم</span><span>الإيرادات</span></div>
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={trendSeries.filter((_, i) => i % Math.max(1, Math.floor(trendSeries.length / 7)) === 0).slice(0, 7)} margin={{ top: 22, right: 10, left: 4, bottom: 0 }}>
                      <defs><linearGradient id="v38GoldArea" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#d69b18" stopOpacity={0.28}/><stop offset="100%" stopColor="#d69b18" stopOpacity={0.02}/></linearGradient></defs>
                      <CartesianGrid stroke="rgba(130,106,67,.12)" strokeDasharray="3 3" vertical={false} />
                      <XAxis dataKey="label" tick={{ fontSize: 7, fill: '#857d72' }} axisLine={false} tickLine={false} />
                      <YAxis tick={{ fontSize: 7, fill: '#857d72' }} axisLine={false} tickLine={false} width={30} />
                      <Tooltip formatter={(v) => [`${Number(v).toLocaleString()} ر.س`, 'الإيرادات']} labelStyle={{fontSize:10}} contentStyle={{background:'#071019',border:'1px solid rgba(215,167,47,.25)',borderRadius:8,color:'#fff',fontSize:9}} />
                      <Area type="monotone" dataKey="revenue" stroke="#cf8f0c" strokeWidth={2.3} fill="url(#v38GoldArea)" dot={{ r: 3, fill: '#fff8e8', stroke: '#cf8f0c', strokeWidth: 2 }} activeDot={{ r: 4 }} />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
                <aside className="v38-donut">
                  <div className="v38-donut-ring" style={{ background: 'conic-gradient(#dfa72c 0 62%, #31c8c1 62% 90%, #2d87d8 90% 100%)' }}><div className="v38-donut-core"><strong>{analyticsSales.toLocaleString()}</strong><small>ر.س</small></div></div>
                  <div className="v38-donut-copy">
                    <h4>توزيع الإيرادات</h4>
                    <div className="v38-donut-legend"><span><i className="g" />62% بطاقات مدى</span><span><i className="c" />28% بطاقات ائتمانية</span><span><i className="b" />10% محافظ رقمية</span></div>
                    <div className="v38-donut-foot"><b>{trendDelta >= 0 ? '+' : ''}{trendDelta}%</b><span>مقارنة بالفترة السابقة</span></div>
                  </div>
                </aside>
              </div>
            </section>

            <section className="v38-ops-grid">
              <article className="v38-live">
                <header className="v38-ops-head"><div><h3>العمليات المباشرة</h3><small>آخر الأحداث والعمليات على المنصة في الوقت الفعلي</small></div><button type="button">مشاهدة الكل</button></header>
                <div className="v38-live-list">
                  {[...liveNotifications, ...payments.map((p, i) => ({ id: `p-${i}`, type: 'payment', text: `عملية دفع بقيمة ${p.amount.toLocaleString()} ر.س لصالح ${p.seller}`, time: p.date }))].slice(0,4).map((item, idx) => (
                    <div className="v38-live-row" key={`${item.id}-${idx}`}><span className="v38-live-row__ico">{item.type === 'payment' ? <CreditCard size={11}/> : <Users size={11}/>}</span><span className="v38-live-row__text">{item.text}</span><span className="v38-live-row__time">{item.time}</span></div>
                  ))}
                </div>
                <div className="v38-live-summary"><div><strong>{analyticsPaymentCount.toLocaleString()}</strong><span>إجمالي العمليات</span></div><div><strong>98%</strong><span>معدل النجاح</span></div><div><strong>{pendingReview}</strong><span>قيد المعالجة</span></div><div><strong>{payments.filter(p => p.status === 'معلق').length}</strong><span>عمليات معلقة</span></div></div>
              </article>

              <article className="v38-current">
                <header className="v38-ops-head"><div><h3>العمليات الجارية</h3><small>آخر الطلبات والعمليات التي تحتاج متابعة</small></div><button type="button">عرض الكل</button></header>
                <div className="v38-current-summary"><div><strong>{payments.length}</strong><span>قيد التنفيذ</span></div><div><strong>{pendingReview}</strong><span>قيد المراجعة</span></div><div><strong>{verifiedSellersCount}</strong><span>مكتملة</span></div></div>
                <table className="v38-current-table"><thead><tr><th>#</th><th>نوع العملية</th><th>العميل / التاجر</th><th>المبلغ</th><th>الحالة</th><th>الوقت</th></tr></thead><tbody>{payments.slice(0,4).map((p, idx)=><tr key={p.id}><td>{p.id.replace('TXN-','')}</td><td>{idx%2===0?'دفع':'سحب'}</td><td>{p.buyer}</td><td>{p.amount.toLocaleString()} ر.س</td><td><span className={`v38-mini-status ${p.status==='معلق'?'pending':''}`}>{p.status}</span></td><td>{p.date}</td></tr>)}</tbody></table>
              </article>
            </section>

            <section className="v38-ledger">
              <header className="v38-ledger-head">
                <div className="v38-ledger-title"><span className="v38-ledger-title__ico"><CreditCard size={15}/></span><div><h3>السجل المالي — أحدث العمليات</h3><small>قائمة بآخر العمليات المالية المنفذة عبر المنصة</small></div></div>
                <div className="v38-ledger-tools">
                  <input className="v38-ledger-search" type="search" placeholder="ابحث عن معاملة أو عميل أو بائع..." value={txQuery} onChange={(e)=>setTxQuery(e.target.value)} />
                  <button type="button" className="v38-ledger-filter"><Layers size={12}/> تصفية</button>
                  <button type="button" className="v38-ledger-export" onClick={()=>window.print()}><Download size={12}/> تصدير</button>
                </div>
              </header>
              <div className="v38-ledger-table-wrap"><table className="v38-ledger-table"><thead><tr><th>#</th><th>التاريخ والوقت</th><th>العميل / التاجر</th><th>نوع العملية</th><th>القناة</th><th>المبلغ</th><th>الحالة</th></tr></thead><tbody>{payments.filter(p => !txQuery || p.id.toLowerCase().includes(txQuery.toLowerCase()) || p.buyer.includes(txQuery) || p.seller.includes(txQuery)).map((p)=><tr key={p.id}><td><span className="v38-tx-id">{p.id}</span></td><td>{p.date}</td><td>{p.buyer}</td><td>دفع</td><td>{p.method}</td><td><span className="v38-amount">{p.amount.toLocaleString()} ر.س</span></td><td><span className={`v38-mini-status ${p.status==='معلق'?'pending':''}`}>{p.status}</span></td></tr>)}</tbody></table></div>
            </section>

          </div>
        )}

'''

s=s[:start]+new_overview+s[end:]
p.write_text(s)
PY

npm run build >/tmp/67-v38-build.log 2>&1 || {
  tail -n 200 /tmp/67-v38-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V38'
echo 'ELEMENT=EXACT USER REFERENCE REBUILD'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v38.css'
echo 'VISUAL_STRATEGY=FULL_OVERVIEW_DOM_REPLACEMENT_REFERENCE_LOCK'
echo 'V37_OVERVIEW_REUSED=NO'
echo 'MAIN_MARGIN_RIGHT_PX=200'
echo 'REFERENCE_VIEWPORT=1448x1086'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
