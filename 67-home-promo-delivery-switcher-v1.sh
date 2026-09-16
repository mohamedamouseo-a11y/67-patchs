#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HOME="$ROOT/src/components/HomeBelowHero.jsx"
CSS="$ROOT/src/components/HomeBelowHero.css"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-home-promo-switcher-v1-$STAMP"

[ -f "$HOME" ] || { echo "ERROR: missing $HOME" >&2; exit 1601; }
[ -f "$CSS" ] || { echo "ERROR: missing $CSS" >&2; exit 1602; }

grep -q 'b01h-delivery-section' "$HOME" || { echo 'ERROR: delivery section marker missing' >&2; exit 1603; }
grep -q 'mockOffers' "$HOME" || { echo 'ERROR: original project product source marker missing' >&2; exit 1604; }

mkdir -p "$BACKUP"
cp -a "$HOME" "$BACKUP/HomeBelowHero.jsx"
cp -a "$CSS" "$BACKUP/HomeBelowHero.css"

PROTECTED=(
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/pages/TopPartsPage.css"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)
HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 1605; }
  sha256sum "$f" >> "$HASHES"
done

rollback(){
  code=$?
  trap - ERR
  cp -f "$BACKUP/HomeBelowHero.jsx" "$HOME" || true
  cp -f "$BACKUP/HomeBelowHero.css" "$CSS" || true
  echo 'ERROR: Home promo/delivery switcher failed; restored target files' >&2
  exit "$code"
}
trap rollback ERR

python3 - "$HOME" "$CSS" <<'PY'
from pathlib import Path
import re, sys

home_path = Path(sys.argv[1])
css_path = Path(sys.argv[2])
s = home_path.read_text(encoding='utf-8')

# Ensure useState exists. Current redesigned Home already uses it, but keep patch robust.
if "useState" not in s.split('\n', 3)[0:3].__str__():
    if "import React" in s:
        pass
    elif "import { useState } from 'react';" not in s:
        s = "import { useState } from 'react';\n" + s

# Add switcher state after navigate if not already present.
if 'const [promoSlide, setPromoSlide]' not in s:
    nav = '  const navigate = useNavigate();'
    if nav not in s:
        raise SystemExit('ERROR: navigate marker missing')
    s = s.replace(nav, nav + "\n  const [promoSlide, setPromoSlide] = useState(0);", 1)

# Resolve promotional product visuals strictly from the project's existing product data.
if 'const promoBrakeOffer' not in s:
    anchor_candidates = [
        '  const visibleBrands = brands.slice(0, 8);',
        '  const filteredHomeProducts =',
        '  return ('
    ]
    insert_at = None
    for a in anchor_candidates:
        pos = s.find(a)
        if pos != -1:
            insert_at = pos
            break
    if insert_at is None:
        raise SystemExit('ERROR: unable to find component insertion point')
    data_block = """  const promoBrakeOffer = mockOffers.find((offer) => (offer.partNameAr || '').includes('فحمات') || (offer.partNameAr || '').includes('فرامل'));
  const promoAcOffer = mockOffers.find((offer) => (offer.partNameAr || '').includes('كمبروسر') || (offer.partNameAr || '').includes('مكيف'));

"""
    s = s[:insert_at] + data_block + s[insert_at:]

new_section = r'''      <section className="b01h-delivery-section b01h-promo-section">
        <div className="b01h-shell">
          <div className="b01h-delivery-card b01h-promo-slider">
            <div className="b01h-promo-stage" key={promoSlide}>
              {promoSlide === 0 ? (
                <>
                  <div className="b01h-promo-visual b01h-promo-products" aria-hidden="true">
                    <div className="b01h-promo-badge">
                      <strong>عروض</strong>
                      <span>يومية</span>
                    </div>
                    {promoAcOffer?.image && (
                      <div className="b01h-promo-polaroid is-small">
                        <img src={promoAcOffer.image} alt="" />
                      </div>
                    )}
                    {promoBrakeOffer?.image && (
                      <div className="b01h-promo-polaroid is-large">
                        <img src={promoBrakeOffer.image} alt="" />
                      </div>
                    )}
                  </div>

                  <div className="b01h-delivery-copy b01h-promo-copy">
                    <span className="b01h-kicker">عروض 67 اليومية</span>
                    <h2>عروض حصرية <em>كل يوم</em></h2>
                    <p>اكتشف عروض القطع المتاحة في 67، بصور المنتجات الموجودة أصلًا في بيانات المشروع.</p>
                    <button type="button" onClick={() => navigate('/daily-deals')}>تصفح العروض <ArrowLeft size={15} /></button>
                  </div>
                </>
              ) : (
                <>
                  <div className="b01h-promo-visual b01h-promo-delivery-mark" aria-hidden="true">
                    <div className="b01h-24-mark">
                      <span>خلال</span>
                      <strong>24</strong>
                      <small>ساعة</small>
                    </div>
                    <Truck size={66} />
                  </div>

                  <div className="b01h-delivery-copy b01h-promo-copy">
                    <span className="b01h-kicker">توصيل سريع ومضمون</span>
                    <h2>طلبك يوصل <em>خلال 24 ساعة</em></h2>
                    <p>احصل على طلبك بسرعة مع تجربة توصيل سهلة وموثوقة.</p>
                    <button type="button" onClick={() => navigate('/top-parts')}>اكتشف الخدمات <ArrowLeft size={15} /></button>
                  </div>
                </>
              )}
            </div>

            <div className="b01h-promo-controls" aria-label="التنقل بين عروض 67">
              <div className="b01h-promo-arrows">
                <button type="button" aria-label="السابق" onClick={() => setPromoSlide((slide) => (slide === 0 ? 1 : 0))}>←</button>
                <button type="button" aria-label="التالي" onClick={() => setPromoSlide((slide) => (slide === 0 ? 1 : 0))}>→</button>
              </div>
              <div className="b01h-promo-dots" role="tablist" aria-label="شرائح العروض">
                {[0, 1].map((slide) => (
                  <button
                    key={slide}
                    type="button"
                    role="tab"
                    aria-selected={promoSlide === slide}
                    aria-label={`الشريحة ${slide + 1}`}
                    className={promoSlide === slide ? 'is-active' : ''}
                    onClick={() => setPromoSlide(slide)}
                  />
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>'''

