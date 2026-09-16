#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-dark-surface-text-white-v2-$STAMP"
MARKER='/* DARK SURFACE TEXT WHITE V2 */'

TARGETS=(
  "$ROOT/src/components/HomeBelowHero.css"
  "$ROOT/src/pages/NotificationsPage.css"
  "$ROOT/src/pages/PartSearchPage.css"
  "$ROOT/src/pages/CustomerProfilePage.css"
  "$ROOT/src/pages/CartPage.css"
  "$ROOT/src/pages/MyOrdersPage.css"
  "$ROOT/src/pages/TopPartsPage.css"
)

PROTECTED=(
  "$ROOT/src/components/HomeBelowHero.jsx"
  "$ROOT/src/pages/NotificationsPage.jsx"
  "$ROOT/src/pages/PartSearchPage.jsx"
  "$ROOT/src/pages/CustomerProfilePage.jsx"
  "$ROOT/src/pages/CartPage.jsx"
  "$ROOT/src/pages/MyOrdersPage.jsx"
  "$ROOT/src/pages/TopPartsPage.jsx"
  "$ROOT/src/data/mockOffers.js"
  "$ROOT/src/data/brands.js"
  "$ROOT/public/assets/hero-car.jpg"
  "$ROOT/public/assets/logo-67.png"
)

for f in "${TARGETS[@]}" "${PROTECTED[@]}"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 1601; }
done

mkdir -p "$BACKUP"
for f in "${TARGETS[@]}"; do
  cp -a "$f" "$BACKUP/$(basename "$f")"
done

HASHES="$BACKUP/protected.sha256"
: > "$HASHES"
for f in "${PROTECTED[@]}"; do
  sha256sum "$f" >> "$HASHES"
done

