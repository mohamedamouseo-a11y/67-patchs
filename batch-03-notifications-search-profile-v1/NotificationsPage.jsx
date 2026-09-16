import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Bell,
  CheckCircle2,
  ChevronLeft,
  Info,
  MessageCircle,
  Settings,
  Tag,
  Trash2,
  Truck,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './NotificationsPage.css';

const INITIAL_NOTIFS = [
  { id: '1', title: 'انخفاض في السعر!', message: 'صدام تويوتا كامري 2020 الذي تبحث عنه انخفض سعره بنسبة 15%', time: 'منذ 10 دقائق', type: 'offer', category: 'offers', read: false },
  { id: '2', title: 'تحديث الشحنة', message: 'شحنتك رقم #ORD-2091 في الطريق إليك مع سمسا', time: 'منذ ساعتين', type: 'shipping', category: 'orders', read: false },
  { id: '3', title: 'رد من المتجر', message: 'متجر الريادة: "القطعة متوفرة حالياً ويمكن شحنها غداً"', time: 'منذ 5 ساعات', type: 'message', category: 'messages', read: true },
  { id: '4', title: 'تحديث حالة تذكرة', message: 'تم الرد على تذكرتك رقم #TCK-990 من قبل فريق الدعم', time: 'أمس', type: 'support', category: 'support', read: true },
  { id: '5', title: 'تحديث النظام', message: 'تم تحديث سياسة الخصوصية وشروط الاستخدام', time: 'منذ يومين', type: 'system', category: 'system', read: true },
];

const TABS = [
  { id: 'all', label: 'الكل' },
  { id: 'orders', label: 'الطلبات' },
  { id: 'offers', label: 'العروض' },
  { id: 'messages', label: 'الرسائل' },
  { id: 'support', label: 'خدمة العملاء' },
  { id: 'system', label: 'النظام' },
];

const NotificationsPage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('all');
  const [notifications, setNotifications] = useState(INITIAL_NOTIFS);

  const filteredNotifs = activeTab === 'all'
    ? notifications
    : notifications.filter((notification) => notification.category === activeTab);

  const unreadCount = notifications.filter((notification) => !notification.read).length;

  const getIcon = (type) => {
    switch (type) {
      case 'offer': return <Tag size={18} />;
      case 'shipping': return <Truck size={18} />;
      case 'message': return <MessageCircle size={18} />;
      case 'support': return <Info size={18} />;
      case 'system': return <Settings size={18} />;
      default: return <Bell size={18} />;
    }
  };

  const markAllAsRead = () => {
    setNotifications((current) => current.map((notification) => ({ ...notification, read: true })));
  };

  const deleteAll = () => {
    if (!confirm('هل أنت متأكد من حذف جميع الإشعارات؟')) return;
    setNotifications((current) => (
      activeTab === 'all'
        ? []
        : current.filter((notification) => notification.category !== activeTab)
    ));
  };

  const deleteNotif = (event, id) => {
    event.stopPropagation();
    setNotifications((current) => current.filter((notification) => notification.id !== id));
  };

  const markAsRead = (event, id) => {
    event.stopPropagation();
    setNotifications((current) => current.map((notification) => (
      notification.id === id ? { ...notification, read: true } : notification
    )));
  };

  const handleNotifClick = (notification) => {
    if (!notification.read) {
      setNotifications((current) => current.map((item) => (
        item.id === notification.id ? { ...item, read: true } : item
      )));
    }

    switch (notification.category) {
      case 'orders': navigate('/orders'); break;
      case 'support': navigate('/my-tickets'); break;
      case 'messages': navigate('/chat/1'); break;
      case 'offers': navigate('/offers'); break;
      default: break;
    }
  };

  return (
    <div className="n67-page" dir="rtl">
      <section className="n67-hero">
        <HomeStoreHeader />
        <div className="n67-hero-overlay" aria-hidden="true" />
        <div className="n67-hero-shell">
          <div className="n67-hero-copy">
            <div className="n67-breadcrumb">
              <button type="button" onClick={() => navigate('/store')}>الرئيسية</button>
              <span>/</span>
              <strong>الإشعارات</strong>
            </div>
            <span className="n67-kicker">مركز تنبيهات 67</span>
            <h1>الإشعارات<span>.</span></h1>
            <p>تابع تنبيهات الطلبات والعروض والرسائل وخدمة العملاء والنظام.</p>
          </div>

          <div className="n67-hero-card">
            <div className="n67-hero-bell"><Bell size={24} /></div>
            <strong>{unreadCount}</strong>
            <span>إشعارات غير مقروءة</span>
          </div>
        </div>
      </section>

      <main className="n67-main">
        <div className="n67-shell">
          <section className="n67-panel">
            <header className="n67-panel-head">
              <div>
                <span className="n67-kicker">آخر التحديثات</span>
                <div className="n67-title-row">
                  <h2>الإشعارات</h2>
                  <span>{notifications.length}</span>
                </div>
                <p>لديك {unreadCount} إشعار غير مقروء من إجمالي {notifications.length}.</p>
              </div>

              <div className="n67-global-actions">
                <button type="button" onClick={markAllAsRead}>
                  <CheckCircle2 size={15} />
                  تحديد الكل كمقروء
                </button>
                <button type="button" className="is-danger" onClick={deleteAll}>
                  <Trash2 size={15} />
                  حذف {activeTab === 'all' ? 'الكل' : 'هذه القائمة'}
                </button>
              </div>
            </header>

            <div className="n67-tabs" role="tablist" aria-label="تصنيفات الإشعارات">
              {TABS.map((tab) => {
                const tabCount = tab.id === 'all'
                  ? notifications.length
                  : notifications.filter((item) => item.category === tab.id).length;

                return (
                  <button
                    type="button"
                    role="tab"
                    aria-selected={activeTab === tab.id}
                    className={activeTab === tab.id ? 'is-active' : ''}
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                  >
                    <span>{tab.label}</span>
                    <b>{tabCount}</b>
                  </button>
                );
              })}
            </div>

            {filteredNotifs.length === 0 ? (
              <div className="n67-empty">
                <Bell size={40} strokeWidth={1.4} />
                <h3>لا توجد إشعارات</h3>
                <p>لم تتلقَ أي إشعارات في هذا القسم.</p>
              </div>
            ) : (
              <div className="n67-list">
                {filteredNotifs.map((notification) => (
                  <article
                    className={`n67-item ${notification.read ? 'is-read' : 'is-unread'}`}
                    key={notification.id}
                    onClick={() => handleNotifClick(notification)}
                  >
                    <div className={`n67-item-icon n67-item-icon--${notification.type}`}>
                      {getIcon(notification.type)}
                    </div>

                    <div className="n67-item-content">
                      <div className="n67-item-title">
                        <h3>{notification.title}</h3>
                        {!notification.read && <span aria-label="غير مقروء" />}
                      </div>
                      <p>{notification.message}</p>
                      <div className="n67-item-inline-actions">
                        <button type="button" className="is-danger" onClick={(event) => deleteNotif(event, notification.id)}>
                          حذف
                        </button>
                        {!notification.read && (
                          <button type="button" onClick={(event) => markAsRead(event, notification.id)}>
                            تعيين كمقروء
                          </button>
                        )}
                      </div>
                    </div>

                    <div className="n67-item-meta">
                      <span>{notification.time}</span>
                      <span className="n67-open"><ChevronLeft size={15} /></span>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default NotificationsPage;
