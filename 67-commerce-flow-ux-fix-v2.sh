#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
OFFER="$ROOT/src/pages/OfferDetailPage.jsx"
CHECKOUT="$ROOT/src/pages/CheckoutPage.jsx"
CHECKOUT_CSS="$ROOT/src/pages/CheckoutPage.css"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-commerce-flow-ux-fix-v2-$STAMP"

for f in "$OFFER" "$CHECKOUT" "$CHECKOUT_CSS"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 2001; }
done

grep -q "const saveOfferToCart" "$OFFER" || { echo 'ERROR: current commerce OfferDetail marker missing' >&2; exit 2002; }
grep -q "const ORIGINAL_ADDRESS" "$CHECKOUT" || { echo 'ERROR: expected hardcoded checkout address marker missing' >&2; exit 2003; }
grep -q "const \[paymentMethod, setPaymentMethod\] = useState('applepay')" "$CHECKOUT" || { echo 'ERROR: expected preselected payment marker missing' >&2; exit 2004; }

mkdir -p "$BACKUP"
cp -a "$OFFER" "$BACKUP/OfferDetailPage.jsx"
cp -a "$CHECKOUT" "$BACKUP/CheckoutPage.jsx"
cp -a "$CHECKOUT_CSS" "$BACKUP/CheckoutPage.css"

PROTECTED=(
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/components/ShippingSelector.jsx"
  "$ROOT/src/components/ShippingSelector.css"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/src/pages/AddressesPage.jsx"
  "$ROOT/src/pages/PaymentMethodsPage.jsx"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)
HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 2005; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/OfferDetailPage.jsx" "$OFFER" || true
  cp -f "$BACKUP/CheckoutPage.jsx" "$CHECKOUT" || true
  cp -f "$BACKUP/CheckoutPage.css" "$CHECKOUT_CSS" || true
  echo 'ERROR: Commerce Flow UX Fix V2 failed; restored target files' >&2
  exit "$code"
}
trap rollback ERR

python3 - "$OFFER" "$CHECKOUT" "$CHECKOUT_CSS" <<'PY'
from pathlib import Path
import re, sys

offer_path = Path(sys.argv[1])
checkout_path = Path(sys.argv[2])
css_path = Path(sys.argv[3])

# ------------------------------------------------------------
# 1) PRODUCT DETAIL: make both purchase actions visibly work by
#    saving to the existing _67_cart and opening the Cart first.
# ------------------------------------------------------------
s = offer_path.read_text(encoding='utf-8')

s = s.replace('const saveOfferToCart = (goToCheckout = false) => {', 'const saveOfferToCart = () => {', 1)
old_tail = "    localStorage.setItem(key, JSON.stringify(clean));\n    if (goToCheckout) navigate('/checkout');"
new_tail = "    localStorage.setItem(key, JSON.stringify(clean));\n    navigate('/cart');"
if old_tail not in s:
    raise SystemExit('ERROR: OfferDetail save cart tail not found')
s = s.replace(old_tail, new_tail, 1)
s = s.replace('onClick={() => saveOfferToCart(false)}', 'onClick={saveOfferToCart}', 1)
s = s.replace('onClick={() => saveOfferToCart(true)}', 'onClick={saveOfferToCart}', 1)

for marker in ["localStorage.setItem(key, JSON.stringify(clean))", "navigate('/cart')", 'onClick={saveOfferToCart}']:
    if marker not in s:
        raise SystemExit(f'ERROR: OfferDetail final marker missing: {marker}')
if "navigate('/checkout')" in s[s.find('const saveOfferToCart'):s.find('const shippingLabel')]:
    raise SystemExit('ERROR: Product Detail still skips Cart')

offer_path.write_text(s, encoding='utf-8')

# ------------------------------------------------------------
# 2) CHECKOUT: remove prefilled user data and preselected payment.
#    User explicitly enters their delivery data during checkout.
# ------------------------------------------------------------
s = checkout_path.read_text(encoding='utf-8')

