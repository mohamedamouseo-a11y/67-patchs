import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  Car,
  CarFront,
  Clock3,
  Gavel,
  ShieldCheck,
  TrendingUp,
  Truck,
  Wrench,
  Zap,
} from 'lucide-react';
import { brands } from '../data/brands';
import './HomeBelowHero.css';

const services = [
  {
    id: 'auctions',
    title: 'مزادات',
    description: 'اكتشف القطع والسيارات المعروضة في المزادات واختر الأنسب لك بسهولة.',
    path: '/auctions',
    Icon: Gavel,
  },
  {
    id: 'scrapyards',
    title: 'تشاليح',
    description: 'تصفح قطع الغيار من التشاليح المعتمدة ووصل للقطعة التي تحتاجها بسرعة.',
    path: '/scrapyards',
    Icon: CarFront,
    featured: true,
  },
  {
    id: 'workshops',
    title: 'ورش وإصلاح',
    description: 'اعثر على الورش والخدمات المناسبة لصيانة وإصلاح سيارتك.',
    path: '/workshops',
    Icon: Wrench,
  },
  {
    id: 'services',
    title: 'خدمات الطريق',
    description: 'خدمات مساندة على الطريق تساعدك وقت الحاجة أينما كنت.',
    path: '/services',
    Icon: Truck,
  },
];

const popularParts = [
  { id: 1, name: 'كمبروسر مكيف كامري', searches: '1,240', trend: '+15%' },
  { id: 2, name: 'فحمات فرامل لاند كروزر', searches: '980', trend: '+8%' },
  { id: 3, name: 'مساعدات لكزس ES', searches: '850', trend: '+12%' },
  { id: 4, name: 'قير اوتوماتيك فورد تورس', searches: '720', trend: '+5%' },
];

const stats = [
  { value: '43+', label: 'ماركات السيارات', path: '/brands', Icon: Car },
  { value: '+250', label: 'إضافات مستقبلية', path: '/future-features', Icon: TrendingUp },
  { value: '24/7', label: 'خدمة العملاء', path: '/support', Icon: Clock3 },
  { value: 'فوري', label: 'استلام بالفرع', path: '/fawry', Icon: Zap },
];

