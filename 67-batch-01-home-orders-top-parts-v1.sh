#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-01-home-orders-top-parts-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-batch-01-home-orders-top-parts-v1-backup-$STAMP"
TMP="/tmp/67-batch-01-home-orders-top-parts-v1-$STAMP"

HOME="$ROOT/src/pages/HomePage.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
ORDERS="$ROOT/src/pages/MyOrdersPage.jsx"
ORDERS_CSS="$ROOT/src/pages/MyOrdersPage.css"
TOP="$ROOT/src/pages/TopPartsPage.jsx"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
HBR="$ROOT/src/components/HomeBelowHero.jsx"
HBR_CSS="$ROOT/src/components/HomeBelowHero.css"

for f in "$HOME" "$HOME_CSS" "$HEADER_JSX" "$HEADER_CSS" "$HERO" "$LOGO" "$ORDERS" "$TOP"; do
  [ -f "$f" ] || { echo "ERROR: missing required project file: $f" >&2; exit 301; }
done

mkdir -p "$TMP" "$BACKUP/src/pages" "$BACKUP/src/components" "$BACKUP/public/assets"

# Snapshot protected and target files before doing any writes.
cp -a "$HOME" "$BACKUP/src/pages/HomePage.jsx"
cp -a "$HOME_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HEADER_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$HERO" "$BACKUP/public/assets/hero-car.jpg"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"
cp -a "$ORDERS" "$BACKUP/src/pages/MyOrdersPage.jsx"
cp -a "$TOP" "$BACKUP/src/pages/TopPartsPage.jsx"

ORDERS_CSS_EXISTED=0
TOP_CSS_EXISTED=0
HBR_EXISTED=0
HBR_CSS_EXISTED=0
if [ -f "$ORDERS_CSS" ]; then ORDERS_CSS_EXISTED=1; cp -a "$ORDERS_CSS" "$BACKUP/src/pages/MyOrdersPage.css"; fi
if [ -f "$TOP_CSS" ]; then TOP_CSS_EXISTED=1; cp -a "$TOP_CSS" "$BACKUP/src/pages/TopPartsPage.css"; fi
if [ -f "$HBR" ]; then HBR_EXISTED=1; cp -a "$HBR" "$BACKUP/src/components/HomeBelowHero.jsx"; fi
if [ -f "$HBR_CSS" ]; then HBR_CSS_EXISTED=1; cp -a "$HBR_CSS" "$BACKUP/src/components/HomeBelowHero.css"; fi

echo "BACKUP_READY $BACKUP"

HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HEADER_JSX_BEFORE="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HEADER_CSS_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_BEFORE="$(sha256sum "$LOGO" | awk '{print $1}')"

rollback() {
  code=$?
  trap - ERR
  echo "ERROR: batch failed; restoring original project files" >&2
  cp -f "$BACKUP/src/pages/HomePage.jsx" "$HOME" || true
  cp -f "$BACKUP/src/pages/MyOrdersPage.jsx" "$ORDERS" || true
  cp -f "$BACKUP/src/pages/TopPartsPage.jsx" "$TOP" || true

  if [ "$ORDERS_CSS_EXISTED" -eq 1 ]; then cp -f "$BACKUP/src/pages/MyOrdersPage.css" "$ORDERS_CSS" || true; else rm -f "$ORDERS_CSS"; fi
  if [ "$TOP_CSS_EXISTED" -eq 1 ]; then cp -f "$BACKUP/src/pages/TopPartsPage.css" "$TOP_CSS" || true; else rm -f "$TOP_CSS"; fi
  if [ "$HBR_EXISTED" -eq 1 ]; then cp -f "$BACKUP/src/components/HomeBelowHero.jsx" "$HBR" || true; else rm -f "$HBR"; fi
  if [ "$HBR_CSS_EXISTED" -eq 1 ]; then cp -f "$BACKUP/src/components/HomeBelowHero.css" "$HBR_CSS" || true; else rm -f "$HBR_CSS"; fi
  exit "$code"
}
trap rollback ERR

# Download prebuilt payloads. OpenHands should not author or redesign any code.
for name in HomeBelowHero.jsx HomeBelowHero.css MyOrdersPage.jsx MyOrdersPage.css TopPartsPage.jsx TopPartsPage.css; do
  curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/$name?v=$(date +%s%N)" -o "$TMP/$name"
