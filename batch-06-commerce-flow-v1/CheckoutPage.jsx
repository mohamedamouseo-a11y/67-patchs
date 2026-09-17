import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Apple,
  ArrowLeft,
  Check,
  CheckCircle2,
  CreditCard,
  MapPin,
  Package,
  ShieldCheck,
  Wallet,
} from 'lucide-react';
import ShippingSelector from '../components/ShippingSelector';
import { mockOffers } from '../data/mockOffers';
import './CheckoutPage.css';

const CART_KEY = '_67_cart';
const ORDERS_KEY = '_67_orders';

const ORIGINAL_ADDRESS = {
  name: 'عبدالله أحمد',
  line: 'الرياض، حي الملقا، شارع الأمير محمد بن سعد',
  phone: '0501234567',
};

const ORIGINAL_ORDERS = [
  { id: '#ORD-2095', itemName: 'كمبروسر مكيف', storeName: 'متجر الريادة لقطع الغيار', date: '2026-07-08', total: 750, status: 'processing', statusLabel: 'قيد التنفيذ' },
  { id: '#ORD-2091', itemName: 'صدام أمامي تويوتا كامري 2020', storeName: 'قطع غيار السيارات الأولى', date: '2026-07-07', total: 450, status: 'shipped', statusLabel: 'تم الشحن' },
  { id: '#ORD-2088', itemName: 'فحمات فرامل خلفية', storeName: 'المركز الفني', date: '2026-07-05', total: 180, status: 'delivered', statusLabel: 'تم التسليم' },
];

const PAYMENT_OPTIONS = [
  { id: 'applepay', label: 'Apple Pay', note: 'Apple Pay' },
  { id: 'stcpay', label: 'stc pay', note: 'STC Pay' },
  { id: 'mada', label: 'مدى', note: 'مدى' },
  { id: 'visa_master', label: 'VISA / MC', note: 'فيزا / ماستركارد' },
  { id: 'tabby', label: 'tabby', note: 'تابي · قسمها على 4' },
  { id: 'tamara', label: 'tamara', note: 'تمارا · قسمها على 3 أو 4' },
];

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

