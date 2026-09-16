#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/TopPartsPage.css"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-top-parts-image-v3-$STAMP.css"

[ -f "$CSS" ] || { echo "ERROR: missing $CSS" >&2; exit 1; }
cp -a "$CSS" "$BACKUP"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP" "$CSS" || true
  echo "ERROR: Top Parts image size V3 failed; CSS restored" >&2
  exit "$code"
}
trap rollback ERR

MARKER='/* TOP PARTS IMAGE SIZE V3 — STRONG SCOPED OVERRIDE */'

python3 - "$CSS" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
marker = '/* TOP PARTS IMAGE SIZE V3 — STRONG SCOPED OVERRIDE */'
block = r'''

/* TOP PARTS IMAGE SIZE V3 — STRONG SCOPED OVERRIDE */
.tp67-card-visual {
  height: 235px !important;
  padding: 26px !important;
  display: grid !important;
  place-items: center !important;
  overflow: hidden !important;
}

.tp67-card-visual > img {
  width: 68% !important;
  height: 68% !important;
  max-width: 68% !important;
  max-height: 68% !important;
  object-fit: contain !important;
  object-position: center !important;
  padding: 0 !important;
  margin: auto !important;
  display: block !important;
  transform: none !important;
}

@media (max-width: 820px) {
  .tp67-card-visual {
    height: 220px !important;
    padding: 22px !important;
  }
  .tp67-card-visual > img {
    width: 72% !important;
    height: 72% !important;
    max-width: 72% !important;
    max-height: 72% !important;
  }
}

@media (max-width: 620px) {
  .tp67-card-visual {
    height: 205px !important;
    padding: 20px !important;
  }
  .tp67-card-visual > img {
    width: 74% !important;
    height: 74% !important;
    max-width: 74% !important;
    max-height: 74% !important;
  }
}
'''
if marker in s:
    s = s[:s.index(marker)].rstrip() + '\n'
s += block
p.write_text(s, encoding='utf-8')
PY

grep -qF "$MARKER" "$CSS"
grep -q "width: 68% !important" "$CSS"
grep -q "height: 235px !important" "$CSS"

echo "TOP_PARTS_IMAGE_SIZE_V3_APPLIED"
echo "TOP_PARTS_IMAGE_DESKTOP_68_PERCENT"
echo "CHANGED_FILES: src/pages/TopPartsPage.css"
