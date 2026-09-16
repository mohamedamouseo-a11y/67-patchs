#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-02-home-header-cart-$STAMP"
BACKUP="/tmp/67-batch-02-home-header-cart-backup-$STAMP"

HOME="$ROOT/src/pages/HomePage.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HBR="$ROOT/src/components/HomeBelowHero.jsx"
HBR_CSS="$ROOT/src/components/HomeBelowHero.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
CART="$ROOT/src/pages/CartPage.jsx"
CART_CSS="$ROOT/src/pages/CartPage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
ORDERS="$ROOT/src/pages/MyOrdersPage.jsx"
ORDERS_CSS="$ROOT/src/pages/MyOrdersPage.css"
TOP="$ROOT/src/pages/TopPartsPage.jsx"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"

for f in "$HOME" "$HOME_CSS" "$HEADER_JSX" "$HEADER_CSS" "$CART" "$CART_CSS" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing required project file: $f" >&2; exit 401; }
done

mkdir -p "$TMP" \
  "$BACKUP/src/pages" \
  "$BACKUP/src/components" \
  "$BACKUP/public/assets"

cp -a "$HOME" "$BACKUP/src/pages/HomePage.jsx"
cp -a "$HOME_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HEADER_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$CART" "$BACKUP/src/pages/CartPage.jsx"
cp -a "$CART_CSS" "$BACKUP/src/pages/CartPage.css"
cp -a "$HERO" "$BACKUP/public/assets/hero-car.jpg"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"

HBR_EXISTED=0
HBR_CSS_EXISTED=0
if [ -f "$HBR" ]; then
  HBR_EXISTED=1
  cp -a "$HBR" "$BACKUP/src/components/HomeBelowHero.jsx"
fi
if [ -f "$HBR_CSS" ]; then
  HBR_CSS_EXISTED=1
  cp -a "$HBR_CSS" "$BACKUP/src/components/HomeBelowHero.css"
fi

HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_BEFORE="$(sha256sum "$LOGO" | awk '{print $1}')"

ORDERS_BEFORE=""
ORDERS_CSS_BEFORE=""
TOP_BEFORE=""
TOP_CSS_BEFORE=""
[ -f "$ORDERS" ] && ORDERS_BEFORE="$(sha256sum "$ORDERS" | awk '{print $1}')"
[ -f "$ORDERS_CSS" ] && ORDERS_CSS_BEFORE="$(sha256sum "$ORDERS_CSS" | awk '{print $1}')"
[ -f "$TOP" ] && TOP_BEFORE="$(sha256sum "$TOP" | awk '{print $1}')"
[ -f "$TOP_CSS" ] && TOP_CSS_BEFORE="$(sha256sum "$TOP_CSS" | awk '{print $1}')"

rollback() {
  code=$?
  trap - ERR
  echo "ERROR: Batch 02 failed; restoring backup" >&2
  cp -f "$BACKUP/src/pages/HomePage.jsx" "$HOME" || true
  cp -f "$BACKUP/src/pages/HomePage.css" "$HOME_CSS" || true
  cp -f "$BACKUP/src/components/HomeStoreHeader.jsx" "$HEADER_JSX" || true
  cp -f "$BACKUP/src/components/HomeStoreHeader.css" "$HEADER_CSS" || true
  cp -f "$BACKUP/src/pages/CartPage.jsx" "$CART" || true
  cp -f "$BACKUP/src/pages/CartPage.css" "$CART_CSS" || true
  cp -f "$BACKUP/public/assets/hero-car.jpg" "$HERO" || true
  cp -f "$BACKUP/public/assets/logo-67.png" "$LOGO" || true

  if [ "$HBR_EXISTED" -eq 1 ]; then
    cp -f "$BACKUP/src/components/HomeBelowHero.jsx" "$HBR" || true
  else
    rm -f "$HBR"
  fi

  if [ "$HBR_CSS_EXISTED" -eq 1 ]; then
    cp -f "$BACKUP/src/components/HomeBelowHero.css" "$HBR_CSS" || true
  else
    rm -f "$HBR_CSS"
  fi

  exit "$code"
}
trap rollback ERR