const CheckoutPage = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [cartLines] = useState(readCart);
  const [shippingMethod, setShippingMethod] = useState(null);
  const [paymentMethod, setPaymentMethod] = useState('applepay');
  const [useWallet, setUseWallet] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [completedOrder, setCompletedOrder] = useState(null);

  const walletBalance = 1280.00;

  const items = useMemo(() => cartLines.map((line) => {
    const offer = mockOffers.find((item) => item.id === line.offerId);
    return offer ? { offer, quantity: line.quantity } : null;
  }).filter(Boolean), [cartLines]);

  const subtotal = items.reduce((sum, item) => sum + (item.offer.price * item.quantity), 0);
  const tax = subtotal * 0.15;
  const shippingCost = shippingMethod ? shippingMethod.cost : 0;
  const total = subtotal + tax + shippingCost;
  const walletDeduction = useWallet ? Math.min(walletBalance, total) : 0;
  const remainingTotal = total - walletDeduction;
  const productCount = items.reduce((sum, item) => sum + item.quantity, 0);

  const selectedPayment = PAYMENT_OPTIONS.find((item) => item.id === paymentMethod) || PAYMENT_OPTIONS[0];

  const persistOrder = () => {
    if (!items.length) return null;
    const orderId = `#ORD-${String(Date.now()).slice(-6)}`;
    const newOrder = {
      id: orderId,
      itemName: items.length === 1
        ? items[0].offer.partNameAr
        : `${items[0].offer.partNameAr} + ${productCount - items[0].quantity} قطعة`,
      storeName: items[0].offer.storeNameAr,
      date: new Date().toISOString().slice(0, 10),
      total: Number(total.toFixed(2)),
      status: 'processing',
      statusLabel: 'قيد التنفيذ',
    };

    let existing = ORIGINAL_ORDERS;
    try {
      const saved = JSON.parse(localStorage.getItem(ORDERS_KEY) || 'null');
      if (Array.isArray(saved)) existing = saved;
    } catch {
      existing = ORIGINAL_ORDERS;
    }

    localStorage.setItem(ORDERS_KEY, JSON.stringify([newOrder, ...existing]));
    localStorage.setItem(CART_KEY, '[]');
    return newOrder;
  };

  const handleCompleteOrder = () => {
    if (!items.length || !shippingMethod) return;
    setIsProcessing(true);
    window.setTimeout(() => {
      const order = persistOrder();
      setCompletedOrder(order);
      setIsProcessing(false);
      setStep(3);
    }, 450);
  };

  if (!items.length && step !== 3) {
    return (
      <div className="co67-page" dir="rtl">
        <CheckoutHeader onBack={() => navigate('/cart')} />
        <main className="co67-empty">
          <Package size={46} strokeWidth={1.3} />
          <h1>لا توجد منتجات لإتمام الطلب</h1>
          <p>أضف منتجاً إلى السلة أولاً ثم تابع خطوات الشراء.</p>
          <button type="button" onClick={() => navigate('/top-parts')}>تصفح المنتجات</button>
        </main>
      </div>
    );
  }

  return (
    <div className="co67-page" dir="rtl">
      <CheckoutHeader onBack={() => step === 1 ? navigate('/cart') : setStep(Math.max(1, step - 1))} />

      <main className="co67-main">
        <div className="co67-shell">
          <CheckoutSteps step={step} />

          {step < 3 && (
            <div className="co67-layout">
              <OrderSummary
                items={items}
                subtotal={subtotal}
                tax={tax}
                shippingCost={shippingCost}
                total={total}
                walletDeduction={walletDeduction}
                useWallet={useWallet}
              />

              <section className="co67-content">
                {step === 1 && (
                  <>
                    <span className="co67-kicker">01 · التوصيل</span>
                    <h1>أين تريد استلام طلبك؟</h1>
                    <p className="co67-lead">اختر عنوان التوصيل وشركة الشحن المناسبة، ثم راجع التكلفة قبل الانتقال للدفع.</p>

                    <article className="co67-address-card">
                      <div className="co67-address-head">
                        <div className="co67-address-title">
                          <span><MapPin size={19} /></span>
                          <div>
                            <small>عنوان التوصيل</small>
                            <strong>المنزل · الرياض</strong>
                          </div>
                        </div>
                        <button type="button" onClick={() => navigate('/addresses')}>تغيير</button>
                      </div>
                      <div className="co67-address-body">
                        <strong>{ORIGINAL_ADDRESS.name}</strong>
                        <span>{ORIGINAL_ADDRESS.line}</span>
                        <span dir="ltr">{ORIGINAL_ADDRESS.phone}</span>
                      </div>
                    </article>

                    <div className="co67-shipping-wrap">
                      <span className="co67-kicker">شركة الشحن</span>
                      <ShippingSelector selectedId={shippingMethod?.id} onSelect={setShippingMethod} />
                    </div>

                    <div className="co67-actions">
                      <button type="button" className="co67-secondary" onClick={() => navigate('/cart')}>الرجوع للسلة</button>
                      <button type="button" className="co67-primary" disabled={!shippingMethod} onClick={() => setStep(2)}>
                        استمرار للدفع <ArrowLeft size={17} />
                      </button>
                    </div>
                  </>
                )}

                {step === 2 && (
                  <>
                    <span className="co67-kicker">02 · الدفع</span>
                    <h1>اختر طريقة الدفع المناسبة.</h1>
                    <p className="co67-lead">يمكنك استخدام رصيد محفظة 67، ثم دفع أي مبلغ متبقٍ بإحدى وسائل الدفع المتاحة.</p>

                    <article className="co67-wallet-card">
                      <div className="co67-wallet-head">
                        <div>
                          <span className="co67-wallet-icon"><Wallet size={20} /></span>
                          <div>
                            <small>المحفظة الإلكترونية</small>
                            <strong>محفظة 67</strong>
                          </div>
                        </div>
                        <button
                          type="button"
                          aria-pressed={useWallet}
                          className={useWallet ? 'is-active' : ''}
                          onClick={() => setUseWallet((value) => !value)}
                        ><i /></button>
                      </div>
                      <div className="co67-wallet-balance">
                        <small>الرصيد المتاح</small>
                        <strong>{walletBalance.toFixed(2)} <span>ر.س</span></strong>
                      </div>
                    </article>

                    {remainingTotal > 0 && (
                      <div className="co67-payment-wrap">
                        <span className="co67-kicker">وسيلة الدفع</span>
                        <h2>طريقة الدفع للمبلغ المتبقي</h2>
                        <div className="co67-payment-grid">
                          {PAYMENT_OPTIONS.map((option) => (
                            <button
                              type="button"
                              key={option.id}
                              className={paymentMethod === option.id ? 'is-selected' : ''}
                              onClick={() => setPaymentMethod(option.id)}
                            >
                              <span className="co67-radio"><i /></span>
                              <strong className={`co67-pay-brand is-${option.id}`}>{option.label}</strong>
                              <small>{option.note}</small>
                            </button>
                          ))}
                        </div>
                      </div>
                    )}

                    <div className="co67-actions">
                      <button type="button" className="co67-secondary" onClick={() => setStep(1)}>الرجوع للتوصيل</button>
                      <button type="button" className="co67-primary" onClick={handleCompleteOrder} disabled={isProcessing}>
                        {isProcessing ? 'جاري إتمام الطلب...' : `إتمام الشراء · ${remainingTotal.toFixed(2)} ر.س`}
                      </button>
                    </div>
                  </>
                )}
              </section>
            </div>
          )}

          {step === 3 && completedOrder && (
            <section className="co67-success-card">
              <div className="co67-success-icon"><Check size={40} /></div>
              <span className="co67-kicker">تمت العملية</span>
              <h1>تم استلام طلبك بنجاح.</h1>
              <p>تم تسجيل الطلب وسيظهر ضمن طلباتك لمتابعة حالته.</p>

              <div className="co67-order-number">
                <small>رقم الطلب</small>
                <strong>{completedOrder.id}</strong>
              </div>

              <div className="co67-success-meta">
                <div><small>الإجمالي</small><strong>{completedOrder.total.toFixed(2)} ر.س</strong></div>
                <div><small>الشحن</small><strong>{shippingMethod?.name}</strong></div>
                <div><small>الدفع</small><strong>{remainingTotal === 0 ? 'محفظة 67' : selectedPayment.label}</strong></div>
              </div>

              <div className="co67-success-actions">
                <button type="button" className="co67-primary" onClick={() => navigate('/orders')}>تتبع الطلب</button>
                <button type="button" className="co67-secondary" onClick={() => navigate('/store')}>العودة للرئيسية</button>
              </div>
            </section>
          )}
        </div>
      </main>
    </div>
  );
};

