import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';
import { 
  ArrowRight, Users, Store, DollarSign, AlertOctagon, TrendingUp, 
  BarChart2, Lightbulb, MessageSquare, Bell, FileText, CheckCircle, 
  XCircle, ShieldAlert, CreditCard, Layers, Eye, Search, RefreshCw, Activity,
  Server, ShieldCheck, HeartPulse, Sparkles, Percent, ShoppingBag,
  UserCheck, AlertCircle, Award, Star, Settings, LogOut, Key, Camera, Link, Github, Loader2, LockKeyhole, CarFront, CalendarDays, ChevronDown, Download
} from 'lucide-react';
import Logo67 from '../components/Logo67';
import officialLogo from '../assets/sixty-seven-official-logo.png';
import heroHighResV295 from '../assets/admin-v29.4-hero-highres.jpg';
import ParticlesBackground from '../components/ParticlesBackground';
import GitHubModule from './GitHubModule';
import './AdminDashboard.css';
import './AdminDashboard.v42.css';
async function adminApi(path, options = {}) {
  const response = await fetch(path, {
    credentials: 'same-origin',
    ...options,
    headers: {
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers || {}),
    },
  });
  if (response.status === 204) return null;
  let data = null;
  try { data = await response.json(); } catch {}
  if (!response.ok) {
    const error = new Error(data?.error || `Request failed (${response.status})`);
    error.status = response.status;
    error.code = data?.code;
    throw error;
  }
  return data;
}

// Highly Detailed Mock Sellers Data
const initialSellers = [
  { id: 'SEL-4412', name: 'تشليح القمة', email: 'qemma@mail.com', date: '2026-07-10 10:15', status: 'تحت المراجعة', completedOrders: 142, rating: 4.8, reviewsCount: 34, strength: 'قوي' },
  { id: 'SEL-3081', name: 'قطع الأمانة', email: 'amanah@mail.com', date: '2026-07-08 14:30', status: 'نشط', completedOrders: 89, rating: 4.2, reviewsCount: 19, strength: 'متوسط' },
  { id: 'SEL-1290', name: 'تشليح الوفاء', email: 'wafa@mail.com', date: '2026-07-05 09:00', status: 'نشط', completedOrders: 5, rating: 3.5, reviewsCount: 4, strength: 'ضعيف' },
  { id: 'SEL-7721', name: 'قطع الجزيرة', email: 'jazeera@mail.com', date: '2026-07-12 18:20', status: 'تحت المراجعة', completedOrders: 0, rating: 0.0, reviewsCount: 0, strength: 'جديد' }
];

// Highly Detailed Mock Customers Data
const initialCustomers = [
  { id: 'USR-8902', name: 'أحمد خالد', email: 'ahmed@mail.com', date: '2026-07-15 22:30', totalOrders: 12, totalSpent: 5400, status: 'نشط' },
  { id: 'USR-7612', name: 'محمد العتيبي', email: 'otaibi@mail.com', date: '2026-07-14 11:15', totalOrders: 8, totalSpent: 3120, status: 'نشط' },
  { id: 'USR-3309', name: 'خالد الدوسري', email: 'khaled@mail.com', date: '2026-07-15 08:45', totalOrders: 1, totalSpent: 450, status: 'نشط' },
  { id: 'USR-2115', name: 'عبدالله السديري', email: 'sudairy@mail.com', date: '2026-07-13 19:10', totalOrders: 24, totalSpent: 18450, status: 'نشط' }
];

const initialPayments = [
  { id: 'TXN-9021', buyer: 'سارة العتيبي', seller: 'تشليح القمة', amount: 450, method: 'مدى', date: 'منذ دقيقة', status: 'مكتمل' },
  { id: 'TXN-9022', buyer: 'أحمد الشمراني', seller: 'قطع الأمانة', amount: 2400, method: 'فيزا', date: 'منذ 5 دقائق', status: 'مكتمل' },
  { id: 'TXN-9023', buyer: 'عبدالرحمن خالد', seller: 'تشليح الوفاء', amount: 320, method: 'حساب بنكي', date: 'منذ 15 دقيقة', status: 'معلق' },
  { id: 'TXN-9024', buyer: 'محمد الحربي', seller: 'قطع الجزيرة', amount: 180, method: 'مدى', date: 'منذ 30 دقيقة', status: 'مكتمل' },
];

const initialDocuments = [
  { id: 'DOC-501', store: 'تشليح القمة', type: 'السجل التجاري', file: 'cr_qemma_2026.pdf', status: 'معلق', date: 'منذ 10 دقائق' },
  { id: 'DOC-502', store: 'قطع الأمانة', type: 'رخصة التشليح', file: 'scrapyard_license_77.jpg', status: 'مقبول', date: 'منذ يوم' },
  { id: 'DOC-503', store: 'تشليح الوفاء', type: 'الهوية الوطنية للمالك', file: 'national_id_owner.jpg', status: 'مرفوض', date: 'منذ يومين' },
];

const toDateInputValue = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const formatExecutiveDate = (date) => new Intl.DateTimeFormat('ar-SA-u-ca-gregory', {
  day: '2-digit', month: 'short', year: 'numeric'
}).format(date);

const formatExecutiveFieldDate = (value) => {
  if (!value) return 'اختر التاريخ';
  const date = new Date(`${value}T12:00:00`);
  if (Number.isNaN(date.getTime())) return 'اختر التاريخ';
  return new Intl.DateTimeFormat('ar-SA-u-ca-gregory', {
    day: 'numeric', month: 'long', year: 'numeric'
  }).format(date);
};

