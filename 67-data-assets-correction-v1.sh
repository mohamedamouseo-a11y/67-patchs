#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-data-assets-correction-v1-$STAMP"

HOME="$ROOT/src/components/HomeBelowHero.jsx"
HOME_CSS="$ROOT/src/components/HomeBelowHero.css"
TOP="$ROOT/src/pages/TopPartsPage.jsx"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
CART="$ROOT/src/pages/CartPage.jsx"

for f in "$HOME" "$HOME_CSS" "$TOP" "$TOP_CSS" "$CART" \
  "$ROOT/src/data/brands.js" "$ROOT/src/data/mockOffers.js" \
  "$ROOT/src/assets/brands/toyota.svg" "$ROOT/src/assets/brands/nissan.svg" \
  "$ROOT/src/assets/brands/honda.svg" "$ROOT/src/assets/brands/hyundai.svg" \
  "$ROOT/src/assets/brands/kia.svg" "$ROOT/src/assets/brands/chevrolet.svg" \
  "$ROOT/src/assets/brands/gmc.svg" "$ROOT/src/assets/brands/ford.svg" \
  "$ROOT/public/images/parts/ac_new.jpg" "$ROOT/public/images/parts/brakes.jpg" \
  "$ROOT/public/images/parts/gearbox.jpg" "$ROOT/public/images/parts/fender.jpg"; do
  [ -f "$f" ] || { echo "ERROR: missing original project data/asset: $f" >&2; exit 601; }
done

mkdir -p "$BACKUP"
cp -a "$HOME" "$BACKUP/HomeBelowHero.jsx"
cp -a "$HOME_CSS" "$BACKUP/HomeBelowHero.css"
cp -a "$TOP" "$BACKUP/TopPartsPage.jsx"
cp -a "$TOP_CSS" "$BACKUP/TopPartsPage.css"
cp -a "$CART" "$BACKUP/CartPage.jsx"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/HomeBelowHero.jsx" "$HOME" || true
  cp -f "$BACKUP/HomeBelowHero.css" "$HOME_CSS" || true
  cp -f "$BACKUP/TopPartsPage.jsx" "$TOP" || true
  cp -f "$BACKUP/TopPartsPage.css" "$TOP_CSS" || true
  cp -f "$BACKUP/CartPage.jsx" "$CART" || true
  echo "ERROR: correction batch failed; restored original files" >&2
  exit "$code"
}
trap rollback ERR

python3 - "$HOME" "$HOME_CSS" "$TOP" "$TOP_CSS" "$CART" <<'PY'
from pathlib import Path
import re, sys

home = Path(sys.argv[1])
home_css = Path(sys.argv[2])
top = Path(sys.argv[3])
top_css = Path(sys.argv[4])
cart = Path(sys.argv[5])

# ---------------- HOME ----------------
s = home.read_text(encoding='utf-8')
if "from '../data/brands'" not in s:
    raise SystemExit('ERROR: HomeBelowHero brands source missing')
if "const popularParts = [" not in s:
    raise SystemExit('ERROR: HomeBelowHero expected popularParts block missing')

imports = """import { mockOffers } from '../data/mockOffers';
import toyotaLogo from '../assets/brands/toyota.svg';
import nissanLogo from '../assets/brands/nissan.svg';
import hondaLogo from '../assets/brands/honda.svg';
import hyundaiLogo from '../assets/brands/hyundai.svg';
import kiaLogo from '../assets/brands/kia.svg';
import chevroletLogo from '../assets/brands/chevrolet.svg';
import gmcLogo from '../assets/brands/gmc.svg';
import fordLogo from '../assets/brands/ford.svg';
"""
s = s.replace("import { brands } from '../data/brands';\n", "import { brands } from '../data/brands';\n" + imports)

s, n = re.subn(r"\nconst popularParts = \[.*?\n\];\n", "\n", s, count=1, flags=re.S)
if n != 1:
    raise SystemExit('ERROR: unable to remove old Home popularParts mock list')