done

python3 - "$TMP" <<'PY_VALIDATE'
from pathlib import Path
import hashlib, sys

base = Path(sys.argv[1])
expected = {
    'HomeBelowHero.jsx': 'a074812a55e068c1b71ac062dd15f174f6217f2f',
    'HomeBelowHero.css': 'f152f10b73c463d6e6a7feb50a1755eb593d6948',
    'MyOrdersPage.jsx': 'effd62469037e2cd170bf8c28a6d7da818a772ac',
    'MyOrdersPage.css': '074143822a646de224e101b2dc1e06505f95d305',
    'TopPartsPage.jsx': 'b5e2ce36ec66e689629b0b91bb42a0bf3d89712f',
    'TopPartsPage.css': '9be93ef1a37db2d4a241692aa029f207dd2337cb',
}

def blob_sha(data: bytes) -> str:
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

for name, wanted in expected.items():
    path = base / name
    if not path.is_file():
        raise SystemExit(f'ERROR: missing payload {name}')
    actual = blob_sha(path.read_bytes())
    if actual != wanted:
        raise SystemExit(f'ERROR: payload SHA mismatch {name}: {actual}')

home = (base / 'HomeBelowHero.jsx').read_text(encoding='utf-8')
orders = (base / 'MyOrdersPage.jsx').read_text(encoding='utf-8')
top = (base / 'TopPartsPage.jsx').read_text(encoding='utf-8')

for marker in ('b01h-services-section','b01h-parts-section','b01h-brands-section','b01h-delivery-section','b01h-stats-section', "from '../data/brands'"):
    if marker not in home:
        raise SystemExit(f'ERROR: Home payload marker missing: {marker}')

for marker in ("localStorage.getItem('_67_orders')", "localStorage.setItem('_67_orders'", "localStorage.getItem('_67_admin_logs')", 'confirmDelivery', "id: '#ORD-2095'", "id: '#ORD-2091'", "id: '#ORD-2088'", '<HomeStoreHeader />'):
    if marker not in orders:
        raise SystemExit(f'ERROR: Orders behavior/data marker missing: {marker}')

original_top_names = (
    'كمبروسر مكيف كامري','فحمات فرامل لاند كروزر','مساعدات لكزس ES','قير اوتوماتيك فورد تورس',
    'شمعات أمامية رنج روفر','بواجي هيونداي سوناتا','فلتر هواء نيسان باترول','صدام أمامي تويوتا هايلوكس',
    'رديتر مازدا 6','دينمو تعبئة كيا سبورتاج'
)
for marker in original_top_names + ("navigate('/search')", "useState('daily')", '<HomeStoreHeader />'):
    if marker not in top:
        raise SystemExit(f'ERROR: Top Parts original-data/behavior marker missing: {marker}')

for css_name, prefix in (('HomeBelowHero.css','.b01h-root'), ('MyOrdersPage.css','.b01o-page'), ('TopPartsPage.css','.b01p-page')):
    css = (base / css_name).read_text(encoding='utf-8')
    if prefix not in css or '@media' not in css:
        raise SystemExit(f'ERROR: CSS structural validation failed: {css_name}')

print('BATCH_01_PAYLOADS_VALID')
PY_VALIDATE

# Stage payload replacements.
cp -f "$TMP/HomeBelowHero.jsx" "$HBR"
cp -f "$TMP/HomeBelowHero.css" "$HBR_CSS"
cp -f "$TMP/MyOrdersPage.jsx" "$ORDERS"
cp -f "$TMP/MyOrdersPage.css" "$ORDERS_CSS"
cp -f "$TMP/TopPartsPage.jsx" "$TOP"
cp -f "$TMP/TopPartsPage.css" "$TOP_CSS"

# Home: keep the existing approved hero byte-for-byte inside HomePage.jsx and replace ONLY what comes after it.
python3 - "$HOME" <<'PY_HOME'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

hero_marker = 'className="home67-hero"'
if s.count(hero_marker) != 1:
    raise SystemExit(f'ERROR: expected exactly one approved home67 hero, found {s.count(hero_marker)}')

