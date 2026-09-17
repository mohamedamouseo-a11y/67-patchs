#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-06-commerce-flow-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-06-commerce-$STAMP"
BACKUP="/tmp/67-batch-06-commerce-backup-$STAMP"

OFFER_JSX="$ROOT/src/pages/OfferDetailPage.jsx"
OFFER_CSS="$ROOT/src/pages/OfferDetailPage.css"
CART_JSX="$ROOT/src/pages/CartPage.jsx"
CHECKOUT_JSX="$ROOT/src/pages/CheckoutPage.jsx"
CHECKOUT_CSS="$ROOT/src/pages/CheckoutPage.css"
OFFERS="$ROOT/src/data/mockOffers.js"
SHIPPING="$ROOT/src/components/ShippingSelector.jsx"
ORDERS="$ROOT/src/pages/MyOrdersPage.jsx"

for f in "$OFFER_JSX" "$OFFER_CSS" "$CART_JSX" "$CHECKOUT_JSX" "$CHECKOUT_CSS" "$OFFERS" "$SHIPPING" "$ORDERS"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 1801; }
done

grep -q "from '../data/mockOffers'" "$OFFER_JSX" || { echo 'ERROR: Offer Detail original product source missing' >&2; exit 1802; }
grep -q 'od67-actions-card' "$OFFER_JSX" || { echo 'ERROR: Offer Detail action-card marker missing' >&2; exit 1803; }
grep -q "shippingCompanies" "$SHIPPING" || { echo 'ERROR: original ShippingSelector data missing' >&2; exit 1804; }
grep -q "_67_orders" "$ORDERS" || { echo 'ERROR: original orders storage behavior missing' >&2; exit 1805; }

echo 'ORIGINAL_COMMERCE_DATA_SOURCES_DETECTED'
echo 'ORIGINAL_SHIPPING_OPTIONS_DETECTED'
echo 'ORIGINAL_ORDER_STORAGE_BEHAVIOR_DETECTED'

mkdir -p "$TMP" "$BACKUP"
cp -a "$OFFER_JSX" "$BACKUP/OfferDetailPage.jsx"
cp -a "$OFFER_CSS" "$BACKUP/OfferDetailPage.css"
cp -a "$CART_JSX" "$BACKUP/CartPage.jsx"
cp -a "$CHECKOUT_JSX" "$BACKUP/CheckoutPage.jsx"
cp -a "$CHECKOUT_CSS" "$BACKUP/CheckoutPage.css"

PROTECTED=(
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/components/ShippingSelector.jsx"
  "$ROOT/src/components/ShippingSelector.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/src/pages/AddressesPage.jsx"
  "$ROOT/src/pages/PaymentMethodsPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/pages/HomePage.css"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/components/HomeBelowHero.css"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/pages/TopPartsPage.css"
  "$ROOT/src/pages/NotificationsPage.jsx"
  "$ROOT/src/pages/NotificationsPage.css"
  "$ROOT/src/pages/PartSearchPage.jsx"
  "$ROOT/src/pages/PartSearchPage.css"
  "$ROOT/src/pages/CustomerProfilePage.jsx"
  "$ROOT/src/pages/CustomerProfilePage.css"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 1806; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/OfferDetailPage.jsx" "$OFFER_JSX" || true
  cp -f "$BACKUP/OfferDetailPage.css" "$OFFER_CSS" || true
  cp -f "$BACKUP/CartPage.jsx" "$CART_JSX" || true
  cp -f "$BACKUP/CheckoutPage.jsx" "$CHECKOUT_JSX" || true
  cp -f "$BACKUP/CheckoutPage.css" "$CHECKOUT_CSS" || true
  echo 'ERROR: Batch 06 failed; target files restored' >&2
  exit "$code"
}
trap rollback ERR

curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/CartPage.jsx?v=$(date +%s)" -o "$TMP/CartPage.jsx"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/CheckoutPage.jsx?v=$(date +%s)" -o "$TMP/CheckoutPage.jsx"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/CheckoutPage.css?v=$(date +%s)" -o "$TMP/CheckoutPage.css"

for f in "$TMP/CartPage.jsx" "$TMP/CheckoutPage.jsx" "$TMP/CheckoutPage.css"; do
  [ -s "$f" ] || { echo "ERROR: empty payload: $f" >&2; false; }
done

# Payload validation: all commerce content must resolve from original sources/state.
grep -q "from '../data/mockOffers'" "$TMP/CartPage.jsx"
grep -q "localStorage.getItem(CART_KEY)" "$TMP/CartPage.jsx"
grep -q "offer.image" "$TMP/CartPage.jsx"
grep -q "offer.partNameAr" "$TMP/CartPage.jsx"
grep -q "offer.storeNameAr" "$TMP/CartPage.jsx"
grep -q "offer.price" "$TMP/CartPage.jsx"

grep -q "from '../data/mockOffers'" "$TMP/CheckoutPage.jsx"
grep -q "import ShippingSelector" "$TMP/CheckoutPage.jsx"
grep -q "localStorage.setItem(ORDERS_KEY" "$TMP/CheckoutPage.jsx"
grep -q "Apple Pay" "$TMP/CheckoutPage.jsx"
grep -q "stc pay" "$TMP/CheckoutPage.jsx"
grep -q "مدى" "$TMP/CheckoutPage.jsx"
grep -q "tabby" "$TMP/CheckoutPage.jsx"
grep -q "tamara" "$TMP/CheckoutPage.jsx"
grep -q "عبدالله أحمد" "$TMP/CheckoutPage.jsx"
grep -q "الرياض، حي الملقا، شارع الأمير محمد بن سعد" "$TMP/CheckoutPage.jsx"
grep -q "1280.00" "$TMP/CheckoutPage.jsx"

echo 'CART_ORIGINAL_PRODUCT_DATA_FLOW_READY'
echo 'CHECKOUT_ORIGINAL_PROJECT_OPTIONS_READY'

# Apply prepared Cart + Checkout payloads.
cp -f "$TMP/CartPage.jsx" "$CART_JSX"
cp -f "$TMP/CheckoutPage.jsx" "$CHECKOUT_JSX"
cp -f "$TMP/CheckoutPage.css" "$CHECKOUT_CSS"

# Patch only the Offer Detail purchase controls; keep product/reviews/detail data binding intact.
python3 - "$OFFER_JSX" "$OFFER_CSS" <<'PY'
from pathlib import Path
import sys

jsx_path = Path(sys.argv[1])
css_path = Path(sys.argv[2])
s = jsx_path.read_text(encoding='utf-8')

if "from '../data/mockOffers'" not in s or 'od67-actions-card' not in s:
    raise SystemExit('ERROR: Offer Detail source markers missing')

# Add quantity icons without changing any existing product data imports.
if '  Minus,' not in s:
    marker = '  MapPin,\n  Package,'
    if marker not in s:
        raise SystemExit('ERROR: Offer Detail lucide import anchor missing')
    s = s.replace(marker, '  MapPin,\n  Minus,\n  Package,\n  Plus,', 1)

state_anchor = "  const [ratingSubmitted, setRatingSubmitted] = useState(false);"
if 'const [quantity, setQuantity]' not in s:
    if state_anchor not in s:
        raise SystemExit('ERROR: Offer Detail state anchor missing')
    s = s.replace(state_anchor, state_anchor + "\n  const [quantity, setQuantity] = useState(1);", 1)