# Remove hardcoded address object.
s, count = re.subn(
    r"\nconst ORIGINAL_ADDRESS = \{[\s\S]*?\n\};\n",
    "\n",
    s,
    count=1,
)
if count != 1:
    raise SystemExit('ERROR: unable to remove ORIGINAL_ADDRESS')

s = s.replace("const [paymentMethod, setPaymentMethod] = useState('applepay');", "const [paymentMethod, setPaymentMethod] = useState(null);", 1)

state_anchor = "  const [completedOrder, setCompletedOrder] = useState(null);"
address_state = r'''  const [address, setAddress] = useState({
    name: '',
    phone: '',
    city: '',
    district: '',
    street: '',
    building: '',
  });'''
if address_state not in s:
    if state_anchor not in s:
        raise SystemExit('ERROR: Checkout state anchor missing')
    s = s.replace(state_anchor, state_anchor + "\n" + address_state, 1)

calc_anchor = "  const productCount = items.reduce((sum, item) => sum + item.quantity, 0);"
calc_block = r'''
  const isAddressComplete = ['name', 'phone', 'city', 'district', 'street', 'building']
    .every((field) => String(address[field] || '').trim().length > 0);
  const updateAddress = (field, value) => setAddress((current) => ({ ...current, [field]: value }));'''
if 'const isAddressComplete' not in s:
    if calc_anchor not in s:
        raise SystemExit('ERROR: Checkout calculation anchor missing')
    s = s.replace(calc_anchor, calc_anchor + calc_block, 1)

s = s.replace(
    "  const selectedPayment = PAYMENT_OPTIONS.find((item) => item.id === paymentMethod) || PAYMENT_OPTIONS[0];",
    "  const selectedPayment = PAYMENT_OPTIONS.find((item) => item.id === paymentMethod) || null;",
    1,
)

s = s.replace(
    "    if (!items.length || !shippingMethod) return;",
    "    if (!items.length || !shippingMethod || !isAddressComplete || (remainingTotal > 0 && !paymentMethod)) return;",
    1,
)

old_lead = "                    <p className=\"co67-lead\">اختر عنوان التوصيل وشركة الشحن المناسبة، ثم راجع التكلفة قبل الانتقال للدفع.</p>"
new_lead = "                    <p className=\"co67-lead\">أدخل بيانات الاستلام بنفسك، ثم اختر شركة الشحن. لن نستخدم بيانات جاهزة بالنيابة عنك.</p>"
if old_lead not in s:
    raise SystemExit('ERROR: Checkout delivery lead marker missing')
s = s.replace(old_lead, new_lead, 1)

start = s.find('                    <article className="co67-address-card">')
if start == -1:
    raise SystemExit('ERROR: Checkout address card start missing')
end_marker = '                    </article>'
end = s.find(end_marker, start)
if end == -1:
    raise SystemExit('ERROR: Checkout address card end missing')
end += len(end_marker)

