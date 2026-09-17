import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  CarFront,
  CheckCircle2,
  ChevronLeft,
  MapPin,
  PackageSearch,
  Search,
  ShieldCheck,
  Star,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './ScrapyardsPage.css';

const scrapyards = [
  { id: 1, name: 'تشليح الحاير المركزي', rating: 4.8, distance: '12 كم', cars: 'تويوتا، لكزس، هيونداي', verified: true },
  { id: 2, name: 'تشليح السلي للسيارات الأمريكية', rating: 4.5, distance: '18 كم', cars: 'فورد، شيفروليه، دودج', verified: false },
  { id: 3, name: 'تشليح القمة الألماني', rating: 4.9, distance: '22 كم', cars: 'مرسيدس، بي إم دبليو، أودي', verified: true },
];

const mockParts = [
  { id: 101, partName: 'مكينة كامري 2020', yardName: 'تشليح الحاير المركزي', price: '4500 ر.س', condition: 'مستخدم نظيف', warranty: 'شهر' },
  { id: 102, partName: 'قير فورد تورس', yardName: 'تشليح السلي', price: '3200 ر.س', condition: 'مجدد', warranty: '15 يوم' },
  { id: 103, partName: 'شمعة أمامية يمين لكزس ES', yardName: 'تشليح الحاير المركزي', price: '900 ر.س', condition: 'وكالة مستعمل', warranty: 'بدون ضمان' },
];

