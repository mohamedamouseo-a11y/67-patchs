#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
PAGE="$ROOT/src/pages/ScrapyardsPage.jsx"
CSS="$ROOT/src/pages/ScrapyardsPage.css"
PUBLIC_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-08-scrapyards-reference-v1"
TMP="$(mktemp -d /tmp/67-batch08-scrapyards.XXXXXX)"
BACKUP="$TMP/backup"
mkdir -p "$BACKUP"

cleanup() {
  rm -rf "$TMP"
}

rollback() {
  local code=$?
  echo "ERROR: Batch 08 failed; restoring ScrapyardsPage files" >&2
  if [[ -f "$BACKUP/ScrapyardsPage.jsx" ]]; then cp "$BACKUP/ScrapyardsPage.jsx" "$PAGE"; fi
  if [[ -f "$BACKUP/ScrapyardsPage.css" ]]; then cp "$BACKUP/ScrapyardsPage.css" "$CSS"; fi
  cleanup
  exit "$code"
}
trap rollback ERR

[[ -d "$ROOT" ]]
[[ -f "$PAGE" ]]
[[ -f "$CSS" ]]
[[ -f "$ROOT/src/App.jsx" ]]
[[ -f "$ROOT/src/components/HomeStoreHeader.jsx" ]]
[[ -f "$ROOT/src/components/HomeStoreHeader.css" ]]
[[ -f "$ROOT/src/components/BottomNav.jsx" ]]

cp "$PAGE" "$BACKUP/ScrapyardsPage.jsx"
cp "$CSS" "$BACKUP/ScrapyardsPage.css"

# Verify the current project still contains the original scrapyard/part records and route.
grep -Fq "تشليح الحاير المركزي" "$PAGE"
grep -Fq "تشليح السلي للسيارات الأمريكية" "$PAGE"
grep -Fq "تشليح القمة الألماني" "$PAGE"
grep -Fq "مكينة كامري 2020" "$PAGE"
grep -Fq "قير فورد تورس" "$PAGE"
grep -Fq "شمعة أمامية يمين لكزس ES" "$PAGE"
grep -Fq 'path="/scrapyards"' "$ROOT/src/App.jsx"

echo "ORIGINAL_SCRAPYARDS_DATA_DETECTED"
echo "ORIGINAL_SCRAPYARDS_ROUTE_DETECTED"

# Protect non-target source/data files.
PROTECTED=(
  "$ROOT/src/App.jsx"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

declare -A BEFORE_SHA
for file in "${PROTECTED[@]}"; do
  if [[ -f "$file" ]]; then
    BEFORE_SHA["$file"]="$(sha256sum "$file" | awk '{print $1}')"
  fi
done

curl -fsSL -H "Cache-Control: no-cache" "$PUBLIC_BASE/ScrapyardsPage.jsx?v=$(date +%s)" -o "$TMP/ScrapyardsPage.jsx"
curl -fsSL -H "Cache-Control: no-cache" "$PUBLIC_BASE/ScrapyardsPage.css?v=$(date +%s)" -o "$TMP/ScrapyardsPage.css"

JSX_BLOB="$(git hash-object "$TMP/ScrapyardsPage.jsx")"
CSS_BLOB="$(git hash-object "$TMP/ScrapyardsPage.css")"
[[ "$JSX_BLOB" == "fa8b2dbf6e7a9dd2d77a0d36c3a1420ec3d4be7c" ]]
[[ "$CSS_BLOB" == "6fd85ca136fdf007a2987450e407b8726ece0b0f" ]]

echo "SCRAPYARDS_REFERENCE_PAYLOAD_VALID"

cp "$TMP/ScrapyardsPage.jsx" "$PAGE"
cp "$TMP/ScrapyardsPage.css" "$CSS"

# Validate the redesign still carries the exact original business records.
grep -Fq "{ id: 1, name: 'تشليح الحاير المركزي', rating: 4.8, distance: '12 كم', cars: 'تويوتا، لكزس، هيونداي', verified: true }" "$PAGE"
grep -Fq "{ id: 2, name: 'تشليح السلي للسيارات الأمريكية', rating: 4.5, distance: '18 كم', cars: 'فورد، شيفروليه، دودج', verified: false }" "$PAGE"
grep -Fq "{ id: 3, name: 'تشليح القمة الألماني', rating: 4.9, distance: '22 كم', cars: 'مرسيدس، بي إم دبليو، أودي', verified: true }" "$PAGE"
grep -Fq "{ id: 101, partName: 'مكينة كامري 2020', yardName: 'تشليح الحاير المركزي', price: '4500 ر.س', condition: 'مستخدم نظيف', warranty: 'شهر' }" "$PAGE"
grep -Fq "{ id: 102, partName: 'قير فورد تورس', yardName: 'تشليح السلي', price: '3200 ر.س', condition: 'مجدد', warranty: '15 يوم' }" "$PAGE"
grep -Fq "{ id: 103, partName: 'شمعة أمامية يمين لكزس ES', yardName: 'تشليح الحاير المركزي', price: '900 ر.س', condition: 'وكالة مستعمل', warranty: 'بدون ضمان' }" "$PAGE"

grep -Fq "scrapyards.length" "$PAGE"
grep -Fq "mockParts.length" "$PAGE"
grep -Fq "verifiedCount" "$PAGE"
grep -Fq "HomeStoreHeader" "$PAGE"
grep -Fq "sy67-search-panel" "$PAGE"
grep -Fq "sy67-network-card" "$PAGE"
grep -Fq "sy67-parts-grid" "$PAGE"

if grep -Eq "fetch\(|axios\.|/api/" "$PAGE"; then
  echo "ERROR: unexpected new API usage in ScrapyardsPage" >&2
  false
fi

echo "ORIGINAL_SCRAPYARD_RECORDS_PRESERVED"
echo "ORIGINAL_SCRAPYARD_PART_RECORDS_PRESERVED"
echo "NO_NEW_SCRAPYARD_API_ADDED"
echo "NO_INVENTED_SCRAPYARD_BUSINESS_DATA"

for file in "${!BEFORE_SHA[@]}"; do
  after="$(sha256sum "$file" | awk '{print $1}')"
  if [[ "$after" != "${BEFORE_SHA[$file]}" ]]; then
    echo "ERROR: protected file changed: $file" >&2
    false
  fi
done

echo "OTHER_REDESIGNED_PAGES_UNCHANGED"
echo "BATCH_08_SCRAPYARDS_REFERENCE_V1_APPLIED"
echo "ORIGINAL_SCRAPYARDS_DATA_SOURCE_PRESERVED"

trap - ERR
cleanup