# Normalize the component import.
import_line = "import HomeBelowHero from '../components/HomeBelowHero';"
s = re.sub(r"^import HomeBelowHero from ['\"]../components/HomeBelowHero['\"];\s*\n?", '', s, flags=re.M)
imports = list(re.finditer(r'^import .*?;\s*$', s, flags=re.M))
if not imports:
    raise SystemExit('ERROR: HomePage import block not found')
insert_at = imports[-1].end()
s = s[:insert_at] + '\n' + import_line + s[insert_at:]

class_pos = s.index(hero_marker)
hero_open = s.rfind('<section', 0, class_pos)
if hero_open < 0:
    raise SystemExit('ERROR: approved hero opening <section> not found')

section_tags = re.compile(r'</?section\b[^>]*>', re.S)
depth = 0
hero_close = None
for match in section_tags.finditer(s, hero_open):
    tag = match.group(0)
    if tag.startswith('</'):
        depth -= 1
        if depth == 0:
            hero_close = match.end()
            break
    else:
        depth += 1
if hero_close is None:
    raise SystemExit('ERROR: approved hero closing </section> not found')

# Preserve the approved hero exactly, and preserve global widgets/navigation after the page content.
candidates = []
for marker in ('<BottomNav', '<WhatsAppButton', '</main>'):
    pos = s.find(marker, hero_close)
    if pos != -1:
        candidates.append((pos, marker))
if not candidates:
    raise SystemExit('ERROR: safe Home below-hero boundary not found')
end_pos, end_marker = min(candidates, key=lambda item: item[0])

s = s[:hero_close] + '\n      <HomeBelowHero />\n      ' + s[end_pos:]
if s.count('<HomeBelowHero />') != 1:
    raise SystemExit('ERROR: HomeBelowHero instance count is not 1')
if s.count(hero_marker) != 1:
    raise SystemExit('ERROR: approved hero marker changed unexpectedly')
if import_line not in s:
    raise SystemExit('ERROR: HomeBelowHero import missing after rewrite')

p.write_text(s, encoding='utf-8')
print(f'HOME_BELOW_HERO_REPLACED_BEFORE={end_marker}')
PY_HOME

# Protected files must remain byte-identical through this batch.
HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HEADER_JSX_AFTER="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HEADER_CSS_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_AFTER="$(sha256sum "$LOGO" | awk '{print $1}')"

[ "$HOME_CSS_BEFORE" = "$HOME_CSS_AFTER" ] || { echo 'ERROR: protected HomePage.css changed' >&2; false; }
[ "$HEADER_JSX_BEFORE" = "$HEADER_JSX_AFTER" ] || { echo 'ERROR: protected HomeStoreHeader.jsx changed' >&2; false; }
[ "$HEADER_CSS_BEFORE" = "$HEADER_CSS_AFTER" ] || { echo 'ERROR: protected HomeStoreHeader.css changed' >&2; false; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo 'ERROR: protected hero-car.jpg changed' >&2; false; }
[ "$LOGO_BEFORE" = "$LOGO_AFTER" ] || { echo 'ERROR: protected logo-67.png changed' >&2; false; }

# Final integration checks.
grep -q "import HomeBelowHero from '../components/HomeBelowHero'" "$HOME"
grep -q '<HomeBelowHero />' "$HOME"
grep -q 'b01h-stats-section' "$HBR"
grep -q "localStorage.getItem('_67_orders')" "$ORDERS"
grep -q 'confirmDelivery' "$ORDERS"
grep -q 'b01o-page' "$ORDERS_CSS"
grep -q 'دينمو تعبئة كيا سبورتاج' "$TOP"
grep -q "navigate('/search')" "$TOP"
grep -q 'b01p-page' "$TOP_CSS"

echo 'BATCH_01_HOME_ORDERS_TOP_PARTS_V1_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/pages/HomePage.jsx (below-hero injection only)'
echo '  src/components/HomeBelowHero.jsx'
echo '  src/components/HomeBelowHero.css'
echo '  src/pages/MyOrdersPage.jsx'
echo '  src/pages/MyOrdersPage.css'
echo '  src/pages/TopPartsPage.jsx'
echo '  src/pages/TopPartsPage.css'
echo 'PROTECTED_UNCHANGED: HomePage.css, HomeStoreHeader.jsx/css, hero-car.jpg, logo-67.png'
