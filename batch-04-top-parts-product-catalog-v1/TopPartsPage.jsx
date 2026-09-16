import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle2,
  Heart,
  Package,
  Search,
  ShoppingCart,
  Star,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import { mockOffers } from '../data/mockOffers';
import './TopPartsPage.css';

const TopPartsPage = () => {
  const navigate = useNavigate();
  const [query, setQuery] = useState('');
  const [condition, setCondition] = useState('all');
  const [sortBy, setSortBy] = useState('featured');
  const [favoriteIds, setFavoriteIds] = useState(() => new Set());

  const conditions = useMemo(() => {
    const unique = new Map();
    mockOffers.forEach((offer) => {
      if (offer.condition && !unique.has(offer.condition)) {
        unique.set(offer.condition, offer.conditionAr || offer.condition);
      }
    });
    return Array.from(unique, ([id, label]) => ({ id, label }));
  }, []);

  const products = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    const list = mockOffers.filter((offer) => {
      const matchesCondition = condition === 'all' || offer.condition === condition;
      const matchesQuery = !normalized || [
        offer.partNameAr,
        offer.partName,
        offer.storeNameAr,
        offer.storeName,
        offer.description,
      ]
        .filter(Boolean)
        .some((value) => String(value).toLowerCase().includes(normalized));
      return matchesCondition && matchesQuery;
    });

    if (sortBy === 'price') return [...list].sort((a, b) => a.price - b.price);
    if (sortBy === 'rating') return [...list].sort((a, b) => b.rating - a.rating);
    if (sortBy === 'shipping') return [...list].sort((a, b) => a.shippingDays - b.shippingDays);
    return list;
  }, [condition, query, sortBy]);

  const toggleFavorite = (event, id) => {
    event.stopPropagation();
    setFavoriteIds((current) => {
      const next = new Set(current);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  return (
    <div className="tp67-page" dir="rtl">
      <section className="tp67-hero">
        <HomeStoreHeader />
        <div className="tp67-hero-overlay" />
        <div className="tp67-hero-shell">
          <div className="tp67-hero-copy">
            <span className="tp67-kicker">كتالوج قطع الغيار</span>
            <h1>اختر القطعة<br /><span>المناسبة.</span></h1>
            <p>كل المنتجات المعروضة هنا تأتي من بيانات المنتجات الموجودة أصلًا داخل مشروع 67، مع إعادة تصميم طريقة العرض فقط.</p>
          </div>

          <div className="tp67-hero-search">
            <Search size={21} />
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="ابحث باسم القطعة أو المتجر..."
              aria-label="البحث داخل قطع الغيار"
            />
            <button type="button" onClick={() => navigate('/search')}>بحث متقدم</button>
          </div>
        </div>
      </section>

      <main className="tp67-main">
        <div className="tp67-shell">
          <div className="tp67-page-head">
            <div>
              <span className="tp67-kicker">قطع غيار 67</span>
              <h2>كل المنتجات</h2>
              <p>لا يتم تقسيم المنتجات إلى فئات غير موجودة في مصدر البيانات الأصلي.</p>
            </div>
            <span className="tp67-total">{products.length} من {mockOffers.length} منتج</span>
          </div>

          <div className="tp67-toolbar">
            <div className="tp67-condition-tabs" aria-label="فلترة حسب الحالة">
              <button
                type="button"
                className={condition === 'all' ? 'is-active' : ''}
                onClick={() => setCondition('all')}
              >
                الكل
              </button>
              {conditions.map((item) => (
                <button
                  type="button"
                  key={item.id}
                  className={condition === item.id ? 'is-active' : ''}
                  onClick={() => setCondition(item.id)}
                >
                  {item.label}
                </button>
              ))}
            </div>

            <label className="tp67-sort">
              <span>ترتيب</span>
              <select value={sortBy} onChange={(event) => setSortBy(event.target.value)}>
                <option value="featured">كما في المصدر</option>
                <option value="price">الأقل سعراً</option>
                <option value="rating">الأعلى تقييماً</option>
                <option value="shipping">الأسرع شحناً</option>
              </select>
            </label>
          </div>

          {products.length === 0 ? (
            <div className="tp67-empty">
              <Package size={44} strokeWidth={1.25} />
              <h3>لا توجد منتجات مطابقة</h3>
              <p>غيّر البحث أو الفلتر لعرض المنتجات المتاحة.</p>
            </div>
          ) : (
            <section className="tp67-grid" aria-label="منتجات قطع الغيار">
              {products.map((offer) => {
                const isFavorite = favoriteIds.has(offer.id);
                return (
                  <article
                    className="tp67-card"
                    key={offer.id}
                    onClick={() => navigate(`/offer/${offer.id}`)}
                  >
                    <div className="tp67-card-visual">
                      {offer.image ? (
                        <img src={offer.image} alt={offer.partNameAr} />
                      ) : (
                        <div className="tp67-no-image"><Package size={48} strokeWidth={1.25} /></div>
                      )}

                      <button
                        type="button"
                        className={`tp67-heart ${isFavorite ? 'is-active' : ''}`}
                        aria-label={isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة'}
                        onClick={(event) => toggleFavorite(event, offer.id)}
                      >
                        <Heart size={20} fill={isFavorite ? 'currentColor' : 'none'} />
                      </button>

                      <span className="tp67-condition-badge">{offer.conditionAr}</span>
                    </div>

                    <div className="tp67-card-body">
                      <div className="tp67-card-meta">
                        <span className="tp67-brand-label">{offer.brandAr}</span>
                        <span className="tp67-rating"><Star size={13} fill="currentColor" /> {offer.rating}</span>
                      </div>

                      <h3>{offer.partNameAr}</h3>
                      <p className="tp67-description">{offer.description}</p>

                      <div className="tp67-divider" />

                      <div className="tp67-store-row">
                        <div className="tp67-store">
                          <span className="tp67-store-avatar">67</span>
                          <div>
                            <strong>{offer.storeNameAr}</strong>
                            <small>
                              {offer.isVerified && <CheckCircle2 size={12} />}
                              {offer.isVerified ? 'موثوق' : 'متجر'} · {offer.storeCityAr}
                            </small>
                          </div>
                        </div>
                        <span className="tp67-review-count">{offer.reviewCount} تقييم</span>
                      </div>

                      <div className="tp67-card-footer">
                        <div className="tp67-price-wrap">
                          <small>السعر يبدأ من</small>
                          <strong>{offer.price} <span>{offer.currency}</span></strong>
                        </div>

                        <button
                          type="button"
                          className="tp67-cart-action"
                          aria-label={`عرض تفاصيل ${offer.partNameAr}`}
                          onClick={(event) => {
                            event.stopPropagation();
                            navigate(`/offer/${offer.id}`);
                          }}
                        >
                          <ShoppingCart size={19} />
                        </button>
                      </div>
                    </div>
                  </article>
                );
              })}
            </section>
          )}

          <section className="tp67-cta">
            <div>
              <span>مش لاقي القطعة؟</span>
              <h2>استخدم البحث المتقدم للوصول للعرض المناسب.</h2>
            </div>
            <button type="button" onClick={() => navigate('/search')}>
              البحث المتقدم <ArrowLeft size={17} />
            </button>
          </section>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default TopPartsPage;