rollback() {
  code=$?
  trap - ERR
  for f in "${TARGETS[@]}"; do
    cp -f "$BACKUP/$(basename "$f")" "$f" || true
  done
  echo "ERROR: dark-surface contrast V2 failed; CSS files restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - "${TARGETS[@]}" <<'PY'
from pathlib import Path
import sys

marker = '/* DARK SURFACE TEXT WHITE V2 */'

blocks = {
    'HomeBelowHero.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
/* Scope: dark home surfaces only. Keep gold accents intact. */
.b01h-delivery-card .b01h-delivery-copy h2,
.b01h-stats-section .b01h-stats-title h2,
.b01h-service-card.is-featured strong {
  color: #ffffff !important;
}

.b01h-delivery-card .b01h-delivery-copy h2 em,
.b01h-stats-section .b01h-stats-title h2 em,
.b01h-service-card.is-featured .b01h-card-link {
  color: var(--b01-gold) !important;
}

.b01h-delivery-card .b01h-delivery-copy p,
.b01h-service-card.is-featured .b01h-service-copy,
.b01h-24-mark span,
.b01h-24-mark small,
.b01h-stat-card:not(.is-gold) span {
  color: rgba(255,255,255,.84) !important;
}
''',
    'NotificationsPage.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
.n67-hero .n67-hero-copy h1,
.n67-hero .n67-hero-card strong {
  color: #ffffff !important;
}
.n67-hero .n67-hero-copy h1 span,
.n67-hero .n67-kicker,
.n67-hero .n67-hero-bell {
  color: var(--n67-gold) !important;
}
.n67-hero .n67-hero-copy p,
.n67-hero .n67-hero-card span,
.n67-hero .n67-breadcrumb,
.n67-hero .n67-breadcrumb button {
  color: rgba(255,255,255,.84) !important;
}
''',
    'PartSearchPage.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
.s67-hero .s67-hero-copy h1,
.s67-how-card h3,
.s67-how-card li strong,
.s67-benefits article.is-dark h3 {
  color: #ffffff !important;
}
.s67-hero .s67-hero-copy h1 em,
.s67-how-card > span,
.s67-how-card li b,
.s67-benefits article.is-dark b {
  color: var(--s67-gold) !important;
}
.s67-hero .s67-hero-copy p,
.s67-hero .s67-breadcrumb,
.s67-hero .s67-breadcrumb button,
.s67-how-card li small,
.s67-benefits article.is-dark p {
  color: rgba(255,255,255,.84) !important;
}
''',
    'CustomerProfilePage.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
.p67-hero .p67-hero-copy h1,
.p67-user-card h2,
.p67-user-card .p67-quick-links button {
  color: #ffffff !important;
}
.p67-hero .p67-hero-copy h1 em,
.p67-side-kicker {
  color: var(--p67-gold) !important;
}
.p67-hero .p67-hero-copy p,
.p67-hero .p67-breadcrumb,
.p67-hero .p67-breadcrumb button,
.p67-hero-avatar > span,
.p67-user-card p {
  color: rgba(255,255,255,.84) !important;
}
''',
    'CartPage.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
.c67-hero h1,
.c67-summary h2,
.c67-summary-lines strong,
.c67-shipping-note strong,
.c67-total-row > span {
  color: #ffffff !important;
}
.c67-hero h1 span,
.c67-summary-kicker,
.c67-total-row > strong {
  color: var(--c67-gold) !important;
}
.c67-hero p,
.c67-breadcrumb,
.c67-breadcrumb button,
.c67-summary-lines span,
.c67-tax-note p,
.c67-shipping-note span,
.c67-secure {
  color: rgba(255,255,255,.84) !important;
}
''',
    'MyOrdersPage.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
.b01o-hero .b01o-hero-copy h1 {
  color: #ffffff !important;
}
.b01o-hero .b01o-hero-copy h1 span,
.b01o-hero .b01o-kicker,
.b01o-hero .b01o-order-count strong {
  color: var(--b01o-gold) !important;
}
.b01o-hero .b01o-hero-copy p,
.b01o-hero .b01o-order-count span {
  color: rgba(255,255,255,.84) !important;
}
''',
    'TopPartsPage.css': r'''

/* DARK SURFACE TEXT WHITE V2 */
.tp67-hero .tp67-hero-copy h1,
.tp67-cta h2 {
  color: #ffffff !important;
}
.tp67-hero .tp67-hero-copy h1 span,
.tp67-hero .tp67-kicker,
.tp67-cta span {
  color: var(--tp67-gold) !important;
}
.tp67-hero .tp67-hero-copy p,
.tp67-hero-search input,
.tp67-hero-search input::placeholder {
  color: rgba(255,255,255,.84) !important;
}
''',
}

for arg in sys.argv[1:]:
    path = Path(arg)
    name = path.name
    if name not in blocks:
        raise SystemExit(f'ERROR: no scoped contrast block prepared for {name}')
    text = path.read_text(encoding='utf-8')
    if marker in text:
        text = text[:text.index(marker)].rstrip() + '\n'
    text += blocks[name]
    path.write_text(text, encoding='utf-8')

print('DARK_SURFACE_TARGETS_PATCHED')
PY

for f in "${TARGETS[@]}"; do
  grep -qF "$MARKER" "$f"
done

# Exact visibility guards for the user-reported dark surfaces.
grep -q ".b01h-stats-section .b01h-stats-title h2" "$ROOT/src/components/HomeBelowHero.css"
grep -q ".b01h-delivery-card .b01h-delivery-copy h2" "$ROOT/src/components/HomeBelowHero.css"
grep -q ".n67-hero .n67-hero-copy h1" "$ROOT/src/pages/NotificationsPage.css"
grep -q ".s67-how-card h3" "$ROOT/src/pages/PartSearchPage.css"
grep -q ".s67-benefits article.is-dark h3" "$ROOT/src/pages/PartSearchPage.css"
grep -q ".p67-user-card h2" "$ROOT/src/pages/CustomerProfilePage.css"
grep -q ".p67-hero .p67-hero-copy h1" "$ROOT/src/pages/CustomerProfilePage.css"
grep -q ".c67-hero h1" "$ROOT/src/pages/CartPage.css"
grep -q ".b01o-hero .b01o-hero-copy h1" "$ROOT/src/pages/MyOrdersPage.css"
grep -q ".tp67-hero .tp67-hero-copy h1" "$ROOT/src/pages/TopPartsPage.css"

sha256sum -c "$HASHES" >/dev/null

echo "DARK_SURFACE_TEXT_WHITE_V2_APPLIED"
echo "USER_REPORTED_DARK_TEXT_TARGETS_FIXED"
echo "NO_DATA_OR_JSX_CHANGED"
echo "CHANGED_FILES:"
echo "  src/components/HomeBelowHero.css"
echo "  src/pages/NotificationsPage.css"
echo "  src/pages/PartSearchPage.css"
echo "  src/pages/CustomerProfilePage.css"
echo "  src/pages/CartPage.css"
echo "  src/pages/MyOrdersPage.css"
echo "  src/pages/TopPartsPage.css"