insert = """
const brandLogos = {
  toyota: toyotaLogo,
  nissan: nissanLogo,
  honda: hondaLogo,
  hyundai: hyundaiLogo,
  kia: kiaLogo,
  chevrolet: chevroletLogo,
  gmc: gmcLogo,
  ford: fordLogo,
};

const homeProducts = mockOffers.slice(0, 4);
"""
s = s.replace("\nconst stats = [", insert + "\nconst stats = [")
s = s.replace("{popularParts.map((part, index) => (", "{homeProducts.map((part, index) => (")
s = s.replace(
"""<div className=\"b01h-part-visual\">\n                  <span className=\"b01h-watermark\">67</span>\n                  <CarFront size={54} strokeWidth={1.25} />\n                  <span className=\"b01h-rank\">#{index + 1}</span>\n                </div>""",
"""<div className=\"b01h-part-visual\">\n                  <img className=\"b01h-part-image\" src={part.image} alt={part.partNameAr} />\n                  <span className=\"b01h-rank\">#{index + 1}</span>\n                </div>""")
s = s.replace(
"""<small>قطعة مطلوبة</small>\n                  <strong>{part.name}</strong>\n                  <div className=\"b01h-part-meta\">\n                    <span>{part.searches} عملية بحث</span>\n                    <b>{part.trend}</b>\n                  </div>""",
"""<small>{part.conditionAr} · {part.brandAr}</small>\n                  <strong>{part.partNameAr}</strong>\n                  <div className=\"b01h-part-meta\">\n                    <span>{part.storeNameAr}</span>\n                    <b>{part.price} {part.currency}</b>\n                  </div>""")
s = s.replace(
"<span className=\"b01h-brand-mark\">{brand.name.slice(0, 2).toUpperCase()}</span>",
"{brandLogos[brand.id] ? <img className=\"b01h-brand-logo\" src={brandLogos[brand.id]} alt={`${brand.nameAr} - ${brand.name}`} /> : <span className=\"b01h-brand-mark\">{brand.name}</span>}"
)

for marker in ("mockOffers.slice(0, 4)", "toyotaLogo", "b01h-part-image", "b01h-brand-logo", "part.partNameAr"):
    if marker not in s:
        raise SystemExit(f'ERROR: Home correction marker missing: {marker}')
home.write_text(s, encoding='utf-8')

hc = home_css.read_text(encoding='utf-8')
block = """

/* ORIGINAL PROJECT DATA/ASSETS CORRECTION V1 */
.b01h-part-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  padding: 16px;
  background: #fff;
}
.b01h-brand-logo {
  width: 76px;
  height: 52px;
  object-fit: contain;
  display: block;
}
.b01h-brand-card.is-active .b01h-brand-logo {
  background: #fff;
  border-radius: 10px;
  padding: 5px;
}
"""
if 'ORIGINAL PROJECT DATA/ASSETS CORRECTION V1' not in hc:
    hc += block
home_css.write_text(hc, encoding='utf-8')

# ---------------- TOP PARTS ----------------
ts = top.read_text(encoding='utf-8')
if 'const TOP_PARTS = [' not in ts:
    raise SystemExit('ERROR: TopParts original list missing')
helper = """

const ORIGINAL_PART_IMAGE_RULES = [
  { match: 'كمبروسر', src: '/images/parts/ac_new.jpg' },
  { match: 'فحمات', src: '/images/parts/brakes.jpg' },
  { match: 'قير', src: '/images/parts/gearbox.jpg' },
  { match: 'رفرف', src: '/images/parts/fender.jpg' },
];

const getOriginalPartImage = (name) =>
  ORIGINAL_PART_IMAGE_RULES.find((item) => name.includes(item.match))?.src || null;
"""
# insert after TOP_PARTS array
m = re.search(r"const TOP_PARTS = \[.*?\n\];", ts, flags=re.S)
if not m:
    raise SystemExit('ERROR: unable to locate TopParts array end')
