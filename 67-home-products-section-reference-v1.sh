#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-home-products-reference-v1-$STAMP"

HOME="$ROOT/src/components/HomeBelowHero.jsx"
HOME_CSS="$ROOT/src/components/HomeBelowHero.css"
OFFERS="$ROOT/src/data/mockOffers.js"

PROTECTED=(
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/pages/HomePage.css"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/pages/TopPartsPage.css"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

for f in "$HOME" "$HOME_CSS" "$OFFERS"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 801; }
done
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 802; }
done

mkdir -p "$BACKUP"
cp -a "$HOME" "$BACKUP/HomeBelowHero.jsx"
cp -a "$HOME_CSS" "$BACKUP/HomeBelowHero.css"

HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/HomeBelowHero.jsx" "$HOME" || true
  cp -f "$BACKUP/HomeBelowHero.css" "$HOME_CSS" || true
  echo "ERROR: Home products reference patch failed; target files restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - "$HOME" "$HOME_CSS" <<'PY'
from pathlib import Path
import re, sys

home_path = Path(sys.argv[1])
css_path = Path(sys.argv[2])
s = home_path.read_text(encoding='utf-8')

# The current local page must already be wired to the original project product data.
required = [
    "from '../data/mockOffers'",
    'mockOffers',
    'b01h-parts-section',
]
for marker in required:
    if marker not in s:
        raise SystemExit(f'ERROR: current Home original-data marker missing: {marker}')

# Add state import without disturbing existing imports.
if "import { useState } from 'react';" not in s:
    s = "import { useState } from 'react';\n" + s

# Replace the prior homeProducts declaration with a source-preserving presentation model.
model = r'''const HOME_PART_TABS = [
  { id: 'all', label: 'الأكثر طلباً' },
  { id: 'ac', label: 'التكييف' },
  { id: 'transmission', label: 'ناقل الحركة' },
  { id: 'body', label: 'الهيكل الخارجي' },
  { id: 'brakes', label: 'الفرامل' },
];

const getHomeProductCategory = (product) => {
  const name = product?.partNameAr || '';
  if (name.includes('كمبروسر') || name.includes('مكيف')) return 'ac';
  if (name.includes('قير')) return 'transmission';
  if (name.includes('رفرف') || name.includes('صدام')) return 'body';
  if (name.includes('فحمات') || name.includes('فرامل')) return 'brakes';
  return 'other';
};

const representativeProducts = ['ac', 'transmission', 'body', 'brakes']
  .map((category) => mockOffers.find((product) => getHomeProductCategory(product) === category))
  .filter(Boolean);
const representativeIds = new Set(representativeProducts.map((product) => product.id));
const homeProducts = [
  ...representativeProducts,
  ...mockOffers.filter((product) => !representativeIds.has(product.id)),
];'''

# Accept either the V2 simple declaration or a previous declaration, but only replace one.
patterns = [
    r"const homeProducts\s*=\s*mockOffers\.slice\([^;]+\);",
    r"const homeProducts\s*=\s*\[[\s\S]*?\];",
]
replaced = False
for pattern in patterns:
    s2, count = re.subn(pattern, model, s, count=1)
    if count == 1:
        s = s2
        replaced = True
        break
if not replaced and 'const HOME_PART_TABS' not in s:
    raise SystemExit('ERROR: unable to locate current homeProducts declaration')

# Add local UI state immediately after navigate.
state_marker = "  const navigate = useNavigate();"
state_block = """  const navigate = useNavigate();
  const [activePartTab, setActivePartTab] = useState('all');
  const [partPage, setPartPage] = useState(0);"""
if 'const [activePartTab' not in s:
    if state_marker not in s:
        raise SystemExit('ERROR: HomeBelowHero navigate marker missing')
    s = s.replace(state_marker, state_block, 1)

# Add derived original-data view model before return.
derived_marker = "  const visibleBrands = brands.slice(0, 8);"
derived_block = """  const visibleBrands = brands.slice(0, 8);
  const filteredHomeProducts = activePartTab === 'all'
    ? homeProducts
    : homeProducts.filter((product) => getHomeProductCategory(product) === activePartTab);
  const partPageCount = Math.max(1, Math.ceil(filteredHomeProducts.length / 4));
  const safePartPage = Math.min(partPage, partPageCount - 1);
  const visibleHomeProducts = filteredHomeProducts.slice(safePartPage * 4, safePartPage * 4 + 4);"""