const HomeBelowHero = () => {
  const navigate = useNavigate();
  const visibleBrands = brands.slice(0, 8);

  return (
    <main className="b01h-root" dir="rtl">
      <section className="b01h-section b01h-services-section">
        <div className="b01h-shell">
          <div className="b01h-heading b01h-heading-center">
            <span className="b01h-kicker">منصة 67</span>
            <h2>كل ما تحتاجه لسيارتك <em>في مكان واحد</em></h2>
            <p>خدمات متكاملة تساعدك للوصول لما تحتاجه بسيارتك بسهولة.</p>
          </div>

          <div className="b01h-service-grid">
            {services.map(({ id, title, description, path, Icon, featured }) => (
              <button
                type="button"
                key={id}
                className={`b01h-service-card ${featured ? 'is-featured' : ''}`}
                onClick={() => navigate(path)}
              >
                <span className="b01h-service-icon"><Icon size={22} /></span>
                <strong>{title}</strong>
                <span className="b01h-service-copy">{description}</span>
                <span className="b01h-card-link">استكشف الخدمة <ArrowLeft size={15} /></span>
              </button>
            ))}
          </div>

          <div className="b01h-help-strip">
            <div className="b01h-help-icon"><ShieldCheck size={20} /></div>
            <div>
              <strong>مو عارف تبدأ من وين؟</strong>
              <span>ابدأ بقطع الغيار الأكثر طلباً واكتشف الخيارات المناسبة.</span>
            </div>
            <button type="button" onClick={() => navigate('/top-parts')}>اكتشف الآن <ArrowLeft size={14} /></button>
          </div>
        </div>
      </section>

      <section className="b01h-section b01h-parts-section">
        <div className="b01h-shell">
          <div className="b01h-section-head">
            <div className="b01h-heading">
              <span className="b01h-kicker">الأكثر بحثاً</span>
              <h2>اكتشف القطع <em>الأكثر طلباً</em></h2>
              <p>نفس بيانات القطع الأكثر بحثاً في المنصة، بتجربة عرض أوضح وأسرع.</p>
            </div>
            <button className="b01h-text-link" type="button" onClick={() => navigate('/top-parts')}>عرض الكل <ArrowLeft size={15} /></button>
          </div>

          <div className="b01h-parts-grid">
            {popularParts.map((part, index) => (
              <button className="b01h-part-card" type="button" key={part.id} onClick={() => navigate('/top-parts')}>
                <div className="b01h-part-visual">
                  <span className="b01h-watermark">67</span>
                  <CarFront size={54} strokeWidth={1.25} />
                  <span className="b01h-rank">#{index + 1}</span>
                </div>
                <div className="b01h-part-body">
                  <small>قطعة مطلوبة</small>
                  <strong>{part.name}</strong>
                  <div className="b01h-part-meta">
                    <span>{part.searches} عملية بحث</span>
                    <b>{part.trend}</b>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      </section>

      <section className="b01h-section b01h-brands-section">
        <div className="b01h-shell b01h-brands-layout">
          <div className="b01h-brand-copy">
            <span className="b01h-kicker">اختر حسب الماركة</span>
            <h2>اختر ماركة سيارتك <em>وابدأ البحث بسهولة</em></h2>
            <p>اختر ماركتك من بيانات السيارات الموجودة بالفعل في المنصة، ثم أكمل للموديلات المتاحة.</p>
            <button type="button" className="b01h-primary-btn" onClick={() => navigate('/brands')}>جميع الماركات <ArrowLeft size={16} /></button>
          </div>

          <div className="b01h-brand-grid">
            {visibleBrands.map((brand, index) => (
              <button
                type="button"
                key={brand.id}
                className={`b01h-brand-card ${index === 0 ? 'is-active' : ''}`}
                onClick={() => navigate(`/models/${brand.id}`)}
              >
                <span className="b01h-brand-mark">{brand.name.slice(0, 2).toUpperCase()}</span>
                <strong>{brand.nameAr}</strong>
                <small>{brand.name}</small>
              </button>
            ))}
          </div>
        </div>
      </section>

      <section className="b01h-delivery-section">
        <div className="b01h-shell">
          <div className="b01h-delivery-card">
            <div className="b01h-delivery-copy">
              <span className="b01h-kicker">توصيل أسرع وتجربة أوضح</span>
              <h2>طلبك يوصل <em>خلال 24 ساعة</em></h2>
              <p>اكتشف الخدمات والخيارات المتاحة في 67 وابدأ طلبك من المكان المناسب.</p>
              <button type="button" onClick={() => navigate('/top-parts')}>اكتشف الخدمات <ArrowLeft size={15} /></button>
            </div>
            <div className="b01h-24-mark">
              <span>خلال</span>
              <strong>24</strong>
              <small>ساعة</small>
              <Truck size={34} />
            </div>
          </div>
        </div>
      </section>

      <section className="b01h-stats-section">
        <div className="b01h-shell">
          <div className="b01h-stats-title">
            <span className="b01h-kicker">67 بالأرقام</span>
            <h2>أرقامنا تصنع <em>الفرق.</em></h2>
          </div>
          <div className="b01h-stats-grid">
            {stats.map(({ value, label, path, Icon }, index) => (
              <button
                key={label}
                type="button"
                className={`b01h-stat-card ${index === 0 ? 'is-gold' : ''} ${index === 3 ? 'is-wide' : ''}`}
                onClick={() => navigate(path)}
              >
                <Icon size={20} />
                <strong>{value}</strong>
                <span>{label}</span>
              </button>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
};

export default HomeBelowHero;