echo "BACKUP_READY $BACKUP"

curl -fsSL -H "Cache-Control: no-cache" \
  "$RAW_BASE/batch-01-home-orders-top-parts-v1/HomeBelowHero.jsx?v=$(date +%s%N)" \
  -o "$TMP/HomeBelowHero.jsx"

curl -fsSL -H "Cache-Control: no-cache" \
  "$RAW_BASE/batch-01-home-orders-top-parts-v1/HomeBelowHero.css?v=$(date +%s%N)" \
  -o "$TMP/HomeBelowHero.css"

curl -fsSL -H "Cache-Control: no-cache" \
  "$RAW_BASE/batch-02-home-header-cart-v1/CartPage.jsx?v=$(date +%s%N)" \
  -o "$TMP/CartPage.jsx"

curl -fsSL -H "Cache-Control: no-cache" \
  "$RAW_BASE/batch-02-home-header-cart-v1/CartPage.css?v=$(date +%s%N)" \
  -o "$TMP/CartPage.css"

python3 - "$TMP" <<'PY_VALIDATE'
from pathlib import Path
import hashlib
import sys

base = Path(sys.argv[1])
expected_sha256 = {
    "CartPage.jsx": "74964785687546e8423f634128a5330dce92285d25737c14784c441ebccb94c8",
    "CartPage.css": "38a41cc9d5cab6b3dc9875cd5b35544814a7661ac82896dc260c048815118123",
}

for name, expected in expected_sha256.items():
    path = base / name
    if not path.is_file():
        raise SystemExit(f"ERROR: missing payload {name}")
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != expected:
        raise SystemExit(f"ERROR: payload SHA mismatch {name}: {actual}")

home = (base / "HomeBelowHero.jsx").read_text(encoding="utf-8")
home_css = (base / "HomeBelowHero.css").read_text(encoding="utf-8")
cart = (base / "CartPage.jsx").read_text(encoding="utf-8")
cart_css = (base / "CartPage.css").read_text(encoding="utf-8")

for marker in (
    "b01h-services-section",
    "b01h-parts-section",
    "b01h-brands-section",
    "b01h-delivery-section",
    "b01h-stats-section",
    "from '../data/brands'",
):
    if marker not in home:
        raise SystemExit(f"ERROR: Home payload marker missing: {marker}")

for marker in (".b01h-root", ".b01h-service-grid", ".b01h-stats-grid", "@media"):
    if marker not in home_css:
        raise SystemExit(f"ERROR: Home CSS marker missing: {marker}")

for marker in (
    "const [cartStores, setCartStores] = useState(INITIAL_CART_STORES)",
    "const updateQuantity =",
    "const removeItem =",
    "const tax = subtotal * 0.15",
    "navigate('/checkout')",
    "navigate('/store')",
    "<HomeStoreHeader />",
    "<BottomNav />",
):
    if marker not in cart:
        raise SystemExit(f"ERROR: Cart behavior marker missing: {marker}")

for marker in (".c67-page", ".c67-hero", ".c67-layout", ".c67-summary", ".c67-item", "@media"):
    if marker not in cart_css:
        raise SystemExit(f"ERROR: Cart CSS marker missing: {marker}")

print("BATCH_02_PAYLOADS_VALID")
PY_VALIDATE

cp -f "$TMP/HomeBelowHero.jsx" "$HBR"
cp -f "$TMP/HomeBelowHero.css" "$HBR_CSS"

cat >> "$HBR_CSS" <<'CSS_HOME_NAV'

