#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-top-parts-polish-v1-$STAMP"

[ -f "$TOP_CSS" ] || { echo "ERROR: missing $TOP_CSS" >&2; exit 1101; }

PROTECTED=(
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/components/HomeStoreHeader.jsx"
  "$ROOT/src/components/HomeStoreHeader.css"
  "$ROOT/src/pages/HomePage.jsx"
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/components/HomeBelowHero.css"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

mkdir -p "$BACKUP"
cp -a "$TOP_CSS" "$BACKUP/TopPartsPage.css"

HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing protected file: $f" >&2; exit 1102; }
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/TopPartsPage.css" "$TOP_CSS" || true
  echo "ERROR: Top Parts polish failed; CSS restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - "$TOP_CSS" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
css = path.read_text(encoding='utf-8')
marker = '/* TOP PARTS POLISH V1 */'

if marker in css:
    print('TOP_PARTS_POLISH_V1_ALREADY_PRESENT')
else:
    css += r'''

/* TOP PARTS POLISH V1 */
/* Scope: /top-parts cards only. No data/source changes. */
.tp67-card {
  display: flex;
  flex-direction: column;
}

.tp67-card-visual {
  min-height: 255px;
  padding: 18px;
}

.tp67-card-visual img {
  width: auto !important;
  height: auto !important;
  max-width: 84% !important;
  max-height: 84% !important;
  margin: auto;
  padding: 0 !important;
  object-fit: contain !important;
  object-position: center !important;
}

.tp67-card-body {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
}

.tp67-description {
  min-height: 48px;
  color: #77746c !important;
  line-height: 1.75;
}

.tp67-divider {
  margin-top: 18px;
}

.tp67-store-row {
  min-height: 58px;
  align-items: center;
}

.tp67-store {
  align-items: center;
}

.tp67-store strong {
  line-height: 1.45;
}

.tp67-store small,
.tp67-review-count {
  line-height: 1.45;
}

.tp67-card-footer {
  min-height: 68px;
  margin-top: auto;
  padding-top: 16px;
  align-items: flex-end;
}

.tp67-price-wrap {
  align-self: flex-end;
}

.tp67-price-wrap strong {
  display: inline-flex;
  align-items: baseline;
  gap: 4px;
}

@media (max-width: 820px) {
  .tp67-card-visual img {
    max-width: 88% !important;
    max-height: 88% !important;
  }
}
'''
    path.write_text(css, encoding='utf-8')
    print('TOP_PARTS_POLISH_V1_WRITTEN')

final = path.read_text(encoding='utf-8')
required = [
    '/* TOP PARTS POLISH V1 */',
    'max-width: 84% !important;',
    'max-height: 84% !important;',
    'object-fit: contain !important;',
    'color: #77746c !important;',
    'margin-top: auto;',
]
for item in required:
    if item not in final:
        raise SystemExit(f'ERROR: missing polish marker: {item}')

print('TOP_PARTS_IMAGES_REDUCED_AND_CENTERED')
print('TOP_PARTS_TEXT_CONTRAST_POLISHED')
print('TOP_PARTS_CARD_BASELINES_ALIGNED')
PY

sha256sum -c "$HASHES" >/dev/null

echo "TOP_PARTS_POLISH_V1_APPLIED"
echo "CHANGED_FILES:"
echo "  src/pages/TopPartsPage.css"