const CheckoutHeader = ({ onBack }) => (
  <header className="co67-header">
    <div className="co67-header-shell">
      <button type="button" onClick={onBack}>العودة للسلة <ArrowLeft size={16} /></button>
      <div>
        <strong>إتمام الطلب</strong>
        <span>راجع التوصيل والدفع قبل تأكيد الشراء</span>
      </div>
      <img src="/assets/logo-67.png" alt="67" />
    </div>
  </header>
);

const CheckoutSteps = ({ step }) => (
  <div className="co67-steps" aria-label="خطوات إتمام الطلب">
    <div className={step >= 1 ? 'is-active' : ''}>
      <span>{step > 1 ? <Check size={16} /> : '1'}</span>
      <strong>التوصيل</strong>
      <small>العنوان والشحن</small>
    </div>
    <i />
    <div className={step >= 2 ? 'is-active' : ''}>
      <span>{step > 2 ? <Check size={16} /> : '2'}</span>
      <strong>الدفع</strong>
      <small>اختر طريقة الدفع</small>
    </div>
    <i />
    <div className={step >= 3 ? 'is-active' : ''}>
      <span>{step >= 3 ? <Check size={16} /> : '3'}</span>
      <strong>تم الطلب</strong>
      <small>تأكيد العملية</small>
    </div>
  </div>
);

const OrderSummary = ({ items, subtotal, tax, shippingCost, total, walletDeduction, useWallet }) => (
  <aside className="co67-summary">
    <span className="co67-kicker">ملخص الطلب</span>
    <div className="co67-summary-title">
      <h2>طلبك</h2>
      <small>{items.reduce((sum, item) => sum + item.quantity, 0)} قطع</small>
    </div>

    <div className="co67-summary-items">
      {items.map(({ offer, quantity }) => (
        <div key={offer.id}>
          <div className="co67-summary-image">
            {offer.image ? <img src={offer.image} alt={offer.partNameAr} /> : <Package size={24} />}
          </div>
          <div>
            <strong>{offer.partNameAr}</strong>
            <small>{offer.storeNameAr} · الكمية {quantity}</small>
          </div>
          <b>{(offer.price * quantity).toFixed(2)} {offer.currency}</b>
        </div>
      ))}
    </div>

    <div className="co67-summary-lines">
      <div><span>المجموع الفرعي</span><strong>{subtotal.toFixed(2)} ر.س</strong></div>
      <div><span>الشحن</span><strong>{shippingCost > 0 ? `${shippingCost.toFixed(2)} ر.س` : 'اختر شركة شحن'}</strong></div>
      <div><span>الضريبة (15%)</span><strong>{tax.toFixed(2)} ر.س</strong></div>
      {useWallet && <div><span>خصم المحفظة</span><strong>-{walletDeduction.toFixed(2)} ر.س</strong></div>}
    </div>

    <div className="co67-summary-total">
      <span>الإجمالي</span>
      <strong>{total.toFixed(2)} <small>ر.س</small></strong>
    </div>

    <div className="co67-summary-secure"><ShieldCheck size={15} /> بيانات الدفع تتم من خلال وسائل الدفع المتاحة داخل المنصة</div>
  </aside>
);

export default CheckoutPage;