new_address = r'''                    <article className="co67-address-card co67-address-form-card">
                      <div className="co67-address-form-head">
                        <div className="co67-address-title">
                          <span><MapPin size={19} /></span>
                          <div>
                            <small>بيانات الاستلام</small>
                            <strong>اكتب بياناتك للتوصيل</strong>
                          </div>
                        </div>
                        <span className="co67-required-note">كل الحقول مطلوبة</span>
                      </div>

                      <div className="co67-address-fields">
                        <label className="co67-field">
                          <span>الاسم الكامل</span>
                          <input
                            type="text"
                            autoComplete="name"
                            placeholder="اكتب اسم المستلم"
                            value={address.name}
                            onChange={(event) => updateAddress('name', event.target.value)}
                          />
                        </label>

                        <label className="co67-field">
                          <span>رقم الجوال</span>
                          <input
                            type="tel"
                            inputMode="tel"
                            autoComplete="tel"
                            placeholder="05xxxxxxxx"
                            value={address.phone}
                            onChange={(event) => updateAddress('phone', event.target.value)}
                          />
                        </label>

                        <label className="co67-field">
                          <span>المدينة</span>
                          <select value={address.city} onChange={(event) => updateAddress('city', event.target.value)}>
                            <option value="">اختر المدينة</option>
                            <option value="الرياض">الرياض</option>
                            <option value="جدة">جدة</option>
                            <option value="الدمام">الدمام</option>
                            <option value="مكة المكرمة">مكة المكرمة</option>
                            <option value="المدينة المنورة">المدينة المنورة</option>
                          </select>
                        </label>

                        <label className="co67-field">
                          <span>الحي</span>
                          <input
                            type="text"
                            placeholder="اكتب اسم الحي"
                            value={address.district}
                            onChange={(event) => updateAddress('district', event.target.value)}
                          />
                        </label>

                        <label className="co67-field co67-field-wide">
                          <span>الشارع</span>
                          <input
                            type="text"
                            autoComplete="street-address"
                            placeholder="اكتب اسم الشارع"
                            value={address.street}
                            onChange={(event) => updateAddress('street', event.target.value)}
                          />
                        </label>

                        <label className="co67-field">
                          <span>رقم المبنى</span>
                          <input
                            type="text"
                            inputMode="numeric"
                            placeholder="رقم المبنى"
                            value={address.building}
                            onChange={(event) => updateAddress('building', event.target.value)}
                          />
                        </label>
                      </div>

                      <div className={`co67-address-status ${isAddressComplete ? 'is-complete' : ''}`}>
                        <span>{isAddressComplete ? 'تم إدخال بيانات الاستلام' : 'أكمل بيانات الاستلام للمتابعة'}</span>
                      </div>
                    </article>'''

s = s[:start] + new_address + s[end:]

s = s.replace(
    'disabled={!shippingMethod} onClick={() => setStep(2)}',
    'disabled={!isAddressComplete || !shippingMethod} onClick={() => setStep(2)}',
    1,
)

old_payment_button = '''                      <button type="button" className="co67-primary" onClick={handleCompleteOrder} disabled={isProcessing}>
                        {isProcessing ? 'جاري إتمام الطلب...' : `إتمام الشراء · ${remainingTotal.toFixed(2)} ر.س`}
                      </button>'''
new_payment_button = '''                      <button
                        type="button"
                        className="co67-primary"
                        onClick={handleCompleteOrder}
                        disabled={isProcessing || (remainingTotal > 0 && !paymentMethod)}
                      >
                        {isProcessing
                          ? 'جاري إتمام الطلب...'
                          : remainingTotal > 0 && !paymentMethod
                            ? 'اختر وسيلة دفع أولاً'
                            : `إتمام الشراء · ${remainingTotal.toFixed(2)} ر.س`}
                      </button>'''
if old_payment_button not in s:
    raise SystemExit('ERROR: Checkout payment completion button marker missing')
s = s.replace(old_payment_button, new_payment_button, 1)

s = s.replace(
    "<div><small>الدفع</small><strong>{remainingTotal === 0 ? 'محفظة 67' : selectedPayment.label}</strong></div>",
    "<div><small>الدفع</small><strong>{remainingTotal === 0 ? 'محفظة 67' : (selectedPayment?.label || '—')}</strong></div>",
    1,
)

# Final guards: no hardcoded address and no default payment selection.
for forbidden in ['ORIGINAL_ADDRESS', "useState('applepay')", 'عبدالله أحمد', '0501234567', 'الرياض، حي الملقا، شارع الأمير محمد بن سعد']:
    if forbidden in s:
        raise SystemExit(f'ERROR: prefilled checkout user data still present: {forbidden}')
for required in ['const [address, setAddress]', 'const isAddressComplete', 'co67-address-fields', "useState(null)", "disabled={!isAddressComplete || !shippingMethod}"]:
    if required not in s:
        raise SystemExit(f'ERROR: Checkout UX marker missing: {required}')

checkout_path.write_text(s, encoding='utf-8')