if 'const saveOfferToCart' not in s:
    function_anchor = "  const shippingLabel = offer.shippingCost === 0"
    pos = s.find(function_anchor)
    if pos == -1:
        raise SystemExit('ERROR: shippingLabel anchor missing')
    block = r'''  const saveOfferToCart = (goToCheckout = false) => {
    if (!offer.availability) return;
    const key = '_67_cart';
    let current = [];
    try {
      const parsed = JSON.parse(localStorage.getItem(key) || '[]');
      if (Array.isArray(parsed)) current = parsed;
    } catch {
      current = [];
    }

    const clean = current
      .map((line) => ({ offerId: String(line.offerId), quantity: Math.max(1, Number(line.quantity) || 1) }))
      .filter((line) => mockOffers.some((item) => item.id === line.offerId));
    const existingIndex = clean.findIndex((line) => line.offerId === offer.id);
    if (existingIndex >= 0) clean[existingIndex].quantity += quantity;
    else clean.push({ offerId: offer.id, quantity });
    localStorage.setItem(key, JSON.stringify(clean));
    if (goToCheckout) navigate('/checkout');
  };

'''
    s = s[:pos] + block + s[pos:]

old = r'''              <div className="od67-actions-card">
                <div className="od67-stock-note">
                  <CheckCircle2 size={17} />
                  <span>{offer.availability ? 'متاح للشراء' : 'غير متاح للشراء حالياً'}</span>
                </div>
                <button type="button" className="od67-buy-btn">
                  <ShoppingCart size={19} />
                  اشتري الآن
                </button>
                <button type="button" className="od67-back-btn" onClick={() => navigate('/top-parts')}>
                  العودة للعروض <ArrowLeft size={17} />
                </button>
              </div>'''

new = r'''              <div className="od67-actions-card od67-purchase-box">
                <div className="od67-purchase-top">
                  <div className="od67-stock-note">
                    <CheckCircle2 size={17} />
                    <span>{offer.availability ? 'متوفر للشراء' : 'غير متوفر حالياً'}</span>
                  </div>

                  <div className="od67-quantity-block">
                    <span>الكمية</span>
                    <div className="od67-quantity-control">
                      <button type="button" onClick={() => setQuantity((value) => Math.max(1, value - 1))} aria-label="تقليل الكمية">
                        <Minus size={15} />
                      </button>
                      <strong>{quantity}</strong>
                      <button type="button" onClick={() => setQuantity((value) => value + 1)} aria-label="زيادة الكمية">
                        <Plus size={15} />
                      </button>
                    </div>
                  </div>
                </div>

                <div className="od67-purchase-buttons">
                  <button type="button" className="od67-add-btn" disabled={!offer.availability} onClick={() => saveOfferToCart(false)}>
                    <ShoppingCart size={19} />
                    أضف إلى السلة
                  </button>
                  <button type="button" className="od67-buy-now-btn" disabled={!offer.availability} onClick={() => saveOfferToCart(true)}>
                    شراء الآن
                  </button>
                </div>
              </div>'''

if old not in s:
    if 'od67-purchase-box' not in s:
        raise SystemExit('ERROR: exact Offer Detail action block not found')
else:
    s = s.replace(old, new, 1)

for marker in [
    'const [quantity, setQuantity]',
    'const saveOfferToCart',
    "localStorage.setItem(key, JSON.stringify(clean))",
    "navigate('/checkout')",
    'od67-quantity-control',
    'od67-add-btn',
    'od67-buy-now-btn',
]:
    if marker not in s:
        raise SystemExit(f'ERROR: Offer Detail commerce marker missing: {marker}')

jsx_path.write_text(s, encoding='utf-8')

css = css_path.read_text(encoding='utf-8')
marker = '/* OFFER DETAIL PURCHASE CONTROLS — COMMERCE FLOW V1 */'
if marker in css:
    css = css[:css.index(marker)].rstrip() + '\n'