if 'const filteredHomeProducts' not in s:
    if derived_marker not in s:
        raise SystemExit('ERROR: visibleBrands marker missing')
    s = s.replace(derived_marker, derived_block, 1)

new_section = r'''      <section className="b01h-section b01h-parts-section b01h-featured-parts">
        <div className="b01h-shell b01h-featured-shell">
          <div className="b01h-featured-head">
            <button className="b01h-featured-all" type="button" onClick={() => navigate('/top-parts')}>
              عرض الكل <ArrowLeft size={16} />
            </button>

            <div className="b01h-featured-copy">
              <span className="b01h-featured-kicker">الأكثر بحثاً</span>
              <h2>اكتشف القطع <em>الأكثر طلباً</em></h2>
              <p>نفس بيانات المنتجات الموجودة في مشروع 67، مع إعادة تصميم طريقة عرضها فقط.</p>

              <div className="b01h-featured-tabs" role="tablist" aria-label="تصنيف القطع">
                {HOME_PART_TABS.map((tab) => (
                  <button
                    type="button"
                    role="tab"
                    aria-selected={activePartTab === tab.id}
                    key={tab.id}
                    className={activePartTab === tab.id ? 'is-active' : ''}
                    onClick={() => {
                      setActivePartTab(tab.id);
                      setPartPage(0);
                    }}
                  >
                    {tab.label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="b01h-featured-divider" />

          <div className="b01h-featured-grid">
            {visibleHomeProducts.map((part, index) => {
              const categoryId = getHomeProductCategory(part);
              const categoryLabel = HOME_PART_TABS.find((tab) => tab.id === categoryId)?.label || 'قطع غيار';
              return (
                <button
                  className="b01h-featured-card"
                  type="button"
                  key={part.id}
                  onClick={() => navigate('/top-parts')}
                >
                  <div className="b01h-featured-visual">
                    {part.image ? (
                      <img src={part.image} alt={part.partNameAr} />
                    ) : (
                      <div className="b01h-featured-no-image"><CarFront size={52} /></div>
                    )}
                    <span className={`b01h-featured-badge ${index === 0 && activePartTab === 'all' ? 'is-dark' : ''}`}>
                      {index === 0 && activePartTab === 'all' ? 'الأكثر طلباً' : (part.brandAr || part.conditionAr)}
                    </span>
                  </div>

                  <div className="b01h-featured-body">
                    <small>{categoryLabel}</small>
                    <strong>{part.partNameAr}</strong>
                    <span>{part.conditionAr} · {part.brandAr} · {part.storeNameAr}</span>
                  </div>
                </button>
              );
            })}
          </div>

          <div className="b01h-featured-pager" aria-label="التنقل بين المنتجات">
            <div className="b01h-featured-pager-buttons">
              <button
                type="button"
                aria-label="الصفحة السابقة"
                disabled={safePartPage <= 0}
                onClick={() => setPartPage((page) => Math.max(0, page - 1))}
              >
                <ArrowLeft size={15} />
              </button>
              <button
                type="button"
                aria-label="الصفحة التالية"
                disabled={safePartPage >= partPageCount - 1}
                onClick={() => setPartPage((page) => Math.min(partPageCount - 1, page + 1))}
              >
                <ArrowLeft size={15} />
              </button>
            </div>

            <div className="b01h-featured-page-number">
              <b>{String(safePartPage + 1).padStart(2, '0')}</b>
              <span>/</span>
              <small>{String(partPageCount).padStart(2, '0')}</small>
            </div>

            <div className="b01h-featured-progress">
              <span style={{ width: `${((safePartPage + 1) / partPageCount) * 100}%` }} />
            </div>
          </div>
        </div>
      </section>'''

section_pattern = r'<section className="b01h-section b01h-parts-section(?: [^"]+)?">[\s\S]*?</section>'
s, count = re.subn(section_pattern, new_section, s, count=1)
if count != 1:
    raise SystemExit('ERROR: unable to replace current Home parts section')