pattern = r'\s*<section className="b01h-delivery-section(?: [^"]*)?">[\s\S]*?</section>'
s2, count = re.subn(pattern, '\n' + new_section, s, count=1)
if count != 1:
    raise SystemExit('ERROR: unable to replace delivery section')
s = s2

for marker in [
    'const [promoSlide, setPromoSlide]',
    'const promoBrakeOffer',
    'const promoAcOffer',
    'b01h-promo-slider',
    "navigate('/daily-deals')",
    "promoSlide === 0",
]:
    if marker not in s:
        raise SystemExit(f'ERROR: final JSX marker missing: {marker}')

home_path.write_text(s, encoding='utf-8')

css = css_path.read_text(encoding='utf-8')
marker = '/* HOME PROMO + DELIVERY SWITCHER V1 */'
if marker in css:
    css = css[:css.index(marker)].rstrip() + '\n'
css += r'''

/* HOME PROMO + DELIVERY SWITCHER V1 */
.b01h-promo-section {
  padding: 86px 0;
  background: #fff;
}

.b01h-promo-slider {
  position: relative;
  min-height: 430px;
  padding: 0 !important;
  display: block !important;
  overflow: hidden;
  border-radius: 28px;
  background:
    radial-gradient(circle at 84% -12%, rgba(210,169,30,.22), transparent 29%),
    radial-gradient(circle at 18% 120%, rgba(210,169,30,.13), transparent 28%),
    linear-gradient(120deg, #171816 0%, #090a09 56%, #171405 100%);
  color: #fff;
}

.b01h-promo-stage {
  min-height: 430px;
  padding: 58px 76px 92px;
  display: grid;
  grid-template-columns: minmax(0, .95fr) minmax(0, 1.05fr);
  grid-template-areas: "visual copy";
  align-items: center;
  gap: 72px;
  direction: ltr;
  animation: b01hPromoFade .28s ease both;
}

@keyframes b01hPromoFade {
  from { opacity: .18; transform: translateY(6px); }
  to { opacity: 1; transform: translateY(0); }
}

.b01h-promo-copy {
  grid-area: copy;
  width: 100%;
  direction: rtl;
  text-align: right;
}

.b01h-promo-copy .b01h-kicker {
  color: #d9b329;
}

.b01h-promo-copy h2 {
  margin: 12px 0 18px;
  color: #fff !important;
  font-size: clamp(42px, 4vw, 64px);
  line-height: 1.14;
  font-weight: 950;
  letter-spacing: -1.2px;
}

.b01h-promo-copy h2 em {
  color: #d9b329 !important;
  font-style: normal;
}

.b01h-promo-copy p {
  max-width: 620px;
  margin: 0;
  color: rgba(255,255,255,.78) !important;
  font-size: 14px;
  line-height: 1.95;
}

.b01h-promo-copy button {
  margin-top: 30px;
  min-height: 52px;
  padding: 0 24px;
  border: 0;
  border-radius: 999px;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: #d9b329;
  color: #11120f;
  font-weight: 900;
  cursor: pointer;
}

.b01h-promo-visual {
  grid-area: visual;
  min-height: 280px;
  position: relative;
  direction: rtl;
}

.b01h-promo-products {
  display: flex;
  align-items: center;
  justify-content: center;
}

.b01h-promo-polaroid {
  position: absolute;
  padding: 18px;
  border-radius: 22px;
  background: #f7f7f5;
  box-shadow: 0 22px 50px rgba(0,0,0,.25);
}

.b01h-promo-polaroid img {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: contain;
  background: #efefec;
}

.b01h-promo-polaroid.is-large {
  width: 300px;
  height: 300px;
  right: 42px;
  top: -8px;
  transform: rotate(4deg);
}

.b01h-promo-polaroid.is-small {
  width: 230px;
  height: 230px;
  left: 26px;
  bottom: -20px;
  z-index: 2;
  transform: rotate(-5deg);
}

.b01h-promo-badge {
  position: absolute;
  left: 105px;
  top: 0;
  z-index: 4;
  width: 112px;
  height: 112px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  align-content: center;
  background: #d9b329;
  color: #11120f;
  box-shadow: 0 12px 28px rgba(0,0,0,.18);
}

.b01h-promo-badge strong {
  font-size: 24px;
  line-height: 1;
}

.b01h-promo-badge span {
  margin-top: 6px;
  font-size: 14px;
}

.b01h-promo-delivery-mark {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 48px;
  color: rgba(217,179,41,.55);
}

.b01h-promo-delivery-mark .b01h-24-mark {
  width: 220px;
  height: 220px;
  justify-self: auto;
}

.b01h-promo-delivery-mark .b01h-24-mark span,
.b01h-promo-delivery-mark .b01h-24-mark small {
  color: rgba(255,255,255,.62);
  font-size: 14px;
}

.b01h-promo-controls {
  position: absolute;
  left: 54px;
  right: 54px;
  bottom: 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  direction: ltr;
  z-index: 5;
}

.b01h-promo-arrows {
  display: flex;
  gap: 10px;
}

.b01h-promo-arrows button {
  width: 42px;
  height: 42px;
  border: 1px solid rgba(255,255,255,.18);
  border-radius: 50%;
  background: rgba(255,255,255,.06);
  color: #fff;
  font-size: 18px;
  cursor: pointer;
}

.b01h-promo-dots {
  display: flex;
  align-items: center;
  gap: 8px;
}

.b01h-promo-dots button {
  width: 8px;
  height: 8px;
  padding: 0;
  border: 0;
  border-radius: 99px;
  background: rgba(255,255,255,.32);
  cursor: pointer;
  transition: width .2s ease, background .2s ease;
}

.b01h-promo-dots button.is-active {
  width: 30px;
  background: #d9b329;
}

@media (max-width: 980px) {
  .b01h-promo-stage {
    padding: 54px 44px 94px;
    gap: 34px;
  }
  .b01h-promo-polaroid.is-large { width: 245px; height: 245px; right: 22px; }
  .b01h-promo-polaroid.is-small { width: 190px; height: 190px; left: 10px; }
  .b01h-promo-badge { width: 92px; height: 92px; left: 72px; }
}

@media (max-width: 760px) {
  .b01h-promo-section { padding: 58px 0; }
  .b01h-promo-stage {
    min-height: 650px;
    grid-template-columns: 1fr;
    grid-template-areas: "copy" "visual";
    gap: 28px;
    padding: 42px 28px 92px;
  }
  .b01h-promo-copy h2 { font-size: 38px; }
  .b01h-promo-visual { min-height: 250px; }
  .b01h-promo-polaroid.is-large { width: 220px; height: 220px; right: 50%; transform: translateX(12%) rotate(4deg); }
  .b01h-promo-polaroid.is-small { width: 165px; height: 165px; left: 50%; transform: translateX(-80%) rotate(-5deg); }
  .b01h-promo-badge { width: 82px; height: 82px; left: 12%; top: 4px; }
  .b01h-promo-delivery-mark { min-height: 245px; gap: 24px; }
  .b01h-promo-delivery-mark .b01h-24-mark { width: 175px; height: 175px; }
  .b01h-promo-controls { left: 28px; right: 28px; }
}

@media (max-width: 480px) {
  .b01h-promo-stage { min-height: 620px; padding-inline: 20px; }
  .b01h-promo-copy h2 { font-size: 32px; }
  .b01h-promo-copy p { font-size: 14px; }
  .b01h-promo-polaroid.is-large { width: 190px; height: 190px; }
  .b01h-promo-polaroid.is-small { width: 145px; height: 145px; }
  .b01h-promo-delivery-mark svg { width: 48px; height: 48px; }
}
'''
css_path.write_text(css, encoding='utf-8')

final_css = css_path.read_text(encoding='utf-8')
for marker in [
    '/* HOME PROMO + DELIVERY SWITCHER V1 */',
    '.b01h-promo-slider',
    '.b01h-promo-dots button.is-active',
    'color: #fff !important;',
]:
    if marker not in final_css:
        raise SystemExit(f'ERROR: final CSS marker missing: {marker}')

print('HOME_PROMO_DELIVERY_SWITCHER_V1_READY')
print('PROMO_IMAGES_FROM_ORIGINAL_MOCKOFFERS')
print('TWO_SLIDES_WITH_ARROWS_AND_DOTS')
PY

sha256sum -c "$HASHES" >/dev/null

echo 'HOME_PROMO_DELIVERY_SWITCHER_V1_APPLIED'
echo 'NO_DATA_SOURCE_CHANGED'
echo 'CHANGED_FILES:'
echo '  src/components/HomeBelowHero.jsx'
echo '  src/components/HomeBelowHero.css'