const ScrapyardsPage = () => {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState('yards');
  const [specialty, setSpecialty] = useState('all');

  const specialties = useMemo(() => {
    const values = scrapyards.flatMap((yard) => yard.cars.split('،').map((item) => item.trim()));
    return [...new Set(values)];
  }, []);

  const filteredYards = useMemo(() => {
    const query = search.trim();
    return scrapyards.filter((yard) => {
      const matchesQuery = !query || yard.name.includes(query) || yard.cars.includes(query);
      const matchesSpecialty = specialty === 'all' || yard.cars.includes(specialty);
      return matchesQuery && matchesSpecialty;
    });
  }, [search, specialty]);

  const filteredParts = useMemo(() => {
    const query = search.trim();
    return mockParts.filter((part) => (
      !query
      || part.partName.includes(query)
      || part.yardName.includes(query)
      || part.condition.includes(query)
    ));
  }, [search]);

  const verifiedCount = scrapyards.filter((yard) => yard.verified).length;

  const submitSearch = (event) => {
    event.preventDefault();
    document.getElementById('scrapyards-results')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  const showParts = () => {
    setActiveTab('parts');
    setSearch('');
    setSpecialty('all');
    requestAnimationFrame(() => {
      document.getElementById('scrapyards-results')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  };

  return (
    <div className="sy67-page" dir="rtl">
      <HomeStoreHeader />

      <main>
        <section className="sy67-hero">
          <div className="sy67-hero-grid" aria-hidden="true" />
          <div className="sy67-watermark" aria-hidden="true">67</div>

          <div className="sy67-shell sy67-hero-inner">
            <div className="sy67-hero-copy">
              <div className="sy67-breadcrumb">
                <button type="button" onClick={() => navigate('/store')}>الرئيسية</button>
                <span>/</span>
                <strong>التشاليح</strong>
              </div>

              <p className="sy67-eyebrow"><span /> شبكة 67 للتشاليح الموثقة</p>
              <h1>دور على القطعة<br /><em>وسط شبكة كاملة.</em></h1>
              <p className="sy67-lead">
                ابحث في بيانات التشاليح المسجلة بالمشروع، وحدد التشليح أو القطعة المناسبة من نفس البيانات المتاحة حالياً.
              </p>

              <div className="sy67-stats" aria-label="ملخص بيانات التشاليح الحالية">
                <div><strong>{scrapyards.length}</strong><span>تشاليح متاحة</span></div>
                <div><strong>{mockParts.length}</strong><span>قطع مسجلة</span></div>
                <div><strong>{verifiedCount}</strong><span>تشاليح موثقة</span></div>
              </div>
            </div>

            <form className="sy67-search-panel" onSubmit={submitSearch}>
              <div className="sy67-panel-head">
                <div className="sy67-radar" aria-hidden="true"><span /><i /></div>
                <div>
                  <small>FIND A PART</small>
                  <h2>إبحث في التشاليح</h2>
                </div>
              </div>

              <div className="sy67-mode-switch" role="tablist" aria-label="نوع البحث">
                <button
                  type="button"
                  className={activeTab === 'yards' ? 'is-active' : ''}
                  onClick={() => { setActiveTab('yards'); setSearch(''); }}
                >
                  تشاليح
                </button>
                <button
                  type="button"
                  className={activeTab === 'parts' ? 'is-active' : ''}
                  onClick={() => { setActiveTab('parts'); setSearch(''); }}
                >
                  قطع غيار
                </button>
              </div>

              <label className="sy67-field sy67-field-wide">
                <span>{activeTab === 'yards' ? 'اسم التشليح أو نوع السيارة' : 'اسم القطعة أو التشليح'}</span>
                <div className="sy67-input-wrap">
                  <Search size={18} />
                  <input
                    value={search}
                    onChange={(event) => setSearch(event.target.value)}
                    placeholder={activeTab === 'yards' ? 'مثال: تويوتا أو تشليح الحاير' : 'مثال: مكينة كامري'}
                  />
                </div>
              </label>

              {activeTab === 'yards' && (
                <label className="sy67-field">
                  <span>تخصص السيارات</span>
                  <select value={specialty} onChange={(event) => setSpecialty(event.target.value)}>
                    <option value="all">كل التخصصات</option>
                    {specialties.map((item) => <option key={item} value={item}>{item}</option>)}
                  </select>
                </label>
              )}

              <button className="sy67-search-button" type="submit">
                <Search size={18} />
                إبحث في الشبكة
              </button>

              <p className="sy67-panel-note"><span /> النتائج مبنية على بيانات التشاليح الموجودة حالياً داخل مشروع 67</p>
            </form>
          </div>
        </section>

        <section className="sy67-results" id="scrapyards-results">
          <div className="sy67-shell">
            <div className="sy67-section-head">
              <div>
                <p className="sy67-section-kicker">{activeTab === 'yards' ? 'تشاليح مقترحة' : 'قطع متاحة'}</p>
                <h2>{activeTab === 'yards' ? 'اختيارات من شبكة التشاليح.' : 'قطع الغيار المتوفرة بالتشاليح.'}</h2>
              </div>
              <span className="sy67-result-count">
                {activeTab === 'yards' ? filteredYards.length : filteredParts.length} نتائج متاحة
              </span>
            </div>

            {activeTab === 'yards' ? (
              <div className="sy67-yards-layout">
                <aside className="sy67-network-card" aria-label="تمثيل شبكي للتشاليح الحالية">
                  <div className="sy67-network-head">
                    <small>شبكة 67</small>
                    <strong>التشاليح</strong>
                  </div>
                  <div className="sy67-network-rings" aria-hidden="true">
                    {scrapyards.map((yard, index) => (
                      <span
                        key={yard.id}
                        className={`sy67-network-node sy67-node-${index + 1} ${yard.verified ? 'is-verified' : ''}`}
                      >
                        {index + 1}
                      </span>
                    ))}
                  </div>
                  <p><span /> {verifiedCount} تشاليح موثقة من أصل {scrapyards.length}</p>
                </aside>

                <div className="sy67-yard-grid">
                  {filteredYards.map((yard, index) => (
                    <article className="sy67-yard-card" key={yard.id}>
                      <div className="sy67-yard-visual">
                        <span className="sy67-card-index">0{index + 1}</span>
                        {yard.verified && <span className="sy67-verified"><ShieldCheck size={15} /> موثوق</span>}
                        <div className="sy67-car-mark" aria-hidden="true"><CarFront size={54} /></div>
                      </div>
                      <div className="sy67-yard-body">
                        <div className="sy67-yard-meta">
                          <span><Star size={15} /> {yard.rating}</span>
                          <span><MapPin size={15} /> {yard.distance}</span>
                        </div>
                        <h3>{yard.name}</h3>
                        <p>{yard.cars}</p>
                        <div className="sy67-specialties">
                          {yard.cars.split('،').map((car) => <span key={car}>{car.trim()}</span>)}
                        </div>
                      </div>
                      <button type="button" className="sy67-card-action" onClick={showParts}>
                        عرض القطع المتاحة <ArrowLeft size={17} />
                      </button>
                    </article>
                  ))}

                  {filteredYards.length === 0 && (
                    <div className="sy67-empty">لا توجد تشاليح مطابقة للبحث الحالي.</div>
                  )}
                </div>
              </div>
            ) : (
              <div className="sy67-parts-grid">
                {filteredParts.map((part) => (
                  <article className="sy67-part-card" key={part.id}>
                    <div className="sy67-part-icon"><PackageSearch size={28} /></div>
                    <p className="sy67-part-yard"><MapPin size={15} /> {part.yardName}</p>
                    <h3>{part.partName}</h3>
                    <div className="sy67-part-tags">
                      <span>{part.condition}</span>
                      <span>{part.warranty}</span>
                    </div>
                    <div className="sy67-part-footer">
                      <strong>{part.price}</strong>
                      <button type="button" onClick={() => navigate('/offers')}>تفاصيل أكثر <ChevronLeft size={17} /></button>
                    </div>
                  </article>
                ))}

                {filteredParts.length === 0 && (
                  <div className="sy67-empty">لا توجد قطع مطابقة للبحث الحالي.</div>
                )}
              </div>
            )}
          </div>
        </section>

        <section className="sy67-steps">
          <div className="sy67-shell">
            <p className="sy67-section-kicker">كيف تستخدم الصفحة؟</p>
            <h2>من البحث إلى القطعة في 3 خطوات.</h2>
            <div className="sy67-steps-grid">
              <article><span>01</span><Search size={22} /><h3>حدد احتياجك</h3><p>اكتب اسم التشليح أو نوع السيارة أو القطعة المطلوبة.</p></article>
              <article><span>02</span><CarFront size={22} /><h3>قارن النتائج</h3><p>راجع التقييم والمسافة والتخصص من البيانات الحالية.</p></article>
              <article><span>03</span><CheckCircle2 size={22} /><h3>استعرض القطع</h3><p>انتقل إلى قائمة القطع المتاحة بالتشاليح في المشروع.</p></article>
            </div>
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  );
};

export default ScrapyardsPage;