# ------------------------------------------------------------
# 3) Scoped checkout CSS for clear editable form.
# ------------------------------------------------------------
css = css_path.read_text(encoding='utf-8')
marker = '/* COMMERCE FLOW UX FIX V2 — USER ENTERED CHECKOUT DATA */'
if marker in css:
    css = css[:css.index(marker)].rstrip() + '\n'
css += r'''

/* COMMERCE FLOW UX FIX V2 — USER ENTERED CHECKOUT DATA */
.co67-address-form-card {
  padding: 22px !important;
}

.co67-address-form-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 20px;
}

.co67-required-note {
  color: #9a7a13;
  font-size: 14px;
  font-weight: 800;
}

.co67-address-fields {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.co67-field {
  min-width: 0;
  display: grid;
  gap: 8px;
}

.co67-field-wide {
  grid-column: 1 / -1;
}

.co67-field > span {
  color: #5f5b52;
  font-size: 14px;
  font-weight: 800;
}

.co67-field input,
.co67-field select {
  width: 100%;
  min-height: 50px;
  padding: 0 14px;
  border: 1px solid #ddd7cc;
  border-radius: 12px;
  outline: 0;
  background: #fff;
  color: #171814;
  font: inherit;
  font-size: 14px;
  transition: border-color .18s ease, box-shadow .18s ease;
}

.co67-field input::placeholder {
  color: #aaa499;
}

.co67-field input:focus,
.co67-field select:focus {
  border-color: #d6ad27;
  box-shadow: 0 0 0 3px rgba(214,173,39,.12);
}

.co67-address-status {
  margin-top: 16px;
  min-height: 42px;
  padding: 0 14px;
  display: flex;
  align-items: center;
  border-radius: 10px;
  background: #f6f3eb;
  color: #847f74;
  font-size: 14px;
  font-weight: 700;
}

.co67-address-status.is-complete {
  background: #edf7f0;
  color: #387552;
}

.co67-primary:disabled {
  opacity: .48;
  cursor: not-allowed;
  transform: none !important;
}

@media (max-width: 700px) {
  .co67-address-form-head {
    align-items: flex-start;
    flex-direction: column;
  }

  .co67-address-fields {
    grid-template-columns: 1fr;
  }

  .co67-field-wide {
    grid-column: auto;
  }
}
'''
css_path.write_text(css, encoding='utf-8')
PY

sha256sum -c "$HASHES" >/dev/null

# Source-level validation.
grep -q "navigate('/cart')" "$OFFER"
grep -q "onClick={saveOfferToCart}" "$OFFER"
! grep -q "navigate('/checkout')" "$OFFER" || { echo 'ERROR: OfferDetail still contains direct checkout navigation' >&2; false; }

grep -q "const \[address, setAddress\]" "$CHECKOUT"
grep -q "const isAddressComplete" "$CHECKOUT"
grep -q "co67-address-fields" "$CHECKOUT"
grep -q "const \[paymentMethod, setPaymentMethod\] = useState(null)" "$CHECKOUT"
! grep -q "ORIGINAL_ADDRESS" "$CHECKOUT" || { echo 'ERROR: hardcoded address remains' >&2; false; }
! grep -q "عبدالله أحمد" "$CHECKOUT" || { echo 'ERROR: hardcoded customer name remains' >&2; false; }

grep -q "COMMERCE FLOW UX FIX V2" "$CHECKOUT_CSS"

trap - ERR

echo 'PRODUCT_ACTIONS_NOW_OPEN_CART'
echo 'ADD_TO_CART_VISIBLY_CONNECTED_TO_CART_FLOW'
echo 'CHECKOUT_USER_DATA_STARTS_EMPTY'
echo 'CHECKOUT_ADDRESS_IS_EDITABLE_INLINE'
echo 'PAYMENT_METHOD_NOT_PRESELECTED'
echo 'ORIGINAL_PRODUCT_SHIPPING_PAYMENT_SOURCES_PRESERVED'
echo 'COMMERCE_FLOW_UX_FIX_V2_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/pages/OfferDetailPage.jsx'
echo '  src/pages/CheckoutPage.jsx'
echo '  src/pages/CheckoutPage.css'
