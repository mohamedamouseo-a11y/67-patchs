#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-07-auctions-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-07-auctions-$STAMP"
BACKUP="/tmp/67-batch-07-auctions-backup-$STAMP"

JSX="$ROOT/src/pages/AuctionsPage.jsx"
CSS="$ROOT/src/pages/AuctionsPage.css"
DETAIL="$ROOT/src/pages/AuctionDetailPage.jsx"

for f in "$JSX" "$CSS" "$DETAIL"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 1901; }
done

# Confirm the current page still exposes the original project auction source and detail flow.
grep -q 'export const auctionsData' "$JSX" || { echo 'ERROR: original auctionsData source missing' >&2; exit 1902; }
grep -q "id: 'ferrari'" "$JSX" || { echo 'ERROR: original Ferrari auction missing' >&2; exit 1903; }
grep -q "id: 'mustang'" "$JSX" || { echo 'ERROR: original Mustang auction missing' >&2; exit 1904; }
grep -q "id: 'rims'" "$JSX" || { echo 'ERROR: original rims auction missing' >&2; exit 1905; }
grep -q "id: 'lights'" "$JSX" || { echo 'ERROR: original lights auction missing' >&2; exit 1906; }
grep -q "from './AuctionsPage'" "$DETAIL" || { echo 'ERROR: AuctionDetailPage no longer reads AuctionsPage data' >&2; exit 1907; }
grep -q 'currentBid' "$DETAIL" || { echo 'ERROR: original detail bidding behavior marker missing' >&2; exit 1908; }
grep -q 'handleBid' "$DETAIL" || { echo 'ERROR: original bid interaction marker missing' >&2; exit 1909; }

echo 'ORIGINAL_AUCTIONS_DATA_DETECTED'
echo 'ORIGINAL_AUCTION_DETAIL_FLOW_DETECTED'

mkdir -p "$TMP" "$BACKUP"
cp -a "$JSX" "$BACKUP/AuctionsPage.jsx"
cp -a "$CSS" "$BACKUP/AuctionsPage.css"

PROTECTED=(
  "$ROOT/src/pages/AuctionDetailPage.jsx"
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/pages/HomePage.css"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/components/HomeBelowHero.css"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/pages/TopPartsPage.css"
  "$ROOT/src/pages/OfferDetailPage.jsx"
  "$ROOT/src/pages/OfferDetailPage.css"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/CheckoutPage.jsx"
  "$ROOT/src/pages/CheckoutPage.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 1910; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/AuctionsPage.jsx" "$JSX" || true
  cp -f "$BACKUP/AuctionsPage.css" "$CSS" || true
  echo 'ERROR: Batch 07 auctions redesign failed; target files restored' >&2
  exit "$code"
}
trap rollback ERR

curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/AuctionsPage.jsx?v=$(date +%s)" -o "$TMP/AuctionsPage.jsx"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/AuctionsPage.css?v=$(date +%s)" -o "$TMP/AuctionsPage.css"

[ -s "$TMP/AuctionsPage.jsx" ] || { echo 'ERROR: empty AuctionsPage.jsx payload' >&2; false; }
[ -s "$TMP/AuctionsPage.css" ] || { echo 'ERROR: empty AuctionsPage.css payload' >&2; false; }

# Validate the redesign preserves the exact original auction records/fields that drive content.
python3 - "$TMP/AuctionsPage.jsx" <<'PY'
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_text(encoding='utf-8')
required = [
    "id: 'ferrari'",
    "title: 'ماكينة فيراري 458'",
    'bids: 35',
    'currentBid: 65000',
    "timeLeft: '00:45:00'",
    "image: '/images/auctions/ferrari.jpg'",
    "id: 'mustang'",
    "title: 'محرك موستنج 1969 كلاسيك'",
    'bids: 12',
    'currentBid: 15000',
    "timeLeft: '02:15:30'",
    "image: '/images/auctions/mustang.jpg'",
    "id: 'rims'",
    "title: 'جنوط مرسيدس AMG أصلية'",
    'bids: 8',
    'currentBid: 3200',
    "timeLeft: '05:40:00'",
    "image: '/images/auctions/rims.jpg'",
    "id: 'lights'",
    "title: 'شمعات رنج روفر 2023'",
    'bids: 24',
    'currentBid: 4500',
    "timeLeft: '00:12:45'",
    "image: '/images/auctions/lights.jpg'",
    'export const auctionsData',
    "navigate(`/auction/${auctionId}`)",
    'HomeStoreHeader',
    'a67-featured',
    'a67-grid',
]
missing = [marker for marker in required if marker not in s]
if missing:
    raise SystemExit('ERROR: auctions payload missing markers: ' + ', '.join(missing))

# Reference-only content that must not become invented structured auction fields.
for forbidden in ['condition:', 'category:', 'vehicleCompatibility:', 'reservePrice:', 'sellerName:']:
    if forbidden in s:
        raise SystemExit(f'ERROR: invented auction data field detected: {forbidden}')
PY

# Ensure all visible CSS text is at least 14px in this new scoped page.
python3 - "$TMP/AuctionsPage.css" <<'PY'
from pathlib import Path
import re, sys
s = Path(sys.argv[1]).read_text(encoding='utf-8')
small = []
for m in re.finditer(r'font-size\s*:\s*([0-9.]+)px', s):
    if float(m.group(1)) < 14:
        small.append(m.group(0))
if small:
    raise SystemExit('ERROR: Auctions CSS contains font-size below 14px: ' + ', '.join(sorted(set(small))))
PY

echo 'AUCTIONS_REFERENCE_PAYLOAD_VALID'
echo 'ORIGINAL_AUCTION_RECORDS_PRESERVED'
echo 'NO_INVENTED_AUCTION_DATA_FIELDS'

cp -f "$TMP/AuctionsPage.jsx" "$JSX"
cp -f "$TMP/AuctionsPage.css" "$CSS"

# Final source validation.
grep -q 'export const auctionsData' "$JSX"
grep -q 'HomeStoreHeader' "$JSX"
grep -q 'a67-featured' "$JSX"
grep -q 'a67-grid' "$JSX"
grep -q 'ACTIONS' /dev/null 2>/dev/null || true

# Protected project/data/commerce/detail files must remain byte-for-byte unchanged.
sha256sum -c "$HASHES" >/dev/null || { echo 'ERROR: protected file changed unexpectedly' >&2; false; }

trap - ERR

echo 'AUCTIONS_REFERENCE_REDESIGN_V1_APPLIED'
echo 'ORIGINAL_AUCTIONS_DATA_SOURCE_PRESERVED'
echo 'ORIGINAL_AUCTION_DETAIL_BEHAVIOR_PRESERVED'
echo 'OTHER_REDESIGNED_PAGES_UNCHANGED'
echo 'CHANGED_FILES:'
echo '  src/pages/AuctionsPage.jsx'
echo '  src/pages/AuctionsPage.css'