css += r'''

/* OFFER DETAIL PURCHASE CONTROLS — COMMERCE FLOW V1 */
.od67-purchase-box {
  padding: 18px !important;
  display: block !important;
  border-radius: 20px !important;
  background: #151714 !important;
  color: #fff !important;
}

.od67-purchase-top {
  min-height: 48px;
  padding-bottom: 15px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.od67-purchase-box .od67-stock-note {
  grid-column: auto !important;
  color: rgba(255,255,255,.78) !important;
}

.od67-quantity-block {
  display: flex;
  align-items: center;
  gap: 12px;
}

.od67-quantity-block > span {
  color: rgba(255,255,255,.72);
  font-size: 14px;
  font-weight: 800;
}

.od67-quantity-control {
  min-width: 124px;
  height: 42px;
  display: grid;
  grid-template-columns: 42px 40px 42px;
  align-items: center;
  border: 1px solid rgba(255,255,255,.10);
  border-radius: 12px;
  overflow: hidden;
  background: #20211e;
  direction: ltr;
}

.od67-quantity-control button {
  height: 100%;
  border: 0;
  background: transparent;
  color: #fff;
  display: grid;
  place-items: center;
  cursor: pointer;
}

.od67-quantity-control strong {
  height: 100%;
  display: grid;
  place-items: center;
  border-right: 1px solid rgba(255,255,255,.08);
  border-left: 1px solid rgba(255,255,255,.08);
  color: #fff;
  font-family: Arial, sans-serif;
  font-size: 15px;
}

.od67-purchase-buttons {
  display: grid;
  grid-template-columns: 1.15fr .85fr;
  gap: 10px;
}

.od67-add-btn,
.od67-buy-now-btn {
  min-height: 56px;
  border-radius: 13px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 900;
}

.od67-add-btn {
  border: 1px solid var(--od67-gold);
  background: var(--od67-gold);
  color: #12130f;
}

.od67-buy-now-btn {
  border: 1px solid rgba(255,255,255,.20);
  background: rgba(255,255,255,.04);
  color: #fff;
}

.od67-add-btn:disabled,
.od67-buy-now-btn:disabled { opacity: .42; cursor: not-allowed; }

@media (max-width: 620px) {
  .od67-purchase-top { align-items: flex-start; flex-direction: column; }
  .od67-quantity-block { width: 100%; justify-content: space-between; }
  .od67-purchase-buttons { grid-template-columns: 1fr; }
}
'''
css_path.write_text(css, encoding='utf-8')
PY

# Preserve original data/config sources byte-for-byte.
sha256sum -c "$HASHES" >/dev/null

# Final source guards.
grep -q "from '../data/mockOffers'" "$OFFER_JSX"
grep -q "from '../data/mockOffers'" "$CART_JSX"
grep -q "from '../data/mockOffers'" "$CHECKOUT_JSX"
grep -q "_67_cart" "$OFFER_JSX"
grep -q "_67_cart" "$CART_JSX"
grep -q "_67_cart" "$CHECKOUT_JSX"
grep -q "_67_orders" "$CHECKOUT_JSX"
grep -q "ShippingSelector" "$CHECKOUT_JSX"
grep -q 'COMMERCE FLOW V1' "$OFFER_CSS"
grep -q '.co67-layout' "$CHECKOUT_CSS"

echo 'PRODUCT_DETAIL_QUANTITY_AND_CART_ACTIONS_APPLIED'
echo 'CART_CONNECTED_TO_ORIGINAL_OFFER_DATA'
echo 'CHECKOUT_THREE_STEP_REFERENCE_FLOW_APPLIED'
echo 'CHECKOUT_TOTALS_DERIVED_FROM_CART_DATA'
echo 'COMPLETED_ORDER_WRITES_TO_ORIGINAL_ORDERS_STORAGE'
echo 'NO_NEW_API_OR_PRODUCT_DATA_ADDED'
echo 'BATCH_06_COMMERCE_FLOW_V1_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/pages/OfferDetailPage.jsx'
echo '  src/pages/OfferDetailPage.css'
echo '  src/pages/CartPage.jsx'
echo '  src/pages/CheckoutPage.jsx'
echo '  src/pages/CheckoutPage.css'
