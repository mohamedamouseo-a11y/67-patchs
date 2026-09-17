import { useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle2,
  Clock3,
  Heart,
  MapPin,
  Package,
  ShieldCheck,
  ShoppingCart,
  Star,
  Store,
  Truck,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import VerifiedBadge from '../components/VerifiedBadge';
import { mockOffers } from '../data/mockOffers';
import './OfferDetailPage.css';

const TABS = [
  { id: 'details', label: 'التفاصيل' },
  { id: 'shipping', label: 'الشحن والضمان' },
  { id: 'reviews', label: 'التقييمات' },
];

const OfferDetailPage = () => {
  const { offerId } = useParams();
  const navigate = useNavigate();
  const offer = useMemo(
    () => mockOffers.find((item) => item.id === offerId) || mockOffers[0],
    [offerId],
  );
  const relatedOffers = useMemo(
    () => mockOffers.filter((item) => item.id !== offer.id).slice(0, 4),
    [offer.id],
  );

  const [activeTab, setActiveTab] = useState('details');
  const [fairRating, setFairRating] = useState(0);
  const [ratingSubmitted, setRatingSubmitted] = useState(false);

  const shippingLabel = offer.shippingCost === 0
    ? 'شحن مجاني'
    : `${offer.shippingCost} ${offer.currency}`;

  const detailRows = [
    ['الحالة', offer.conditionAr],
    ['النوع', offer.brandAr],
    ['الضمان', offer.warranty],
    ['التوفر', offer.availability ? 'متوفر' : 'غير متوفر'],
    ['مدينة المتجر', offer.storeCityAr],
    ['مدة الشحن', `${offer.shippingDays} يوم`],
  ];

  return (
    <div className="od67-page" dir="rtl">
      <div className="od67-topbar">
        <HomeStoreHeader />
      </div>

      <main className="od67-main">
        <div className="od67-shell">
          <nav className="od67-breadcrumb" aria-label="مسار الصفحة">
            <button type="button" onClick={() => navigate('/store')}>الرئيسية</button>
            <span>/</span>
            <button type="button" onClick={() => navigate('/top-parts')}>قطع الغيار</button>
            <span>/</span>
            <strong>{offer.partNameAr}</strong>
          </nav>

          <section className="od67-hero-grid">
            <div className="od67-product-copy">
              <div className="od67-meta-row">
                <span>{offer.brandAr}</span>
                <i />
                <span>{offer.conditionAr}</span>
                <span className="od67-rating"><Star size={15} fill="currentColor" /> {offer.rating}</span>
                <span>{offer.reviewCount} تقييم</span>
              </div>

              <h1>{offer.partNameAr}</h1>

              <div className="od67-availability">
                <span className={offer.availability ? 'is-available' : 'is-unavailable'} />
                <strong>{offer.availability ? 'متوفر الآن' : 'غير متوفر حالياً'}</strong>
              </div>

              <p className="od67-description">{offer.description}</p>

              <div className="od67-purchase-summary">
                <div className="od67-price-block">
                  <small>السعر</small>
                  <strong>{offer.price} <span>{offer.currency}</span></strong>
                </div>
                <div className="od67-shipping-block">
                  <Truck size={20} />
                  <div>
                    <small>{shippingLabel}</small>
                    <strong>خلال {offer.shippingDays} يوم</strong>
                  </div>
                </div>
              </div>

              <div className="od67-actions-card">
                <div className="od67-stock-note">
                  <CheckCircle2 size={17} />
                  <span>{offer.availability ? 'متاح للشراء' : 'غير متاح للشراء حالياً'}</span>
                </div>
                <button type="button" className="od67-buy-btn">
                  <ShoppingCart size={19} />
                  اشتري الآن
                </button>
                <button type="button" className="od67-back-btn" onClick={() => navigate('/top-parts')}>
                  العودة للعروض <ArrowLeft size={17} />
                </button>
              </div>

              <article className="od67-store-card">
                <div className="od67-store-avatar">67</div>
                <div className="od67-store-info">
                  <small>متوفر بواسطة</small>
                  <div className="od67-store-title">
                    <strong>{offer.storeNameAr}</strong>
                    {offer.isVerified && <VerifiedBadge />}
                  </div>
                  <span><MapPin size={14} /> {offer.storeCityAr}</span>
                </div>
                <div className="od67-store-rating">
                  <Star size={14} fill="currentColor" />
                  <strong>{offer.rating}</strong>
                  <small>{offer.reviewCount} تقييم</small>
                </div>
              </article>
            </div>

            <div className="od67-product-media">
              <div className="od67-image-card">
                <button type="button" className="od67-heart" aria-label="المفضلة">
                  <Heart size={20} />
                </button>
                <span className="od67-image-badge">{offer.conditionAr}</span>
                {offer.image ? (
                  <img src={offer.image} alt={offer.partNameAr} />
                ) : (
                  <div className="od67-no-image">
                    <Package size={70} strokeWidth={1.2} />
                    <span>لا توجد صورة متاحة</span>
                  </div>
                )}
              </div>

              {offer.image && (
                <div className="od67-thumbs">
                  <button type="button" className="is-active" aria-label="صورة المنتج">
                    <img src={offer.image} alt="" />
                  </button>
                </div>
              )}

              <div className="od67-trust-grid">
                <div>
                  <MapPin size={20} />
                  <span>مدينة المتجر</span>
                  <strong>{offer.storeCityAr}</strong>
                </div>
                <div>
                  <Truck size={20} />
                  <span>الشحن</span>
                  <strong>{shippingLabel}</strong>
                </div>
                <div>
                  <ShieldCheck size={20} />
                  <span>الضمان</span>
                  <strong>{offer.warranty}</strong>
                </div>
              </div>
            </div>
          </section>

          <section className="od67-info-section">
            <div className="od67-tabs" role="tablist" aria-label="تفاصيل المنتج">
              {TABS.map((tab) => (
                <button
                  type="button"
                  role="tab"
                  key={tab.id}
                  aria-selected={activeTab === tab.id}
                  className={activeTab === tab.id ? 'is-active' : ''}
                  onClick={() => setActiveTab(tab.id)}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            {activeTab === 'details' && (
              <div className="od67-tab-panel od67-details-panel">
                <div className="od67-section-copy">
                  <span className="od67-kicker">عن القطعة</span>
                  <h2>تفاصيل واضحة قبل الشراء.</h2>
                  <p>{offer.description}</p>
                </div>
                <div className="od67-spec-grid">
                  {detailRows.map(([label, value]) => (
                    <div key={label}>
                      <small>{label}</small>
                      <strong>{value}</strong>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {activeTab === 'shipping' && (
              <div className="od67-tab-panel od67-shipping-panel">
                <article>
                  <Truck size={24} />
                  <small>تكلفة الشحن</small>
                  <strong>{shippingLabel}</strong>
                </article>
                <article>
                  <Clock3 size={24} />
                  <small>مدة الشحن</small>
                  <strong>{offer.shippingDays} يوم</strong>
                </article>
                <article>
                  <ShieldCheck size={24} />
                  <small>الضمان</small>
                  <strong>{offer.warranty}</strong>
                </article>
              </div>
            )}

            {activeTab === 'reviews' && (
              <div className="od67-tab-panel od67-reviews-panel">
                <div className="od67-rating-summary">
                  <Star size={28} fill="currentColor" />
                  <strong>{offer.rating}</strong>
                  <span>{offer.reviewCount} تقييم</span>
                </div>

                {offer.marketPrice && offer.price <= offer.marketPrice && (
                  <div className="od67-fair-price">
                    <strong><ShieldCheck size={18} /> السعر مطابق أو أقل من متوسط السوق المسجل في بيانات المنتج.</strong>
                    {!ratingSubmitted ? (
                      <div className="od67-star-rate">
                        <span>قيّم السعر:</span>
                        {[1, 2, 3, 4, 5].map((star) => (
                          <button
                            type="button"
                            key={star}
                            className={fairRating >= star ? 'is-active' : ''}
                            onClick={() => setFairRating(star)}
                            aria-label={`تقييم ${star}`}
                          >
                            <Star size={20} fill={fairRating >= star ? 'currentColor' : 'none'} />
                          </button>
                        ))}
                        {fairRating > 0 && (
                          <button type="button" className="od67-submit-rating" onClick={() => setRatingSubmitted(true)}>
                            إرسال التقييم
                          </button>
                        )}
                      </div>
                    ) : (
                      <p>شكراً لتقييمك.</p>
                    )}
                  </div>
                )}

                {offer.marketPrice && offer.price > offer.marketPrice && (
                  <div className="od67-market-warning">
                    السعر الحالي أعلى من متوسط السوق المسجل ({offer.marketPrice} {offer.currency}).
                  </div>
                )}
              </div>
            )}
          </section>

          <section className="od67-related-section">
            <div className="od67-related-head">
              <div>
                <span className="od67-kicker">قد تناسبك أيضاً</span>
                <h2>منتجات مشابهة</h2>
              </div>
              <button type="button" onClick={() => navigate('/top-parts')}>عرض كل المنتجات <ArrowLeft size={16} /></button>
            </div>

            <div className="od67-related-grid">
              {relatedOffers.map((item) => (
                <article className="od67-related-card" key={item.id} onClick={() => navigate(`/offer/${item.id}`)}>
                  <div className="od67-related-image">
                    {item.image ? <img src={item.image} alt={item.partNameAr} /> : <Package size={40} />}
                  </div>
                  <div className="od67-related-body">
                    <small>{item.brandAr}</small>
                    <strong>{item.partNameAr}</strong>
                    <span>{item.conditionAr} · {item.storeCityAr}</span>
                    <div>
                      <b>{item.price} <em>{item.currency}</em></b>
                      <button type="button" aria-label={`عرض ${item.partNameAr}`} onClick={(event) => {
                        event.stopPropagation();
                        navigate(`/offer/${item.id}`);
                      }}>
                        <ArrowLeft size={16} />
                      </button>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          </section>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default OfferDetailPage;
