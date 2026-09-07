#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/67/QARIX}"
cd "$ROOT"

cat > src/pages/Home.jsx <<'EOF'
import React, { useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { brands, generateYears, getModelsForBrand } from '../data/cars';
import {
  ArrowLeft,
  Car,
  ChevronLeft,
  Clock3,
  Headphones,
  PackageSearch,
  Search,
  Settings,
  ShieldCheck,
  Sparkles,
  Truck,
  TrendingUp,
  Wrench,
  Gavel,
} from 'lucide-react';
import '../concept01-v5.css';

const stats = [
  { icon: Car, value: '+43', label: 'ماركات السيارات' },
  { icon: PackageSearch, value: '+250', label: 'قطع وخدمات' },
  { icon: Headphones, value: '24/7', label: 'خدمة العملاء' },
  { icon: Clock3, value: 'فوري', label: 'استلام الطلب' },
];

const services = [
  { icon: PackageSearch, title: 'قطع الغيار', text: 'اعثر على القطعة المناسبة لسيارتك' },
  { icon: Car, title: 'التشاليح', text: 'خيارات مستعملة موثوقة بأسعار أفضل' },
  { icon: Wrench, title: 'ورش وإصلاح', text: 'صيانة وإصلاح باحترافية' },
  { icon: Gavel, title: 'مزادات', text: 'فرص مميزة بأسعار تنافسية' },
  { icon: Truck, title: 'خدمات الطريق', text: 'مساعدة سريعة أينما كنت' },
];

const Home = () => {
  const navigate = useNavigate();
  const [brand, setBrand] = useState('');
  const [model, setModel] = useState('');
  const [year, setYear] = useState('');

  const years = useMemo(() => generateYears(), []);
  const models = useMemo(() => (brand ? getModelsForBrand(brand) : []), [brand]);

  const submitVehicle = () => {
    if (!brand || !model || !year) return;
    navigate('/request', { state: { brand, model, year: Number(year) } });
  };

  return (
    <div className="p5-home">
      <section className="p5-hero">
        <div className="container p5-hero-grid">
          <div className="p5-showcase" aria-hidden="true">
            <div className="p5-arch" />
            <div className="p5-stage" />
            <div className="p5-car-wrap">
              <Car className="p5-car" size={310} strokeWidth={1.05} />
            </div>
            <div className="p5-parts p5-parts-a">
              <Settings size={34} />
              <span>قطع أصلية</span>
            </div>
            <div className="p5-parts p5-parts-b">
              <Wrench size={31} />
              <span>صيانة</span>
            </div>
            <div className="p5-brand-box">
              <img src="/logo.jpg" alt="" />
              <span>PREMIUM AUTOMOTIVE</span>
            </div>
          </div>

          <div className="p5-hero-copy">
            <span className="p5-kicker"><Sparkles size={15} /> قطع أصلية، ثقة تدوم</span>
            <h1>كل ما تحتاجه<br />لسيارتك <strong>في مكان واحد</strong></h1>
            <p>اكتشف قطع الغيار والخدمات المناسبة لسيارتك بخيارات موثوقة وتجربة أسرع وأكثر احترافية.</p>

            <div className="p5-actions">
              <button className="p5-primary" onClick={() => document.getElementById('vehicle-finder')?.scrollIntoView({ behavior: 'smooth' })}>
                ابدأ البحث الآن <Search size={18} />
              </button>
              <Link className="p5-secondary" to="/offers">
                تصفح العروض <ArrowLeft size={17} />
              </Link>
            </div>

            <div className="p5-proof">
              <span><ShieldCheck size={17} /> منتجات موثوقة</span>
              <span><Truck size={17} /> توصيل سريع</span>
              <span><Headphones size={17} /> دعم متخصص</span>
            </div>
          </div>
        </div>
      </section>

      <section id="vehicle-finder" className="p5-finder-wrap">
        <div className="container">
          <div className="p5-finder">
            <div className="p5-finder-title">
              <span>ابحث حسب سيارتك</span>
              <h2>اختر بيانات السيارة</h2>
            </div>

            <label className="p5-field">
              <small>العلامة التجارية</small>
              <select value={brand} onChange={(e) => { setBrand(e.target.value); setModel(''); setYear(''); }}>
                <option value="">اختر الماركة</option>
                {brands.map((item) => <option key={item.name} value={item.name}>{item.name}</option>)}
              </select>
            </label>

            <label className="p5-field">
              <small>الموديل</small>
              <select value={model} disabled={!brand} onChange={(e) => { setModel(e.target.value); setYear(''); }}>
                <option value="">اختر الموديل</option>
                {models.map((item) => <option key={item.name} value={item.name}>{item.name}</option>)}
              </select>
            </label>

            <label className="p5-field">
              <small>السنة</small>
              <select value={year} disabled={!model} onChange={(e) => setYear(e.target.value)}>
                <option value="">اختر السنة</option>
                {years.map((item) => <option key={item} value={item}>{item}</option>)}
              </select>
            </label>

            <button className="p5-search-btn" onClick={submitVehicle} disabled={!brand || !model || !year}>
              ابحث <Search size={18} />
            </button>
          </div>
        </div>
      </section>

      <section className="p5-stats">
        <div className="container p5-stats-grid">
          {stats.map(({ icon: Icon, value, label }) => (
            <article className="p5-stat" key={label}>
              <span className="p5-stat-icon"><Icon size={22} /></span>
              <div><strong>{value}</strong><small>{label}</small></div>
            </article>
          ))}
        </div>
      </section>

      <section className="p5-services">
        <div className="container">
          <div className="p5-section-head">
            <div>
              <span>خدمات 67</span>
              <h2>كل خدمات سيارتك، بتجربة أرقى</h2>
            </div>
            <Link to="/request">استكشف خدماتنا <ArrowLeft size={16} /></Link>
          </div>

          <div className="p5-services-grid">
            {services.map(({ icon: Icon, title, text }) => (
              <article className="p5-service" key={title}>
                <div className="p5-service-art"><Icon size={42} /></div>
                <div>
                  <h3>{title}</h3>
                  <p>{text}</p>
                </div>
                <span className="p5-card-arrow"><ChevronLeft size={17} /></span>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="p5-offer">
        <div className="container">
          <div className="p5-offer-card">
            <div className="p5-offer-copy">
              <span>عروض مميزة</span>
              <h2>خصومات مختارة على قطع الغيار</h2>
              <p>استفد من عروض محدودة على قطع وخدمات مختارة.</p>
            </div>
            <div className="p5-offer-visual">
              <div className="p5-wheel"><Settings size={54} /></div>
              <div className="p5-tire"><Car size={54} /></div>
            </div>
            <div className="p5-discount"><small>خصم حتى</small><strong>25%</strong></div>
            <Link to="/offers">تسوق الآن <ArrowLeft size={17} /></Link>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
EOF

cat > src/concept01-v5.css <<'EOF'
:root{--p5-gold:#c99b37;--p5-gold-dark:#9e7220;--p5-gold-soft:#fbf1dc;--p5-green:#153d2b;--p5-ink:#201f1d;--p5-muted:#7e786f;--p5-line:#e7e0d5;--p5-ivory:#fbf7ef;--p5-white:#fff}
.p5-home{background:#fff;color:var(--p5-ink);overflow:hidden}.p5-hero{position:relative;background:radial-gradient(circle at 18% 20%,rgba(201,155,55,.14),transparent 25%),linear-gradient(110deg,#f7efe1 0%,#fffaf4 48%,#fff 100%);border-bottom:1px solid #eee5d8}.p5-hero:before{content:"";position:absolute;inset:0;pointer-events:none;opacity:.32;background-image:radial-gradient(circle,rgba(201,155,55,.18) 1.3px,transparent 1.3px);background-size:48px 48px;mask-image:linear-gradient(90deg,transparent,#000 28%,#000 72%,transparent)}.p5-hero-grid{position:relative;z-index:2;min-height:430px;padding-top:48px;padding-bottom:88px;display:grid;grid-template-columns:minmax(470px,1.06fr) minmax(0,.94fr);gap:60px;align-items:center}.p5-showcase{position:relative;min-height:330px;display:grid;place-items:center}.p5-arch{position:absolute;width:390px;height:280px;border-radius:190px 190px 30px 30px;background:linear-gradient(145deg,rgba(255,255,255,.92),rgba(236,223,198,.55));border:1px solid rgba(201,155,55,.24);box-shadow:inset 0 0 0 12px rgba(255,255,255,.45)}.p5-arch:before{content:"";position:absolute;inset:18px;border-radius:170px 170px 24px 24px;border:1px solid rgba(201,155,55,.14)}.p5-stage{position:absolute;width:88%;height:78px;bottom:22px;border-radius:50%;background:linear-gradient(#fff,#e7d9c6);box-shadow:0 22px 42px rgba(83,63,31,.13);transform:perspective(520px) rotateX(63deg)}.p5-car-wrap{position:relative;z-index:3;transform:translateY(14px)}.p5-car{width:min(100%,430px);height:auto;color:#46423c;filter:drop-shadow(0 24px 18px rgba(58,49,36,.18))}.p5-parts{position:absolute;z-index:5;display:flex;align-items:center;gap:8px;padding:9px 12px;border-radius:12px;background:rgba(255,255,255,.94);border:1px solid #e7dece;box-shadow:0 12px 26px rgba(59,48,31,.09);color:#4e493f;font-size:11px;font-weight:900}.p5-parts svg{color:var(--p5-gold-dark)}.p5-parts-a{right:3%;bottom:46px}.p5-parts-b{left:4%;top:54px}.p5-brand-box{position:absolute;z-index:6;left:8%;bottom:18px;display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:11px;background:#183b2c;color:#fff;box-shadow:0 10px 24px rgba(15,47,34,.18)}.p5-brand-box img{width:34px;height:34px;border-radius:7px;object-fit:cover}.p5-brand-box span{font-size:8px;letter-spacing:1.4px;color:#ead6a5}.p5-hero-copy{max-width:610px}.p5-kicker{display:inline-flex;align-items:center;gap:7px;color:var(--p5-gold-dark);font-size:12px;font-weight:900}.p5-hero-copy h1{margin:14px 0 0;font-size:clamp(43px,5vw,66px);line-height:1.12;letter-spacing:-1.2px;font-weight:900}.p5-hero-copy h1 strong{color:var(--p5-gold);font-weight:900}.p5-hero-copy p{max-width:560px;margin:18px 0 0;color:#726c63;font-size:14px;line-height:1.9}.p5-actions{display:flex;gap:11px;flex-wrap:wrap;margin-top:25px}.p5-primary,.p5-secondary{min-height:49px;padding:0 21px;border-radius:12px;display:inline-flex;align-items:center;justify-content:center;gap:8px;font-size:13px;font-weight:900}.p5-primary{background:linear-gradient(180deg,#d5a947,#bd8824);color:#fff;box-shadow:0 12px 27px rgba(172,120,20,.2)}.p5-secondary{background:#fff;border:1px solid #dcd4c8;color:#47413a}.p5-proof{margin-top:21px;display:flex;gap:18px;flex-wrap:wrap;color:#827c72;font-size:11px;font-weight:800}.p5-proof span{display:inline-flex;align-items:center;gap:6px}.p5-proof svg{color:var(--p5-gold)}.p5-finder-wrap{position:relative;z-index:8;margin-top:-48px}.p5-finder{padding:17px;border:1px solid #e5ddd1;border-radius:18px;background:rgba(255,255,255,.98);box-shadow:0 20px 54px rgba(59,49,35,.11);display:grid;grid-template-columns:1.1fr repeat(3,1fr) auto;gap:11px;align-items:stretch}.p5-finder-title{padding:6px 8px;display:flex;flex-direction:column;justify-content:center}.p5-finder-title span{color:var(--p5-gold-dark);font-size:11px;font-weight:900}.p5-finder-title h2{margin:3px 0 0;font-size:17px;font-weight:900}.p5-field{min-height:68px;padding:8px 12px;border:1px solid #e8e2d9;border-radius:12px;background:#fff;display:grid;gap:3px}.p5-field small{color:#8e887f;font-size:10px;font-weight:800}.p5-field select{width:100%;border:0;outline:0;background:transparent;font:inherit;color:#575149;font-size:12px}.p5-field:has(select:disabled){opacity:.5;background:#faf9f7}.p5-search-btn{min-width:112px;border-radius:12px;background:var(--p5-gold);color:#fff;display:inline-flex;align-items:center;justify-content:center;gap:7px;font-size:12px;font-weight:900}.p5-search-btn:disabled{opacity:.4;cursor:not-allowed}.p5-stats{padding:20px 0 14px}.p5-stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}.p5-stat{min-height:82px;padding:14px 16px;border:1px solid #ebe5dc;border-radius:15px;background:#fff;display:flex;align-items:center;gap:12px;box-shadow:0 6px 18px rgba(55,46,34,.035)}.p5-stat-icon{width:40px;height:40px;border-radius:12px;display:grid;place-items:center;background:var(--p5-gold-soft);color:var(--p5-gold-dark)}.p5-stat div{display:grid}.p5-stat strong{font-size:18px;font-weight:900}.p5-stat small{color:#918b82;font-size:10px}.p5-services{padding:42px 0 22px}.p5-section-head{display:flex;align-items:end;justify-content:space-between;gap:20px;margin-bottom:18px}.p5-section-head span{color:var(--p5-gold-dark);font-size:11px;font-weight:900}.p5-section-head h2{margin:5px 0 0;font-size:28px;font-weight:900}.p5-section-head>a{display:inline-flex;align-items:center;gap:6px;color:var(--p5-gold-dark);font-size:12px;font-weight:900}.p5-services-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:11px}.p5-service{position:relative;min-height:190px;padding:17px;border:1px solid #e9e3d9;border-radius:16px;background:#fff;display:flex;flex-direction:column;justify-content:flex-end;overflow:hidden;box-shadow:0 8px 24px rgba(53,45,33,.04);transition:.2s ease}.p5-service:hover{transform:translateY(-4px);border-color:#d9c490;box-shadow:0 16px 34px rgba(53,45,33,.08)}.p5-service-art{position:absolute;right:16px;top:16px;width:78px;height:78px;border-radius:50%;display:grid;place-items:center;background:radial-gradient(circle,#fff 0%,#f7ecd6 70%);color:var(--p5-gold-dark)}.p5-service h3{margin:0;font-size:15px;font-weight:900}.p5-service p{margin:7px 0 0;max-width:150px;color:#898279;font-size:10px;line-height:1.65}.p5-card-arrow{position:absolute;left:15px;bottom:14px;width:30px;height:30px;border-radius:50%;display:grid;place-items:center;border:1px solid #eadfc9;color:var(--p5-gold-dark)}.p5-offer{padding:18px 0 72px}.p5-offer-card{min-height:150px;padding:25px 28px;border-radius:18px;overflow:hidden;display:grid;grid-template-columns:1.25fr .8fr auto auto;gap:26px;align-items:center;color:#fff;background:radial-gradient(circle at 58% 50%,rgba(201,155,55,.2),transparent 22%),linear-gradient(110deg,#102f23,#174532 65%,#0d2a1f);border:1px solid rgba(201,155,55,.35);box-shadow:0 15px 34px rgba(17,58,41,.11)}.p5-offer-copy span{color:#e0bd6e;font-size:11px;font-weight:900}.p5-offer-copy h2{margin:5px 0 0;font-size:22px;font-weight:900}.p5-offer-copy p{margin:6px 0 0;color:rgba(255,255,255,.63);font-size:11px}.p5-offer-visual{display:flex;align-items:center;justify-content:center;gap:6px}.p5-wheel,.p5-tire{width:72px;height:72px;border-radius:50%;display:grid;place-items:center;background:linear-gradient(145deg,#dfc787,#b58a2c);color:#112f23;border:5px solid rgba(255,255,255,.14)}.p5-tire{margin-right:-12px;transform:translateY(9px)}.p5-discount{width:86px;height:86px;border-radius:50%;display:grid;place-items:center;align-content:center;background:#fff6df;color:var(--p5-gold-dark);border:1px solid #e4c77e}.p5-discount small{font-size:9px}.p5-discount strong{font-size:29px;line-height:1}.p5-offer-card>a{min-width:128px;min-height:45px;padding:0 16px;border-radius:11px;background:linear-gradient(180deg,#d7aa48,#b98422);color:#fff;display:inline-flex;align-items:center;justify-content:center;gap:7px;font-size:12px;font-weight:900}@media(max-width:1120px){.p5-hero-grid{grid-template-columns:1fr .9fr;gap:30px}.p5-finder{grid-template-columns:repeat(2,1fr)}.p5-finder-title{grid-column:1/-1}.p5-search-btn{min-height:56px}.p5-services-grid{grid-template-columns:repeat(3,1fr)}}@media(max-width:820px){.p5-hero-grid{grid-template-columns:1fr;padding-top:38px;padding-bottom:78px}.p5-showcase{order:2;min-height:270px}.p5-hero-copy{order:1}.p5-stats-grid{grid-template-columns:repeat(2,1fr)}.p5-services-grid{grid-template-columns:repeat(2,1fr)}.p5-offer-card{grid-template-columns:1fr auto}.p5-offer-visual{display:none}}@media(max-width:600px){.p5-hero-grid{padding-top:30px;gap:12px}.p5-hero-copy h1{font-size:37px}.p5-actions{display:grid}.p5-primary,.p5-secondary{width:100%}.p5-proof{display:grid;gap:7px}.p5-showcase{min-height:220px}.p5-arch{width:250px;height:190px}.p5-car{width:260px}.p5-brand-box,.p5-parts{display:none}.p5-finder-wrap{margin-top:-33px}.p5-finder{grid-template-columns:1fr;padding:13px}.p5-finder-title{grid-column:auto}.p5-search-btn{min-height:52px}.p5-stats-grid{grid-template-columns:repeat(2,1fr)}.p5-section-head{align-items:flex-start;flex-direction:column}.p5-section-head h2{font-size:23px}.p5-services-grid{grid-template-columns:1fr}.p5-service{min-height:165px}.p5-offer{padding-bottom:90px}.p5-offer-card{grid-template-columns:1fr;gap:14px;padding:21px}.p5-discount{width:75px;height:75px}.p5-offer-card>a{width:100%}}
EOF

echo "Concept 01 V5 files written."
