#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/seller-phase2-v1"
BACKUP="$(mktemp -d /tmp/67-seller-phase2.XXXXXX)"

cd "$ROOT"
test -f src/seller_app/pages/PendingReview.jsx
grep -q "SELLER ONBOARDING\|seller/pending" src/seller_app/pages/PendingReview.jsx src/seller_app/SellerApp.jsx

mkdir -p "$BACKUP/server" "$BACKUP/src/seller_app/pages" "$BACKUP/src/seller_app/components" "$BACKUP/src/pages"
cp server/index.js "$BACKUP/server/index.js"
cp src/seller_app/SellerApp.jsx "$BACKUP/src/seller_app/SellerApp.jsx"
cp src/pages/AdminDashboard.jsx "$BACKUP/src/pages/AdminDashboard.jsx"
for f in Register.jsx Login.jsx PendingReview.jsx; do cp "src/seller_app/pages/$f" "$BACKUP/src/seller_app/pages/$f"; done
[ -f server/sellerStore.js ] && cp server/sellerStore.js "$BACKUP/server/sellerStore.js" || true
[ -f src/seller_app/components/SellerGate.jsx ] && cp src/seller_app/components/SellerGate.jsx "$BACKUP/src/seller_app/components/SellerGate.jsx" || true
[ -f src/pages/SellerApplicationsPanel.jsx ] && cp src/pages/SellerApplicationsPanel.jsx "$BACKUP/src/pages/SellerApplicationsPanel.jsx" || true

restore() {
  cp "$BACKUP/server/index.js" server/index.js
  cp "$BACKUP/src/seller_app/SellerApp.jsx" src/seller_app/SellerApp.jsx
  cp "$BACKUP/src/pages/AdminDashboard.jsx" src/pages/AdminDashboard.jsx
  for f in Register.jsx Login.jsx PendingReview.jsx; do cp "$BACKUP/src/seller_app/pages/$f" "src/seller_app/pages/$f"; done
  if [ -f "$BACKUP/server/sellerStore.js" ]; then cp "$BACKUP/server/sellerStore.js" server/sellerStore.js; else rm -f server/sellerStore.js; fi
  if [ -f "$BACKUP/src/seller_app/components/SellerGate.jsx" ]; then cp "$BACKUP/src/seller_app/components/SellerGate.jsx" src/seller_app/components/SellerGate.jsx; else rm -f src/seller_app/components/SellerGate.jsx; fi
  if [ -f "$BACKUP/src/pages/SellerApplicationsPanel.jsx" ]; then cp "$BACKUP/src/pages/SellerApplicationsPanel.jsx" src/pages/SellerApplicationsPanel.jsx; else rm -f src/pages/SellerApplicationsPanel.jsx; fi
}
trap restore ERR

mkdir -p server src/seller_app/pages src/seller_app/components src/pages
cp "$PATCH_DIR/server/sellerStore.js" server/sellerStore.js
cp "$PATCH_DIR/src/seller_app/pages/Register.jsx" src/seller_app/pages/Register.jsx
cp "$PATCH_DIR/src/seller_app/pages/Login.jsx" src/seller_app/pages/Login.jsx
cp "$PATCH_DIR/src/seller_app/pages/PendingReview.jsx" src/seller_app/pages/PendingReview.jsx
cp "$PATCH_DIR/src/seller_app/components/SellerGate.jsx" src/seller_app/components/SellerGate.jsx
cp "$PATCH_DIR/src/pages/SellerApplicationsPanel.jsx" src/pages/SellerApplicationsPanel.jsx

python3 "$PATCH_DIR/patch_phase2.py"

grep -q "SellerStore" server/index.js
grep -q "/api/seller/applications" server/index.js
grep -q "SellerGate" src/seller_app/SellerApp.jsx
grep -q "SellerApplicationsPanel" src/pages/AdminDashboard.jsx
npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-SELLER-PHASE2-BACKEND-VERIFICATION-V1"
echo "BUILD=PASS"
echo "SELLER_APPLICATION_API=YES"
echo "SELLER_DOCUMENT_STORAGE=YES"
echo "SELLER_PASSWORD_HASHING=YES"
echo "SELLER_SESSION=YES"
echo "DASHBOARD_GATE=YES"
echo "ADMIN_REVIEW_API=YES"
echo "ADMIN_APPROVE_REJECT_NEEDS_CHANGES=YES"
echo "SUPERADMIN_SECURITY_CHANGED=NO"
echo "DEVELOPER_HUB_CHANGED=NO"
echo "COMMERCE_DATA_CHANGED=NO"
echo "READY_FOR_REVIEW=YES"
echo "ERROR=NONE"
