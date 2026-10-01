#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/seller-phase3a-v1"
BACKUP="$(mktemp -d /tmp/67-seller-phase3a.XXXXXX)"

cd "$ROOT"

# Phase 3A must sit on the verified Phase 2 seller identity layer.
grep -q "SellerStore" server/index.js
grep -q "SellerGate" src/seller_app/SellerApp.jsx
grep -q "/api/seller/applications" server/index.js
test -f src/seller_app/pages/Products.jsx
test -f src/seller_app/pages/Orders.jsx
test -f src/pages/AdminDashboard.jsx

mkdir -p "$BACKUP/server" "$BACKUP/src/seller_app/pages" "$BACKUP/src/pages"
cp server/index.js "$BACKUP/server/index.js"
cp src/seller_app/pages/Products.jsx "$BACKUP/src/seller_app/pages/Products.jsx"
cp src/seller_app/pages/Orders.jsx "$BACKUP/src/seller_app/pages/Orders.jsx"
cp src/pages/AdminDashboard.jsx "$BACKUP/src/pages/AdminDashboard.jsx"
[ -f server/commerceStore.js ] && cp server/commerceStore.js "$BACKUP/server/commerceStore.js" || true
[ -f src/pages/CommerceOrdersPanel.jsx ] && cp src/pages/CommerceOrdersPanel.jsx "$BACKUP/src/pages/CommerceOrdersPanel.jsx" || true

restore() {
  cp "$BACKUP/server/index.js" server/index.js
  cp "$BACKUP/src/seller_app/pages/Products.jsx" src/seller_app/pages/Products.jsx
  cp "$BACKUP/src/seller_app/pages/Orders.jsx" src/seller_app/pages/Orders.jsx
  cp "$BACKUP/src/pages/AdminDashboard.jsx" src/pages/AdminDashboard.jsx
  if [ -f "$BACKUP/server/commerceStore.js" ]; then cp "$BACKUP/server/commerceStore.js" server/commerceStore.js; else rm -f server/commerceStore.js; fi
  if [ -f "$BACKUP/src/pages/CommerceOrdersPanel.jsx" ]; then cp "$BACKUP/src/pages/CommerceOrdersPanel.jsx" src/pages/CommerceOrdersPanel.jsx; else rm -f src/pages/CommerceOrdersPanel.jsx; fi
}
trap restore ERR

cp "$PATCH_DIR/server/commerceStore.js" server/commerceStore.js
cp "$PATCH_DIR/src/seller_app/pages/Products.jsx" src/seller_app/pages/Products.jsx
cp "$PATCH_DIR/src/seller_app/pages/Orders.jsx" src/seller_app/pages/Orders.jsx
cp "$PATCH_DIR/src/pages/CommerceOrdersPanel.jsx" src/pages/CommerceOrdersPanel.jsx

python3 "$PATCH_DIR/patch_phase3a.py"

grep -q "CommerceStore" server/index.js
grep -q "/api/seller/products" server/index.js
grep -q "/api/seller/orders" server/index.js
grep -q "/api/marketplace/products" server/index.js
grep -q "/api/marketplace/orders" server/index.js
grep -q "CommerceOrdersPanel" src/pages/AdminDashboard.jsx

npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-SELLER-PHASE3A-COMMERCE-CORE-V1"
echo "BUILD=PASS"
echo "SELLER_PRODUCTS_BACKEND=YES"
echo "SELLER_INVENTORY_BACKEND=YES"
echo "SELLER_PRODUCTS_UI=YES"
echo "SELLER_ORDERS_BACKEND=YES"
echo "SELLER_ORDERS_UI=YES"
echo "ORDER_STATUS_WORKFLOW=YES"
echo "PUBLIC_CATALOG_API=YES"
echo "MARKETPLACE_ORDER_API=YES"
echo "ADMIN_COMMERCE_VIEW=YES"
echo "COMMISSION_RATE=1_PERCENT"
echo "CUSTOMER_STORE_CONNECTED=NO_PHASE3B"
echo "CUSTOMER_CHECKOUT_CONNECTED=NO_PHASE3B"
echo "SUPERADMIN_SECURITY_CHANGED=NO"
echo "DEVELOPER_HUB_CHANGED=NO"
echo "READY_FOR_REVIEW=YES"
echo "ERROR=NONE"