/* B02_HOME_BOTTOMNAV_START */
@media (min-width: 701px) {
  .home67-page > .bottom-nav {
    display: none !important;
  }
}
@media (max-width: 700px) {
  .home67-page > .bottom-nav {
    display: flex;
  }
}
/* B02_HOME_BOTTOMNAV_END */
CSS_HOME_NAV

python3 - "$HOME" <<'PY_HOME'
from pathlib import Path
import hashlib
import re
import sys

p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")

def matching_tag_end(text: str, start: int, tag: str):
    rx = re.compile(fr"</?{tag}\b[^>]*>", re.S | re.I)
    depth = 0
    seen = False
    for m in rx.finditer(text, start):
        token = m.group(0)
        if not seen:
            if token.lower().startswith(f"<{tag}"):
                seen = True
                depth = 1
            continue
        if token.startswith("</"):
            depth -= 1
            if depth == 0:
                return m.end()
        else:
            depth += 1
    return None

hero_marker = 'className="home67-hero"'
if s.count(hero_marker) != 1:
    raise SystemExit(f"ERROR: expected exactly one approved hero marker, found {s.count(hero_marker)}")

hero_class = s.index(hero_marker)
hero_start = s.rfind("<section", 0, hero_class)
if hero_start < 0:
    raise SystemExit("ERROR: approved hero opening section not found")
hero_end = matching_tag_end(s, hero_start, "section")
if hero_end is None:
    raise SystemExit("ERROR: approved hero closing section not found")

hero_before = s[hero_start:hero_end]
hero_sha_before = hashlib.sha256(hero_before.encode()).hexdigest()

import_line = "import HomeBelowHero from '../components/HomeBelowHero';"
s = re.sub(
    r"^import HomeBelowHero from ['\"]../components/HomeBelowHero['\"];\s*\n?",
    "",
    s,
    flags=re.M,
)
imports = list(re.finditer(r"^import .*?;\s*$", s, flags=re.M))
if not imports:
    raise SystemExit("ERROR: HomePage import block not found")
insert_at = imports[-1].end()
s = s[:insert_at] + "\n" + import_line + s[insert_at:]

hero_class = s.index(hero_marker)
hero_start = s.rfind("<section", 0, hero_class)
hero_end = matching_tag_end(s, hero_start, "section")
if hero_end is None:
    raise SystemExit("ERROR: hero could not be re-read after import normalization")

post_hero = s[hero_end:]
post_hero = re.sub(r"^\s*<HomeBelowHero\s*/>\s*", "\n", post_hero, count=1)
s = s[:hero_end] + post_hero

main_match = re.search(r'<main\b[^>]*className=["\'][^"\']*\bhome67-main\b[^"\']*["\'][^>]*>', s[hero_end:])
if not main_match:
    raise SystemExit("ERROR: current <main className=\"home67-main\"> not found after hero")

main_start = hero_end + main_match.start()
main_end = matching_tag_end(s, main_start, "main")
if main_end is None:
    raise SystemExit("ERROR: matching </main> for home67-main not found")

s = s[:main_start] + "      <HomeBelowHero />\n" + s[main_end:]

if s.count("<HomeBelowHero />") != 1:
    raise SystemExit(f"ERROR: expected one HomeBelowHero render, found {s.count('<HomeBelowHero />')}")
if import_line not in s:
    raise SystemExit("ERROR: HomeBelowHero import missing")
if "<BottomNav" not in s:
    raise SystemExit("ERROR: BottomNav disappeared from HomePage")
if "<WhatsAppButton" not in s:
    raise SystemExit("ERROR: WhatsAppButton disappeared from HomePage")

hero_class_after = s.index(hero_marker)
hero_start_after = s.rfind("<section", 0, hero_class_after)
hero_end_after = matching_tag_end(s, hero_start_after, "section")
if hero_end_after is None:
    raise SystemExit("ERROR: final hero closing section not found")
hero_after = s[hero_start_after:hero_end_after]
hero_sha_after = hashlib.sha256(hero_after.encode()).hexdigest()

