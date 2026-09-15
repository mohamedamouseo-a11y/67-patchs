#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
SOURCE_LOGO="${1:-/tmp/67-logo-exact.png}"
EXPECTED_SHA="5f097e4cfe7802a2baa8b1440bcfe27eb1c37484a1cafb9c006e446624ce6090"
BACKUP="/tmp/67-home-header-exact-logo-v8-9-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$HEADER_JSX" "$HEADER_CSS" "$HOME_CSS" "$HERO" "$LOGO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 121
  fi
done

mkdir -p "$BACKUP/src/components" "$BACKUP/public/assets"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"

HOME_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
JSX_BEFORE="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
CURRENT_LOGO_SHA="$(sha256sum "$LOGO" | awk '{print $1}')"

echo "Current logo SHA: $CURRENT_LOGO_SHA"

if [ "$CURRENT_LOGO_SHA" != "$EXPECTED_SHA" ]; then
  if [ ! -f "$SOURCE_LOGO" ]; then
    echo "ERROR: exact approved logo not already installed and source file not found: $SOURCE_LOGO" >&2
    echo "Save the user-provided exact logo to /tmp/67-logo-exact.png and rerun." >&2
    exit 122
  fi

  SOURCE_SHA="$(sha256sum "$SOURCE_LOGO" | awk '{print $1}')"
  if [ "$SOURCE_SHA" != "$EXPECTED_SHA" ]; then
    echo "ERROR: provided source logo is not the exact approved file" >&2
    echo "Expected: $EXPECTED_SHA" >&2
    echo "Found:    $SOURCE_SHA" >&2
    exit 123
  fi

  python3 - "$SOURCE_LOGO" <<'PY'
from pathlib import Path
import struct, sys
p = Path(sys.argv[1])
b = p.read_bytes()
if len(b) < 24 or b[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: source logo is not a PNG')
w, h = struct.unpack('>II', b[16:24])
if (w, h) != (946, 567):
    raise SystemExit(f'ERROR: expected 946x567, got {w}x{h}')
print(f'Exact approved source logo validated: {w}x{h} | {len(b)} bytes')
PY

  cp -f "$SOURCE_LOGO" "$LOGO"
fi

FINAL_LOGO_SHA="$(sha256sum "$LOGO" | awk '{print $1}')"
if [ "$FINAL_LOGO_SHA" != "$EXPECTED_SHA" ]; then
  echo "ERROR: installed logo SHA mismatch" >&2
  exit 124
fi

python3 - "$HEADER_JSX" <<'PY'
from pathlib import Path
import sys
s = Path(sys.argv[1]).read_text(encoding='utf-8')
if '/assets/logo-67.png' not in s:
    raise SystemExit('ERROR: HomeStoreHeader.jsx is not wired to /assets/logo-67.png')
print('Header JSX wiring validated')
PY

python3 - "$HEADER_CSS" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

s = re.sub(
    r'\n?/\* 67_HOME_HEADER_EXACT_LOGO_V8_9_START \*/.*?/\* 67_HOME_HEADER_EXACT_LOGO_V8_9_END \*/\n?',
    '\n', s, flags=re.S
)

block = r'''
/* 67_HOME_HEADER_EXACT_LOGO_V8_9_START */
/* Desktop-only display of the exact user-approved 946x567 Six Seven artwork.
   Preserve the native aspect ratio: no crop, no stretch, no filter. */
@media (min-width: 1281px) {
  .h67-header .h67-logo {
    position: absolute !important;
    top: 50% !important;
    right: 28px !important;
    left: auto !important;
    transform: translateY(-50%) !important;
    width: 164px !important;
    height: 96px !important;
    min-width: 164px !important;
    min-height: 96px !important;
    max-width: 164px !important;
    max-height: 96px !important;
    padding: 0 !important;
    margin: 0 !important;
    border: 0 !important;
    background: transparent !important;
    overflow: visible !important;
    opacity: 1 !important;
    visibility: visible !important;
    z-index: 30000 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
  }

  .h67-header .h67-logo > img {
    display: block !important;
    width: 158px !important;
    height: auto !important;
    max-width: 158px !important;
    max-height: none !important;
    aspect-ratio: auto !important;
    object-fit: contain !important;
    object-position: center !important;
    margin: 0 !important;
    padding: 0 !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    transform: none !important;
    clip: auto !important;
    clip-path: none !important;
  }
}
/* 67_HOME_HEADER_EXACT_LOGO_V8_9_END */
'''

p.write_text(s.rstrip() + "\n\n" + block + "\n", encoding='utf-8')
PY

HOME_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
JSX_AFTER="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"

[ "$HOME_BEFORE" = "$HOME_AFTER" ] || { echo "ERROR: HomePage.css changed unexpectedly" >&2; exit 125; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo "ERROR: hero background changed unexpectedly" >&2; exit 126; }
[ "$JSX_BEFORE" = "$JSX_AFTER" ] || { echo "ERROR: HomeStoreHeader.jsx changed unexpectedly" >&2; exit 127; }

echo "HOME_HEADER_EXACT_LOGO_V8_9_APPLIED"
echo "Exact logo SHA: $FINAL_LOGO_SHA"
echo "Changed: src/components/HomeStoreHeader.css"
echo "Logo asset changed only if its previous SHA differed from the exact approved file"
