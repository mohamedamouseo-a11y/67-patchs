import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  CalendarClock,
  CheckCircle2,
  MapPin,
  Search,
  Star,
  Wrench,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './WorkshopsPage.css';

const workshops = [
  { id: 1, name: 'مركز العناية الشاملة', rating: 4.7, reviews: 124, distance: '3 كم', specialized: 'ميكانيكا عامة', price: '$$' },
  { id: 2, name: 'ورشة الخبراء الألمان', rating: 4.9, reviews: 89, distance: '5 كم', specialized: 'سيارات ألمانية', price: '$$$' },
];

const WorkshopsPage = () => {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [activeSpecialty, setActiveSpecialty] = useState('all');

  const specialties = useMemo(
    () => [...new Set(workshops.map((shop) => shop.specialized))],
    []
  );

  const filteredWorkshops = useMemo(() => {
    const query = search.trim();
    return workshops.filter((shop) => {
      const matchesQuery = !query
        || shop.name.includes(query)
        || shop.specialized.includes(query)
        || shop.distance.includes(query);
      const matchesSpecialty = activeSpecialty === 'all' || shop.specialized === activeSpecialty;
      return matchesQuery && matchesSpecialty;
    });
  }, [search, activeSpecialty]);

  const totalReviews = workshops.reduce((sum, shop) => sum + shop.reviews, 0);
  const averageRating = (
    workshops.reduce((sum, shop) => sum + shop.rating, 0) / workshops.length
  ).toFixed(1);

  const scrollToResults = () => {
    document.getElementById('workshops-results')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  return (
    <div className="ws67-page" dir="rtl">
      <HomeStoreHeader />

      <main>
        <section className="ws67-hero">
          <div className="ws67-shell ws67-hero-inner">
            <div className="ws67-hero-copy">
              <div className="ws67-breadcrumb">
                <button type="button" onClick={() => navigate('/store')}>الرئيسية</button>
                <span>/</span>
                <strong>ورش وإصلاح</strong>
              </div>

              <p className="ws67-eyebrow"><span /> GARAGE NETWORK 67</p>
              <h1>صيانة أو إصلاح؟<br /><em>احجزها من مكانك.</em></h1>
              <p className="ws67-lead">
                ابحث في الورش المسجلة حالياً داخل مشروع 67، وقارن التقييم والمسافة والتخصص قبل اختيار الورشة المناسبة.
              </p>

              <div className="ws67-trust-row">
                <span><CheckCircle2 size={17} /> بيانات الورش الحالية</span>
                <span><CheckCircle2 size={17} /> تقييمات أصلية بالمشروع</span>
                <span><CheckCircle2 size={17} /> بحث حسب التخصص</span>
              </div>
            </div>

            <aside className="ws67-service-panel">
              <div className="ws67-panel-top">
                <div>
                  <small>إبدأ من احتياجك</small>
                  <h2>سيارتك محتاجة إيه؟</h2>
                </div>
                <span className="ws67-live"><i /> {workshops.length} ورش متاحة</span>
              </div>

              <div className="ws67-specialty-choices">
                {specialties.map((specialty, index) => (
                  <button
                    key={specialty}
                    type="button"
                    className={activeSpecialty === specialty ? 'is-active' : ''}
                    onClick={() => setActiveSpecialty((current) => current === specialty ? 'all' : specialty)}
                  >
                    <Wrench size={21} />
                    <span>{specialty}</span>
                    <small>0{index + 1}</small>
                  </button>
                ))}
              </div>

              <label className="ws67-search-field">
                <Search size={18} />
                <input
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder="ابحث باسم الورشة أو التخصص..."
                />
              </label>

              <button className="ws67-primary-action" type="button" onClick={scrollToResults}>
                اعرض الورش المناسبة <ArrowLeft size={18} />
              </button>
            </aside>
          </div>
        </section>

        <section className="ws67-stats-strip" aria-label="ملخص بيانات الورش الحالية">
          <div className="ws67-shell ws67-stats-grid">
            <div><strong>{workshops.length}</strong><span>ورش مسجلة</span></div>
            <div><strong>{averageRating}/5</strong><span>متوسط التقييم</span></div>
            <div><strong>{totalReviews}</strong><span>إجمالي التقييمات</span></div>
            <div><strong>{specialties.length}</strong><span>تخصصات متاحة</span></div>
          </div>
        </section>

        <section className="ws67-results" id="workshops-results">
          <div className="ws67-shell">
            <div className="ws67-section-head">
              <div>
                <p className="ws67-section-kicker">ورش متاحة حالياً</p>
                <h2>اختار الورشة على راحتك.</h2>
              </div>
              <span>{filteredWorkshops.length} نتائج متاحة</span>
            </div>

            <div className="ws67-filter-row" aria-label="فلترة الورش">
              <button
                type="button"
                className={activeSpecialty === 'all' ? 'is-active' : ''}
                onClick={() => setActiveSpecialty('all')}
              >
                الكل
              </button>
              {specialties.map((specialty) => (
                <button
                  type="button"
                  key={specialty}
                  className={activeSpecialty === specialty ? 'is-active' : ''}
                  onClick={() => setActiveSpecialty(specialty)}
                >
                  {specialty}
                </button>
              ))}
            </div>

            <div className="ws67-workshops-list">
              {filteredWorkshops.map((shop, index) => (
                <article className="ws67-workshop-card" key={shop.id}>
                  <div className="ws67-card-number">0{index + 1}</div>

                  <div className="ws67-card-main">
                    <p className="ws67-card-place"><MapPin size={15} /> على بُعد {shop.distance}</p>
                    <h3>{shop.name}</h3>
                    <p className="ws67-card-specialty"><Wrench size={16} /> {shop.specialized}</p>
                    <div className="ws67-card-meta">
                      <span><Star size={15} /> {shop.rating}</span>
                      <span>{shop.reviews} تقييم</span>
                      <span className="ws67-price-level">{shop.price}</span>
                    </div>
                  </div>

                  <div className="ws67-card-actions">
                    <button type="button" className="ws67-book-btn">
                      <CalendarClock size={17} /> حجز موعد
                    </button>
                    <button type="button" className="ws67-quote-btn">طلب عرض سعر</button>
                  </div>
                </article>
              ))}

              {filteredWorkshops.length === 0 && (
                <div className="ws67-empty">لا توجد ورش مطابقة للبحث الحالي.</div>
              )}
            </div>
          </div>
        </section>

        <section className="ws67-maintenance-cta">
          <div className="ws67-shell ws67-maintenance-grid">
            <div className="ws67-maintenance-copy">
              <p className="ws67-section-kicker">CARE 67</p>
              <h2>اختار ورشتك بناءً على البيانات الموجودة.</h2>
              <p>
                كل النتائج المعروضة هنا مبنية على نفس بيانات الورش الحالية داخل المشروع، بدون إضافة مواعيد أو أسعار خدمات أو معلومات تشغيل غير موجودة بالمصدر الأصلي.
              </p>
            </div>

            <div className="ws67-maintenance-card">
              <div className="ws67-maintenance-icon"><Wrench size={28} /></div>
              <strong>{workshops.length} ورش</strong>
              <span>{specialties.length} تخصصات</span>
              <small>{totalReviews} تقييم مسجل</small>
            </div>
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  );
};

export default WorkshopsPage;
