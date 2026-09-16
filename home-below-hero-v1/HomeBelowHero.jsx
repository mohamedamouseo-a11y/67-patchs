import { useNavigate } from 'react-router-dom';
import {
  Gavel,
  CarFront,
  Wrench,
  Truck,
  Search,
  ChevronLeft,
  Car,
  TrendingUp,
  Clock,
  Zap,
} from 'lucide-react';
import './HomeBelowHero.css';

const serviceCards = [
  { id: 'auctions', title: 'مزادات', description: 'شارك في مزادات قطع الغيار والسيارات بسهولة وأمان.', cta: 'استكشف المزادات', path: '/auctions', icon: Gavel },
  { id: 'scrapyards', title: 'تشاليح', description: 'اعثر على قطع أصلية ومستعملة من تشاليح موثوقة حول المملكة.', cta: 'ابحث في التشاليح', path: '/scrapyards', icon: CarFront, featured: true },
  { id: 'workshops', title: 'ورش وإصلاح', description: 'اختر ورشة مناسبة لخدمة سيارتك ومتابعة احتياجك بسرعة.', cta: 'اكتشف الورش', path: '/workshops', icon: Wrench },
  { id: 'road', title: 'خدمات الطريق', description: 'خدمات مساندة على الطريق لتبقى سيارتك جاهزة أينما كنت.', cta: 'استكشف الخدمات', path: '/services', icon: Truck },
];

const partCards = [
  { id: 'compressor', title: 'كمبروسر مكيف', meta: 'متوفر الآن', art: 'compressor' },
  { id: 'gearbox', title: 'قير أوتوماتيك', meta: 'الأكثر طلباً', art: 'gearbox', badge: 'الأكثر طلباً' },
  { id: 'fender', title: 'رفرف أمامي يمين', meta: 'قطع هيكل', art: 'fender' },
  { id: 'brakes', title: 'فحمات وفرامل أمامية', meta: 'نظام الفرامل', art: 'brakes' },
];

const brands = [
  { id: 'toyota', ar: 'تويوتا', en: 'TOYOTA', mark: 'T', featured: true },
  { id: 'hyundai', ar: 'هيونداي', en: 'HYUNDAI', mark: 'H' },
  { id: 'nissan', ar: 'نيسان', en: 'NISSAN', mark: 'N' },
  { id: 'chevrolet', ar: 'شفروليه', en: 'CHEVROLET', mark: '+' },
  { id: 'kia', ar: 'كيا', en: 'KIA', mark: 'KIA' },
  { id: 'ford', ar: 'فورد', en: 'FORD', mark: 'F' },
  { id: 'bmw', ar: 'بي إم دبليو', en: 'BMW', mark: 'BMW' },
  { id: 'mercedes', ar: 'مرسيدس', en: 'MERCEDES', mark: 'M' },
];

