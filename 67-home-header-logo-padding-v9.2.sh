#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
TMP="/tmp/67-logo-exact-v9.2.png"
BACKUP="/tmp/67-home-header-logo-padding-v9-2-backup-$(date +%Y%m%d-%H%M%S)"

RAW_LOGO="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/home-assets-v9/logo-67-user-exact.png"
EXPECTED_SHA="5f097e4cfe7802a2baa8b1440bcfe27eb1c37484a1cafb9c006e446624ce6090"

for f in "$HEADER_CSS" "$HEADER_JSX" "$HOME_CSS" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing $f" >&2; exit 141; }
done

mkdir -p "$BACKUP/src/components" "$BACKUP/public/assets"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"

HEADER_JSX_BEFORE="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"

rm -f "$TMP"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_LOGO?v=$(date +%s)" -o "$TMP"
DOWNLOADED_SHA="$(sha256sum "$TMP" | awk '{print $1}')"
[ "$DOWNLOADED_SHA" = "$EXPECTED_SHA" ] || {
  echo "ERROR: exact user logo SHA mismatch" >&2
  echo "Expected: $EXPECTED_SHA" >&2
  echo "Found:    $DOWNLOADED_SHA" >&2
  exit 142
}

python3 - "$TMP" <<'PY'
from pathlib import Path
from PIL import Image
import hashlib, sys
p = Path(sys.argv[1])
b = p.read_bytes()
if b[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: downloaded logo is not PNG')
im = Image.open(p).convert('RGBA')
if im.size != (946, 567):
    raise SystemExit(f'ERROR: expected 946x567, got {im.size}')
alpha = im.getchannel('A')
bbox = alpha.getbbox()
if bbox != (24, 24, 922, 543):
    raise SystemExit(f'ERROR: unexpected artwork alpha bbox: {bbox}')
print(f'Exact user logo validated: {im.size[0]}x{im.size[1]} | alpha bbox={bbox} | {len(b)} bytes')
PY

cp -f "$TMP" "$LOGO"
FINAL_SHA="$(sha256sum "$LOGO" | awk '{print $1}')"
[ "$FINAL_SHA" = "$EXPECTED_SHA" ] || { echo "ERROR: installed logo SHA mismatch" >&2; exit 143; }

python3 - "$HEADER_CSS" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

# Remove only our own V9.2 block if re-running.
s = re.sub(
    r'\n?/\* 67_HOME_HEADER_LOGO_PADDING_V9_2_START \*/.*?/\* 67_HOME_HEADER_LOGO_PADDING_V9_2_END \*/\n?',
    '\n', s, flags=re.S
)

block = r'''
/* 67_HOME_HEADER_LOGO_PADDING_V9_2_START */
/* Desktop visual edge inset without disturbing the approved center nav. */
@media (min-width: 1281px) {
  .h67-header {
    box-sizing: border-box !important;
    overflow: visible !important;
  }

  /* Right edge: keep the full approved logo comfortably inside the navbar. */
  .h67-header .h67-logo {
    position: absolute !important;
    top: 50% !important;
    right: clamp(48px, 3.2vw, 64px) !important;
    left: auto !important;
    transform: translateY(-50%) !important;
    width: 166px !important;
    min-width: 166px !important;
    max-width: 166px !important;
    height: 96px !important;
    min-height: 96px !important;
    max-height: 96px !important;
    margin: 0 !important;
    padding: 0 !important;
    border: 0 !important;
    background: transparent !important;
    overflow: visible !important;
    opacity: 1 !important;
    visibility: visible !important;
    clip: auto !important;
    clip-path: none !important;
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
    object-fit: contain !important;
    object-position: center !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    transform: none !important;
    clip: auto !important;
    clip-path: none !important;
    margin: 0 !important;
    padding: 0 !important;
  }

  /* Left edge: create visual navbar padding without moving the centered nav. */
  .h67-header .h67-actions {
    margin-left: clamp(48px, 3.2vw, 64px) !important;
    margin-right: 0 !important;
  }
}
/* 67_HOME_HEADER_LOGO_PADDING_V9_2_END */
'''

p.write_text(s.rstrip() + "\n\n" + block + "\n", encoding='utf-8')
PY

HEADER_JSX_AFTER="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"

[ "$HEADER_JSX_BEFORE" = "$HEADER_JSX_AFTER" ] || { echo "ERROR: Header JSX changed unexpectedly" >&2; exit 144; }
[ "$HOME_CSS_BEFORE" = "$HOME_CSS_AFTER" ] || { echo "ERROR: HomePage.css changed unexpectedly" >&2; exit 145; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo "ERROR: hero background changed unexpectedly" >&2; exit 146; }

echo "HOME_HEADER_LOGO_PADDING_V9_2_APPLIED"
echo "Exact logo SHA: $FINAL_SHA"
echo "Changed: public/assets/logo-67.png"
echo "Changed: src/components/HomeStoreHeader.css"