for marker in [
    'b01h-featured-parts',
    'HOME_PART_TABS',
    'visibleHomeProducts',
    'part.partNameAr',
    'part.image',
    "navigate('/top-parts')",
]:
    if marker not in s:
        raise SystemExit(f'ERROR: final Home section marker missing: {marker}')

home_path.write_text(s, encoding='utf-8')

css = css_path.read_text(encoding='utf-8')
marker = '/* HOME FEATURED PRODUCTS — REFERENCE MATCH V1 */'
if marker not in css:
    css += r'''

/* HOME FEATURED PRODUCTS — REFERENCE MATCH V1 */
.b01h-featured-parts {
  padding: 92px 0 82px;
  background-color: #fff;
  background-image: radial-gradient(circle, rgba(201, 164, 45, .09) 1px, transparent 1.2px);
  background-size: 34px 34px;
  background-position: 8px 8px;
}

.b01h-featured-shell {
  position: relative;
}

.b01h-featured-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 72px;
  direction: ltr;
}

.b01h-featured-copy {
  width: min(780px, 100%);
  margin-left: auto;
  direction: rtl;
  text-align: right;
}

.b01h-featured-kicker {
  display: inline-flex;
  align-items: center;
  gap: 13px;
  color: #caa119;
  font-size: 13px;
  font-weight: 900;
  margin-bottom: 14px;
}

.b01h-featured-kicker::after {
  content: '';
  width: 34px;
  height: 1px;
  background: currentColor;
}

.b01h-featured-copy h2 {
  margin: 0;
  color: #11120f;
  font-size: clamp(42px, 4.3vw, 70px);
  line-height: 1.1;
  letter-spacing: -1.8px;
  font-weight: 950;
}

.b01h-featured-copy h2 em {
  color: #d2a91e;
  font-style: normal;
}

.b01h-featured-copy p {
  margin: 17px 0 0;
  color: #98968d;
  font-size: 13px;
  line-height: 1.8;
}

.b01h-featured-all {
  flex: 0 0 auto;
  margin-top: 72px;
  border: 0;
  background: transparent;
  color: #171815;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-weight: 900;
  cursor: pointer;
  direction: rtl;
  padding: 8px 0;
}

.b01h-featured-tabs {
  margin-top: 28px;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 34px;
  overflow-x: auto;
  scrollbar-width: none;
}

.b01h-featured-tabs::-webkit-scrollbar { display: none; }

.b01h-featured-tabs button {
  flex: 0 0 auto;
  position: relative;
  border: 0;
  background: transparent;
  color: #77766f;
  padding: 0 0 18px;
  font: inherit;
  font-size: 13px;
  font-weight: 800;
  cursor: pointer;
}

.b01h-featured-tabs button.is-active {
  color: #c89b0c;
}

.b01h-featured-tabs button.is-active::after {
  content: '';
  position: absolute;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 2px;
  background: #d2a91e;
}

.b01h-featured-divider {
  height: 1px;
  margin: 0 0 34px;
  background: #e5e4de;
}

.b01h-featured-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.b01h-featured-card {
  overflow: hidden;
  border: 1px solid #e5e3dc;
  border-radius: 20px;
  padding: 0;
  background: #fff;
  color: #11120f;
  text-align: right;
  cursor: pointer;
  transition: transform .22s ease, box-shadow .22s ease;
}

.b01h-featured-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 18px 45px rgba(25, 23, 17, .08);
}

.b01h-featured-visual {
  position: relative;
  height: 260px;
  display: grid;
  place-items: center;
  overflow: hidden;
  background: linear-gradient(145deg, #f4f4f2 0%, #eeeeeb 100%);
}

.b01h-featured-visual img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
  padding: 24px;
}

.b01h-featured-no-image {
  width: 100%;
  height: 100%;
  display: grid;
  place-items: center;
  color: #b7b4aa;
}

.b01h-featured-badge {
  position: absolute;
  top: 18px;
  right: 18px;
  min-width: 44px;
  min-height: 30px;
  padding: 0 12px;
  border-radius: 999px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #f2ecd7;
  color: #4a4433;
  font-size: 10px;
  font-weight: 900;
}

.b01h-featured-badge.is-dark {
  background: #11120f;
  color: #fff;
}

.b01h-featured-body {
  min-height: 150px;
  padding: 24px 24px 26px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  direction: rtl;
}

.b01h-featured-body small {
  color: #c39a11;
  font-size: 11px;
  font-weight: 900;
}

.b01h-featured-body strong {
  display: block;
  margin-top: 12px;
  color: #171815;
  font-size: 18px;
  line-height: 1.45;
  font-weight: 900;
}

.b01h-featured-body span {
  display: block;
  margin-top: 8px;
  color: #a09e96;
  font-size: 10px;
  line-height: 1.5;
}

.b01h-featured-pager {
  margin-top: 30px;
  display: grid;
  grid-template-columns: auto auto 1fr;
  align-items: center;
  gap: 20px;
  direction: ltr;
}

.b01h-featured-pager-buttons {
  display: flex;
  gap: 8px;
}

.b01h-featured-pager-buttons button {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1px solid #dddcd6;
  background: #fff;
  color: #161713;
  display: grid;
  place-items: center;
  cursor: pointer;
}

.b01h-featured-pager-buttons button:nth-child(2) svg {
  transform: rotate(180deg);
}

.b01h-featured-pager-buttons button:disabled {
  opacity: .35;
  cursor: default;
}

.b01h-featured-page-number {
  display: flex;
  align-items: center;
  gap: 7px;
  font-family: Arial, sans-serif;
  font-size: 10px;
}

.b01h-featured-page-number b { color: #151612; }
.b01h-featured-page-number span,
.b01h-featured-page-number small { color: #99978f; }

.b01h-featured-progress {
  position: relative;
  height: 2px;
  background: #dddcd6;
  overflow: hidden;
}

.b01h-featured-progress span {
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  background: #d2a91e;
  transition: width .25s ease;
}

@media (max-width: 1100px) {
  .b01h-featured-head { gap: 36px; }
  .b01h-featured-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .b01h-featured-visual { height: 280px; }
}

@media (max-width: 760px) {
  .b01h-featured-parts { padding: 68px 0; }
  .b01h-featured-head { flex-direction: column-reverse; gap: 12px; }
  .b01h-featured-all { margin-top: 0; }
  .b01h-featured-copy h2 { font-size: 42px; }
  .b01h-featured-tabs { gap: 22px; }
  .b01h-featured-divider { margin-top: 0; }
}

@media (max-width: 560px) {
  .b01h-featured-grid { grid-template-columns: 1fr; }
  .b01h-featured-visual { height: 260px; }
  .b01h-featured-pager { grid-template-columns: auto auto; }
  .b01h-featured-progress { grid-column: 1 / -1; }
}
'''
    css_path.write_text(css, encoding='utf-8')

