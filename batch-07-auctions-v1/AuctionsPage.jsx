import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Clock3, Gavel, Timer } from 'lucide-react';
import HomeStoreHeader from '../components/HomeStoreHeader';
import BottomNav from '../components/BottomNav';
import './AuctionsPage.css';

// Original project auction data. Keep this as the single source used by
// AuctionsPage and AuctionDetailPage.
export const auctionsData = [
  {
    id: 'ferrari',
    title: 'ماكينة فيراري 458',
    bids: 35,
    currentBid: 65000,
    timeLeft: '00:45:00',
    image: '/images/auctions/ferrari.jpg',
    description: 'ممشى قليل جداً، بحالة الوكالة. المحرك V8 أصلي ولم يتم فكه أو توضيبه سابقاً.',
    isHero: true,
  },
  {
    id: 'mustang',
    title: 'محرك موستنج 1969 كلاسيك',
    bids: 12,
    currentBid: 15000,
    timeLeft: '02:15:30',
    image: '/images/auctions/mustang.jpg',
    description: 'محرك V8 مجدد بالكامل بقطع غيار أصلية، جاهز للتركيب.',
  },
  {
    id: 'rims',
    title: 'جنوط مرسيدس AMG أصلية',
    bids: 8,
    currentBid: 3200,
    timeLeft: '05:40:00',
    image: '/images/auctions/rims.jpg',
    description: 'طقم جنوط مقاس 20 إنش أصلية نظيفة جداً بدون لحام أو طعوج.',
  },
  {
    id: 'lights',
    title: 'شمعات رنج روفر 2023',
    bids: 24,
    currentBid: 4500,
    timeLeft: '00:12:45',
    image: '/images/auctions/lights.jpg',
    description: 'شمعات LED أصلية وكالة مع توقيع الإضاءة المميز.',
  },
];

const AuctionsPage = () => {
  const navigate = useNavigate();
  const heroAuction = auctionsData.find((auction) => auction.isHero) || auctionsData[0];

  const openAuction = (auctionId) => {
    navigate(`/auction/${auctionId}`);
  };

  return (
    <div className="a67-page" dir="rtl">
      <header className="a67-header">
        <HomeStoreHeader />
      </header>

      <main>
        <section className="a67-hero">
          <div className="a67-hero-decor a67-hero-decor-one" aria-hidden="true" />
          <div className="a67-hero-decor a67-hero-decor-two" aria-hidden="true" />

          <div className="a67-shell a67-hero-grid">
            <div className="a67-hero-copy">
              <nav className="a67-breadcrumb" aria-label="مسار الصفحة">
                <button type="button" onClick={() => navigate('/store')}>الرئيسية</button>
                <span>/</span>
                <strong>المزادات</strong>
              </nav>

              <div className="a67-eyebrow"><i /> AUCTIONS 67</div>
              <h1>مزادات القطع <span>النادرة.</span></h1>
              <p>اختر أي قطعة من المزادات النشطة بالأسفل، واستعرض بياناتها ومزايداتها من نفس بيانات المشروع.</p>
              <button type="button" className="a67-dark-cta" onClick={() => document.getElementById('active-auctions')?.scrollIntoView({ behavior: 'smooth' })}>
                المزادات النشطة <ArrowLeft size={17} />
              </button>
            </div>

            <article className="a67-featured" onClick={() => openAuction(heroAuction.id)}>
              <div className="a67-featured-top">
                <span className="a67-counter">01 / 0{auctionsData.length}</span>
                <span className="a67-live"><i /> مزاد مميز</span>
              </div>

              <div className="a67-featured-image">
                <img src={heroAuction.image} alt={heroAuction.title} />
                <span><Gavel size={15} /> مزاد الوكالة</span>
              </div>

              <div className="a67-featured-body">
                <small>حالة القطعة</small>
                <h2>{heroAuction.title}</h2>
                <p>{heroAuction.description}</p>

                <div className="a67-featured-stats">
                  <div>
                    <span>أعلى مزايدة</span>
                    <strong>{heroAuction.currentBid.toLocaleString()} <em>ر.س</em></strong>
                  </div>
                  <div>
                    <span>عدد المزايدات</span>
                    <strong>{heroAuction.bids}</strong>
                  </div>
                  <div>
                    <span>الوقت المتبقي</span>
                    <strong className="is-time">{heroAuction.timeLeft}</strong>
                  </div>
                </div>

                <button type="button" onClick={(event) => { event.stopPropagation(); openAuction(heroAuction.id); }}>
                  زايد الآن <Gavel size={17} />
                </button>
              </div>
            </article>
          </div>
        </section>

        <section className="a67-active" id="active-auctions">
          <div className="a67-shell">
            <div className="a67-section-head">
              <div>
                <div className="a67-eyebrow"><i /> المزادات النشطة</div>
                <h2>اختر القطعة اللي عايز تعرف عنها أكثر.</h2>
                <p>اضغط على أي مزاد لاستعراض تفاصيله والمزايدة عليه بالقيم المسجلة في المشروع.</p>
              </div>
            </div>

            <div className="a67-grid">
              {auctionsData.map((auction, index) => (
                <article
                  className={`a67-card ${auction.isHero ? 'is-featured' : ''}`}
                  key={auction.id}
                  onClick={() => openAuction(auction.id)}
                >
                  <div className="a67-card-media">
                    <img src={auction.image} alt={auction.title} />
                    <span className="a67-card-status"><i /> {auction.isHero ? 'مزاد مميز' : 'مزاد نشط'}</span>
                    <span className="a67-card-time"><Clock3 size={14} /> {auction.timeLeft}</span>
                  </div>

                  <div className="a67-card-body">
                    <small>المزاد #{String(index + 1).padStart(2, '0')}</small>
                    <h3>{auction.title}</h3>
                    <p>{auction.description}</p>

                    <div className="a67-card-meta">
                      <div>
                        <span>أعلى مزايدة</span>
                        <strong>{auction.currentBid.toLocaleString()} <em>ر.س</em></strong>
                      </div>
                      <div>
                        <span>عدد المزايدات</span>
                        <strong>{auction.bids}</strong>
                      </div>
                    </div>

                    <button type="button" onClick={(event) => { event.stopPropagation(); openAuction(auction.id); }}>
                      زايد الآن <Gavel size={15} />
                    </button>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  );
};

export default AuctionsPage;
