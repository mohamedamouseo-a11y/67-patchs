#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HOME_JSX="$ROOT/src/pages/HomePage.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
COMPONENT="$ROOT/src/components/HomeBelowHero.jsx"
COMPONENT_CSS="$ROOT/src/components/HomeBelowHero.css"
TMP_JSX="/tmp/67-HomeBelowHero-v1.jsx"
TMP_CSS="/tmp/67-HomeBelowHero-v1.css"
BACKUP="/tmp/67-home-below-hero-reference-v1-backup-$(date +%Y%m%d-%H%M%S)"

RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/home-below-hero-v1"
EXPECTED_JSX_BLOB="4d5a054d9eb8d525e0039785e42c972c2f739e5b"
EXPECTED_CSS_BLOB="53b3d5685a9eac463b28a0f3770fd1bd257b9347"

for f in "$HOME_JSX" "$HOME_CSS" "$HEADER_JSX" "$HEADER_CSS" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 201; }
done

rm -f "$TMP_JSX" "$TMP_CSS"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/HomeBelowHero.jsx?v=$(date +%s)" -o "$TMP_JSX"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_BASE/HomeBelowHero.css?v=$(date +%s)" -o "$TMP_CSS"

python3 - "$TMP_JSX" "$TMP_CSS" "$EXPECTED_JSX_BLOB" "$EXPECTED_CSS_BLOB" <<'PY_PAYLOAD'
from pathlib import Path
import hashlib, sys

def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

jsx_path, css_path, jsx_expected, css_expected = sys.argv[1:]
jsx = Path(jsx_path).read_bytes()
css = Path(css_path).read_bytes()
jsx_sha = git_blob_sha(jsx)
css_sha = git_blob_sha(css)
if jsx_sha != jsx_expected:
    raise SystemExit(f'ERROR: JSX payload mismatch: {jsx_sha}')
if css_sha != css_expected:
    raise SystemExit(f'ERROR: CSS payload mismatch: {css_sha}')
jsx_text = jsx.decode('utf-8')
css_text = css.decode('utf-8')
for marker in ('hbr-services-section', 'hbr-parts-section', 'hbr-brands-section', 'hbr-delivery-section', 'hbr-stats-section'):
    if marker not in jsx_text:
        raise SystemExit(f'ERROR: missing JSX marker: {marker}')
if '.hbr-root' not in css_text or '@media (max-width: 560px)' not in css_text:
    raise SystemExit('ERROR: CSS payload structural validation failed')
print('PAYLOADS_VALID')
PY_PAYLOAD

mkdir -p "$BACKUP/src/pages" "$BACKUP/src/components" "$BACKUP/public/assets"
cp -a "$HOME_JSX" "$BACKUP/src/pages/HomePage.jsx"
cp -a "$HOME_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HEADER_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$HERO" "$BACKUP/public/assets/hero-car.jpg"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"
[ ! -f "$COMPONENT" ] || cp -a "$COMPONENT" "$BACKUP/src/components/HomeBelowHero.jsx"
[ ! -f "$COMPONENT_CSS" ] || cp -a "$COMPONENT_CSS" "$BACKUP/src/components/HomeBelowHero.css"

echo "Backup: $BACKUP"

HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HEADER_JSX_BEFORE="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HEADER_CSS_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_BEFORE="$(sha256sum "$LOGO" | awk '{print $1}')"

cp -f "$TMP_JSX" "$COMPONENT"
cp -f "$TMP_CSS" "$COMPONENT_CSS"

python3 - "$HOME_JSX" <<'PY_HOME'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
hero_count = s.count('className="home67-hero"')
if hero_count != 1:
    raise SystemExit(f'ERROR: expected exactly one home67-hero section, found {hero_count}')

import_line = "import HomeBelowHero from '../components/HomeBelowHero';"
s = re.sub(r"^import HomeBelowHero from ['\"]../components/HomeBelowHero['\"];\s*\n?", '', s, flags=re.M)
imports = list(re.finditer(r'^import .*?;\s*$', s, flags=re.M))
if not imports:
    raise SystemExit('ERROR: import block not found in HomePage.jsx')
insert_at = imports[-1].end()
s = s[:insert_at] + "\n" + import_line + s[insert_at:]

hero_class = 'className="home67-hero"'
class_pos = s.index(hero_class)
hero_open = s.rfind('<section', 0, class_pos)
if hero_open < 0:
    raise SystemExit('ERROR: home67-hero opening section not found')

tag_re = re.compile(r'</?section\b[^>]*>', re.S)
depth = 0
hero_close = None
for m in tag_re.finditer(s, hero_open):
    if m.group(0).startswith('</'):
        depth -= 1
        if depth == 0:
            hero_close = m.end()
            break
    else:
        depth += 1
if hero_close is None:
    raise SystemExit('ERROR: matching hero closing section not found')

candidates = []
for marker in ('<BottomNav', '<WhatsAppButton', '</main>'):
    pos = s.find(marker, hero_close)
    if pos != -1:
        candidates.append((pos, marker))
if not candidates:
    raise SystemExit('ERROR: safe below-hero end boundary not found')
end_pos, end_marker = min(candidates, key=lambda item: item[0])

s = s[:hero_close] + "\n      <HomeBelowHero />\n      " + s[end_pos:]
if s.count('<HomeBelowHero />') != 1:
    raise SystemExit('ERROR: HomeBelowHero injection count is not 1')
if s.count('className="home67-hero"') != 1:
    raise SystemExit('ERROR: hero marker changed unexpectedly')
if import_line not in s:
    raise SystemExit('ERROR: HomeBelowHero import missing')

p.write_text(s, encoding='utf-8')
print(f'INJECTED_BEFORE={end_marker}')
PY_HOME

HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HEADER_JSX_AFTER="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
HEADER_CSS_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
LOGO_AFTER="$(sha256sum "$LOGO" | awk '{print $1}')"

[ "$HOME_CSS_BEFORE" = "$HOME_CSS_AFTER" ] || { echo "ERROR: HomePage.css changed unexpectedly" >&2; exit 202; }
[ "$HEADER_JSX_BEFORE" = "$HEADER_JSX_AFTER" ] || { echo "ERROR: HomeStoreHeader.jsx changed unexpectedly" >&2; exit 203; }
[ "$HEADER_CSS_BEFORE" = "$HEADER_CSS_AFTER" ] || { echo "ERROR: HomeStoreHeader.css changed unexpectedly" >&2; exit 204; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo "ERROR: hero-car.jpg changed unexpectedly" >&2; exit 205; }
[ "$LOGO_BEFORE" = "$LOGO_AFTER" ] || { echo "ERROR: logo-67.png changed unexpectedly" >&2; exit 206; }

grep -q 'HomeBelowHero' "$HOME_JSX" || { echo "ERROR: HomePage injection missing" >&2; exit 207; }
grep -q 'hbr-stats-section' "$COMPONENT" || { echo "ERROR: final content section missing" >&2; exit 208; }
grep -q '.hbr-root' "$COMPONENT_CSS" || { echo "ERROR: component CSS missing" >&2; exit 209; }

echo "HOME_BELOW_HERO_REFERENCE_V1_APPLIED"
echo "Changed/created only:"
echo "  src/pages/HomePage.jsx"
echo "  src/components/HomeBelowHero.jsx"
echo "  src/components/HomeBelowHero.css"
echo "Protected unchanged: HomePage.css, HomeStoreHeader.jsx/css, hero-car.jpg, logo-67.png"
