import { useState } from 'react';
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
import './CartPage.css';

const INITIAL_CART_STORES = [
  {
    storeId: 's1',
    storeName: 'متجر الريادة لقطع الغيار',
    items: [
      { id: '1', name: 'كمبروسر مكيف كامري 2020', price: 750, quantity: 1, image: null, condition: 'جديد' },
    ],
  },
  {
    storeId: 's2',
    storeName: 'المركز الفني',
    items: [
      { id: '2', name: 'فحمات فرامل أمامية', price: 180, quantity: 2, image: null, condition: 'جديد' },
    ],
  },
];

const CartPage = () => {
  const navigate = useNavigate();
  const [cartStores, setCartStores] = useState(INITIAL_CART_STORES);

  const updateQuantity = (storeId, itemId, delta) => {
    setCartStores((prev) => prev.map((store) => {
      if (store.storeId !== storeId) return store;
      return {
        ...store,
        items: store.items.map((item) => {
          if (item.id !== itemId) return item;
          const newQ = item.quantity + delta;
          return { ...item, quantity: newQ > 0 ? newQ : 1 };
        }),
      };
    }));
  };

  const removeItem = (storeId, itemId) => {
    setCartStores((prev) => prev
      .map((store) => {
        if (store.storeId !== storeId) return store;
        return { ...store, items: store.items.filter((item) => item.id !== itemId) };
      })
      .filter((store) => store.items.length > 0));
  };

  const subtotal = cartStores.reduce(
    (sum, store) => sum + store.items.reduce(
      (storeSum, item) => storeSum + (item.price * item.quantity),
      0,
    ),
    0,
  );
  const tax = subtotal * 0.15;
  const total = subtotal + tax;
  const productCount = cartStores.reduce((sum, store) => sum + store.items.length, 0);

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
              <button type="button" onClick={() => navigate('/store')}>تصفح المنتجات</button>
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

                      {store.items.map((item) => (
                        <div className="c67-item" key={item.id}>
                          <div className="c67-item-visual">
                            {item.image ? (
                              <img src={item.image} alt={item.name} />
                            ) : (
                              <>
                                <span>67</span>
                                <Package size={42} strokeWidth={1.3} />
                              </>
                            )}
                          </div>

                          <div className="c67-item-info">
                            <span className="c67-condition">{item.condition} · مضمون</span>
                            <h3>{item.name}</h3>
                            <small>سعر القطعة</small>
                            <strong className="c67-price">{item.price.toFixed(2)} ر.س</strong>
                          </div>

                          <div className="c67-item-actions">
                            <button
                              type="button"
                              className="c67-remove"
                              onClick={() => removeItem(store.storeId, item.id)}
                              aria-label={`حذف ${item.name}`}
                            >
                              <Trash2 size={16} />
                            </button>

                            <div className="c67-qty" aria-label={`كمية ${item.name}`}>
                              <button
                                type="button"
                                onClick={() => updateQuantity(store.storeId, item.id, -1)}
                                aria-label="تقليل الكمية"
                              >
                                <Minus size={15} />
                              </button>
                              <strong>{item.quantity}</strong>
                              <button
                                type="button"
                                onClick={() => updateQuantity(store.storeId, item.id, 1)}
                                aria-label="زيادة الكمية"
                              >
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