print('HOME_PRODUCTS_REFERENCE_LAYOUT_V1_READY')
print('HOME_PRODUCTS_ORIGINAL_PROJECT_DATA_ONLY')
PY

# Verify only the intended target files changed.
while read -r expected_hash file; do
  actual_hash="$(sha256sum "$file" | awk '{print $1}')"
  if [ "$expected_hash" != "$actual_hash" ]; then
    echo "ERROR: protected file changed: $file" >&2
    false
  fi
done < "$HASHES"

# Final guards on original project data usage and reference layout.
grep -q "from '../data/mockOffers'" "$HOME"
grep -q 'HOME_PART_TABS' "$HOME"
grep -q 'visibleHomeProducts' "$HOME"
grep -q 'part.partNameAr' "$HOME"
grep -q 'part.image' "$HOME"
grep -q 'HOME FEATURED PRODUCTS — REFERENCE MATCH V1' "$HOME_CSS"
grep -q 'b01h-featured-grid' "$HOME_CSS"
grep -q 'b01h-featured-tabs' "$HOME_CSS"

# This is a frontend layout patch only. No API/backend source is introduced or modified.
if grep -Eq 'fetch\(|axios|/api/' "$HOME" "$HOME_CSS"; then
  echo 'ERROR: unexpected API/network call introduced in Home section patch' >&2
  false
fi

echo 'HOME_PRODUCTS_REFERENCE_LAYOUT_V1_APPLIED'
echo 'ORIGINAL_PRODUCT_DATA_SOURCE_PRESERVED'
echo 'OTHER_REDESIGNED_PAGES_UNCHANGED'
echo 'CHANGED_FILES:'
echo '  src/components/HomeBelowHero.jsx'
echo '  src/components/HomeBelowHero.css'
