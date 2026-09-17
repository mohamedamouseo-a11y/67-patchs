import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Minus,
  Package,
  Plus,
  ShieldCheck,
  ShoppingBag,
  Store,
  Trash2,
  Truck,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import { mockOffers } from '../data/mockOffers';
import './CartPage.css';

const CART_KEY = '_67_cart';

const readCart = () => {
  try {
    const parsed = JSON.parse(localStorage.getItem(CART_KEY) || '[]');
    if (!Array.isArray(parsed)) return [];
    return parsed
      .map((line) => ({ offerId: String(line.offerId), quantity: Math.max(1, Number(line.quantity) || 1) }))
      .filter((line) => mockOffers.some((offer) => offer.id === line.offerId));
  } catch {
    return [];
  }
};

const CartPage = () => {
  const navigate = useNavigate();
  const [cartLines, setCartLines] = useState(readCart);

  useEffect(() => {
    localStorage.setItem(CART_KEY, JSON.stringify(cartLines));
  }, [cartLines]);

  const cartStores = useMemo(() => {
    const groups = new Map();
    cartLines.forEach((line) => {
      const offer = mockOffers.find((item) => item.id === line.offerId);
      if (!offer) return;
      const key = offer.storeNameAr || offer.storeName || '67';
      if (!groups.has(key)) groups.set(key, { storeId: key, storeName: key, items: [] });
      groups.get(key).items.push({ offer, quantity: line.quantity });
    });
    return Array.from(groups.values());
  }, [cartLines]);

  const updateQuantity = (offerId, delta) => {
    setCartLines((current) => current.map((line) => (
      line.offerId === offerId
        ? { ...line, quantity: Math.max(1, line.quantity + delta) }
        : line
    )));
  };

  const removeItem = (offerId) => {
    setCartLines((current) => current.filter((line) => line.offerId !== offerId));
  };

  const subtotal = cartStores.reduce(
    (sum, store) => sum + store.items.reduce(
      (storeSum, item) => storeSum + (item.offer.price * item.quantity),
      0,
    ),
    0,
  );
  const tax = subtotal * 0.15;
  const total = subtotal + tax;
  const productCount = cartLines.reduce((sum, line) => sum + line.quantity, 0);

  return (
    <div className="c67-page" dir="rtl">
      <section className="c67-hero">
        <HomeStoreHeader />
        <div className="c67-hero-overlay" aria-hidden="true" />
        <div className="c67-hero-shell">
          <div className="c67-hero-copy">
            <div className="c67-breadcrumb">
              <button type="button" onClick={() => navigate('/store')}>67</button>
              <span>/</span>
              <strong>السلة</strong>
            </div>
            <span className="c67-kicker">مشترياتك</span>
            <h1>سلة التسوق<span>.</span></h1>
            <p>راجع المنتجات والكميات قبل الانتقال إلى إتمام عملية الدفع.</p>
          </div>

          <div className="c67-hero-count" aria-label={`${productCount} قطع في السلة`}>
            <strong>{productCount}</strong>
            <span>قطع في السلة</span>
          </div>
        </div>
      </section>

      <main className="c67-main">
        <div className="c67-shell">
          {cartStores.length === 0 ? (
            <section className="c67-empty">
              <div className="c67-empty-icon"><ShoppingBag size={36} /></div>
              <span className="c67-kicker">سلة التسوق</span>
              <h2>السلة فارغة</h2>
              <p>لم تقم بإضافة أي منتجات حتى الآن.</p>
              <button type="button" onClick={() => navigate('/top-parts')}>تصفح المنتجات</button>
            </section>
          ) : (
            <div className="c67-layout">
              <aside className="c67-summary">
                <span className="c67-summary-kicker">ملخص الطلب</span>
                <h2>إجمالي السلة</h2>

                <div className="c67-summary-lines">
                  <div>
                    <span>المجموع الفرعي</span>
                    <strong>{subtotal.toFixed(2)} ر.س</strong>
                  </div>
                  <div>
                    <span>ضريبة القيمة المضافة</span>
                    <strong>{tax.toFixed(2)} ر.س</strong>
                  </div>
                </div>

                <div className="c67-tax-note">
                  <span>15%</span>
                  <p>تشمل ضريبة القيمة المضافة حسب قيمة المنتجات.</p>
                </div>

                <div className="c67-shipping-note">
                  <Truck size={20} />
                  <div>
                    <strong>تكلفة الشحن</strong>
                    <span>يتم تحديدها في الخطوة التالية</span>
                  </div>
                </div>

                <div className="c67-total-row">
                  <span>الإجمالي</span>
                  <strong>{total.toFixed(2)} <small>ر.س</small></strong>
                </div>

                <button type="button" className="c67-checkout-btn" onClick={() => navigate('/checkout')}>
                  متابعة الدفع
                  <span>←</span>
                </button>

                <div className="c67-secure">
                  <ShieldCheck size={15} />
                  <span>عملية دفع آمنة ومحمية</span>
                </div>
              </aside>

              <section className="c67-products">
                <div className="c67-section-heading">
                  <div>
                    <span className="c67-kicker">تفاصيل السلة</span>
                    <h2>المنتجات المضافة</h2>
                  </div>
                  <small>{productCount} قطعة</small>
                </div>

                <div className="c67-store-list">
                  {cartStores.map((store) => (
                    <article className="c67-store-card" key={store.storeId}>
                      <header className="c67-store-head">
                        <div className="c67-store-icon"><Store size={17} /></div>
                        <div>
                          <small>البائع</small>
                          <strong>{store.storeName}</strong>
                        </div>
                      </header>

                      {store.items.map(({ offer, quantity }) => (
                        <div className="c67-item" key={offer.id}>
                          <div className="c67-item-visual">
                            {offer.image ? (
                              <img src={offer.image} alt={offer.partNameAr} />
                            ) : (
                              <>
                                <span>67</span>
                                <Package size={42} strokeWidth={1.3} />
                              </>
                            )}
                          </div>

                          <div className="c67-item-info">
                            <span className="c67-condition">{offer.conditionAr} · {offer.brandAr}</span>
                            <h3>{offer.partNameAr}</h3>
                            <small>سعر القطعة</small>
                            <strong className="c67-price">{offer.price.toFixed(2)} {offer.currency}</strong>
                          </div>

                          <div className="c67-item-actions">
                            <button
                              type="button"
                              className="c67-remove"
                              onClick={() => removeItem(offer.id)}
                              aria-label={`حذف ${offer.partNameAr}`}
                            >
                              <Trash2 size={16} />
                            </button>

                            <div className="c67-qty" aria-label={`كمية ${offer.partNameAr}`}>
                              <button type="button" onClick={() => updateQuantity(offer.id, -1)} aria-label="تقليل الكمية">
                                <Minus size={15} />
                              </button>
                              <strong>{quantity}</strong>
                              <button type="button" onClick={() => updateQuantity(offer.id, 1)} aria-label="زيادة الكمية">
                                <Plus size={15} />
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </article>
                  ))}
                </div>

                <button type="button" className="c67-continue" onClick={() => navigate('/top-parts')}>
                  متابعة التسوق
                  <span>←</span>
                </button>
              </section>
            </div>
          )}
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default CartPage;