ts = ts[:m.end()] + helper + ts[m.end():]
old_visual = """<span className=\"b01p-card-watermark\">67</span>\n                        <CarFront size={72} strokeWidth={1.05} />"""
new_visual = """{getOriginalPartImage(part.name) ? (\n                          <img className=\"b01p-card-image\" src={getOriginalPartImage(part.name)} alt={part.name} />\n                        ) : (\n                          <div className=\"b01p-no-original-image\">\n                            <Package size={40} strokeWidth={1.2} />\n                            <span>لا توجد صورة أصلية لهذه القطعة</span>\n                          </div>\n                        )}"""
if old_visual not in ts:
    raise SystemExit('ERROR: TopParts visual block not found')
ts = ts.replace(old_visual, new_visual, 1)
for marker in ('ORIGINAL_PART_IMAGE_RULES', '/images/parts/ac_new.jpg', 'b01p-card-image', 'لا توجد صورة أصلية لهذه القطعة'):
    if marker not in ts:
        raise SystemExit(f'ERROR: TopParts correction marker missing: {marker}')
top.write_text(ts, encoding='utf-8')

tc = top_css.read_text(encoding='utf-8')
tblock = """

/* ORIGINAL PROJECT PRODUCT IMAGES V1 */
.b01p-card-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  padding: 14px;
  background: #fff;
}
.b01p-no-original-image {
  display: grid;
  justify-items: center;
  gap: 10px;
  color: #9b998f;
  font-size: 10px;
  text-align: center;
}
.b01p-no-original-image svg { color: #b9a052; }
"""
if 'ORIGINAL PROJECT PRODUCT IMAGES V1' not in tc:
    tc += tblock
top_css.write_text(tc, encoding='utf-8')

# ---------------- CART ----------------
cs = cart.read_text(encoding='utf-8')
repls = {
"{ id: '1', name: 'كمبروسر مكيف كامري 2020', price: 750, quantity: 1, image: null, condition: 'جديد' }":
"{ id: '1', name: 'كمبروسر مكيف كامري 2020', price: 750, quantity: 1, image: '/images/parts/ac_new.jpg', condition: 'جديد' }",
"{ id: '2', name: 'فحمات فرامل أمامية', price: 180, quantity: 2, image: null, condition: 'جديد' }":
"{ id: '2', name: 'فحمات فرامل أمامية', price: 180, quantity: 2, image: '/images/parts/brakes.jpg', condition: 'جديد' }",
}
for old, new in repls.items():
    if old not in cs:
        raise SystemExit(f'ERROR: Cart original item marker missing: {old[:40]}')
    cs = cs.replace(old, new, 1)
cart.write_text(cs, encoding='utf-8')

print('ORIGINAL_PROJECT_BRANDS_DATA_PRESERVED')
print('ORIGINAL_PROJECT_BRAND_LOGOS_APPLIED')
print('ORIGINAL_PROJECT_PRODUCT_IMAGES_APPLIED')
print('NO_INVENTED_PRODUCT_IMAGES_ADDED')
PY

# Final guards: original source files/assets are referenced, not recreated.
grep -q "from '../data/brands'" "$HOME"
grep -q "from '../data/mockOffers'" "$HOME"
grep -q "../assets/brands/toyota.svg" "$HOME"
grep -q "/images/parts/ac_new.jpg" "$HOME"
grep -q "/images/parts/brakes.jpg" "$TOP"
grep -q "/images/parts/gearbox.jpg" "$TOP"
grep -q "/images/parts/ac_new.jpg" "$CART"
grep -q "/images/parts/brakes.jpg" "$CART"

# No API/backend layer is touched here.
if grep -Eq "fetch\(|axios|/api/" "$HOME" "$TOP" "$CART"; then
  echo 'ERROR: unexpected API/network call introduced by correction batch' >&2
  false
fi

echo 'DATA_ASSETS_CORRECTION_V1_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/components/HomeBelowHero.jsx'
echo '  src/components/HomeBelowHero.css'
echo '  src/pages/TopPartsPage.jsx'
echo '  src/pages/TopPartsPage.css'
echo '  src/pages/CartPage.jsx'
