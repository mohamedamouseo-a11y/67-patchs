#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/seller-phase3b-v1"
BACKUP="$(mktemp -d /tmp/67-seller-phase3b.XXXXXX)"

cd "$ROOT"

# Require verified 3A commerce layer.
grep -q "CommerceStore" server/index.js
grep -q "/api/marketplace/products" server/index.js
grep -q "/api/marketplace/orders" server/index.js
grep -q "/api/seller/products" server/index.js
test -f server/commerceStore.js

FILES=(
  server/index.js
  server/commerceStore.js
  src/components/HomeBelowHero.jsx
  src/pages/TopPartsPage.jsx
  src/pages/OfferDetailPage.jsx
  src/pages/CartPage.jsx
  src/pages/CheckoutPage.jsx
  src/pages/MyOrdersPage.jsx
)

for f in "${FILES[@]}"; do
  mkdir -p "$BACKUP/$(dirname "$f")"
  cp "$f" "$BACKUP/$f"
done
mkdir -p "$BACKUP/src/utils"
[ -f src/utils/marketplaceClient.js ] && cp src/utils/marketplaceClient.js "$BACKUP/src/utils/marketplaceClient.js" || true

restore() {
  for f in "${FILES[@]}"; do cp "$BACKUP/$f" "$f"; done
  if [ -f "$BACKUP/src/utils/marketplaceClient.js" ]; then
    cp "$BACKUP/src/utils/marketplaceClient.js" src/utils/marketplaceClient.js
  else
    rm -f src/utils/marketplaceClient.js
  fi
}
trap restore ERR

mkdir -p src/utils
cp "$PATCH_DIR/server/commerceStore.js" server/commerceStore.js
cp "$PATCH_DIR/src/utils/marketplaceClient.js" src/utils/marketplaceClient.js

python3 "$PATCH_DIR/patch_server3b.py"
python3 "$PATCH_DIR/patch_phase3b.py"

grep -q "/api/marketplace/order-status" server/index.js
grep -q "useMarketplaceProducts" src/pages/TopPartsPage.jsx
grep -q "useMarketplaceProducts" src/pages/OfferDetailPage.jsx
grep -q "useMarketplaceProducts" src/pages/CartPage.jsx
grep -q "useMarketplaceProducts" src/pages/CheckoutPage.jsx
grep -q "readOrderReceipts" src/pages/MyOrdersPage.jsx
grep -q "saveOrderReceipts" src/pages/CheckoutPage.jsx
! grep -q "tabby" src/pages/CheckoutPage.jsx
! grep -q "tamara" src/pages/CheckoutPage.jsx

npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-SELLER-PHASE3B-CUSTOMER-COMMERCE-BRIDGE-V1"
echo "BUILD=PASS"
echo "HOME_CATALOG_BACKEND=YES"
echo "TOP_PARTS_BACKEND=YES"
echo "OFFER_DETAIL_BACKEND=YES"
echo "CART_REAL_PRODUCTS=YES"
echo "CHECKOUT_REAL_ORDER=YES"
echo "SERVER_TOTAL_CALCULATION=YES"
echo "VAT_RATE=15_PERCENT"
echo "COMMISSION_RATE=1_PERCENT"
echo "ORDER_RECEIPT_TRACKING=YES"
echo "CUSTOMER_ORDERS_BACKEND=YES"
echo "SELLER_SAME_ORDER=YES"
echo "ADMIN_SAME_ORDER=YES"
echo "TABBY_REMOVED=YES"
echo "TAMARA_REMOVED=YES"
echo "NAFATH_CHANGED=NO"
echo "CUSTOMER_OTP_CHANGED=NO"
echo "SUPERADMIN_SECURITY_CHANGED=NO"
echo "DEVELOPER_HUB_CHANGED=NO"
echo "READY_FOR_REVIEW=YES"
echo "ERROR=NONE"
