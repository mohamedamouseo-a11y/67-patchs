#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
TMP="/tmp/67-logo-exact-v9.png"
BACKUP="/tmp/67-home-logo-exact-v9-backup-$(date +%Y%m%d-%H%M%S)"

RAW_LOGO="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/home-assets-v9/logo-67-exact.png"
EXPECTED_SHA="a593aa152ca36f6ff704efb1b716ff3c637fd352e130892874cb74574c12bd08"

for f in "$HEADER_CSS" "$HEADER_JSX" "$HOME_CSS" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing $f" >&2; exit 131; }
done

mkdir -p "$BACKUP/public/assets"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"

HEADER_CSS_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
HEADER_JSX_BEFORE="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"

rm -f "$TMP"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_LOGO?v=$(date +%s)" -o "$TMP"

DOWNLOADED_SHA="$(sha256sum "$TMP" | awk '{print $1}')"
if [ "$DOWNLOADED_SHA" != "$EXPECTED_SHA" ]; then
  echo "ERROR: downloaded logo SHA mismatch" >&2
  echo "Expected: $EXPECTED_SHA" >&2
  echo "Found:    $DOWNLOADED_SHA" >&2
  exit 132
fi

python3 - "$TMP" <<'PY'
from pathlib import Path
import struct, sys
p = Path(sys.argv[1])
b = p.read_bytes()
if len(b) < 24 or b[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: downloaded asset is not a PNG')
w, h = struct.unpack('>II', b[16:24])
if (w, h) != (946, 567):
    raise SystemExit(f'ERROR: expected 946x567, got {w}x{h}')
print(f'Approved logo validated: {w}x{h} | {len(b)} bytes')
PY

cp -f "$TMP" "$LOGO"
FINAL_SHA="$(sha256sum "$LOGO" | awk '{print $1}')"
[ "$FINAL_SHA" = "$EXPECTED_SHA" ] || { echo "ERROR: installed logo SHA mismatch" >&2; exit 133; }

HEADER_CSS_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
HEADER_JSX_AFTER="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"

[ "$HEADER_CSS_BEFORE" = "$HEADER_CSS_AFTER" ] || { echo "ERROR: header CSS changed unexpectedly" >&2; exit 134; }
[ "$HEADER_JSX_BEFORE" = "$HEADER_JSX_AFTER" ] || { echo "ERROR: header JSX changed unexpectedly" >&2; exit 135; }
[ "$HOME_CSS_BEFORE" = "$HOME_CSS_AFTER" ] || { echo "ERROR: HomePage.css changed unexpectedly" >&2; exit 136; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo "ERROR: hero background changed unexpectedly" >&2; exit 137; }

echo "HOME_LOGO_EXACT_ASSET_V9_APPLIED"
echo "Exact logo SHA: $FINAL_SHA"
echo "Changed only: public/assets/logo-67.png"