if hero_sha_before != hero_sha_after:
    raise SystemExit("ERROR: Home hero JSX changed unexpectedly")

p.write_text(s, encoding="utf-8")
print("HOME_BELOW_HERO_WIRED")
print(f"HOME_HERO_JSX_SHA {hero_sha_after}")
PY_HOME

python3 - "$HEADER_JSX" "$HEADER_CSS" <<'PY_HEADER'
from pathlib import Path
import re
import sys

jsx_path = Path(sys.argv[1])
css_path = Path(sys.argv[2])

jsx = jsx_path.read_text(encoding="utf-8")
css = css_path.read_text(encoding="utf-8")

pattern = r'src=["\']/assets/logo-67\.png(?:\?[^"\']*)?["\']'
jsx_new, count = re.subn(
    pattern,
    'src="/assets/logo-67.png?v=67-b02-v1"',
    jsx,
    count=1,
)
if count != 1:
    raise SystemExit(f"ERROR: expected one Home header logo src, changed {count}")

required = (
    'className="h67-navbar"',
    'className="h67-logo"',
    'className="h67-nav"',
    'className="h67-actions"',
    'className="h67-auth"',
    'aria-label="الإشعارات"',
    'aria-label="بحث"',
)
for marker in required:
    if marker not in jsx_new:
        raise SystemExit(f"ERROR: Header DOM marker missing: {marker}")

auth = jsx_new.index('className="h67-auth"')
notice = jsx_new.index('aria-label="الإشعارات"')
search = jsx_new.index('aria-label="بحث"')
if not (auth < notice < search):
    raise SystemExit("ERROR: unexpected header action DOM order")

start = "/* 67_BATCH02_HEADER_V1_START */"
end = "/* 67_BATCH02_HEADER_V1_END */"
css = re.sub(
    re.escape(start) + r".*?" + re.escape(end) + r"\s*",
    "",
    css,
    flags=re.S,
)

override = r'''
/* 67_BATCH02_HEADER_V1_START */
@media (min-width: 1281px) {
  .h67-header {
    position: absolute !important;
    top: 0 !important;
    right: 0 !important;
    left: 0 !important;
    width: 100% !important;
    height: 106px !important;
    z-index: 80 !important;
    overflow: visible !important;
  }

  .h67-navbar {
    position: relative !important;
    width: 100% !important;
    max-width: none !important;
    height: 100% !important;
    margin: 0 !important;
    padding-inline: max(32px, calc((100vw - 1360px) / 2)) !important;
    box-sizing: border-box !important;
    display: grid !important;
    grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) !important;
    grid-template-areas: "actions nav logo" !important;
    align-items: center !important;
    direction: ltr !important;
  }

  .h67-actions {
    grid-area: actions !important;
    position: static !important;
    inset: auto !important;
    transform: none !important;
    translate: none !important;
    justify-self: start !important;
    align-self: center !important;
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
    width: auto !important;
    direction: ltr !important;
  }

  .h67-actions .h67-auth { order: 0 !important; }
  .h67-actions .h67-icon-btn[aria-label="الإشعارات"] { order: 1 !important; }
  .h67-actions .h67-icon-btn[aria-label="بحث"] { order: 2 !important; }

  .h67-nav {
    grid-area: nav !important;
    position: static !important;
    inset: auto !important;
    transform: none !important;
    translate: none !important;
    justify-self: center !important;
    align-self: stretch !important;
    width: auto !important;
    max-width: none !important;
    height: 100% !important;
    direction: rtl !important;
  }

  .h67-logo {
    grid-area: logo !important;
    position: static !important;
    inset: auto !important;
    transform: none !important;
    translate: none !important;
    justify-self: end !important;
    align-self: center !important;
    width: 155px !important;
    height: 92px !important;
    margin: 0 !important;
    padding: 0 !important;
    border: 0 !important;
    overflow: visible !important;
    display: block !important;
    background-color: transparent !important;
    background-image: url("/assets/logo-67.png?v=67-b02-v1") !important;
    background-repeat: no-repeat !important;
    background-position: center !important;
    background-size: contain !important;
  }

  .h67-logo img {
    display: none !important;
  }
}
/* 67_BATCH02_HEADER_V1_END */
'''