const AdminDashboard = () => {
  const navigate = useNavigate();

  // V21 browser identity — admin tab title follows the executive dashboard.
  useEffect(() => {
    const previousTitle = document.title;
    document.title = '67 | لوحة الإدارة';
    return () => { document.title = previousTitle; };
  }, []);
  const [activeTab, setActiveTab] = useState('overview');
  const [logoTheme, setLogoTheme] = useState(localStorage.getItem('logoTheme') || 'car_concept');
  
  // Production Superadmin session — verified server-side only.
  const [session, setSession] = useState({ loading: true, authenticated: false, configured: true });
  const isLoggedIn = session.authenticated;
  const [usernameInput, setUsernameInput] = useState('');
  const [passwordInput, setPasswordInput] = useState('');
  const [loginError, setLoginError] = useState('');
  const [loginBusy, setLoginBusy] = useState(false);

  // Sensitive profile fields are loaded from the encrypted server-side store.
  const [adminAvatar, setAdminAvatar] = useState('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150');
  const [bankName, setBankName] = useState('');
  const [bankIBAN, setBankIBAN] = useState('');
  const [accountHolder, setAccountHolder] = useState('');
  const [profileBusy, setProfileBusy] = useState(false);

  const [payments, setPayments] = useState(initialPayments);
  const [sellers, setSellers] = useState(initialSellers);
  const [customers, setCustomers] = useState(initialCustomers);
  const [documents, setDocuments] = useState(initialDocuments);
  
  const [serverResponseTime, setServerResponseTime] = useState(124);
  const [systemLoad, setSystemLoad] = useState(14);
  const [totalSales, setTotalSales] = useState(452000);
  const [paymentCount, setPaymentCount] = useState(14892);

  const [liveNotifications, setLiveNotifications] = useState([]);
  const [txQuery, setTxQuery] = useState('');

  // V19 — one executive analytics period shared by KPI + revenue views.
  const initialRangeEnd = new Date();
  const initialRangeStart = new Date();
  initialRangeStart.setDate(initialRangeEnd.getDate() - 29);
  const [datePreset, setDatePreset] = useState('30d');
  const [datePopoverOpen, setDatePopoverOpen] = useState(false);
  const [customFrom, setCustomFrom] = useState(toDateInputValue(initialRangeStart));
  const [customTo, setCustomTo] = useState(toDateInputValue(initialRangeEnd));
  const [dateError, setDateError] = useState('');
  const [heroImageReady, setHeroImageReady] = useState(false);

  useEffect(() => {
    if (!datePopoverOpen) return;
    const positionExternalDatePanel = () => {
      const hero = document.querySelector('.ov-header');
      const shell = document.querySelector('.executive-date-shell');
      const root = document.documentElement;
      if (!hero || !shell) return;
      const heroRect = hero.getBoundingClientRect();
      const shellRect = shell.getBoundingClientRect();
      const panelWidth = window.innerWidth <= 1360 ? 440 : 500;
      const sidebarReserve = window.innerWidth >= 900 ? 300 : 16;
      const preferredLeft = Math.max(16, Math.min(shellRect.left, window.innerWidth - sidebarReserve - panelWidth - 16));
      const top = Math.round(heroRect.bottom + 12);
      root.style.setProperty('--v296-date-panel-top', `${top}px`);
      root.style.setProperty('--v296-date-panel-left', `${Math.round(preferredLeft)}px`);
    };
    positionExternalDatePanel();
    requestAnimationFrame(positionExternalDatePanel);
    window.addEventListener('resize', positionExternalDatePanel);
    window.addEventListener('scroll', positionExternalDatePanel, { passive: true });
    return () => {
      window.removeEventListener('resize', positionExternalDatePanel);
      window.removeEventListener('scroll', positionExternalDatePanel);
    };
  }, [datePopoverOpen]);

  useEffect(() => {
    let mounted = true;
    const img = new Image();
    img.src = heroHighResV295;
    const markReady = () => { if (mounted) setHeroImageReady(true); };
    if (img.complete && img.naturalWidth >= 2000) markReady();
    else {
      img.onload = markReady;
      img.onerror = markReady;
      if (typeof img.decode === 'function') img.decode().then(markReady).catch(() => {});
    }
    return () => { mounted = false; };
  }, []);

  useEffect(() => {
    const loadLogs = () => {
      const logs = localStorage.getItem('_67_admin_logs');
      if (logs) {
        setLiveNotifications(JSON.parse(logs));
      } else {
        const initial = [
          { id: 1, type: 'registration', text: 'مستخدم جديد أحمد خالد سجل الآن كـ (عميل)', time: 'منذ دقيقتين' },
          { id: 2, type: 'payment', text: 'عملية دفع جديدة بقيمة 450 ر.س لصالح تشليح القمة', time: 'منذ دقيقة' }
        ];
        localStorage.setItem('_67_admin_logs', JSON.stringify(initial));
        setLiveNotifications(initial);
      }
    };
    loadLogs();
    window.addEventListener('storage', loadLogs);
    return () => window.removeEventListener('storage', loadLogs);
  }, []);

  const loadSession = useCallback(async () => {
    try {
      const data = await adminApi('/api/superadmin/session');
      setSession({ loading: false, configured: true, ...data });
      return data;
    } catch (error) {
      setSession({ loading: false, authenticated: false, configured: error.status !== 503 });
      return null;
    }
  }, []);

  useEffect(() => { loadSession(); }, [loadSession]);

  useEffect(() => {
    if (!session.authenticated) return;
    let active = true;
    adminApi('/api/superadmin/profile')
      .then((data) => {
        if (!active) return;
        const profile = data?.profile || {};
        setBankName(profile.bankName || '');
        setBankIBAN(profile.bankIBAN || '');
        setAccountHolder(profile.accountHolder || '');
        if (profile.adminAvatar) setAdminAvatar(profile.adminAvatar);
      })
      .catch((error) => { if (error.status === 401) loadSession(); });
    return () => { active = false; };
  }, [session.authenticated, loadSession]);

  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    setLoginBusy(true);
    setLoginError('');
    try {
      const data = await adminApi('/api/superadmin/login', {
        method: 'POST',
        body: JSON.stringify({ username: usernameInput, password: passwordInput }),
      });
      setSession({ loading: false, configured: true, ...data });
      setUsernameInput('');
      setPasswordInput('');
    } catch (error) {
      setLoginError(error.message || 'تعذر تسجيل الدخول.');
    } finally {
      setLoginBusy(false);
    }
  };

  const handleLogout = async () => {
    try {
      await adminApi('/api/superadmin/logout', {
        method: 'POST',
        headers: session.csrfToken ? { 'X-CSRF-Token': session.csrfToken } : {},
      });
    } catch {}
    setSession({ loading: false, authenticated: false, configured: true });
    setUsernameInput('');
    setPasswordInput('');
  };

  const handleSaveSettings = async (e) => {
    e.preventDefault();
    setProfileBusy(true);
    try {
      const data = await adminApi('/api/superadmin/profile', {
        method: 'PUT',
        headers: session.csrfToken ? { 'X-CSRF-Token': session.csrfToken } : {},
        body: JSON.stringify({ bankName, bankIBAN, accountHolder, adminAvatar }),
      });
      const profile = data?.profile || {};
      setBankName(profile.bankName || '');
      setBankIBAN(profile.bankIBAN || '');
      setAccountHolder(profile.accountHolder || '');
      if (profile.adminAvatar) setAdminAvatar(profile.adminAvatar);
      alert('تم حفظ إعدادات الملف الشخصي والحساب البنكي بشكل مشفّر على السيرفر. ✅');
    } catch (error) {
      if (error.status === 401) await loadSession();
      alert(error.message || 'تعذر حفظ الإعدادات.');
    } finally {
      setProfileBusy(false);
    }
  };

  const handleLogoThemeToggle = (newTheme) => {
    localStorage.setItem('logoTheme', newTheme);
    setLogoTheme(newTheme);
    window.dispatchEvent(new Event('storage'));
  };

  // Simulate real-time metrics fluctuation and notifications
  useEffect(() => {
    if (!isLoggedIn) return;
    const interval = setInterval(() => {
      setServerResponseTime(Math.floor(110 + Math.random() * 30));
      setSystemLoad(Math.floor(10 + Math.random() * 12));

      const names = ['خالد الدوسري', 'سلطان المطيري', 'عبدالله السديري', 'فهد العنزي'];
      const stores = ['تشليح القمة', 'قطع الأمانة', 'تشليح الوفاء', 'مستودع الشرق'];
      const methods = ['مدى', 'فيزا', 'Apple Pay', 'فوري'];
      
      const randomName = names[Math.floor(Math.random() * names.length)];
      const randomStore = stores[Math.floor(Math.random() * stores.length)];
      const randomMethod = methods[Math.floor(Math.random() * methods.length)];
      const randomAmount = Math.floor(Math.random() * 2000) + 100;
      
      if (Math.random() > 0.5) {
        const newTxnId = `TXN-${Math.floor(Math.random() * 9000) + 1000}`;
        const newTxn = { id: newTxnId, buyer: randomName, seller: randomStore, amount: randomAmount, method: randomMethod, date: 'الآن', status: 'مكتمل' };
        setPayments(prev => [newTxn, ...prev.slice(0, 7)]);
        setTotalSales(prev => prev + randomAmount);
        setPaymentCount(prev => prev + 1);
        setSellers(prev => prev.map(s => s.name === randomStore ? { ...s, completedOrders: s.completedOrders + 1 } : s));
        
        const newNotify = {
          id: Date.now(),
          type: 'payment',
          text: `عملية دفع جديدة بقيمة ${randomAmount} ر.س من ${randomName} لصالح ${randomStore}`,
          time: 'الآن'
        };
        setLiveNotifications(prev => [newNotify, ...prev.slice(0, 9)]);
      } else {
        const isSeller = Math.random() > 0.5;
        const newUsrId = `${isSeller ? 'SEL' : 'USR'}-${Math.floor(Math.random() * 9000) + 1000}`;
        const timestamp = new Date().toISOString().replace('T', ' ').slice(0, 16);
        
        if (isSeller) {
          const newSel = { id: newUsrId, name: randomName, email: `${newUsrId}@mail.com`, date: timestamp, status: 'تحت المراجعة', completedOrders: 0, rating: 0.0, reviewsCount: 0, strength: 'جديد' };
          setSellers(prev => [newSel, ...prev]);
        } else {
          const newCust = { id: newUsrId, name: randomName, email: `${newUsrId}@mail.com`, date: timestamp, totalOrders: 0, totalSpent: 0, status: 'نشط' };
          setCustomers(prev => [newCust, ...prev]);
        }

        const newNotify = {
          id: Date.now(),
          type: 'registration',
          text: `تسجيل جديد: ${randomName} انضم كـ (${isSeller ? 'تاجر' : 'عميل'})`,
          time: 'الآن'
        };
        setLiveNotifications(prev => [newNotify, ...prev.slice(0, 9)]);
      }
    }, 12000); 

    return () => clearInterval(interval);
  }, [isLoggedIn]);

  const handleApproveDoc = (id) => {
    setDocuments(prev => prev.map(doc => doc.id === id ? { ...doc, status: 'مقبول' } : doc));
  };

  const handleRejectDoc = (id) => {
    setDocuments(prev => prev.map(doc => doc.id === id ? { ...doc, status: 'مرفوض' } : doc));
  };

  const handleApproveSeller = (id) => {
    setSellers(prev => prev.map(sel => sel.id === id ? { ...sel, status: 'نشط' } : sel));
  };

  const applyDatePreset = (preset) => {
    setDatePreset(preset);
    setDateError('');
    setDatePopoverOpen(false);
  };

  const applyCustomDateRange = () => {
    const from = new Date(`${customFrom}T00:00:00`);
    const to = new Date(`${customTo}T23:59:59`);
    if (!customFrom || !customTo || Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
      setDateError('اختر تاريخ بداية ونهاية صالحين.');
      return;
    }
    if (from > to) {
      setDateError('تاريخ البداية يجب أن يسبق تاريخ النهاية.');
      return;
    }
    setDatePreset('custom');
    setDateError('');
    setDatePopoverOpen(false);
  };

  const analyticsRange = (() => {
    let end = new Date();
    end.setHours(23, 59, 59, 999);
    let start = new Date(end);
    let days = 30;

    if (datePreset === 'today') days = 1;
    if (datePreset === '7d') days = 7;
    if (datePreset === '30d') days = 30;

    if (datePreset === 'custom') {
      const customStart = new Date(`${customFrom}T00:00:00`);
      const customEnd = new Date(`${customTo}T23:59:59`);
      if (!Number.isNaN(customStart.getTime()) && !Number.isNaN(customEnd.getTime()) && customStart <= customEnd) {
        start = customStart;
        end = customEnd;
        days = Math.max(1, Math.round((customEnd - customStart) / 86400000) + 1);
      }
    } else {
      start.setDate(end.getDate() - (days - 1));
      start.setHours(0, 0, 0, 0);
    }

    return { start, end, days };
  })();

  const rangeLabel = `${formatExecutiveDate(analyticsRange.start)} — ${formatExecutiveDate(analyticsRange.end)}`;
  const rangeSummaryLabel = datePreset === 'today' ? 'اليوم' : datePreset === '7d' ? 'آخر 7 أيام' : datePreset === '30d' ? 'آخر 30 يوم' : 'فترة مخصصة';
  const customDraftDays = (() => {
    const from = new Date(`${customFrom}T00:00:00`);
    const to = new Date(`${customTo}T23:59:59`);
    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime()) || from > to) return 0;
    return Math.max(1, Math.round((to - from) / 86400000) + 1);
  })();
  const analyticsRatio = Math.min(analyticsRange.days, 30) / 30;
  const analyticsSales = Math.max(0, Math.round(totalSales * analyticsRatio));
  const analyticsPaymentCount = Math.max(0, Math.round(paymentCount * analyticsRatio));
  const periodPlatformRevenue = Math.floor(analyticsSales * 0.01);

  const platformRevenue = Math.floor(totalSales * 0.01);
  const verifiedSellersCount = sellers.filter(s => s.status === 'نشط').length;
  const unverifiedSellersCount = sellers.filter(s => s.status === 'تحت المراجعة').length;

  // V19: period-aware executive revenue trend derived from the current dashboard totals.
  const trendSeries = Array.from({ length: analyticsRange.days }, (_, i) => {
    const base = analyticsSales / Math.max(analyticsRange.days, 1);
    const wave = Math.sin(i / 3.2) * base * 0.09 + Math.cos(i / 6.5) * base * 0.05;
    const revenue = Math.max(0, Math.round(base + wave + (i * base * 0.006)));
    const pointDate = new Date(analyticsRange.start);
    pointDate.setDate(pointDate.getDate() + i);
    return {
      day: i + 1,
      label: new Intl.DateTimeFormat('ar-SA-u-ca-gregory', { day: 'numeric', month: 'short' }).format(pointDate),
      revenue,
      operations: Math.max(0, Math.round(analyticsPaymentCount / Math.max(analyticsRange.days, 1) + ((i % 7) - 3) * 2)),
    };
  });
  const revToday = trendSeries[trendSeries.length - 1]?.revenue || 0;
  const revPrev = trendSeries[0]?.revenue || 1;
  const trendDelta = Math.round(((revToday - revPrev) / revPrev) * 100);
  const pendingReview = sellers.filter(s => s.status === 'تحت المراجعة').length;

  // ==========================================
  // 1. PRODUCTION SUPERADMIN LOGIN SCREEN
  // ==========================================
  if (session.loading) {
    return <div style={{ minHeight: '100vh', display: 'grid', placeItems: 'center', background: '#F8FAFC', color: '#475569', direction: 'rtl', fontFamily: 'Cairo, sans-serif' }}><div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontWeight: 800 }}><Loader2 className="spin" size={26} />جاري التحقق من جلسة Superadmin…</div></div>;
  }

  // ==========================================
  // 1. PREMIUM ADMIN LOGIN SCREEN
  // ==========================================
  if (!isLoggedIn) {
    return (
      <div style={{
        display: 'flex',
        minHeight: '100vh',
        backgroundColor: '#F8FAFC',
        fontFamily: 'Cairo, sans-serif',
        direction: 'rtl',
        position: 'relative',
        overflow: 'hidden'
      }}>
        <ParticlesBackground />
        
        {/* Left Side - Visual Illustration (Clean & Modern) */}
        <div style={{ 
          flex: '1.2', 
          background: 'rgba(30, 41, 59, 0.95)', 
          backdropFilter: 'blur(8px)',
          position: 'relative',
          overflow: 'hidden',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          borderRight: '1px solid rgba(255, 255, 255, 0.08)'
        }}>
          <div style={{ position: 'absolute', width: '100%', height: '100%', background: 'radial-gradient(circle at 50% 50%, rgba(212,175,55,0.08) 0%, transparent 60%)' }}></div>
          
          <div style={{ zIndex: 1, textAlign: 'center', padding: '40px' }}>
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '32px' }}>
              <Logo67 size={160} color="#D4AF37" />
            </div>
            <h2 style={{ color: '#FFFFFF', fontSize: '2.4rem', fontWeight: '900', marginBottom: '15px' }}>منصة الإدارة والتحكم</h2>
            <p style={{ color: '#94A3B8', fontSize: '1.15rem', maxWidth: '450px', margin: '0 auto', lineHeight: '1.8' }}>
              اللوحة الرقابية العليا لمشرفي منصة 67. تتيح لك الرقابة الكاملة على عمليات البيع، التوثيق، والتواصل الفوري في المجتمع.
            </p>
          </div>
        </div>

        {/* Right Side - Login Form */}
        <div style={{ flex: '1', display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '5%', maxWidth: '600px', margin: '0 auto', backgroundColor: 'rgba(255, 255, 255, 0.9)', backdropFilter: 'blur(10px)', zIndex: 10 }}>
          <div style={{ width: '100%', maxWidth: '420px', margin: '0 auto' }}>
            
            <button 
              onClick={() => navigate('/')}
              style={{ background: '#F1F5F9', color: '#475569', border: '1px solid #E2E8F0', padding: '10px', borderRadius: '10px', cursor: 'pointer', marginBottom: '30px' }}
            >
              <ArrowRight size={20} />
            </button>

            <div style={{ marginBottom: '30px' }}>
              <h1 style={{ fontSize: '2rem', color: '#0F172A', fontWeight: '900', marginBottom: '8px' }}>تسجيل دخول المشرف</h1>
              <p style={{ fontSize: '1rem', color: '#64748B' }}>
                الرجاء إدخال بيانات المسؤول الفوقي للوصول إلى لوحة الأداء الرقابية.
              </p>
            </div>

            {loginError && (
              <div style={{
                background: 'rgba(239, 68, 68, 0.1)',
                border: '1px solid rgba(239, 68, 68, 0.25)',
                color: '#EF4444',
                padding: '12px 14px',
                borderRadius: '12px',
                fontSize: '0.85rem',
                width: '100%',
                textAlign: 'center',
                fontWeight: 'bold',
                marginBottom: '20px'
              }}>{loginError}</div>
            )}

            {!session.configured && (
              <div style={{ background: 'rgba(239, 68, 68, 0.08)', border: '1px solid rgba(239, 68, 68, 0.3)', color: '#B91C1C', padding: '12px 14px', borderRadius: '12px', fontSize: '0.82rem', marginBottom: '18px', fontWeight: 800 }}>
                بوابة Superadmin مقفولة Fail-Closed لأن إعدادات الأمان على السيرفر غير مكتملة.
              </div>
            )}

            <form onSubmit={handleLoginSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <label style={{ fontSize: '0.85rem', color: '#334155', fontWeight: 'bold' }}>اسم مستخدم Superadmin</label>
                <input type="text" autoComplete="username" placeholder="اسم المستخدم" value={usernameInput} onChange={(e) => setUsernameInput(e.target.value)} required disabled={!session.configured || loginBusy} style={{ padding: '14px 16px', height: '52px', fontSize: '1.05rem', backgroundColor: '#F8FAFC', border: '1px solid #CBD5E1', color: '#0F172A', borderRadius: '12px', width: '100%', outline: 'none' }} />
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <label style={{ fontSize: '0.85rem', color: '#334155', fontWeight: 'bold' }}>كلمة المرور</label>
                <input type="password" autoComplete="current-password" placeholder="••••••••••••" value={passwordInput} onChange={(e) => setPasswordInput(e.target.value)} required disabled={!session.configured || loginBusy} style={{ padding: '14px 16px', height: '52px', fontSize: '1.05rem', backgroundColor: '#F8FAFC', border: '1px solid #CBD5E1', color: '#0F172A', borderRadius: '12px', width: '100%', outline: 'none' }} />
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#64748B', fontSize: '0.78rem' }}><LockKeyhole size={15} color="#D4AF37" />المصادقة تتم على السيرفر؛ لا توجد كلمة مرور أو كود افتراضي داخل الواجهة.</div>
              <button type="submit" disabled={!session.configured || loginBusy} style={{ background: 'linear-gradient(135deg, #D4AF37 0%, #B8962C 100%)', color: '#000000', fontWeight: '800', width: '100%', padding: '14px', borderRadius: '12px', border: 'none', cursor: (!session.configured || loginBusy) ? 'not-allowed' : 'pointer', opacity: (!session.configured || loginBusy) ? 0.55 : 1, fontSize: '1.05rem', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
                {loginBusy ? <Loader2 className="spin" size={18} /> : <Key size={18} />} دخول آمن
              </button>
            </form>
          </div>
        </div>
      </div>
    );
  }

  // ==========================================
  // LOGGED IN SUPER ADMIN DASHBOARD
  // ==========================================
  return (
    <div className="admin-dashboard admin-exec min-h-screen" style={{ direction: 'rtl', fontFamily: 'Cairo, sans-serif', display: 'flex', backgroundColor: 'transparent', position: 'relative' }}>
      {/* Right Sidebar */}
      <aside className="admin-sidebar" style={{
        width: '264px',
        backgroundColor: '#090d12',
        borderLeft: '1px solid rgba(194,139,44,0.12)',
        position: 'fixed',
        top: 0,
        right: 0,
        bottom: 0,
        zIndex: 100,
        padding: '20px 16px',
        display: 'flex',
        flexDirection: 'column',
        gap: '8px',
        overflowY: 'auto'
      }}>
        {/* Header Block — identity + online status */}
        <div className="admin-sidebar__brand">
          <button className="back-btn" onClick={() => navigate('/')} style={{ position: 'absolute', top: '12px', left: '12px', background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.10)', padding: '5px', borderRadius: '6px', cursor: 'pointer', display: 'flex', alignItems: 'center', color: '#9c958e', zIndex: 2 }}>
            <ArrowRight size={15} />
          </button>
          <img src={officialLogo} alt="Six Seven" className="admin-sidebar__official-logo" />
          <div className="admin-sidebar__brand-text">
            <h2>الإدارة الفوقية</h2>
            <span><span className="neon-pulse-green" /> متصل وقيد المراقبة</span>
          </div>
        </div>

        {/* Navigation — grouped */}
        <div className="admin-sidebar__nav-group">
          <div className="admin-sidebar__group-label">نظرة عامة</div>
          <button className={`admin-sidebar-button ${activeTab === 'overview' ? 'active' : ''}`} onClick={() => setActiveTab('overview')}>
            <Activity className="sb-ico" size={18} />
            <span>لوحة الأداء والاستقرار</span>
          </button>
        </div>

        <div className="admin-sidebar__nav-group">
          <div className="admin-sidebar__group-label">الإدارة</div>
          <button className={`admin-sidebar-button ${activeTab === 'users' ? 'active' : ''}`} onClick={() => setActiveTab('users')}>
            <Users className="sb-ico" size={18} />
            <span>سجل العملاء والتجار</span>
          </button>
          <button className={`admin-sidebar-button ${activeTab === 'documents' ? 'active' : ''}`} onClick={() => setActiveTab('documents')}>
            <FileText className="sb-ico" size={18} />
            <span>السجلات والتوثيق</span>
          </button>
          <button className={`admin-sidebar-button ${activeTab === 'community' ? 'active' : ''}`} onClick={() => setActiveTab('community')}>
            <MessageSquare className="sb-ico" size={18} />
            <span>إدارة منشورات المجتمع</span>
          </button>
        </div>

        <div className="admin-sidebar__nav-group">
          <div className="admin-sidebar__group-label">المراقبة</div>
          <button className={`admin-sidebar-button ${activeTab === 'transactions' ? 'active' : ''}`} onClick={() => setActiveTab('transactions')}>
            <CreditCard className="sb-ico" size={18} />
            <span>مراقبة العمليات والصفقات</span>
          </button>
          <button className={`admin-sidebar-button ${activeTab === 'notifications' ? 'active' : ''}`} onClick={() => setActiveTab('notifications')}>
            <Bell className="sb-ico" size={18} />
            <span>إشعارات الحركة المباشرة</span>
          </button>
        </div>

        <div className="admin-sidebar__nav-group">
          <div className="admin-sidebar__group-label">النظام</div>
          <button className={`admin-sidebar-button ${activeTab === 'github' ? 'active' : ''}`} onClick={() => setActiveTab('github')}>
            <Github className="sb-ico" size={18} />
            <span>GitHub Module</span>
          </button>
          <button className={`admin-sidebar-button ${activeTab === 'settings' ? 'active' : ''}`} onClick={() => setActiveTab('settings')}>
            <Settings className="sb-ico" size={18} />
            <span>إعدادات حسابي وأرباحي</span>
          </button>
        </div>

        <div className="ref-v36-sidebar-promo v39-sidebar-promo" aria-hidden="true">
          <Award size={20} />
          <strong>تميّز في كل خطوة</strong>
          <span>معًا نحو مستقبل أكثر تميزًا</span>
        </div>

        {/* Bottom utility — logout only (logo switcher moved to Settings) */}
        <div className="admin-sidebar__footer">
          <div className="admin-sidebar__identity ref-v36-admin v39-sidebar-admin">
              <div className="admin-sidebar__identity-avatar">SA</div>
              <div className="admin-sidebar__identity-info">
                <strong>Super Admin</strong>
                <small>مشرف النظام</small>
              </div>
            </div>
            <button className="admin-sidebar-button admin-sidebar-button--logout" onClick={handleLogout}>
            <LogOut className="sb-ico" size={18} />
            <span>تسجيل الخروج للمشرف</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div style={{ flex: 1, marginRight: '200px', padding: '0 8px 14px 14px', minHeight: '100vh', overflowY: 'visible' }}>
        
        {/* Tab Content: OVERVIEW — V38 exact user reference rebuild */}
        {activeTab === 'overview' && (
          <div className="v38-dashboard v39-dashboard v40-dashboard v41-dashboard animate-fadeIn">

            <section className="v38-hero" style={{ '--v38-hero': `url(${heroHighResV295})` }}>
              <div className="v38-hero-tools">
                <span className="v38-admin-mini v39-hero-greeting">
                  <span className="v38-admin-mini__avatar"><Users size={13} /></span>
                  <span><b>مرحبًا بك مجددًا</b><small>Super Admin</small></span>
                </span>
                <span className="v38-tool-dot"><Search size={12} /></span>
                <span className="v38-tool-dot"><Bell size={12} /></span>
                <span className="v38-tool-dot"><Settings size={12} /></span>
              </div>

              <div className="v38-hero-copy-left">
                <h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>
                <p>منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</p>
              </div>

              <div className="v38-hero-copy-right v39-hero-right-copy">
                <span>سرعة أكبر</span>
                <strong>فرص أوسع</strong>
                <small>DRIVE A BRIGHTER TOMORROW</small>
              </div>

              <div className="v38-datebar">
                <button type="button" className="v38-date-display" onClick={() => { setDateError(''); setDatePopoverOpen((open) => !open); }} aria-expanded={datePopoverOpen}>
                  <CalendarDays size={13} />
                  <span><small>الفترة المحددة</small><strong>{rangeLabel}</strong></span>
                  <ChevronDown size={12} />
                </button>
                <div className="v38-date-presets">
                  <button type="button" data-v40-preset="today" aria-pressed={datePreset === 'today'} className={datePreset === 'today' ? 'active' : ''} onClick={() => applyDatePreset('today')}>اليوم</button>
                  <button type="button" data-v40-preset="7d" aria-pressed={datePreset === '7d'} className={datePreset === '7d' ? 'active' : ''} onClick={() => applyDatePreset('7d')}>الأسبوع</button>
                  <button type="button" data-v40-preset="30d" aria-pressed={datePreset === '30d'} className={datePreset === '30d' ? 'active' : ''} onClick={() => applyDatePreset('30d')}>آخر 30 يوم</button>
                  <button type="button" data-v40-preset="custom" aria-pressed={datePreset === 'custom'} className={datePreset === 'custom' ? 'active' : ''} onClick={() => { setDateError(''); setDatePopoverOpen(true); }}>مخصص</button>
                </div>
                <div className="v38-date-actions">
                  <button type="button" title="تحديث" onClick={() => window.location.reload()}><RefreshCw size={12} /></button>
                  <button type="button" title="تصدير" onClick={() => window.print()}><Download size={12} /></button>
                </div>
              </div>
              <span className="v38-hero-redline" />
            </section>

            {datePopoverOpen && (
              <section className="v38-date-popover" role="dialog" aria-label="تخصيص الفترة الزمنية">
                <div className="v38-date-popover__head">
                  <div><strong>تخصيص الفترة الزمنية</strong><small>اختر نطاق التواريخ لعرض البيانات والتقارير في الفترة المحددة</small></div>
                  <span className="v38-date-popover__badge">{rangeLabel}</span>
                </div>
                <div className="v38-date-popover__fields">
                  <label className="v38-date-field"><span>من</span><input aria-label="تاريخ بداية الفترة" type="date" value={customFrom} max={customTo || toDateInputValue(new Date())} onChange={(e) => { setCustomFrom(e.target.value); setDateError(''); }} /></label>
                  <label className="v38-date-field"><span>إلى</span><input aria-label="تاريخ نهاية الفترة" type="date" value={customTo} min={customFrom} max={toDateInputValue(new Date())} onChange={(e) => { setCustomTo(e.target.value); setDateError(''); }} /></label>
                </div>
                {dateError && <div className="executive-date-error">{dateError}</div>}
                <div className="v38-date-popover__foot">
                  <span>سيتم تطبيق الفترة على جميع المؤشرات والرسوم البيانية.</span>
                  <div className="v38-date-popover__buttons">
                    <button type="button" className="v38-date-close" onClick={() => { setDateError(''); setDatePopoverOpen(false); }}>إلغاء</button>
                    <button type="button" className="v38-date-apply" onClick={applyCustomDateRange}>تطبيق الفترة</button>
                  </div>
                </div>
              </section>
            )}

            <section className="v38-kpis">
              <article className="v38-kpi v38-kpi--sales">
                <div className="v38-kpi__top"><span>إجمالي المبيعات</span><span className="v38-kpi__ico"><DollarSign size={16} /></span></div>
                <div className="v38-kpi__value">{analyticsSales.toLocaleString()} <small>ر.س</small></div>
                <div className="v38-kpi__foot"><TrendingUp size={11} /><b>+12%</b><span>تحديث فوري مباشر</span></div>
              </article>
              <article className="v38-kpi v38-kpi--pay">
                <div className="v38-kpi__top"><span>عمليات دفع ناجحة</span><span className="v38-kpi__ico"><CreditCard size={16} /></span></div>
                <div className="v38-kpi__value">{analyticsPaymentCount.toLocaleString()}</div>
                <div className="v38-kpi__foot"><TrendingUp size={11} /><b>+8%</b><span>عملية</span></div>
              </article>
              <article className="v38-kpi v38-kpi--seller">
                <div className="v38-kpi__top"><span>التجار النشطون</span><span className="v38-kpi__ico"><Store size={16} /></span></div>
                <div className="v38-kpi__value">{verifiedSellersCount}</div>
                <div className="v38-kpi__foot"><UserCheck size={11} /><b>+100%</b><span>متجر</span></div>
              </article>
              <article className="v38-kpi v38-kpi--user">
                <div className="v38-kpi__top"><span>العملاء المسجلون</span><span className="v38-kpi__ico"><Users size={16} /></span></div>
                <div className="v38-kpi__value">{customers.length.toLocaleString()}</div>
                <div className="v38-kpi__foot"><Activity size={11} /><b>+33%</b><span>نمو مستمر</span></div>
              </article>
            </section>

            <section className="v38-health">
              <div className="v38-health__status">
                <h3>حالة المنصة</h3>
                <span className="v38-health__stable"><i className="v38-dot" /> تعمل بشكل طبيعي</span>
                <p>جميع الأنظمة تعمل بكفاءة عالية</p>
              </div>
              <div className="v38-health__metrics">
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>استقرار المنصة</span><i className="v38-health-metric__ico"><ShieldCheck size={13} /></i></div><strong>100%</strong><small>استقرار المنصة</small></article>
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>معدل الأخطاء</span><i className="v38-health-metric__ico"><AlertCircle size={13} /></i></div><strong>0.01%</strong><small>معدل الأخطاء</small></article>
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>متوسط زمن الاستجابة</span><i className="v38-health-metric__ico"><Activity size={13} /></i></div><strong>{serverResponseTime}ms</strong><small>زمن الاستجابة</small></article>
                <article className="v38-health-metric"><div className="v38-health-metric__head"><span>معدل الحمل الحالي</span><i className="v38-health-metric__ico"><Server size={13} /></i></div><strong>{systemLoad}%</strong><small>حمولة الخادم</small></article>
              </div>
              <div className="v38-health__scene v39-health-scene"><div><h4>أداء مستقر<br/>لرحلة أكثر سلاسة</h4><small>STABLE TODAY • FOR A SMOOTHER TOMORROW</small></div></div>
            </section>

            <section className="v38-revenue">
              <header className="v38-section-head">
                <div className="v38-section-title"><span className="v38-section-title__ico"><BarChart2 size={16} /></span><div><h3>الإيرادات والأداء</h3><small>نظرة شاملة على أداء المنصة ونمو الإيرادات</small></div></div>
                <span className="v38-period">{rangeSummaryLabel}</span>
              </header>
              <div className="v38-rev-stats">
                <div className="v38-rev-stat"><span>إجمالي المبيعات</span><strong>{analyticsSales.toLocaleString()} ر.س</strong></div>
                <div className="v38-rev-stat"><span>متوسط قيمة العملية</span><strong>{Math.round(analyticsSales / Math.max(analyticsPaymentCount,1)).toLocaleString()} ر.س</strong></div>
                <div className="v38-rev-stat"><span>عمليات الدفع</span><strong>{analyticsPaymentCount.toLocaleString()}</strong></div>
                <div className="v38-rev-stat v38-rev-stat--green"><span>نسبة النمو</span><strong>{trendDelta >= 0 ? '+' : ''}{trendDelta}%</strong></div>
              </div>
              <div className="v38-rev-visual">
                <div className="v38-chart">
                  <div className="v38-chart-toolbar"><span>آخر 30 يوم</span><span>الإيرادات</span></div>
                  {trendSeries.length > 0 && (
                    <div className="v41-chart-callout">
                      <span>{trendSeries[Math.floor(trendSeries.length / 2)]?.label || rangeSummaryLabel}</span>
                      <strong>{Number(trendSeries[Math.floor(trendSeries.length / 2)]?.revenue || 0).toLocaleString()} ر.س</strong>
                    </div>
                  )}
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={trendSeries.filter((_, i) => i % Math.max(1, Math.floor(trendSeries.length / 7)) === 0).slice(0, 7)} margin={{ top: 22, right: 10, left: 4, bottom: 0 }}>
                      <defs><linearGradient id="v38GoldArea" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#d69b18" stopOpacity={0.36}/><stop offset="100%" stopColor="#d69b18" stopOpacity={0.02}/></linearGradient></defs>
                      <CartesianGrid stroke="rgba(130,106,67,.12)" strokeDasharray="3 3" vertical={false} />
                      <XAxis dataKey="label" tick={{ fontSize: 7, fill: '#857d72' }} axisLine={false} tickLine={false} />
                      <YAxis tick={{ fontSize: 7, fill: '#857d72' }} axisLine={false} tickLine={false} width={30} />
                      <Tooltip formatter={(v) => [`${Number(v).toLocaleString()} ر.س`, 'الإيرادات']} labelStyle={{fontSize:10}} contentStyle={{background:'#071019',border:'1px solid rgba(215,167,47,.25)',borderRadius:8,color:'#fff',fontSize:9}} />
                      <Area type="monotone" dataKey="revenue" stroke="#cf8f0c" strokeWidth={2.6} fill="url(#v38GoldArea)" dot={{ r: 3.4, fill: '#fff8e8', stroke: '#cf8f0c', strokeWidth: 2 }} activeDot={{ r: 4 }} />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
                <aside className="v38-donut">
                  <div className="v38-donut-ring" style={{ background: 'conic-gradient(#dfa72c 0 62%, #31c8c1 62% 90%, #2d87d8 90% 100%)' }}><div className="v38-donut-core"><strong>{analyticsSales.toLocaleString()}</strong><small>ر.س</small></div></div>
                  <div className="v38-donut-copy">
                    <h4>توزيع الإيرادات</h4>
                    <div className="v38-donut-legend"><span><i className="g" />62% بطاقات مدى</span><span><i className="c" />28% بطاقات ائتمانية</span><span><i className="b" />10% محافظ رقمية</span></div>
                    <div className="v38-donut-foot"><b>{trendDelta >= 0 ? '+' : ''}{trendDelta}%</b><span>مقارنة بالفترة السابقة</span></div>
                  </div>
                </aside>
              </div>
            </section>

            <section className="v38-ops-grid">
              <article className="v38-live">
                <header className="v38-ops-head"><div><h3>العمليات المباشرة</h3><small>آخر الأحداث والعمليات على المنصة في الوقت الفعلي</small></div><button type="button">مشاهدة الكل</button></header>
                <div className="v38-live-list">
                  {[...liveNotifications, ...payments.map((p, i) => ({ id: `p-${i}`, type: 'payment', text: `عملية دفع بقيمة ${p.amount.toLocaleString()} ر.س لصالح ${p.seller}`, time: p.date }))].slice(0,4).map((item, idx) => (
                    <div className="v38-live-row" key={`${item.id}-${idx}`}><span className="v38-live-row__ico">{item.type === 'payment' ? <CreditCard size={11}/> : <Users size={11}/>}</span><span className="v38-live-row__text">{item.text}</span><span className="v38-live-row__time">{item.time}</span></div>
                  ))}
                </div>
                <div className="v38-live-summary"><div><strong>{analyticsPaymentCount.toLocaleString()}</strong><span>إجمالي العمليات</span></div><div><strong>98%</strong><span>معدل النجاح</span></div><div><strong>{pendingReview}</strong><span>قيد المعالجة</span></div><div><strong>{payments.filter(p => p.status === 'معلق').length}</strong><span>عمليات معلقة</span></div></div>
              </article>

              <article className="v38-current">
                <header className="v38-ops-head"><div><h3>العمليات الجارية</h3><small>آخر الطلبات والعمليات التي تحتاج متابعة</small></div><button type="button">عرض الكل</button></header>
                <div className="v38-current-summary v40-current-summary"><div><strong>{payments.length}</strong><span>قيد التنفيذ</span></div><div><strong>{pendingReview}</strong><span>قيد المراجعة</span></div><div><strong>{verifiedSellersCount}</strong><span>مكتملة</span></div></div>
                <table className="v38-current-table"><thead><tr><th>#</th><th>نوع العملية</th><th>العميل / التاجر</th><th>المبلغ</th><th>الحالة</th><th>الوقت</th></tr></thead><tbody>{payments.slice(0,4).map((p, idx)=><tr key={p.id}><td>{p.id.replace('TXN-','')}</td><td>{idx%2===0?'دفع':'سحب'}</td><td>{p.buyer}</td><td>{p.amount.toLocaleString()} ر.س</td><td><span className={`v38-mini-status ${p.status==='معلق'?'pending':''}`}>{p.status}</span></td><td>{p.date}</td></tr>)}</tbody></table>
              </article>
            </section>

            <section className="v38-ledger">
              <header className="v38-ledger-head">
                <div className="v38-ledger-title"><span className="v38-ledger-title__ico"><CreditCard size={15}/></span><div><h3>السجل المالي — أحدث العمليات</h3><small>قائمة بآخر العمليات المالية المنفذة عبر المنصة</small></div></div>
                <div className="v38-ledger-tools">
                  <input className="v38-ledger-search" type="search" placeholder="ابحث عن معاملة أو عميل أو بائع..." value={txQuery} onChange={(e)=>setTxQuery(e.target.value)} />
                  <button type="button" className="v38-ledger-filter"><Layers size={12}/> تصفية</button>
                  <button type="button" className="v38-ledger-export" onClick={()=>window.print()}><Download size={12}/> تصدير</button>
                </div>
              </header>
              <div className="v38-ledger-table-wrap"><table className="v38-ledger-table"><thead><tr><th>#</th><th>التاريخ والوقت</th><th>العميل / التاجر</th><th>نوع العملية</th><th>القناة</th><th>المبلغ</th><th>الحالة</th></tr></thead><tbody>{payments.filter(p => !txQuery || p.id.toLowerCase().includes(txQuery.toLowerCase()) || p.buyer.includes(txQuery) || p.seller.includes(txQuery)).map((p)=><tr key={p.id}><td><span className="v38-tx-id">{p.id}</span></td><td>{p.date}</td><td>{p.buyer}</td><td>دفع</td><td>{p.method}</td><td><span className="v38-amount">{p.amount.toLocaleString()} ر.س</span></td><td><span className={`v38-mini-status ${p.status==='معلق'?'pending':''}`}>{p.status}</span></td></tr>)}</tbody></table></div>
            </section>

          </div>
        )}

        {/* Tab Content: USERS AND SELLERS LOGS */}
        {activeTab === 'users' && (
          <div className="animate-fadeIn ref-batch-users" data-v42-reference-screen="users-sellers" style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
            
            {/* Sellers */}
            <div className="ref-batch-panel ref-batch-sellers" style={cardStyle}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', borderBottom: '1px solid #F1F5F9', paddingBottom: '15px' }}>
                <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Store color="#FFEA00" size={22} />
                  <span>تفاصيل التجار وأداء المتاجر</span>
                </h3>
                <div style={{ display: 'flex', gap: '10px' }}>
                  <span style={{ background: '#E8F5E9', color: '#2E7D32', fontSize: '0.8rem', padding: '4px 12px', borderRadius: '12px', fontWeight: 'bold' }}>الموثقة: {verifiedSellersCount}</span>
                  <span style={{ background: '#FFF3E0', color: '#E65100', fontSize: '0.8rem', padding: '4px 12px', borderRadius: '12px', fontWeight: 'bold' }}>تحت المراجعة: {unverifiedSellersCount}</span>
                </div>
              </div>

              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid #E2E8F0' }}>
                      <th style={thStyle}>معرف المتجر</th>
                      <th style={thStyle}>اسم التاجر/المتجر</th>
                      <th style={thStyle}>البريد الإلكتروني</th>
                      <th style={thStyle}>تاريخ التسجيل</th>
                      <th style={thStyle}>الطلبات المنجزة</th>
                      <th style={thStyle}>تقييم العملاء</th>
                      <th style={thStyle}>مؤشر الأداء</th>
                      <th style={thStyle}>الحالة والإجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sellers.map((s, idx) => (
                      <tr key={idx} style={{ borderBottom: '1px solid #F1F5F9' }}>
                        <td style={tdStyle}><span style={{ fontFamily: 'monospace', fontWeight: 'bold' }}>{s.id}</span></td>
                        <td style={tdStyle}><strong>{s.name}</strong></td>
                        <td style={tdStyle}>{s.email}</td>
                        <td style={tdStyle}><span style={{ fontSize: '0.8rem', color: '#64748B' }}>{s.date}</span></td>
                        <td style={tdStyle}><strong style={{ color: '#2E7D32' }}>{s.completedOrders} طلب موصل</strong></td>
                        <td style={tdStyle}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                            <Star size={14} fill={s.rating > 0 ? "#FFB300" : "none"} stroke={s.rating > 0 ? "#FFB300" : "#888"} />
                            <span style={{ fontWeight: 'bold' }}>{s.rating}</span>
                            <span style={{ fontSize: '0.75rem', color: '#888' }}>({s.reviewsCount} رأي)</span>
                          </div>
                        </td>
                        <td style={tdStyle}>
                          <span style={{
                            display: 'inline-flex', alignItems: 'center', gap: '5px',
                            background: s.strength === 'قوي' ? '#E8F5E9' : s.strength === 'متوسط' ? '#FFF3E0' : s.strength === 'ضعيف' ? '#FFEBEE' : '#F1F5F9',
                            color: s.strength === 'قوي' ? '#2E7D32' : s.strength === 'متوسط' ? '#E65100' : s.strength === 'ضعيف' ? '#C62828' : '#64748B',
                            padding: '4px 10px', borderRadius: '10px', fontSize: '0.8rem', fontWeight: 'bold'
                          }}>
                            تاجر {s.strength}
                          </span>
                        </td>
                        <td style={tdStyle}>
                          {s.status === 'تحت المراجعة' ? (
                            <button 
                              onClick={() => handleApproveSeller(s.id)}
                              style={{ background: '#FFEA00', color: '#000000', border: 'none', padding: '6px 12px', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold', fontSize: '0.8rem' }}
                            >
                              تفعيل المتجر
                            </button>
                          ) : (
                            <span style={{ color: '#2E7D32', fontWeight: 'bold', fontSize: '0.85rem' }}>معتمد ونشط</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Customers */}
            <div className="ref-batch-panel ref-batch-customers" style={cardStyle}>
              <h3 style={{ margin: '0 0 20px 0', fontSize: '1.25rem', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px', borderBottom: '1px solid #F1F5F9', paddingBottom: '15px' }}>
                <Users color="#FFEA00" size={22} />
                <span>تفاصيل سجل العملاء ومشترياتهم</span>
              </h3>
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid #E2E8F0' }}>
                      <th style={thStyle}>معرف العميل</th>
                      <th style={thStyle}>اسم العميل</th>
                      <th style={thStyle}>البريد الإلكتروني</th>
                      <th style={thStyle}>تاريخ التسجيل</th>
                      <th style={thStyle}>الطلبات المشتраة</th>
                      <th style={thStyle}>إجمالي المشتريات</th>
                      <th style={thStyle}>حالة الحساب</th>
                    </tr>
                  </thead>
                  <tbody>
                    {customers.map((c, idx) => (
                      <tr key={idx} style={{ borderBottom: '1px solid #F1F5F9' }}>
                        <td style={tdStyle}><span style={{ fontFamily: 'monospace', fontWeight: 'bold' }}>{c.id}</span></td>
                        <td style={tdStyle}><strong>{c.name}</strong></td>
                        <td style={tdStyle}>{c.email}</td>
                        <td style={tdStyle}><span style={{ fontSize: '0.8rem', color: '#64748B' }}>{c.date}</span></td>
                        <td style={tdStyle}><strong>{c.totalOrders} طلب</strong></td>
                        <td style={tdStyle}><strong style={{ color: '#FFEA00' }}>{c.totalSpent.toLocaleString()} ر.س</strong></td>
                        <td style={tdStyle}>
                          <span style={{ background: '#E8F5E9', color: '#2E7D32', padding: '3px 8px', borderRadius: '8px', fontSize: '0.8rem', fontWeight: 'bold' }}>
                            {c.status} 🟢
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

          </div>
        )}

        {/* Tab Content: DOCUMENTS */}
        {activeTab === 'documents' && (
          <div className="animate-fadeIn ref-batch-panel ref-batch-documents" data-v42-reference-screen="documents-verification" style={cardStyle}>
            <h3 style={{ margin: '0 0 20px 0', fontSize: '1.2rem', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <FileText color="#FFEA00" size={20} />
              <span>مراجعة المستندات الرسمية والسجلات التجارية للتجار</span>
            </h3>
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid #E2E8F0' }}>
                    <th style={thStyle}>رقم المستند</th>
                    <th style={thStyle}>اسم المتجر التابع</th>
                    <th style={thStyle}>نوع المستند</th>
                    <th style={thStyle}>الملف المرفق</th>
                    <th style={thStyle}>تاريخ الإرسال</th>
                    <th style={thStyle}>حالة السجل</th>
                    <th style={thStyle}>الإجراءات والمراجعة</th>
                  </tr>
                </thead>
                <tbody>
                  {documents.map((d, idx) => (
                    <tr key={idx} style={{ borderBottom: '1px solid #F1F5F9' }}>
                      <td style={tdStyle}><span style={{ fontFamily: 'monospace', fontWeight: 'bold' }}>{d.id}</span></td>
                      <td style={tdStyle}>{d.store}</td>
                      <td style={tdStyle}>{d.type}</td>
                      <td style={tdStyle}><span style={{ textDecoration: 'underline', color: '#3B82F6', cursor: 'pointer' }}><Eye size={14} style={{ display: 'inline', marginLeft: '5px' }} /> {d.file}</span></td>
                      <td style={tdStyle}>{d.date}</td>
                      <td style={tdStyle}>
                        <span style={{
                          background: d.status === 'مقبول' ? '#E8F5E9' : d.status === 'مرفوض' ? '#FFEBEE' : '#FFF3E0',
                          color: d.status === 'مقبول' ? '#2E7D32' : d.status === 'مرفوض' ? '#C62828' : '#E65100',
                          padding: '4px 10px', borderRadius: '10px', fontSize: '0.8rem', fontWeight: 'bold'
                        }}>{d.status}</span>
                      </td>
                      <td style={tdStyle}>
                        {d.status === 'معلق' && (
                          <div style={{ display: 'flex', gap: '8px' }}>
                            <button onClick={() => handleApproveDoc(d.id)} style={{ background: '#4CAF50', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '8px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '0.8rem', fontWeight: 'bold' }}>
                              <CheckCircle size={14} /> قبول السجل
                            </button>
                            <button onClick={() => handleRejectDoc(d.id)} style={{ background: '#EF5350', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '8px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '0.8rem', fontWeight: 'bold' }}>
                              <XCircle size={14} /> رفض
                            </button>
                          </div>
                        )}
                        {d.status !== 'معلق' && <span style={{ color: '#888', fontSize: '0.85rem' }}>تم البت في الطلب</span>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
        {activeTab === 'notifications' && (
          <div className="animate-fadeIn" style={cardStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Bell color="#FFEA00" size={20} />
                <span>شاشة مراقبة التنبيهات والأحداث المباشرة</span>
              </h3>
              <button onClick={() => {
                setLiveNotifications([]);
                localStorage.setItem('_67_admin_logs', JSON.stringify([]));
              }} style={{ background: 'transparent', border: '1px solid #E2E8F0', padding: '6px 12px', borderRadius: '8px', cursor: 'pointer', fontSize: '0.8rem', color: '#64748B', display: 'flex', alignItems: 'center', gap: '4px' }}>
                <RefreshCw size={12} /> مسح السجل
              </button>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {liveNotifications.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '40px', color: '#888' }}>لا توجد تنبيهات جديدة.</div>
              ) : (
                liveNotifications.map(n => (
                  <div key={n.id} style={{
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                    padding: '16px 20px', borderRadius: '12px',
                    border: '1px solid #E2E8F0',
                    background: n.type === 'order_shipped' || n.type === 'order_completed' ? 'rgba(72,187,120,0.06)' : 'rgba(255,234,0,0.06)'
                  }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <span style={{ fontSize: '0.95rem', fontWeight: 'bold' }}>{n.text}</span>
                    </div>
                    <span style={{ fontSize: '0.8rem', color: '#64748B' }}>{n.time}</span>
                  </div>
                ))
              )}
            </div>
          </div>
        )}

        {/* Tab Content: TRANSACTIONS */}
        {activeTab === 'transactions' && (
          <div className="animate-fadeIn ref-batch-panel ref-batch-transactions" data-v42-reference-screen="payments-transactions" style={cardStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <CreditCard color="#FFEA00" size={20} />
                <span>سجل المراقبة والتحقق من العمليات بين الأفراد والأعمال</span>
              </h3>
            </div>
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid #F1F5F9', color: '#64748B' }}>
                    <th style={thStyle}>رقم الطلب</th>
                    <th style={thStyle}>العميل</th>
                    <th style={thStyle}>التاجر</th>
                    <th style={thStyle}>القطعة المطلوبة</th>
                    <th style={thStyle}>القيمة</th>
                    <th style={thStyle}>الحالة</th>
                  </tr>
                </thead>
                <tbody>
                  {JSON.parse(localStorage.getItem('_67_orders') || '[]').map((o, idx) => (
                    <tr key={idx} style={{ borderBottom: '1px solid #F1F5F9' }}>
                      <td style={tdStyle}>{o.id}</td>
                      <td style={tdStyle}>{o.customer}</td>
                      <td style={tdStyle}>{o.storeName}</td>
                      <td style={tdStyle}>{o.itemName}</td>
                      <td style={tdStyle}><span style={{fontWeight: 'bold', color: '#D4AF37'}}>{o.total} ر.س</span></td>
                      <td style={tdStyle}>
                        <span style={{
                          padding: '4px 10px',
                          borderRadius: '50px',
                          fontSize: '0.8rem',
                          fontWeight: 'bold',
                          backgroundColor: o.status === 'delivered' ? '#E8F5E9' : o.status === 'shipped' ? '#E3F2FD' : '#FFF3E0',
                          color: o.status === 'delivered' ? '#2E7D32' : o.status === 'shipped' ? '#1565C0' : '#E65100'
                        }}>
                          {o.status === 'delivered' ? 'عملية ناجحة ومكتملة' : o.status === 'shipped' ? 'مشحون' : 'قيد المعالجة'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Tab Content: COMMUNITY CONTROL */}
        {activeTab === 'community' && (
          <div className="animate-fadeIn" style={cardStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <MessageSquare color="#FFEA00" size={20} />
                <span>الرقابة والتحكم في منشورات المجتمع (عملاء وتجار)</span>
              </h3>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
              {JSON.parse(localStorage.getItem('_67_community_posts') || '[]').map((p, idx) => (
                <div key={idx} style={{ padding: '16px', border: '1px solid #E2E8F0', borderRadius: '12px', background: '#F8FAFC' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <strong style={{ fontSize: '0.95rem' }}>{p.author}</strong>
                      <span style={{ fontSize: '0.75rem', background: '#E2E8F0', padding: '2px 8px', borderRadius: '4px' }}>{p.role}</span>
                    </div>
                    <button 
                      onClick={() => {
                        const saved = JSON.parse(localStorage.getItem('_67_community_posts') || '[]');
                        const updated = saved.filter(post => post.id !== p.id);
                        localStorage.setItem('_67_community_posts', JSON.stringify(updated));
                        
                        // Add log
                        const adminLogs = JSON.parse(localStorage.getItem('_67_admin_logs') || '[]');
                        adminLogs.unshift({
                          id: 'LOG-' + Math.floor(1000 + Math.random() * 9000),
                          text: `قام المسؤول بحذف منشور للكاتب (${p.author}) لمخالفته القوانين`,
                          time: 'الآن',
                          type: 'post_deleted'
                        });
                        localStorage.setItem('_67_admin_logs', JSON.stringify(adminLogs));

                        // Force refresh tab
                        setActiveTab('overview');
                        setTimeout(() => setActiveTab('community'), 10);
                      }}
                      style={{ background: '#EF4444', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '6px', cursor: 'pointer', fontSize: '0.8rem' }}
                    >
                      حذف المنشور
                    </button>
                  </div>
                  <p style={{ margin: 0, fontSize: '0.9rem', color: '#475569', lineHeight: '1.6' }}>{p.content}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Tab Content: GITHUB DEVELOPER HUB */}
        {activeTab === 'github' && (
          <div className="animate-fadeIn">
            <GitHubModule session={session} onSessionExpired={loadSession} />
          </div>
        )}

        {/* Tab Content: SETTINGS */}
        {activeTab === 'settings' && (
          <div className="animate-fadeIn" style={{ display: 'flex', flexDirection: 'column', gap: '25px' }}>
            <div style={cardStyle}>
              <h3 style={{ margin: '0 0 20px 0', fontSize: '1.25rem', fontWeight: '900', borderBottom: '1px solid #F1F5F9', paddingBottom: '15px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Settings color="#FFEA00" size={22} />
                <span>إعدادات ملف المشرف الشخصي (بياناتي والحساب البنكي للأرباح)</span>
              </h3>

              <form onSubmit={handleSaveSettings} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              {/* Logo switcher (moved from sidebar utility) */}
              <div style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <h4 style={{ margin: '0 0 4px 0', fontSize: '0.9rem', fontWeight: '900', color: '#1c1e26' }}>مبدل شعار المنصة</h4>
                <p style={{ margin: '0 0 6px 0', fontSize: '0.76rem', color: '#64748B' }}>اختر نمط الشعار المعروض في المنصة.</p>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button className={`theme-select-btn ${logoTheme === 'car_concept' ? 'active' : ''}`} onClick={() => handleLogoThemeToggle('car_concept')} style={{ padding: '10px 14px' }}>
                    شعار السيارات
                  </button>
                  <button className={`theme-select-btn ${logoTheme === 'classic' ? 'active' : ''}`} onClick={() => handleLogoThemeToggle('classic')} style={{ padding: '10px 14px' }}>
                    شعار كلاسيك
                  </button>
                </div>
              </div>

                
                {/* Profile Photo Settings Section */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '20px', background: '#F8FAFC', padding: '16px', borderRadius: '14px', border: '1px solid #E2E8F0' }}>
                  <div style={{ position: 'relative' }}>
                    <img src={adminAvatar} alt="Admin Avatar" style={{ width: '80px', height: '80px', borderRadius: '50%', objectFit: 'cover', border: '2px solid #FFEA00' }} />
                    <div title="الصورة محفوظة ضمن ملف Superadmin المشفّر" style={{ position: 'absolute', bottom: '0', right: '0', background: '#FFEA00', borderRadius: '50%', padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <Camera size={14} color="#000000" />
                    </div>
                  </div>
                  <div style={{ flex: 1 }}>
                    <h4 style={{ margin: '0 0 4px 0', fontSize: '0.95rem', fontWeight: 'bold', color: '#1E293B' }}>الصورة الشخصية للمشرف</h4>
                    <p style={{ margin: '0 0 8px 0', fontSize: '0.75rem', color: '#64748B' }}>أدخل رابط HTTPS للصورة؛ يتم حفظه داخل ملف Superadmin المشفّر.</p>
                    <input type="url" value={adminAvatar} onChange={(e) => setAdminAvatar(e.target.value)} placeholder="https://…" style={{ ...adminInputStyle, padding: '8px 10px', fontSize: '0.78rem' }} />
                  </div>
                </div>

                <div style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  <div style={{ fontSize: '0.85rem', color: '#475569', fontWeight: 'bold' }}>هوية Superadmin المحمية</div>
                  <div style={{ color: '#0F172A', fontWeight: 900 }}>{session.username || 'Superadmin'}</div>
                  <div style={{ fontSize: '0.76rem', color: '#64748B', lineHeight: 1.7 }}>اسم المستخدم وكلمة المرور مُداران على السيرفر. تغيير كلمة المرور يتم بتوليد <code>SUPERADMIN_PASSWORD_HASH</code> جديد وإعادة تشغيل الخدمة؛ لا يتم تخزين أي Credential في المتصفح.</div>
                </div>

                <div style={{ borderTop: '1px solid #F1F5F9', paddingTop: '15px' }} />

                {/* Bank Account Settings */}
                <h4 style={{ margin: '0 0 10px 0', fontSize: '1rem', fontWeight: '900', color: '#1E293B', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <CreditCard size={18} color="#FFEA00" />
                  <span>تفاصيل الحساب البنكي لسحب أرباح العمولات (1%)</span>
                </h4>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                  {/* Bank Name */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                    <label style={{ fontSize: '0.85rem', color: '#475569', fontWeight: 'bold' }}>اسم البنك المحلي</label>
                    <input 
                      type="text" 
                      value={bankName} 
                      onChange={(e) => setBankName(e.target.value)} 
                      placeholder="مثال: مصرف الراجحي" 
                      style={adminInputStyle} 
                      required 
                    />
                  </div>

                  {/* Account Holder Name */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                    <label style={{ fontSize: '0.85rem', color: '#475569', fontWeight: 'bold' }}>اسم صاحب الحساب (رباعي)</label>
                    <input 
                      type="text" 
                      value={accountHolder} 
                      onChange={(e) => setAccountHolder(e.target.value)} 
                      placeholder="أدخل الاسم بالكامل" 
                      style={adminInputStyle} 
                      required 
                    />
                  </div>
                </div>

                {/* IBAN Number */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                  <label style={{ fontSize: '0.85rem', color: '#475569', fontWeight: 'bold' }}>رقم الآيبان (IBAN)</label>
                  <input 
                    type="text" 
                    value={bankIBAN} 
                    onChange={(e) => setBankIBAN(e.target.value)} 
                    placeholder="SA0000000000000000000000" 
                    style={adminInputStyle} 
                    required 
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '10px' }}>
                  <button type="submit" disabled={profileBusy} style={{ ...submitButtonStyle, width: 'auto', padding: '12px 30px', opacity: profileBusy ? 0.6 : 1 }}>
                    {profileBusy ? 'جاري الحفظ المشفّر…' : 'حفظ التغييرات والحساب البنكي'}
                  </button>
                </div>

              </form>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};

const inputStyle = {
  padding: '12px 16px',
  borderRadius: '10px',
  border: '1.5px solid #E2E8F0',
  backgroundColor: '#FFFFFF',
  color: '#1E293B',
  fontSize: '0.9rem',
  outline: 'none',
  width: '100%',
  transition: 'all 0.3s ease',
  boxShadow: 'inset 0 1px 3px rgba(0,0,0,0.02)'
};

const adminInputStyle = {
  padding: '12px 16px',
  borderRadius: '10px',
  border: '1px solid #E2E8F0',
  backgroundColor: '#F8FAFC',
  color: '#1E293B',
  fontSize: '0.9rem',
  outline: 'none',
  width: '100%',
  transition: 'border-color 0.2s'
};

const submitButtonStyle = {
  width: '100%',
  padding: '14px',
  borderRadius: '12px',
  border: 'none',
  background: 'linear-gradient(135deg, #D4AF37 0%, #B8962C 100%)',
  color: '#FFFFFF',
  fontWeight: '900',
  fontSize: '1rem',
  cursor: 'pointer',
  transition: 'all 0.3s ease',
  boxShadow: '0 4px 15px rgba(212,175,55,0.25)'
};

const sidebarMetricStyle = {
  display: 'flex',
  flexDirection: 'column',
  gap: '6px',
  padding: '12px 14px',
  borderRadius: '10px',
  background: '#F8FAFC',
  border: '1px solid #E2E8F0',
  transition: 'all 0.2s'
};

const cardStyle = {
  background: '#FFFFFF',
  border: '1px solid #E2E8F0',
  borderRadius: '16px',
  padding: '24px',
  boxShadow: '0 4px 12px rgba(0,0,0,0.01)',
  marginBottom: '25px'
};

const thStyle = {
  padding: '12px 16px',
  color: '#64748B',
  fontWeight: 'bold',
  fontSize: '0.9rem',
  borderBottom: '2px solid #E2E8F0'
};

const tdStyle = {
  padding: '16px',
  fontSize: '0.9rem',
  color: '#334155'
};

export default AdminDashboard;
