#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-05-offer-detail-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-05-offer-detail-$STAMP"
BACKUP="/tmp/67-batch-05-offer-detail-backup-$STAMP"

PAGE="$ROOT/src/pages/OfferDetailPage.jsx"
CSS="$ROOT/src/pages/OfferDetailPage.css"
OFFERS="$ROOT/src/data/mockOffers.js"

for f in "$PAGE" "$CSS" "$OFFERS"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 1701; }
done

grep -q "from '../data/mockOffers'" "$PAGE" || { echo 'ERROR: original Offer Detail data source marker missing' >&2; exit 1702; }
grep -q "mockOffers.find" "$PAGE" || { echo 'ERROR: original offer lookup behavior missing' >&2; exit 1703; }
grep -q "fairRating" "$PAGE" || { echo 'ERROR: original fair-price rating behavior missing' >&2; exit 1704; }

echo "ORIGINAL_OFFER_DETAIL_BEHAVIOR_DETECTED"

mkdir -p "$TMP" "$BACKUP"
cp -a "$PAGE" "$BACKUP/OfferDetailPage.jsx"
cp -a "$CSS" "$BACKUP/OfferDetailPage.css"

PROTECTED=(
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/components/HomeBelowHero.css"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/pages/TopPartsPage.css"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
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
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 1705; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/OfferDetailPage.jsx" "$PAGE" || true
  cp -f "$BACKUP/OfferDetailPage.css" "$CSS" || true
  echo "ERROR: Batch 05 failed; Offer Detail files restored" >&2
  exit "$code"
}
trap rollback ERR

curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/OfferDetailPage.jsx?v=$(date +%s%N)" -o "$TMP/OfferDetailPage.jsx"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/OfferDetailPage.css?v=$(date +%s%N)" -o "$TMP/OfferDetailPage.css"

[ -s "$TMP/OfferDetailPage.jsx" ] || { echo 'ERROR: empty OfferDetailPage.jsx payload' >&2; false; }
[ -s "$TMP/OfferDetailPage.css" ] || { echo 'ERROR: empty OfferDetailPage.css payload' >&2; false; }

# Original-data-only validation.
for marker in \
  "from '../data/mockOffers'" \
  "mockOffers.find" \
  "offer.partNameAr" \
  "offer.image" \
  "offer.price" \
  "offer.rating" \
  "offer.reviewCount" \
  "offer.conditionAr" \
  "offer.brandAr" \
  "offer.shippingCost" \
  "offer.shippingDays" \
  "offer.warranty" \
  "offer.storeNameAr" \
  "offer.storeCityAr" \
  "relatedOffers" \
  "fairRating"; do
  grep -q "$marker" "$TMP/OfferDetailPage.jsx" || { echo "ERROR: payload original-data marker missing: $marker" >&2; false; }
done

# No invented compatibility / part-number content from the visual reference.
for forbidden in "P-102" "رقم القطعة" "هيونداي سوناتا 2018-2022" "توافق موثوق"; do
  if grep -q "$forbidden" "$TMP/OfferDetailPage.jsx"; then
    echo "ERROR: invented reference-only content detected: $forbidden" >&2
    false
  fi
done

# This redesign must not introduce a new remote/API data layer.
if grep -Eq "fetch\(|axios|/api/|https?://" "$TMP/OfferDetailPage.jsx"; then
  echo 'ERROR: unexpected new API/remote data layer in OfferDetailPage payload' >&2
  false
fi

# Typography floor for this new page.
if grep -Eq "font-size:[[:space:]]*([0-9]|1[0-3])px" "$TMP/OfferDetailPage.css"; then
  echo 'ERROR: Offer Detail payload contains font-size below 14px' >&2
  false
fi

echo "OFFER_DETAIL_REFERENCE_LAYOUT_V1_READY"
echo "OFFER_DETAIL_ORIGINAL_PRODUCT_DATA_ONLY"
echo "NO_INVENTED_COMPATIBILITY_OR_PART_NUMBER"

cp -f "$TMP/OfferDetailPage.jsx" "$PAGE"
cp -f "$TMP/OfferDetailPage.css" "$CSS"

# Final behavior and source guards.
grep -q "from '../data/mockOffers'" "$PAGE"
grep -q "mockOffers.find" "$PAGE"
grep -q "fairRating" "$PAGE"
grep -q "navigate(\`/offer/\${item.id}\`)" "$PAGE"
grep -q "od67-page" "$PAGE"
grep -q ".od67-hero-grid" "$CSS"

sha256sum -c "$HASHES" >/dev/null

trap - ERR
echo "BATCH_05_OFFER_DETAIL_REFERENCE_V1_APPLIED"
echo "ORIGINAL_PRODUCT_DATA_SOURCE_PRESERVED"
echo "ORIGINAL_OFFER_DETAIL_BEHAVIOR_PRESERVED"
echo "OTHER_REDESIGNED_PAGES_UNCHANGED"
echo "CHANGED_FILES:"
echo "  src/pages/OfferDetailPage.jsx"
echo "  src/pages/OfferDetailPage.css"
