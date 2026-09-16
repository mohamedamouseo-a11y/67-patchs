#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-data-assets-correction-v3-backup-$STAMP"

HOME="$ROOT/src/components/HomeBelowHero.jsx"
HOME_CSS="$ROOT/src/components/HomeBelowHero.css"
TOP="$ROOT/src/pages/TopPartsPage.jsx"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
CART="$ROOT/src/pages/CartPage.jsx"
BRANDS="$ROOT/src/data/brands.js"
OFFERS="$ROOT/src/data/mockOffers.js"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"

for f in "$HOME" "$HOME_CSS" "$TOP" "$TOP_CSS" "$CART" "$BRANDS" "$OFFERS" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 701; }
done

for f in \
  "$ROOT/src/assets/brands/toyota.svg" \
  "$ROOT/src/assets/brands/nissan.svg" \
  "$ROOT/src/assets/brands/honda.svg" \
  "$ROOT/src/assets/brands/hyundai.svg" \
  "$ROOT/src/assets/brands/kia.svg" \
  "$ROOT/src/assets/brands/chevrolet.svg" \
  "$ROOT/src/assets/brands/gmc.svg" \
  "$ROOT/src/assets/brands/ford.svg" \
  "$ROOT/public/images/parts/ac_new.jpg" \
  "$ROOT/public/images/parts/brakes.jpg" \
  "$ROOT/public/images/parts/gearbox.jpg" \
  "$ROOT/public/images/parts/fender.jpg"; do
  [ -f "$f" ] || { echo "ERROR: original project asset missing: $f" >&2; exit 702; }
done

mkdir -p "$BACKUP"
cp -a "$HOME_CSS" "$BACKUP/HomeBelowHero.css"
cp -a "$TOP_CSS" "$BACKUP/TopPartsPage.css"

BRANDS_BEFORE="$(sha256sum "$BRANDS" | awk '{print $1}')"
OFFERS_BEFORE="$(sha256sum "$OFFERS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_BEFORE="$(sha256sum "$LOGO" | awk '{print $1}')"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/HomeBelowHero.css" "$HOME_CSS" || true
  cp -f "$BACKUP/TopPartsPage.css" "$TOP_CSS" || true
  echo "ERROR: V3 style finalizer failed; CSS restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - "$HOME" "$TOP" "$CART" "$HOME_CSS" "$TOP_CSS" <<'PY'
from pathlib import Path
import sys

home = Path(sys.argv[1]).read_text(encoding='utf-8')
top = Path(sys.argv[2]).read_text(encoding='utf-8')
cart = Path(sys.argv[3]).read_text(encoding='utf-8')
home_css_path = Path(sys.argv[4])
top_css_path = Path(sys.argv[5])

# Validate the manual V2 data/assets wiring that already exists in /67.
home_markers = [
    "from '../data/brands'",
    "from '../data/mockOffers'",
    "toyotaLogo",
    "const brandLogos",
    "const homeProducts = mockOffers.slice(0, 4)",
    "b01h-part-image",
    "b01h-brand-logo",
    "part.partNameAr",
    "part.storeNameAr",
]
for marker in home_markers:
    if marker not in home:
        raise SystemExit(f'ERROR: Home V2 wiring marker missing: {marker}')

top_markers = [
    'ORIGINAL_PART_IMAGE_RULES',
    'getOriginalPartImage',
    '/images/parts/ac_new.jpg',
    '/images/parts/brakes.jpg',
    '/images/parts/gearbox.jpg',
    'b01p-card-image',
    'b01p-no-original-image',
]
for marker in top_markers:
    if marker not in top:
        raise SystemExit(f'ERROR: TopParts V2 wiring marker missing: {marker}')

cart_markers = [
    "/images/parts/ac_new.jpg",
    "/images/parts/brakes.jpg",
]
for marker in cart_markers:
    if marker not in cart:
        raise SystemExit(f'ERROR: Cart V2 original-image marker missing: {marker}')

# Append only the CSS required by the already-applied JSX wiring.
home_css = home_css_path.read_text(encoding='utf-8')
home_marker = '/* ORIGINAL PROJECT DATA/ASSETS CORRECTION V3 */'
if home_marker not in home_css:
    home_css += r'''

/* ORIGINAL PROJECT DATA/ASSETS CORRECTION V3 */
.b01h-part-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
  padding: 16px;
  background: #fff;
}

.b01h-brand-logo {
  width: 78px;
  height: 56px;
  max-width: 82%;
  object-fit: contain;
  display: block;
}

.b01h-brand-card.is-active .b01h-brand-logo {
  background: #fff;
  border-radius: 10px;
  padding: 6px;
}
'''
    home_css_path.write_text(home_css, encoding='utf-8')


top_css = top_css_path.read_text(encoding='utf-8')
top_marker = '/* ORIGINAL PROJECT PRODUCT IMAGES V3 */'
if top_marker not in top_css:
    top_css += r'''

/* ORIGINAL PROJECT PRODUCT IMAGES V3 */
.b01p-card-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
  padding: 14px;
  background: #fff;
}

.b01p-no-original-image {
  width: 100%;
  height: 100%;
  display: grid;
  place-items: center;
  align-content: center;
  gap: 10px;
  padding: 20px;
  color: #9b998f;
  font-size: 10px;
  text-align: center;
}

.b01p-no-original-image svg {
  color: #b9a052;
}
'''
    top_css_path.write_text(top_css, encoding='utf-8')

print('MANUAL_V2_DATA_WIRING_VERIFIED')
print('ORIGINAL_PROJECT_ASSET_STYLING_V3_READY')
PY

# Original data/assets themselves must remain byte-identical.
BRANDS_AFTER="$(sha256sum "$BRANDS" | awk '{print $1}')"
OFFERS_AFTER="$(sha256sum "$OFFERS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_AFTER="$(sha256sum "$LOGO" | awk '{print $1}')"

[ "$BRANDS_BEFORE" = "$BRANDS_AFTER" ] || { echo 'ERROR: brands.js changed' >&2; false; }
[ "$OFFERS_BEFORE" = "$OFFERS_AFTER" ] || { echo 'ERROR: mockOffers.js changed' >&2; false; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo 'ERROR: hero-car.jpg changed' >&2; false; }
[ "$LOGO_BEFORE" = "$LOGO_AFTER" ] || { echo 'ERROR: logo-67.png changed' >&2; false; }

# Final presentation guards.
grep -q 'ORIGINAL PROJECT DATA/ASSETS CORRECTION V3' "$HOME_CSS"
grep -q 'b01h-part-image' "$HOME_CSS"
grep -q 'b01h-brand-logo' "$HOME_CSS"
grep -q 'ORIGINAL PROJECT PRODUCT IMAGES V3' "$TOP_CSS"
grep -q 'b01p-card-image' "$TOP_CSS"
grep -q 'b01p-no-original-image' "$TOP_CSS"

# Ensure no network/API layer was added by this finalizer.
if grep -Eq 'fetch\(|axios|/api/' "$HOME_CSS" "$TOP_CSS"; then
  echo 'ERROR: unexpected network/API marker in CSS' >&2
  false
fi

echo 'ORIGINAL_PROJECT_BRANDS_DATA_PRESERVED'
echo 'ORIGINAL_PROJECT_BRAND_LOGOS_APPLIED'
echo 'ORIGINAL_PROJECT_PRODUCT_IMAGES_APPLIED'
echo 'NO_INVENTED_PRODUCT_IMAGES_ADDED'
echo 'DATA_ASSETS_CORRECTION_V3_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/components/HomeBelowHero.css'
echo '  src/pages/TopPartsPage.css'
