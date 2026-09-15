#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/HomePage.css"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
BACKUP="/tmp/67-home-hero-real-target-v8-4-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$CSS" "$HEADER_CSS" "$HERO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 88
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

# Remove only our previous hero-position hotfix blocks that targeted the wrong/nonexistent
# .home67-hero-copy selector or overrode .home67-hero-content with inset:0.
markers = (
    '67_HERO_CONTENT_FRONT_V5',
    '67_HERO_CONTENT_FRONT_V6',
    '67_HERO_FINAL_V8_1',
    '67_HERO_SHIFT_V8_2',
    '67_HERO_SHIFT_V8_3',
    '67_HERO_REAL_TARGET_V8_4',
)
for marker in markers:
    s = re.sub(
        r'\n?/\* ' + re.escape(marker) + r'_START \*/.*?/\* ' + re.escape(marker) + r'_END \*/\n?',
        '\n',
        s,
        flags=re.S,
    )

# The real rendered text container is .home67-hero-content.
# Move that real block LEFT by increasing right offset, and DOWN by increasing top.
# Do not use transforms and do not touch background/navbar/hero geometry.
block = r'''
/* 67_HERO_REAL_TARGET_V8_4_START */
@media (min-width: 1281px) {
  .home67-page .home67-hero > .home67-hero-content {
    position: absolute !important;
    inset: auto !important;
    top: 185px !important;
    right: clamp(150px, 10vw, 190px) !important;
    bottom: auto !important;
    left: auto !important;
    width: 620px !important;
    max-width: 40% !important;
    transform: none !important;
    translate: none !important;
  }
}
/* 67_HERO_REAL_TARGET_V8_4_END */
'''

p.write_text(s.rstrip() + "\n\n" + block + "\n", encoding='utf-8')
PY

HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

if [ "$HERO_BEFORE" != "$HERO_AFTER" ]; then
  echo "ERROR: hero background changed unexpectedly" >&2
  exit 89
fi
if [ "$HEADER_BEFORE" != "$HEADER_AFTER" ]; then
  echo "ERROR: navbar CSS changed unexpectedly" >&2
  exit 90
fi

echo "HERO_REAL_TARGET_V8_4_APPLIED"
echo "Hero unchanged: $HERO_AFTER"
echo "Navbar CSS unchanged: $HEADER_AFTER"
echo "Changed only: src/pages/HomePage.css"
