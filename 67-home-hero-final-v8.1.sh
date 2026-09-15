#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/HomePage.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-hero-final-v8-1-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$CSS" "$HEADER_JSX" "$HEADER_CSS" "$HERO" "$LOGO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 81
  fi
done

mkdir -p "$BACKUP/src/pages" "$BACKUP/src/components" "$BACKUP/public/assets"
cp -a "$CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HEADER_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"

HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_CSS_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

echo "Backup: $BACKUP"
echo "Hero guard SHA: $HERO_BEFORE"
echo "Navbar CSS guard SHA: $HEADER_CSS_BEFORE"

# Validate that the already-restored logo asset is the approved 946x567 PNG.
python3 - "$LOGO" <<'PY'
from pathlib import Path
import struct, sys
p = Path(sys.argv[1])
b = p.read_bytes()
if len(b) < 24 or b[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: logo-67.png is not a valid PNG')
w, h = struct.unpack('>II', b[16:24])
print(f'Logo asset: {w}x{h} | {len(b)} bytes')
if (w, h) != (946, 567):
    raise SystemExit('ERROR: expected approved 946x567 logo asset')
PY

# The navbar layout/CSS is already approved. Only make the existing logo slot render
# the real /assets/logo-67.png image instead of the Logo67 text/component.
python3 - "$HEADER_JSX" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

# If the exact image is already wired, leave JSX untouched.
if '/assets/logo-67.png' not in s:
    # Replace the Logo67 component instance only; keep its existing wrapper/layout intact.
    new, n = re.subn(r'<Logo67\b[^>]*/>', '<img src="/assets/logo-67.png" alt="Six Seven 67" className="h67-logo-image" />', s, count=1, flags=re.S)
    if n != 1:
        raise SystemExit('ERROR: could not find exactly one <Logo67 ... /> instance in HomeStoreHeader.jsx')
    s = new
    # Remove only the now-unused Logo67 import line.
    s = re.sub(r'^import\s+Logo67\s+from\s+[\'\"][^\'\"]+[\'\"];?\s*\n', '', s, count=1, flags=re.M)
    p.write_text(s, encoding='utf-8')
    print('Header logo source switched to /assets/logo-67.png')
else:
    print('Header already uses /assets/logo-67.png; no JSX logo change needed')
PY

# Fix only the hero content layer. Important: do NOT redefine the background image,
# background position, gradient values, hero height, navbar layout, or sections below hero.
python3 - "$CSS" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

# Remove only previous content-front hotfix blocks so old transforms cannot fight the final block.
for marker in ('67_HERO_CONTENT_FRONT_V5', '67_HERO_CONTENT_FRONT_V6', '67_HERO_FINAL_V8_1'):
    s = re.sub(r'\n?/\* ' + re.escape(marker) + r'_START \*/.*?/\* ' + re.escape(marker) + r'_END \*/\n?', '\n', s, flags=re.S)

block = r'''
/* 67_HERO_FINAL_V8_1_START */
@media (min-width:1281px) {
  /* Keep current hero visual exactly; only establish a clean stacking context. */
  .home67-page .home67-hero {
    position: relative !important;
    isolation: isolate !important;
  }

  /* Existing dark layers stay visually identical, but always behind the copy. */
  .home67-page .home67-hero::before,
  .home67-page .home67-hero::after,
  .home67-page .home67-hero .home67-hero-overlay,
  .home67-page .home67-hero [class*="hero-overlay"],
  .home67-page .home67-hero [class*="hero-shade"] {
    pointer-events: none !important;
  }

  .home67-page .home67-hero::before,
  .home67-page .home67-hero::after {
    z-index: 0 !important;
  }

  .home67-page .home67-hero .home67-hero-overlay,
  .home67-page .home67-hero [class*="hero-overlay"],
  .home67-page .home67-hero [class*="hero-shade"] {
    z-index: 1 !important;
  }

  /* CRITICAL: previous parent transforms were the reason top/right values rendered wrong. */
  .home67-page .home67-hero .home67-hero-shell,
  .home67-page .home67-hero .home67-hero-content {
    position: absolute !important;
    inset: 0 !important;
    width: 100% !important;
    max-width: none !important;
    height: 100% !important;
    margin: 0 !important;
    padding: 0 !important;
    transform: none !important;
    translate: none !important;
    scale: 1 !important;
    rotate: 0deg !important;
    animation: none !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    overflow: visible !important;
    z-index: 20 !important;
    pointer-events: none !important;
    box-sizing: border-box !important;
  }

  /* Exact desktop copy box: fully inside the RIGHT side, never clipped. */
  .home67-page .home67-hero .home67-hero-copy {
    position: absolute !important;
    top: 138px !important;
    right: clamp(144px, 10vw, 185px) !important;
    left: auto !important;
    bottom: auto !important;
    width: 620px !important;
    max-width: 620px !important;
    min-width: 0 !important;
    margin: 0 !important;
    padding: 0 !important;
    transform: none !important;
    translate: none !important;
    scale: 1 !important;
    rotate: 0deg !important;
    animation: none !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    mix-blend-mode: normal !important;
    overflow: visible !important;
    z-index: 30 !important;
    direction: rtl !important;
    text-align: right !important;
    color: #fff !important;
    pointer-events: auto !important;
    box-sizing: border-box !important;
  }

  /* Reset inherited hotfix offsets on the structural children only. */
  .home67-page .home67-hero .home67-hero-copy > * {
    left: auto !important;
    right: auto !important;
    top: auto !important;
    bottom: auto !important;
    transform: none !important;
    translate: none !important;
    scale: 1 !important;
    rotate: 0deg !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    mix-blend-mode: normal !important;
    box-sizing: border-box !important;
  }

  .home67-page .home67-hero .home67-hero-kicker,
  .home67-page .home67-hero .home67-hero-eyebrow,
  .home67-page .home67-hero .home67-eyebrow {
    display: flex !important;
    align-items: center !important;
    justify-content: flex-start !important;
    gap: 14px !important;
    width: max-content !important;
    max-width: 100% !important;
    margin: 0 0 30px auto !important;
    padding: 0 !important;
    color: #d5ad2d !important;
    font-size: 15px !important;
    line-height: 1 !important;
    font-weight: 900 !important;
    white-space: nowrap !important;
  }

  .home67-page .home67-hero .home67-hero-kicker::before,
  .home67-page .home67-hero .home67-hero-eyebrow::before,
  .home67-page .home67-hero .home67-eyebrow::before {
    content: '' !important;
    width: 38px !important;
    height: 2px !important;
    flex: 0 0 38px !important;
    display: block !important;
    border-radius: 999px !important;
    background: #d5ad2d !important;
  }

  .home67-page .home67-hero .home67-hero-kicker::after,
  .home67-page .home67-hero .home67-hero-eyebrow::after,
  .home67-page .home67-hero .home67-eyebrow::after {
    content: none !important;
    display: none !important;
  }

  .home67-page .home67-hero .home67-hero-copy h1,
  .home67-page .home67-hero .home67-hero-title {
    position: relative !important;
    width: 100% !important;
    max-width: 620px !important;
    margin: 0 !important;
    padding: 0 !important;
    color: #fff !important;
    font-size: clamp(70px, 4.1vw, 78px) !important;
    line-height: 1.15 !important;
    letter-spacing: -1.5px !important;
    font-weight: 950 !important;
    text-align: right !important;
    white-space: normal !important;
    overflow: visible !important;
    text-shadow: none !important;
  }

  .home67-page .home67-hero .home67-hero-copy h1 span,
  .home67-page .home67-hero .home67-hero-highlight,
  .home67-page .home67-hero .home67-gold {
    display: block !important;
    margin: 14px 0 0 !important;
    padding: 0 !important;
    color: #d5ad2d !important;
    font-size: clamp(58px, 3.45vw, 66px) !important;
    line-height: 1.12 !important;
    font-weight: 950 !important;
    white-space: nowrap !important;
  }

  .home67-page .home67-hero .home67-hero-copy > p,
  .home67-page .home67-hero .home67-hero-description {
    width: 580px !important;
    max-width: 100% !important;
    margin: 28px 0 0 auto !important;
    padding: 0 !important;
    color: rgba(255,255,255,.82) !important;
    font-size: 16px !important;
    line-height: 1.95 !important;
    font-weight: 450 !important;
    text-align: right !important;
  }

  .home67-page .home67-hero .home67-hero-actions,
  .home67-page .home67-hero .home67-hero-buttons {
    display: flex !important;
    flex-direction: row !important;
    flex-wrap: nowrap !important;
    align-items: center !important;
    justify-content: flex-start !important;
    direction: rtl !important;
    gap: 14px !important;
    width: 100% !important;
    margin: 30px 0 0 !important;
    padding: 0 !important;
  }

  .home67-page .home67-hero .home67-hero-actions button,
  .home67-page .home67-hero .home67-hero-actions a,
  .home67-page .home67-hero .home67-hero-buttons button,
  .home67-page .home67-hero .home67-hero-buttons a {
    flex: 0 0 auto !important;
    min-width: 184px !important;
    height: 58px !important;
    min-height: 58px !important;
    margin: 0 !important;
    padding: 0 26px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
  }

  .home67-page .home67-hero .home67-hero-trust {
    display: block !important;
    width: max-content !important;
    max-width: 100% !important;
    margin: 36px 0 0 auto !important;
    padding: 0 16px 0 0 !important;
    border-right: 3px solid #d5ad2d !important;
    color: #fff !important;
    direction: rtl !important;
    text-align: right !important;
    opacity: 1 !important;
    visibility: visible !important;
  }
}
/* 67_HERO_FINAL_V8_1_END */
'''

p.write_text(s.rstrip() + '\n' + block + '\n', encoding='utf-8')
PY

# Hard guards: approved background asset and approved navbar CSS must be byte-identical.
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_CSS_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

if [ "$HERO_BEFORE" != "$HERO_AFTER" ]; then
  echo "ERROR: hero background asset changed; restoring backup CSS/JS and stopping" >&2
  cp -f "$BACKUP/src/pages/HomePage.css" "$CSS"
  cp -f "$BACKUP/src/components/HomeStoreHeader.jsx" "$HEADER_JSX"
  exit 82
fi

if [ "$HEADER_CSS_BEFORE" != "$HEADER_CSS_AFTER" ]; then
  echo "ERROR: navbar CSS changed unexpectedly; restoring backup CSS/JS and stopping" >&2
  cp -f "$BACKUP/src/pages/HomePage.css" "$CSS"
  cp -f "$BACKUP/src/components/HomeStoreHeader.jsx" "$HEADER_JSX"
  cp -f "$BACKUP/src/components/HomeStoreHeader.css" "$HEADER_CSS"
  exit 83
fi

echo "HERO_FINAL_V8_1_APPLIED"
echo "Hero background unchanged: $HERO_AFTER"
echo "Navbar CSS unchanged: $HEADER_CSS_AFTER"
echo "Changed only if required:"
echo "- src/pages/HomePage.css"
echo "- src/components/HomeStoreHeader.jsx (logo child only)"
echo "No source-repo push/merge/deploy/restart performed by this script."
