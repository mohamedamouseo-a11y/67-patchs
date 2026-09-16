#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-04-top-parts-product-catalog-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-04-top-parts-$STAMP"
BACKUP="/tmp/67-batch-04-top-parts-backup-$STAMP"

TOP="$ROOT/src/pages/TopPartsPage.jsx"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
OFFERS="$ROOT/src/data/mockOffers.js"

for f in "$TOP" "$TOP_CSS" "$OFFERS"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 901; }
done

# The current original product source has no category field. Therefore this redesign must NOT invent categories.
if grep -Eq "(^|[,{[:space:]])category(Ar|Name)?[[:space:]]*:" "$OFFERS"; then
  echo "ERROR: original product source now contains category data; this prepared no-category layout must be revised before applying" >&2
  exit 902
fi

echo "ORIGINAL_PRODUCT_SOURCE_HAS_NO_CATEGORY_FIELD"
echo "NO_INVENTED_CATEGORY_SPLIT"

mkdir -p "$TMP" "$BACKUP"
cp -a "$TOP" "$BACKUP/TopPartsPage.jsx"
cp -a "$TOP_CSS" "$BACKUP/TopPartsPage.css"

PROTECTED=(
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/pages/HomePage.css"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/components/HomeBelowHero.css"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
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
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 903; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/TopPartsPage.jsx" "$TOP" || true
  cp -f "$BACKUP/TopPartsPage.css" "$TOP_CSS" || true
  echo "ERROR: Batch 04 failed; Top Parts files restored" >&2
  exit "$code"
}
trap rollback ERR

curl -fsSL -H "Cache-Control: no-cache" \
  "$RAW_BASE/TopPartsPage.jsx?v=$(date +%s)" \
  -o "$TMP/TopPartsPage.jsx"

curl -fsSL -H "Cache-Control: no-cache" \
  "$RAW_BASE/TopPartsPage.css?v=$(date +%s)" \
  -o "$TMP/TopPartsPage.css"

[ -s "$TMP/TopPartsPage.jsx" ] || { echo 'ERROR: empty TopPartsPage.jsx payload' >&2; false; }
[ -s "$TMP/TopPartsPage.css" ] || { echo 'ERROR: empty TopPartsPage.css payload' >&2; false; }

grep -q "from '../data/mockOffers'" "$TMP/TopPartsPage.jsx"
grep -q "mockOffers.length" "$TMP/TopPartsPage.jsx"
grep -q "products.map" "$TMP/TopPartsPage.jsx"
grep -q "offer.image" "$TMP/TopPartsPage.jsx"
grep -q "offer.partNameAr" "$TMP/TopPartsPage.jsx"
grep -q "offer.storeNameAr" "$TMP/TopPartsPage.jsx"
grep -q "offer.price" "$TMP/TopPartsPage.jsx"
grep -q "offer.rating" "$TMP/TopPartsPage.jsx"
grep -q "offer.conditionAr" "$TMP/TopPartsPage.jsx"
grep -q "tp67-card" "$TMP/TopPartsPage.css"

# Guard against accidentally shipping a sliced/subset catalog.
if grep -Eq "mockOffers\.(slice|filter)\([^)]*\)[[:space:]]*;[[:space:]]*$" "$TMP/TopPartsPage.jsx"; then
  echo 'ERROR: prepared payload appears to reduce the base product collection' >&2
  false
fi

# No invented category taxonomy in the prepared UI.
if grep -Eq "categoryTabs|CATEGORY_TABS|categories[[:space:]]*=" "$TMP/TopPartsPage.jsx"; then
  echo 'ERROR: invented category split detected in payload' >&2
  false
fi

echo "TOP_PARTS_PRODUCT_CARDS_REFERENCE_V1_READY"
echo "ALL_ORIGINAL_PRODUCTS_RENDERED_BY_DEFAULT"
echo "ORIGINAL_PRODUCT_FIELDS_ONLY"

cp -f "$TMP/TopPartsPage.jsx" "$TOP"
cp -f "$TMP/TopPartsPage.css" "$TOP_CSS"

# Final data/source guards.
grep -q "from '../data/mockOffers'" "$TOP"
grep -q "products.map" "$TOP"
grep -q "mockOffers.length" "$TOP"
grep -q "offer.image" "$TOP"
grep -q "offer.partNameAr" "$TOP"
grep -q "offer.storeNameAr" "$TOP"
grep -q "offer.price" "$TOP"
grep -q "offer.rating" "$TOP"
grep -q "offer.conditionAr" "$TOP"

# Confirm every protected file remained byte-identical.
sha256sum -c "$HASHES" >/dev/null

echo "ORIGINAL_PRODUCT_DATA_SOURCE_PRESERVED"
echo "OTHER_REDESIGNED_PAGES_UNCHANGED"
echo "BATCH_04_TOP_PARTS_PRODUCT_CATALOG_V1_APPLIED"
echo "CHANGED_FILES:"
echo "  src/pages/TopPartsPage.jsx"
echo "  src/pages/TopPartsPage.css"
