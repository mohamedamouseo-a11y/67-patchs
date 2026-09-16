import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Bell,
  Car,
  ChevronLeft,
  CreditCard,
  HeadphonesIcon,
  Heart,
  LogOut,
  MapPin,
  Package,
  Pencil,
  Settings,
  Star,
  Tag,
  Ticket,
  Users,
  Wallet,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './CustomerProfilePage.css';

const CustomerProfilePage = () => {
  const navigate = useNavigate();
  const [isEditing, setIsEditing] = useState(false);
  const [userInfo, setUserInfo] = useState({ name: 'عبدالله أحمد', phone: '050 123 4567', city: 'الرياض' });
  const [tempInfo, setTempInfo] = useState({ ...userInfo });

  const handleSave = () => {
    setUserInfo({ ...tempInfo });
    setIsEditing(false);
  };

  const menuItems = [
    { id: 'orders', label: 'طلباتي', icon: Package, path: '/orders', hint: 'تابع حالة طلباتك' },
    { id: 'wallet', label: 'المحفظة الإلكترونية', icon: Wallet, path: '/wallet', hint: 'الرصيد والمعاملات' },
    { id: 'favorites', label: 'المفضلة', icon: Heart, path: '/favorites', hint: 'القطع المحفوظة' },
    { id: 'addresses', label: 'عناويني', icon: MapPin, path: '/addresses', hint: 'عناوين التوصيل' },
    { id: 'payment', label: 'وسائل الدفع', icon: CreditCard, path: '/payment-methods', hint: 'إدارة طرق الدفع' },
    { id: 'notifications', label: 'الإشعارات', icon: Bell, path: '/notifications', hint: 'تنبيهات حسابك' },
    { id: 'community', label: 'مجتمع 67', icon: Users, path: '/community', hint: 'المجتمع والخبرات' },
    { id: 'coupons', label: 'أكواد الخصم', icon: Tag, path: '/discount-codes', hint: 'عروض وخصومات' },
    { id: 'loyalty', label: 'نقاط الولاء', icon: Star, path: '/loyalty', hint: 'نقاطك ومكافآتك' },
  ];

  const supportItems = [
    { id: 'support', label: 'الدعم الفني والشكاوى', icon: HeadphonesIcon, path: '/support' },
    { id: 'my-tickets', label: 'تذاكري السابقة', icon: Ticket, path: '/my-tickets' },
    { id: 'policy', label: 'سياسة الاسترجاع', icon: Tag, path: '/return-policy' },
    { id: 'settings', label: 'الإعدادات', icon: Settings, path: '/settings' },
  ];

  const logout = () => {
    localStorage.removeItem('customerSession');
    navigate('/');
  };

  return (
    <div className="p67-page" dir="rtl">
      <section className="p67-hero">
        <HomeStoreHeader />
        <div className="p67-hero-overlay" aria-hidden="true" />
        <div className="p67-hero-shell">
          <div className="p67-hero-copy">
            <div className="p67-breadcrumb">
              <button type="button" onClick={() => navigate('/store')}>67</button>
              <span>/</span>
              <strong>حسابي</strong>
            </div>
            <span className="p67-kicker">حسابك في 67</span>
            <h1>مرحباً، <em>{userInfo.name.split(' ')[0]}</em><span>.</span></h1>
            <p>تحكم في بيانات حسابك، سياراتك، طلباتك وكل خدماتك داخل 67 من مكان واحد.</p>
          </div>

          <div className="p67-hero-avatar">
            <strong>{userInfo.name.charAt(0)}</strong>
            <span><i /> حساب نشط</span>
          </div>
        </div>
      </section>

      <main className="p67-main">
        <div className="p67-shell p67-layout">
          <aside className="p67-sidebar">
            <section className="p67-user-card">
              <span className="p67-side-kicker">حسابك</span>
              <div className="p67-side-avatar">{userInfo.name.charAt(0)}</div>
              <h2>{userInfo.name}</h2>
              <p dir="ltr">{userInfo.phone}</p>

              <div className="p67-quick-links">
                <button type="button" onClick={() => navigate('/orders')}>طلباتي <ChevronLeft size={15} /></button>
                <button type="button" onClick={() => navigate('/cart')}>السلة <ChevronLeft size={15} /></button>
              </div>
            </section>

            <section className="p67-support-card">
              <span className="p67-side-kicker">المساعدة</span>
              <h3>تحتاج مساعدة؟</h3>
              <p>الوصول السريع للدعم والإعدادات.</p>
              {supportItems.map((item) => {
                const Icon = item.icon;
                return (
                  <button type="button" key={item.id} onClick={() => navigate(item.path)}>
                    <Icon size={16} />
                    <span>{item.label}</span>
                    <ChevronLeft size={14} />
                  </button>
                );
              })}
              <button type="button" className="is-logout" onClick={logout}>
                <LogOut size={16} />
                <span>تسجيل الخروج</span>
              </button>
            </section>
          </aside>

          <div className="p67-content">
            <section className="p67-card p67-profile-card">
              <header>
                <div>
                  <span className="p67-kicker">بيانات الحساب</span>
                  <h2>معلوماتك الشخصية</h2>
                </div>
                {isEditing ? (
                  <button type="button" className="p67-edit-btn is-save" onClick={handleSave}>حفظ</button>
                ) : (
                  <button type="button" className="p67-edit-btn" onClick={() => {
                    setTempInfo({ ...userInfo });
                    setIsEditing(true);
                  }}>
                    <Pencil size={14} />
                    تعديل
                  </button>
                )}
              </header>

              {isEditing ? (
                <div className="p67-info-grid">
                  <label>
                    <span>الاسم</span>
                    <input value={tempInfo.name} onChange={(event) => setTempInfo({ ...tempInfo, name: event.target.value })} />
                  </label>
                  <label>
                    <span>رقم الجوال</span>
                    <input dir="ltr" value={tempInfo.phone} onChange={(event) => setTempInfo({ ...tempInfo, phone: event.target.value })} />
                  </label>
                  <label>
                    <span>المدينة</span>
                    <input value={tempInfo.city} onChange={(event) => setTempInfo({ ...tempInfo, city: event.target.value })} />
                  </label>
                </div>
              ) : (
                <div className="p67-info-grid">
                  <div><span>الاسم</span><strong>{userInfo.name}</strong></div>
                  <div><span>رقم الجوال</span><strong dir="ltr">{userInfo.phone}</strong></div>
                  <div><span>المدينة</span><strong>{userInfo.city}</strong></div>
                </div>
              )}
            </section>

            <section className="p67-card p67-garage">
              <header>
                <div>
                  <span className="p67-kicker">سياراتي</span>
                  <h2>كراجي</h2>
                </div>
                <button
                  type="button"
                  className="p67-gold-btn"
                  onClick={() => {
                    const car = prompt('أدخل ماركة السيارة (مثال: تويوتا كامري 2020):');
                    if (car) alert(`تمت إضافة ${car} بنجاح إلى كراجك!`);
                  }}
                >
                  + إضافة سيارة
                </button>
              </header>

              <div className="p67-car-row">
                <div className="p67-car-icon"><Car size={23} /></div>
                <div><strong>تويوتا كامري</strong><span>2020</span></div>
                <button type="button">حذف</button>
              </div>
            </section>

            <section className="p67-card p67-services">
              <header>
                <div>
                  <span className="p67-kicker">خدمات حسابك</span>
                  <h2>إدارة حسابك</h2>
                </div>
              </header>

              <div className="p67-service-grid">
                {menuItems.map((item) => {
                  const Icon = item.icon;
                  return (
                    <button type="button" key={item.id} onClick={() => navigate(item.path)}>
                      <span className="p67-service-icon"><Icon size={19} /></span>
                      <span>
                        <strong>{item.label}</strong>
                        <small>{item.hint}</small>
                      </span>
                      <ChevronLeft size={15} />
                    </button>
                  );
                })}
              </div>
            </section>
          </div>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default CustomerProfilePage;
