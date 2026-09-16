import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CheckCircle, Package, Store } from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './MyOrdersPage.css';

const INITIAL_ORDERS = [
  {
    id: '#ORD-2095',
    itemName: 'كمبروسر مكيف',
    storeName: 'متجر الريادة لقطع الغيار',
    date: '2026-07-08',
    total: 750,
    status: 'processing',
    statusLabel: 'قيد التنفيذ',
  },
  {
    id: '#ORD-2091',
    itemName: 'صدام أمامي تويوتا كامري 2020',
    storeName: 'قطع غيار السيارات الأولى',
    date: '2026-07-07',
    total: 450,
    status: 'shipped',
    statusLabel: 'تم الشحن',
  },
  {
    id: '#ORD-2088',
    itemName: 'فحمات فرامل خلفية',
    storeName: 'المركز الفني',
    date: '2026-07-05',
    total: 180,
    status: 'delivered',
    statusLabel: 'تم التسليم',
  },
];

const TABS = [
  { id: 'all', label: 'الكل' },
  { id: 'new', label: 'الجديدة' },
  { id: 'processing', label: 'قيد التنفيذ' },
  { id: 'shipped', label: 'تم الشحن' },
  { id: 'delivered', label: 'تم التسليم' },
  { id: 'rejected', label: 'المرفوضة/الملغاة' },
];

const STATUS_META = {
  new: { label: 'جديد', className: 'is-new' },
  processing: { label: 'قيد التنفيذ', className: 'is-processing' },
  shipped: { label: 'تم الشحن', className: 'is-shipped' },
  delivered: { label: 'تم التسليم', className: 'is-delivered' },
  rejected: { label: 'ملغى / مرفوض', className: 'is-rejected' },
};

const MyOrdersPage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('all');
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const saved = localStorage.getItem('_67_orders');
    if (saved) {
      try {
        setOrders(JSON.parse(saved));
      } catch {
        localStorage.setItem('_67_orders', JSON.stringify(INITIAL_ORDERS));
        setOrders(INITIAL_ORDERS);
      }
    } else {
      localStorage.setItem('_67_orders', JSON.stringify(INITIAL_ORDERS));
      setOrders(INITIAL_ORDERS);
    }
  }, []);

  const tabCounts = useMemo(() => {
    const counts = { all: orders.length, new: 0, processing: 0, shipped: 0, delivered: 0, rejected: 0 };
    orders.forEach((order) => {
      if (Object.prototype.hasOwnProperty.call(counts, order.status)) counts[order.status] += 1;
    });
    return counts;
  }, [orders]);

  const filteredOrders = useMemo(
    () => (activeTab === 'all' ? orders : orders.filter((order) => order.status === activeTab)),
    [activeTab, orders],
  );

  const confirmDelivery = (order) => {
    const updated = orders.map((item) => (
      item.id === order.id
        ? { ...item, status: 'delivered', statusLabel: 'تم التسليم' }
        : item
    ));
    setOrders(updated);
    localStorage.setItem('_67_orders', JSON.stringify(updated));

    const adminLogs = JSON.parse(localStorage.getItem('_67_admin_logs') || '[]');
    adminLogs.unshift({
      id: `LOG-${Math.floor(1000 + Math.random() * 9000)}`,
      text: `أكد العميل استلام الطلب #${order.id.replace('#', '').replace('ORD-', '')} بنجاح وتم إنجاز المعاملة المالية`,
      time: 'الآن',
      type: 'order_completed',
    });
    localStorage.setItem('_67_admin_logs', JSON.stringify(adminLogs));
  };

  return (
    <div className="b01o-page" dir="rtl">
      <section className="b01o-hero">
        <HomeStoreHeader />
        <div className="b01o-hero-overlay" />
        <div className="b01o-hero-shell">
          <div className="b01o-hero-copy">
            <span className="b01o-kicker">حسابك في 67</span>
            <h1>طلباتي<span>.</span></h1>
            <p>تابع حالة طلباتك وتفاصيل الشحن والاستلام من مكان واحد بسهولة.</p>
          </div>
          <div className="b01o-order-count" aria-label={`${orders.length} طلبات`}>
            <strong>{orders.length}</strong>
            <span>طلبات</span>
          </div>
        </div>
      </section>

      <main className="b01o-main">
        <div className="b01o-shell">
          <div className="b01o-tabs" role="tablist" aria-label="حالات الطلبات">
            {TABS.map((tab) => (
              <button
                type="button"
                role="tab"
                aria-selected={activeTab === tab.id}
                key={tab.id}
                className={activeTab === tab.id ? 'is-active' : ''}
                onClick={() => setActiveTab(tab.id)}
              >
                <span>{tab.label}</span>
                <b>{tabCounts[tab.id] || 0}</b>
              </button>
            ))}
          </div>

          {filteredOrders.length === 0 ? (
            <div className="b01o-empty">
              <Package size={44} strokeWidth={1.4} />
              <h2>لا توجد طلبات في هذا القسم</h2>
              <p>غيّر حالة العرض من الأعلى لعرض باقي طلباتك.</p>
            </div>
          ) : (
            <div className="b01o-list">
              {filteredOrders.map((order) => {
                const status = STATUS_META[order.status] || { label: order.statusLabel || 'غير معروف', className: '' };
                return (
                  <article className={`b01o-order-card ${status.className}`} key={order.id}>
                    <div className="b01o-order-main">
                      <div className="b01o-store-line">
                        <Store size={15} />
                        <span>{order.storeName}</span>
                      </div>
                      <h2>{order.itemName}</h2>
                      <div className="b01o-order-meta">
                        <span>تاريخ الطلب: <b>{order.date}</b></span>
                        <span>رقم الطلب: <b>{order.id}</b></span>
                      </div>
                    </div>

                    <div className="b01o-order-side">
                      <span className={`b01o-status ${status.className}`}>{status.label}<i /></span>
                      <small>الإجمالي</small>
                      <strong>{order.total.toLocaleString('ar-SA')} <em>ر.س</em></strong>
                    </div>

                    <div className="b01o-order-actions">
                      {order.status === 'shipped' && (
                        <button type="button" className="b01o-confirm" onClick={() => confirmDelivery(order)}>
                          <CheckCircle size={15} />
                          تأكيد الاستلام
                        </button>
                      )}
                      <button type="button" className="b01o-details">التفاصيل</button>
                    </div>
                  </article>
                );
              })}
            </div>
          )}
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default MyOrdersPage;
