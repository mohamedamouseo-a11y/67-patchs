#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/HomePage.css"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
BACKUP="/tmp/67-home-hero-shift-v8-2-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$CSS" "$HEADER_CSS" "$HERO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 82
  fi
done

mkdir -p "$BACKUP/src/pages"
cp -a "$CSS" "$BACKUP/src/pages/HomePage.css"

HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

echo "Backup: $BACKUP"
echo "Hero guard SHA: $HERO_BEFORE"
echo "Navbar CSS guard SHA: $HEADER_BEFORE"

python3 - "$CSS" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

# Remove only our previous shift-only block so repeated runs stay clean.
s = re.sub(r'\n?/\* 67_HERO_SHIFT_V8_2_START \*/.*?/\* 67_HERO_SHIFT_V8_2_END \*/\n?', '\n', s, flags=re.S)

block = r'''
/* 67_HERO_SHIFT_V8_2_START */
/* Shift-only correction from the approved V8.1 visual result.
   Do not alter background/navbar. Move the existing hero copy LEFT and DOWN only. */
@media (min-width: 1281px) {
  .home67-page .home67-hero .home67-hero-copy {
    /* Current visual is too far RIGHT and too HIGH.
       Keep all existing sizing/typography; only translate the whole block. */
    transform: translate(clamp(-340px, -17.2vw, -250px), 140px) !important;
    transform-origin: top right !important;
    will-change: transform !important;
  }

  /* Prevent nested legacy transforms from fighting the group shift. */
  .home67-page .home67-hero .home67-hero-copy > *,
  .home67-page .home67-hero .home67-hero-copy h1,
  .home67-page .home67-hero .home67-hero-copy h1 span,
  .home67-page .home67-hero .home67-hero-actions,
  .home67-page .home67-hero .home67-hero-buttons,
  .home67-page .home67-hero .home67-hero-trust {
    translate: none !important;
  }
}
/* 67_HERO_SHIFT_V8_2_END */
'''

p.write_text(s.rstrip() + "\n" + block + "\n", encoding='utf-8')
PY

HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

if [ "$HERO_BEFORE" != "$HERO_AFTER" ]; then
  echo "ERROR: hero background changed unexpectedly" >&2
  exit 83
fi
if [ "$HEADER_BEFORE" != "$HEADER_AFTER" ]; then
  echo "ERROR: navbar CSS changed unexpectedly" >&2
  exit 84
fi

echo "HERO_SHIFT_V8_2_APPLIED"
echo "Hero unchanged: $HERO_AFTER"
echo "Navbar CSS unchanged: $HEADER_AFTER"
echo "Changed only: src/pages/HomePage.css"
