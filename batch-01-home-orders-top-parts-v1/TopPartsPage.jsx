import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  CarFront,
  Heart,
  Package,
  Search,
  SlidersHorizontal,
  TrendingUp,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './TopPartsPage.css';

const TABS = [
  { id: 'daily', label: 'اليومي' },
  { id: 'weekly', label: 'الأسبوعي' },
  { id: 'monthly', label: 'الشهري' },
];

const TOP_PARTS = [
  { id: 1, name: 'كمبروسر مكيف كامري', searches: '1,240', trend: '+15%' },
  { id: 2, name: 'فحمات فرامل لاند كروزر', searches: '980', trend: '+8%' },
  { id: 3, name: 'مساعدات لكزس ES', searches: '850', trend: '+12%' },
  { id: 4, name: 'قير اوتوماتيك فورد تورس', searches: '720', trend: '+5%' },
  { id: 5, name: 'شمعات أمامية رنج روفر', searches: '690', trend: '+20%' },
  { id: 6, name: 'بواجي هيونداي سوناتا', searches: '610', trend: '+3%' },
  { id: 7, name: 'فلتر هواء نيسان باترول', searches: '540', trend: '-2%' },
  { id: 8, name: 'صدام أمامي تويوتا هايلوكس', searches: '490', trend: '+10%' },
  { id: 9, name: 'رديتر مازدا 6', searches: '420', trend: '+7%' },
  { id: 10, name: 'دينمو تعبئة كيا سبورتاج', searches: '380', trend: '+1%' },
];

const TopPartsPage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('daily');
  const [query, setQuery] = useState('');
  const [risingOnly, setRisingOnly] = useState(false);

  const filteredParts = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    return TOP_PARTS.filter((part) => {
      const matchesText = !normalized || part.name.toLowerCase().includes(normalized);
      const matchesTrend = !risingOnly || part.trend.startsWith('+');
      return matchesText && matchesTrend;
    });
  }, [query, risingOnly]);

  return (
    <div className="b01p-page" dir="rtl">
      <section className="b01p-hero">
        <HomeStoreHeader />
        <div className="b01p-hero-overlay" />
        <div className="b01p-hero-shell">
          <div className="b01p-hero-copy">
            <span className="b01p-kicker">كتالوج 67</span>
            <h1>قطعتك أقرب<br />مما تتخيل<span>.</span></h1>
            <p>تصفح قطع الغيار حسب بيانات الأكثر بحثاً في المنصة، وقارن الخيارات قبل الشراء.</p>
          </div>

          <div className="b01p-hero-search">
            <div className="b01p-search-icon"><Search size={21} /></div>
            <label>
              <span>ابحث داخل القطع</span>
              <input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="مثال: كمبروسر، فحمات، قير..."
              />
            </label>
            <button type="button" onClick={() => navigate('/search')}>بحث</button>
          </div>
        </div>
      </section>

      <main className="b01p-main">
        <div className="b01p-shell">
          <div className="b01p-title-row">
            <div>
              <span className="b01p-kicker">اكتشف الكتالوج</span>
              <h2>قطع الغيار</h2>
              <p>أكثر القطع بحثاً وطلباً من بيانات المنصة الحالية.</p>
            </div>
            <span className="b01p-count">{filteredParts.length} منتجات</span>
          </div>

          <div className="b01p-period-tabs" role="tablist" aria-label="فترة الأكثر طلباً">
            {TABS.map((tab) => (
              <button
                type="button"
                role="tab"
                aria-selected={activeTab === tab.id}
                className={activeTab === tab.id ? 'is-active' : ''}
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
              >
                {tab.label}
              </button>
            ))}
          </div>

          <div className="b01p-catalog-layout">
            <aside className="b01p-filter-card">
              <div className="b01p-filter-title">
                <SlidersHorizontal size={18} />
                <div>
                  <small>تصفية النتائج</small>
                  <strong>اختر طريقة العرض</strong>
                </div>
              </div>

              <div className="b01p-filter-group">
                <span>الفترة</span>
                <div className="b01p-filter-periods">
                  {TABS.map((tab) => (
                    <button
                      type="button"
                      key={tab.id}
                      className={activeTab === tab.id ? 'is-active' : ''}
                      onClick={() => setActiveTab(tab.id)}
                    >
                      {tab.label}
                    </button>
                  ))}
                </div>
              </div>

              <label className="b01p-check-row">
                <input
                  type="checkbox"
                  checked={risingOnly}
                  onChange={(event) => setRisingOnly(event.target.checked)}
                />
                <span>الطلبات ذات الاتجاه الصاعد فقط</span>
              </label>

              <div className="b01p-filter-group">
                <span>بحث سريع</span>
                <div className="b01p-side-search">
                  <Search size={15} />
                  <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="اسم القطعة" />
                </div>
              </div>

              <button
                type="button"
                className="b01p-reset"
                onClick={() => { setQuery(''); setRisingOnly(false); setActiveTab('daily'); }}
              >
                إعادة ضبط الفلاتر
              </button>
            </aside>

            <section className="b01p-results">
              <div className="b01p-results-toolbar">
                <span>{filteredParts.length} نتيجة متاحة الآن</span>
                <b>ترتيب حسب الأكثر بحثاً</b>
              </div>

              {filteredParts.length === 0 ? (
                <div className="b01p-empty">
                  <Package size={42} strokeWidth={1.35} />
                  <h3>لا توجد نتائج مطابقة</h3>
                  <p>جرّب اسم قطعة مختلف أو أعد ضبط الفلاتر.</p>
                </div>
              ) : (
                <div className="b01p-grid">
                  {filteredParts.map((part, index) => (
                    <article className="b01p-card" key={part.id} onClick={() => navigate('/search')}>
                      <div className="b01p-card-visual">
                        <span className="b01p-rank">#{part.id}</span>
                        <button
                          type="button"
                          className="b01p-heart"
                          aria-label="إضافة للمفضلة"
                          onClick={(event) => event.stopPropagation()}
                        >
                          <Heart size={17} />
                        </button>
                        <span className="b01p-card-watermark">67</span>
                        <CarFront size={72} strokeWidth={1.05} />
                      </div>

                      <div className="b01p-card-body">
                        <div className="b01p-trend-line">
                          <span>الأكثر طلباً</span>
                          <b className={part.trend.startsWith('+') ? 'is-up' : 'is-down'}>{part.trend}</b>
                        </div>
                        <h3>{part.name}</h3>
                        <p>بيانات الطلب والبحث الحالية في منصة 67.</p>
                        <div className="b01p-card-footer">
                          <div>
                            <small>عمليات البحث</small>
                            <strong>{part.searches}</strong>
                          </div>
                          <button type="button" aria-label={`استكشف ${part.name}`}>
                            <ArrowLeft size={16} />
                          </button>
                        </div>
                      </div>
                    </article>
                  ))}
                </div>
              )}
            </section>
          </div>

          <section className="b01p-cta">
            <div className="b01p-cta-icon"><CarFront size={28} /></div>
            <div>
              <span>مو متأكد من القطعة المناسبة؟</span>
              <h2>ابدأ بسيارتك، وإحنا نضيّق لك الاختيارات.</h2>
              <p>اختيار الماركة والموديل يساعدك للوصول للنتائج المناسبة بشكل أسرع.</p>
            </div>
            <button type="button" onClick={() => navigate('/brands')}>ابدأ البحث المتقدم <ArrowLeft size={16} /></button>
          </section>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default TopPartsPage;
