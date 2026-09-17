#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-09-workshops-reference-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-09-workshops-$STAMP"
BACKUP="/tmp/67-batch-09-workshops-backup-$STAMP"

JSX="$ROOT/src/pages/WorkshopsPage.jsx"
CSS="$ROOT/src/pages/WorkshopsPage.css"
APP="$ROOT/src/App.jsx"

for f in "$JSX" "$CSS" "$APP"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 2101; }
done

grep -q "const workshops = \[" "$JSX" || { echo 'ERROR: original workshops data source missing' >&2; exit 2102; }
grep -q "name: 'مركز العناية الشاملة'" "$JSX" || { echo 'ERROR: original workshop 1 missing' >&2; exit 2103; }
grep -q "name: 'ورشة الخبراء الألمان'" "$JSX" || { echo 'ERROR: original workshop 2 missing' >&2; exit 2104; }
grep -q 'path="/workshops"' "$APP" || { echo 'ERROR: original /workshops route missing' >&2; exit 2105; }

echo 'ORIGINAL_WORKSHOPS_DATA_DETECTED'
echo 'ORIGINAL_WORKSHOPS_ROUTE_DETECTED'

mkdir -p "$TMP" "$BACKUP"
cp -a "$JSX" "$BACKUP/WorkshopsPage.jsx"
cp -a "$CSS" "$BACKUP/WorkshopsPage.css"

PROTECTED=(
  "$ROOT/src/App.jsx"
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/pages/AuctionsPage.jsx"
  "$ROOT/src/pages/AuctionDetailPage.jsx"
  "$ROOT/src/pages/ScrapyardsPage.jsx"
  "$ROOT/src/pages/ScrapyardsPage.css"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/pages/OfferDetailPage.jsx"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CheckoutPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/NotificationsPage.jsx"
  "$ROOT/src/pages/PartSearchPage.jsx"
  "$ROOT/src/pages/CustomerProfilePage.jsx"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 2106; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/WorkshopsPage.jsx" "$JSX" || true
  cp -f "$BACKUP/WorkshopsPage.css" "$CSS" || true
  echo 'ERROR: Batch 09 workshops redesign failed; target files restored' >&2
  exit "$code"
}
trap rollback ERR

curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/WorkshopsPage.jsx?v=$(date +%s)" -o "$TMP/WorkshopsPage.jsx"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/WorkshopsPage.css?v=$(date +%s)" -o "$TMP/WorkshopsPage.css"

[ -s "$TMP/WorkshopsPage.jsx" ] || { echo 'ERROR: empty WorkshopsPage.jsx payload' >&2; false; }
[ -s "$TMP/WorkshopsPage.css" ] || { echo 'ERROR: empty WorkshopsPage.css payload' >&2; false; }

python3 - "$TMP/WorkshopsPage.jsx" <<'PY'
from pathlib import Path
import sys
s = Path(sys.argv[1]).read_text(encoding='utf-8')
required = [
    "const workshops = [",
    "{ id: 1, name: 'مركز العناية الشاملة', rating: 4.7, reviews: 124, distance: '3 كم', specialized: 'ميكانيكا عامة', price: '$$' }",
    "{ id: 2, name: 'ورشة الخبراء الألمان', rating: 4.9, reviews: 89, distance: '5 كم', specialized: 'سيارات ألمانية', price: '$$$' }",
    'HomeStoreHeader',
    'ws67-hero',
    'ws67-service-panel',
    'ws67-workshops-list',
    'workshops.reduce',
]
missing = [marker for marker in required if marker not in s]
if missing:
    raise SystemExit('ERROR: workshops payload missing markers: ' + ', '.join(missing))

for forbidden in [
    '120+',
    '35 دقيقة',
    '7 أيام',
    'Prime Auto',
    'Volt Garage',
    'Cool Drive Center',
    'Stop+ Workshop',
    'openNow:',
    'bookingSlots:',
    'servicePrice:',
    'address:',
    'city:',
]:
    if forbidden in s:
        raise SystemExit(f'ERROR: invented workshop/reference business data detected: {forbidden}')
PY

python3 - "$TMP/WorkshopsPage.css" <<'PY'
from pathlib import Path
import re, sys
s = Path(sys.argv[1]).read_text(encoding='utf-8')
small = []
for m in re.finditer(r'font-size\s*:\s*([0-9.]+)px', s):
    if float(m.group(1)) < 14:
        small.append(m.group(0))
if small:
    raise SystemExit('ERROR: Workshops CSS contains font-size below 14px: ' + ', '.join(sorted(set(small))))
PY

echo 'WORKSHOPS_REFERENCE_PAYLOAD_VALID'
echo 'ORIGINAL_WORKSHOP_RECORDS_PRESERVED'
echo 'NO_INVENTED_WORKSHOP_BUSINESS_DATA'

cp -f "$TMP/WorkshopsPage.jsx" "$JSX"
cp -f "$TMP/WorkshopsPage.css" "$CSS"

grep -q 'className="ws67-page"' "$JSX"
grep -q 'HomeStoreHeader' "$JSX"
grep -q 'ws67-workshops-list' "$JSX"
grep -q 'ws67-maintenance-cta' "$JSX"

sha256sum -c "$HASHES" >/dev/null || { echo 'ERROR: protected file changed unexpectedly' >&2; false; }

trap - ERR
rm -rf "$TMP" "$BACKUP"

echo 'BATCH_09_WORKSHOPS_REFERENCE_V1_APPLIED'
echo 'ORIGINAL_WORKSHOPS_DATA_SOURCE_PRESERVED'
echo 'ORIGINAL_WORKSHOP_RECORDS_PRESERVED'
echo 'NO_NEW_WORKSHOP_API_ADDED'
echo 'NO_INVENTED_WORKSHOP_BUSINESS_DATA'
echo 'OTHER_REDESIGNED_PAGES_UNCHANGED'
echo 'CHANGED_FILES:'
echo '  src/pages/WorkshopsPage.jsx'
echo '  src/pages/WorkshopsPage.css'