css = css.rstrip() + "\n\n" + override.strip() + "\n"
jsx_path.write_text(jsx_new, encoding="utf-8")
css_path.write_text(css, encoding="utf-8")
print("HEADER_DESKTOP_V1_APPLIED")
PY_HEADER

cp -f "$TMP/CartPage.jsx" "$CART"
cp -f "$TMP/CartPage.css" "$CART_CSS"

HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_AFTER="$(sha256sum "$LOGO" | awk '{print $1}')"

[ "$HOME_CSS_BEFORE" = "$HOME_CSS_AFTER" ] || { echo "ERROR: protected HomePage.css changed" >&2; false; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo "ERROR: protected hero-car.jpg changed" >&2; false; }
[ "$LOGO_BEFORE" = "$LOGO_AFTER" ] || { echo "ERROR: protected logo-67.png changed" >&2; false; }

if [ -n "$ORDERS_BEFORE" ]; then
  [ "$ORDERS_BEFORE" = "$(sha256sum "$ORDERS" | awk '{print $1}')" ] || { echo "ERROR: MyOrdersPage.jsx changed" >&2; false; }
fi
if [ -n "$ORDERS_CSS_BEFORE" ]; then
  [ "$ORDERS_CSS_BEFORE" = "$(sha256sum "$ORDERS_CSS" | awk '{print $1}')" ] || { echo "ERROR: MyOrdersPage.css changed" >&2; false; }
fi
if [ -n "$TOP_BEFORE" ]; then
  [ "$TOP_BEFORE" = "$(sha256sum "$TOP" | awk '{print $1}')" ] || { echo "ERROR: TopPartsPage.jsx changed" >&2; false; }
fi
if [ -n "$TOP_CSS_BEFORE" ]; then
  [ "$TOP_CSS_BEFORE" = "$(sha256sum "$TOP_CSS" | awk '{print $1}')" ] || { echo "ERROR: TopPartsPage.css changed" >&2; false; }
fi

grep -q "import HomeBelowHero from '../components/HomeBelowHero'" "$HOME"
grep -q '<HomeBelowHero />' "$HOME"
grep -q 'b01h-services-section' "$HBR"
grep -q 'b01h-stats-section' "$HBR"
grep -q '67_BATCH02_HEADER_V1_START' "$HEADER_CSS"
grep -q 'logo-67.png?v=67-b02-v1' "$HEADER_JSX"
grep -q 'className="c67-page"' "$CART"
grep -q 'const updateQuantity =' "$CART"
grep -q 'const removeItem =' "$CART"
grep -q "navigate('/checkout')" "$CART"
grep -q '<HomeStoreHeader />' "$CART"
grep -q '.c67-summary' "$CART_CSS"

echo "BATCH_02_HOME_HEADER_CART_V1_APPLIED"
echo "CHANGED_FILES:"
echo "  src/pages/HomePage.jsx"
echo "  src/components/HomeBelowHero.jsx"
echo "  src/components/HomeBelowHero.css"
echo "  src/components/HomeStoreHeader.jsx"
echo "  src/components/HomeStoreHeader.css"
echo "  src/pages/CartPage.jsx"
echo "  src/pages/CartPage.css"
echo "PROTECTED_UNCHANGED:"
echo "  src/pages/HomePage.css"
echo "  public/assets/hero-car.jpg"
echo "  public/assets/logo-67.png"
echo "  MyOrdersPage.jsx/css"
echo "  TopPartsPage.jsx/css"
