import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Camera,
  Cpu,
  ImageUp,
  ListFilter,
  Mic,
  ScanLine,
  Search,
  Sparkles,
} from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import { brands } from '../data/brands';
import './PartSearchPage.css';

const PartSearchPage = () => {
  const { brandId, modelId, year } = useParams();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('ai');
  const [vinNumber, setVinNumber] = useState('');
  const [partNumber, setPartNumber] = useState('');
  const [isAiScanning, setIsAiScanning] = useState(false);

  const brand = brands.find((item) => item.id === brandId);
  const model = brand?.models.find((item) => item.id === modelId);

  const handleAiScan = () => {
    setIsAiScanning(true);
    setTimeout(() => {
      setIsAiScanning(false);
      navigate('/offers');
    }, 3000);
  };

  return (
    <div className="s67-page" dir="rtl">
      <section className="s67-hero">
        <HomeStoreHeader />
        <div className="s67-hero-overlay" aria-hidden="true" />
        <div className="s67-hero-shell">
          <div className="s67-hero-copy">
            <div className="s67-breadcrumb">
              <button type="button" onClick={() => navigate('/store')}>الرئيسية</button>
              <span>/</span>
              <strong>البحث</strong>
            </div>
            <span className="s67-kicker">بحث 67</span>
            <h1>اعثر على القطعة<br /><em>المناسبة.</em></h1>
            <p>ابحث باسم القطعة، رقم القطعة، رقم الهيكل أو استخدم الصورة للوصول إلى ما تحتاجه بسهولة.</p>
          </div>

          <div className="s67-hero-orb" aria-hidden="true">
            <Search size={54} />
          </div>
        </div>
      </section>

      <main className="s67-main">
        <div className="s67-shell">
          <section className="s67-workspace">
            <div className="s67-mode-tabs" role="tablist" aria-label="طرق البحث">
              <button type="button" className={activeTab === 'ai' ? 'is-active' : ''} onClick={() => setActiveTab('ai')}>
                <Cpu size={17} />
                البحث الذكي
              </button>
              <button type="button" className={activeTab === 'vin' ? 'is-active' : ''} onClick={() => setActiveTab('vin')}>
                <ScanLine size={17} />
                رقم الهيكل
              </button>
              <button type="button" className={activeTab === 'number' ? 'is-active' : ''} onClick={() => setActiveTab('number')}>
                <ListFilter size={17} />
                رقم القطعة
              </button>
            </div>

            {activeTab === 'ai' && (
              <div className="s67-ai-layout">
                <section className="s67-manual-search">
                  <span className="s67-kicker">أو ابحث بالاسم</span>
                  <h2>تعرف اسم القطعة؟</h2>
                  <p>اكتب اسم القطعة التي تبحث عنها وسنساعدك في الوصول إلى العروض المتاحة داخل 67.</p>

                  {brand && model && (
                    <div className="s67-car-summary">
                      <span>المركبة المحددة</span>
                      <strong>{brand.nameAr} {model.nameAr} - {year}</strong>
                    </div>
                  )}

                  <div className="s67-search-field">
                    <Search size={20} />
                    <input
                      type="text"
                      value={partNumber}
                      onChange={(event) => setPartNumber(event.target.value)}
                      placeholder="مثال: كمبروسر مكيف، قير، فحمات فرامل..."
                    />
                    <button type="button" onClick={() => navigate(`/offers?q=${encodeURIComponent(partNumber)}`)}>
                      بحث في العروض
                      <span>←</span>
                    </button>
                  </div>

                  <div className="s67-suggestions">
                    <span>اقتراحات سريعة:</span>
                    {['فحمات فرامل', 'كمبروسر مكيف', 'قير', 'فلتر', 'مساعدات'].map((suggestion) => (
                      <button type="button" key={suggestion} onClick={() => setPartNumber(suggestion)}>
                        {suggestion}
                      </button>
                    ))}
                  </div>
                </section>

                <div className="s67-divider"><span>أو</span></div>

                <section className="s67-image-search">
                  <div>
                    <span className="s67-kicker">التعرف الذكي</span>
                    <h2>صوّر القطعة</h2>
                    <p>يمكنك عرض صورة واضحة للقطعة لتجربة البحث الحالية في الموقع.</p>
                  </div>

                  <div className={`s67-upload-box ${isAiScanning ? 'is-scanning' : ''}`}>
                    {isAiScanning ? (
                      <>
                        <div className="s67-scan-line" />
                        <Sparkles size={34} />
                        <h3>جاري التعرف على القطعة...</h3>
                        <p>يرجى الانتظار حتى تنتهي عملية الفحص.</p>
                      </>
                    ) : (
                      <>
                        <div className="s67-camera-icon"><Camera size={29} /></div>
                        <span>التعرف بالصورة</span>
                        <h3>ارفع صورة القطعة</h3>
                        <p>حاول استخدام صورة واضحة وتظهر فيها القطعة بالكامل.</p>
                        <div className="s67-upload-actions">
                          <button type="button" className="is-primary" onClick={handleAiScan}>
                            <ImageUp size={16} />
                            رفع صورة
                          </button>
                          <button type="button">
                            <Mic size={16} />
                            بحث صوتي
                          </button>
                        </div>
                      </>
                    )}
                  </div>

                  <aside className="s67-how-card">
                    <span>كيف نساعدك؟</span>
                    <h3>من الصورة إلى العروض.</h3>
                    <ol>
                      <li><b>01</b><span><strong>صوّر القطعة</strong><small>استخدم صورة واضحة للقطعة.</small></span></li>
                      <li><b>02</b><span><strong>تحليل ذكي</strong><small>تبدأ تجربة التعرف الحالية.</small></span></li>
                      <li><b>03</b><span><strong>مشاهدة العروض</strong><small>نقلك للعروض المتاحة.</small></span></li>
                    </ol>
                  </aside>
                </section>
              </div>
            )}

            {activeTab === 'vin' && (
              <section className="s67-simple-mode">
                <div className="s67-mode-icon"><ScanLine size={30} /></div>
                <span className="s67-kicker">بحث برقم الهيكل</span>
                <h2>أدخل رقم VIN</h2>
                <p>أدخل رقم الهيكل المكون من 17 حرفاً ورقماً.</p>
                <input
                  dir="ltr"
                  value={vinNumber}
                  onChange={(event) => setVinNumber(event.target.value.toUpperCase())}
                  maxLength={17}
                  placeholder="XXXXXXXXXXXXXXXXX"
                />
                <button type="button" onClick={() => navigate('/offers')}>
                  <Search size={18} />
                  فحص المركبة
                </button>
              </section>
            )}

            {activeTab === 'number' && (
              <section className="s67-simple-mode">
                <div className="s67-mode-icon"><ListFilter size={30} /></div>
                <span className="s67-kicker">بحث برقم القطعة</span>
                <h2>أدخل رقم القطعة</h2>
                <p>تتطابق مع سيارتك: {brand?.nameAr || 'غير محدد'}</p>
                <input
                  dir="ltr"
                  value={partNumber}
                  onChange={(event) => setPartNumber(event.target.value)}
                  placeholder="12345-ABCDE"
                />
                <button type="button" onClick={() => navigate('/offers')}>
                  <Search size={18} />
                  بحث الآن
                </button>
              </section>
            )}
          </section>

          <section className="s67-benefits">
            <article><b>01</b><h3>ابحث بطريقتك</h3><p>بنفس خيارات البحث المتاحة في المشروع الحالي.</p></article>
            <article className="is-dark"><b>02</b><h3>وصول أسرع</h3><p>انتقل من البحث مباشرة إلى العروض.</p></article>
            <article><b>03</b><h3>خيارات متعددة</h3><p>اسم القطعة، VIN، رقم القطعة أو الصورة.</p></article>
          </section>
        </div>
      </main>

      <BottomNav />
    </div>
  );
};

export default PartSearchPage;