const HomeBelowHero = () => {
  const navigate = useNavigate();
  return (
    <div className="hbr-root" dir="rtl">
      <section className="hbr-services-section" aria-labelledby="hbr-services-title">
        <div className="hbr-container">
          <header className="hbr-section-heading hbr-section-heading--center">
            <span className="hbr-kicker">كل ما تحتاجه</span>
            <h2 id="hbr-services-title">كل ما تحتاجه لسيارتك <strong>في مكان واحد</strong></h2>
            <p>من القطع والخدمات وحتى الورش والتشاليح، جمعنا لك أهم احتياجات سيارتك في تجربة واحدة.</p>
          </header>

          <div className="hbr-services-grid">
            {serviceCards.map((item) => {
              const Icon = item.icon;
              return (
                <button key={item.id} type="button" className={`hbr-service-card${item.featured ? ' is-featured' : ''}`} onClick={() => navigate(item.path)}>
                  <span className="hbr-service-icon" aria-hidden="true"><Icon size={24} /></span>
                  <span className="hbr-service-title">{item.title}</span>
                  <span className="hbr-service-description">{item.description}</span>
                  <span className="hbr-service-cta">{item.cta}<ChevronLeft size={15} /></span>
                </button>
              );
            })}
          </div>

          <div className="hbr-help-strip">
            <span className="hbr-help-check" aria-hidden="true">✓</span>
            <div className="hbr-help-copy">
              <strong>مو لاقي القطعة اللي تحتاجها؟</strong>
              <span>أرسل طلبك وفريقنا يساعدك في الوصول للخيار المناسب.</span>
            </div>
            <button type="button" className="hbr-help-button" onClick={() => navigate('/support')}><Search size={16} /> ابحث معنا</button>
          </div>
        </div>
      </section>

      <section className="hbr-parts-section" aria-labelledby="hbr-parts-title">
        <div className="hbr-container">
          <div className="hbr-parts-heading-row">
            <div>
              <span className="hbr-kicker">الأكثر طلباً</span>
              <h2 id="hbr-parts-title">اكتشف القطع <strong>الأكثر طلباً</strong></h2>
              <div className="hbr-tabs" aria-hidden="true"><span className="is-active">الأكثر طلباً</span><span>الأحدث</span><span>العروض</span><span>الأصلي</span></div>
            </div>
            <button type="button" className="hbr-text-link" onClick={() => navigate('/top-parts')}>عرض المزيد <ChevronLeft size={16} /></button>
          </div>

          <div className="hbr-parts-grid">
            {partCards.map((part) => (
              <button key={part.id} type="button" className="hbr-part-card" onClick={() => navigate('/top-parts')}>
                {part.badge && <span className="hbr-part-badge">{part.badge}</span>}
                <div className={`hbr-part-art hbr-part-art--${part.art}`} aria-hidden="true">
                  <span className="hbr-part-shape hbr-part-shape--one" />
                  <span className="hbr-part-shape hbr-part-shape--two" />
                  <span className="hbr-part-shape hbr-part-shape--three" />
                </div>
                <span className="hbr-part-meta">{part.meta}</span>
                <strong className="hbr-part-title">{part.title}</strong>
                <span className="hbr-part-subtitle">خيارات متعددة تناسب سيارتك</span>
              </button>
            ))}
          </div>
          <div className="hbr-slider-line" aria-hidden="true"><span /></div>
        </div>
      </section>

      <section className="hbr-brands-section" aria-labelledby="hbr-brands-title">
        <div className="hbr-container hbr-brands-layout">
          <div className="hbr-brand-copy">
            <span className="hbr-kicker">ابحث حسب الماركة</span>
            <h2 id="hbr-brands-title">اختر ماركة سيارتك <strong>وابدأ البحث بسهولة</strong></h2>
            <p>اختيار الماركة يساعدك في الوصول إلى القطع المتوافقة مع سيارتك بشكل أسرع وأدق.</p>
            <div className="hbr-brand-chips" aria-hidden="true"><span>الأكثر انتشاراً</span><span>قطع أصلية</span><span>خيارات متنوعة</span></div>
            <button type="button" className="hbr-gold-button" onClick={() => navigate('/brands')}>جميع الماركات <ChevronLeft size={16} /></button>
          </div>

          <div className="hbr-brand-panel">
            <div className="hbr-brand-grid">
              {brands.map((brand) => (
                <button key={brand.id} type="button" className={`hbr-brand-card${brand.featured ? ' is-featured' : ''}`} onClick={() => navigate('/brands')}>
                  <span className="hbr-brand-mark" aria-hidden="true">{brand.mark}</span>
                  <strong>{brand.ar}</strong>
                  <small>{brand.en}</small>
                </button>
              ))}
            </div>
            <div className="hbr-slider-line hbr-slider-line--brands" aria-hidden="true"><span /></div>
          </div>
        </div>
      </section>

      <section className="hbr-delivery-section" aria-labelledby="hbr-delivery-title">
        <div className="hbr-container">
          <div className="hbr-delivery-banner">
            <div className="hbr-delivery-copy">
              <span className="hbr-kicker hbr-kicker--dark">سرعة توصل لك</span>
              <h2 id="hbr-delivery-title">طلبك يوصل <strong>خلال 24 ساعة</strong></h2>
              <p>نسرّع رحلة طلبك من اختيار القطعة إلى وصولها، مع متابعة واضحة في كل خطوة.</p>
              <button type="button" className="hbr-gold-button" onClick={() => navigate('/top-parts')}>اطلب قطعك الآن <ChevronLeft size={16} /></button>
            </div>
            <div className="hbr-delivery-visual" aria-hidden="true">
              <div className="hbr-24-orbit"><span>24</span><small>ساعة</small></div>
              <Truck size={52} strokeWidth={1.25} />
            </div>
          </div>
        </div>
      </section>

      <section className="hbr-stats-section" aria-labelledby="hbr-stats-title">
        <div className="hbr-container hbr-stats-layout">
          <div className="hbr-stats-copy">
            <span className="hbr-kicker hbr-kicker--dark">أرقام تثبت التجربة</span>
            <h2 id="hbr-stats-title">أرقامنا <strong>تصنع الفرق.</strong></h2>
            <p>من تنوع الماركات إلى سرعة الخدمة، نطوّر تجربة البحث عن قطع الغيار لتكون أبسط وأسرع.</p>
          </div>
          <div className="hbr-stats-grid">
            <article className="hbr-stat-card hbr-stat-card--gold"><Car size={22} /><strong><b>43</b>+</strong><span>ماركات السيارات</span></article>
            <article className="hbr-stat-card"><TrendingUp size={22} /><strong><b>241</b>+</strong><span>خيارات وقطع متاحة</span></article>
            <article className="hbr-stat-card"><Clock size={22} /><strong><b>24/7</b></strong><span>خدمة ودعم العملاء</span></article>
            <article className="hbr-stat-card hbr-stat-card--wide"><Zap size={22} /><strong>فوري</strong><span>تجربة بحث وطلب أسرع</span></article>
          </div>
        </div>
      </section>
    </div>
  );
};

export default HomeBelowHero;
