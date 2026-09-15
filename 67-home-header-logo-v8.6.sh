#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-header-logo-v8-6-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$HEADER_JSX" "$HEADER_CSS" "$HOME_CSS" "$HERO" "$LOGO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 95
  fi
done

mkdir -p "$BACKUP/src/components"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"

HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HEADER_JSX_BEFORE="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"

echo "Backup: $BACKUP"
echo "Hero guard SHA: $HERO_BEFORE"
echo "HomePage.css guard SHA: $HOME_CSS_BEFORE"
echo "Header JSX guard SHA: $HEADER_JSX_BEFORE"

python3 - "$LOGO" "$HEADER_JSX" <<'PY'
from pathlib import Path
import re, struct, sys
logo = Path(sys.argv[1])
jsx = Path(sys.argv[2])
b = logo.read_bytes()
if len(b) < 24 or b[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: logo-67.png is not a valid PNG')
w, h = struct.unpack('>II', b[16:24])
print(f'Logo asset: {w}x{h} | {len(b)} bytes')
if (w, h) != (946, 567):
    raise SystemExit('ERROR: expected approved 946x567 logo asset')
s = jsx.read_text(encoding='utf-8')
if '/assets/logo-67.png' not in s:
    raise SystemExit('ERROR: HomeStoreHeader.jsx is not wired to /assets/logo-67.png')
if not re.search(r'className=[\'\"]h67-logo[\'\"]', s):
    raise SystemExit('ERROR: expected .h67-logo wrapper not found in HomeStoreHeader.jsx')
print('Header JSX uses /assets/logo-67.png inside .h67-logo')
PY

python3 - "$HEADER_CSS" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

# Remove the broken V8.5 block and any prior V8.6 block only.
for marker in ('67_HOME_HEADER_LOGO_V8_5', '67_HOME_HEADER_LOGO_V8_6'):
    s = re.sub(
        r'\n?/\* ' + re.escape(marker) + r'_START \*/.*?/\* ' + re.escape(marker) + r'_END \*/\n?',
        '\n',
        s,
        flags=re.S,
    )

block = r'''
/* 67_HOME_HEADER_LOGO_V8_6_START */
/* Desktop-only logo correction using the ACTUAL DOM:
   <button class="h67-logo"><img src="/assets/logo-67.png" ... /></button>
   Keep center nav and left actions untouched. */
@media (min-width: 1281px) {
  .h67-header {
    position: relative !important;
    overflow: visible !important;
  }

  .h67-header .h67-logo {
    position: absolute !important;
    top: 50% !important;
    right: 28px !important;
    left: auto !important;
    transform: translateY(-50%) !important;
    width: 142px !important;
    min-width: 142px !important;
    max-width: 142px !important;
    height: 84px !important;
    min-height: 84px !important;
    max-height: 84px !important;
    margin: 0 !important;
    padding: 0 !important;
    border: 0 !important;
    background: transparent !important;
    overflow: visible !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    z-index: 30 !important;
  }

  .h67-header .h67-logo > img {
    display: block !important;
    width: 138px !important;
    height: 82px !important;
    max-width: 138px !important;
    max-height: 82px !important;
    object-fit: contain !important;
    object-position: center !important;
    margin: 0 !important;
    padding: 0 !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    transform: none !important;
  }
}
/* 67_HOME_HEADER_LOGO_V8_6_END */
'''

p.write_text(s.rstrip() + "\n\n" + block + "\n", encoding='utf-8')
PY

HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HEADER_JSX_AFTER="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"

if [ "$HERO_BEFORE" != "$HERO_AFTER" ]; then
  echo "ERROR: hero background changed unexpectedly" >&2
  exit 96
fi
if [ "$HOME_CSS_BEFORE" != "$HOME_CSS_AFTER" ]; then
  echo "ERROR: HomePage.css changed unexpectedly" >&2
  exit 97
fi
if [ "$HEADER_JSX_BEFORE" != "$HEADER_JSX_AFTER" ]; then
  echo "ERROR: HomeStoreHeader.jsx changed unexpectedly" >&2
  exit 98
fi

echo "HOME_HEADER_LOGO_V8_6_APPLIED"
echo "Hero unchanged: $HERO_AFTER"
echo "HomePage.css unchanged: $HOME_CSS_AFTER"
echo "Header JSX unchanged: $HEADER_JSX_AFTER"
echo "Changed only: src/components/HomeStoreHeader.css"
