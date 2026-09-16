#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HOME_JSX="$ROOT/src/pages/HomePage.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
HBR_JSX="$ROOT/src/components/HomeBelowHero.jsx"
HBR_CSS="$ROOT/src/components/HomeBelowHero.css"

TMP_B64="/tmp/67-logo-user-exact-v812.base64"
TMP_LOGO="/tmp/67-logo-user-exact-v812.png"
TMP_JSX="/tmp/67-HomeStoreHeader-v812.jsx"
TMP_CSS="/tmp/67-HomeStoreHeader-v812.css"
BACKUP="/tmp/67-home-header-v8-12-backup-$(date +%Y%m%d-%H%M%S)"

RAW_B64="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/home-assets-v9/logo-67-user-exact.png.base64"
EXPECTED_LOGO_SHA="5f097e4cfe7802a2baa8b1440bcfe27eb1c37484a1cafb9c006e446624ce6090"
EXPECTED_LOGO_BYTES="157821"
EXPECTED_WIDTH="946"
EXPECTED_HEIGHT="567"
CACHE_BUST="20260916-v812"

for f in "$HEADER_JSX" "$HEADER_CSS" "$HOME_JSX" "$HOME_CSS" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 212; }
done

mkdir -p "$BACKUP/src/components" "$BACKUP/src/pages" "$BACKUP/public/assets"
cp -a "$HEADER_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"
cp -a "$HOME_JSX" "$BACKUP/src/pages/HomePage.jsx"
cp -a "$HOME_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HERO" "$BACKUP/public/assets/hero-car.jpg"
[ ! -f "$HBR_JSX" ] || cp -a "$HBR_JSX" "$BACKUP/src/components/HomeBelowHero.jsx"
[ ! -f "$HBR_CSS" ] || cp -a "$HBR_CSS" "$BACKUP/src/components/HomeBelowHero.css"
echo "Backup: $BACKUP"

rollback() {
  code=$?
  echo "ERROR: V8.12 failed; restoring original header files/logo from backup" >&2
  cp -f "$BACKUP/src/components/HomeStoreHeader.jsx" "$HEADER_JSX" || true
  cp -f "$BACKUP/src/components/HomeStoreHeader.css" "$HEADER_CSS" || true
  cp -f "$BACKUP/public/assets/logo-67.png" "$LOGO" || true
  exit "$code"
}
trap rollback ERR

HOME_JSX_BEFORE="$(sha256sum "$HOME_JSX" | awk '{print $1}')"
HOME_CSS_BEFORE="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
HBR_JSX_BEFORE=""
HBR_CSS_BEFORE=""
[ ! -f "$HBR_JSX" ] || HBR_JSX_BEFORE="$(sha256sum "$HBR_JSX" | awk '{print $1}')"
[ ! -f "$HBR_CSS" ] || HBR_CSS_BEFORE="$(sha256sum "$HBR_CSS" | awk '{print $1}')"

rm -f "$TMP_B64" "$TMP_LOGO" "$TMP_JSX" "$TMP_CSS"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_B64?v=$(date +%s)" -o "$TMP_B64"

python3 - "$TMP_B64" "$TMP_LOGO" "$EXPECTED_LOGO_SHA" "$EXPECTED_LOGO_BYTES" "$EXPECTED_WIDTH" "$EXPECTED_HEIGHT" <<'PY_LOGO'
from pathlib import Path
import base64, hashlib, struct, sys
src, dst, expected_sha, expected_bytes, expected_w, expected_h = sys.argv[1:]
raw = Path(src).read_text(encoding='ascii')
compact = ''.join(raw.split())
try:
    data = base64.b64decode(compact, validate=True)
except Exception as exc:
    raise SystemExit(f'ERROR: exact-logo base64 decode failed: {exc}')
sha = hashlib.sha256(data).hexdigest()
if sha != expected_sha:
    raise SystemExit(f'ERROR: exact-logo SHA mismatch: {sha}')
if len(data) != int(expected_bytes):
    raise SystemExit(f'ERROR: exact-logo byte size mismatch: {len(data)}')
if len(data) < 24 or data[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: decoded exact logo is not PNG')
w, h = struct.unpack('>II', data[16:24])
if (w, h) != (int(expected_w), int(expected_h)):
    raise SystemExit(f'ERROR: exact-logo dimensions mismatch: {w}x{h}')
Path(dst).write_bytes(data)
print(f'EXACT_LOGO_VALID {w}x{h} {len(data)} bytes sha256={sha}')
PY_LOGO

cp -f "$HEADER_JSX" "$TMP_JSX"
cp -f "$HEADER_CSS" "$TMP_CSS"

python3 - "$TMP_JSX" "$CACHE_BUST" <<'PY_JSX'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
cache_bust = sys.argv[2]
s = p.read_text(encoding='utf-8')

required = [
    'className="h67-navbar"',
    'className="h67-logo"',
    'className="h67-nav"',
    'className="h67-actions"',
    'className="h67-auth"',
    'aria-label="الإشعارات"',
    'aria-label="بحث"',
    'localStorage.removeItem("customerSession")',
    'localStorage.removeItem("userToken")',
    'navigate("/")',
]
for marker in required:
    if marker not in s:
        raise SystemExit(f'ERROR: required header behavior marker missing: {marker}')
for route in ('/store','/top-parts','/orders','/cart','/profile','/notifications','/search'):
    if route not in s:
        raise SystemExit(f'ERROR: required header route missing: {route}')

auth_i = s.index('className="h67-auth"')
bell_i = s.index('aria-label="الإشعارات"')
search_i = s.index('aria-label="بحث"')
if not (auth_i < bell_i < search_i):
    raise SystemExit('ERROR: action DOM order is not Logout | Notification | Search')

pattern = r'src="/assets/logo-67\.png(?:\?[^\"]*)?"'
replacement = f'src="/assets/logo-67.png?v={cache_bust}"'
s2, count = re.subn(pattern, replacement, s)
if count != 1:
    raise SystemExit(f'ERROR: expected exactly one logo src replacement, got {count}')

# Confirm only the logo src literal changed; all behavior/routes remain present.
for marker in required:
    if marker not in s2:
        raise SystemExit(f'ERROR: protected JSX marker lost after edit: {marker}')
p.write_text(s2, encoding='utf-8')
print('HEADER_JSX_LOGO_URL_STAGED')
PY_JSX

python3 - "$TMP_CSS" <<'PY_CSS'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

for name in (
    '67_HOME_HEADER_LOGO_V8_5',
    '67_HOME_HEADER_LOGO_V8_6',
    '67_HOME_HEADER_V8_7',
    '67_HOME_HEADER_V8_8',
    '67_HOME_HEADER_EXACT_LOGO_V8_9',
    '67_HOME_HEADER_V8_10',
    '67_HOME_HEADER_V8_11',
    '67_HOME_HEADER_STABLE_V8_12',
):
    pattern = rf'\n?/\* {re.escape(name)}_START \*/.*?/\* {re.escape(name)}_END \*/\n?'
    s = re.sub(pattern, '\n', s, flags=re.S)

# Remove malformed duplicate-important syntax if any old line remains outside tagged blocks.
s = s.replace('!important !important', '!important')

block = r'''
/* 67_HOME_HEADER_STABLE_V8_12_START */
@media (min-width: 1281px) {
  .h67-header {
    position: absolute !important;
    top: 0 !important;
    left: 0 !important;
    right: 0 !important;
    width: 100% !important;
    height: 106px !important;
    overflow: visible !important;
  }

  .h67-navbar {
    position: relative !important;
    width: min(1360px, calc(100% - 64px)) !important;
    height: 100% !important;
    margin: 0 auto !important;
    padding: 0 !important;
    display: grid !important;
    grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) !important;
    grid-template-areas: "actions nav logo" !important;
    align-items: center !important;
    box-sizing: border-box !important;
    direction: ltr !important;
  }

  .h67-actions {
    grid-area: actions !important;
    justify-self: start !important;
    align-self: center !important;
    position: static !important;
    inset: auto !important;
    top: auto !important;
    right: auto !important;
    bottom: auto !important;
    left: auto !important;
    transform: none !important;
    translate: none !important;
    width: auto !important;
    min-width: 0 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: flex-start !important;
    gap: 12px !important;
    direction: ltr !important;
  }

  .h67-actions .h67-auth {
    direction: rtl !important;
  }

  .h67-nav {
    grid-area: nav !important;
    justify-self: center !important;
    align-self: stretch !important;
    position: static !important;
    inset: auto !important;
    top: auto !important;
    right: auto !important;
    bottom: auto !important;
    left: auto !important;
    transform: none !important;
    translate: none !important;
    width: auto !important;
    max-width: none !important;
    height: 100% !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    direction: rtl !important;
    white-space: nowrap !important;
  }

  .h67-logo {
    grid-area: logo !important;
    justify-self: end !important;
    align-self: center !important;
    position: static !important;
    inset: auto !important;
    top: auto !important;
    right: auto !important;
    bottom: auto !important;
    left: auto !important;
    transform: none !important;
    translate: none !important;
    width: 155px !important;
    min-width: 155px !important;
    max-width: 155px !important;
    height: 96px !important;
    min-height: 96px !important;
    max-height: 96px !important;
    margin: 0 !important;
    padding: 0 !important;
    border: 0 !important;
    background: transparent !important;
    overflow: visible !important;
    display: flex !important;
    align-items: center !important;
    justify-content: flex-end !important;
    opacity: 1 !important;
    visibility: visible !important;
    z-index: 2 !important;
  }

  .h67-logo img {
    display: block !important;
    width: 155px !important;
    height: auto !important;
    min-width: 0 !important;
    max-width: none !important;
    min-height: 0 !important;
    max-height: none !important;
    margin: 0 !important;
    padding: 0 !important;
    object-fit: contain !important;
    object-position: center !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    transform: none !important;
    translate: none !important;
    clip: auto !important;
    clip-path: none !important;
  }
}
/* 67_HOME_HEADER_STABLE_V8_12_END */
'''

out = s.rstrip() + '\n\n' + block + '\n'
if '!important !important' in out:
    raise SystemExit('ERROR: invalid duplicate !important remains')
for marker in (
    'grid-template-areas: "actions nav logo"',
    'width: min(1360px, calc(100% - 64px))',
    '67_HOME_HEADER_STABLE_V8_12_START',
):
    if marker not in out:
        raise SystemExit(f'ERROR: V8.12 CSS marker missing: {marker}')
p.write_text(out, encoding='utf-8')
print('HEADER_CSS_V8_12_STAGED')
PY_CSS

# Validate staged files before touching live files.
grep -q 'logo-67.png?v=20260916-v812' "$TMP_JSX" || { echo "ERROR: staged cache-busted logo URL missing" >&2; false; }
grep -q '67_HOME_HEADER_STABLE_V8_12_START' "$TMP_CSS" || { echo "ERROR: staged V8.12 CSS block missing" >&2; false; }
! grep -q '!important !important' "$TMP_CSS" || { echo "ERROR: invalid duplicate !important found in staged CSS" >&2; false; }

# Commit the three prepared files only after every staged validation passes.
cp -f "$TMP_JSX" "$HEADER_JSX"
cp -f "$TMP_CSS" "$HEADER_CSS"
cp -f "$TMP_LOGO" "$LOGO"

HOME_JSX_AFTER="$(sha256sum "$HOME_JSX" | awk '{print $1}')"
HOME_CSS_AFTER="$(sha256sum "$HOME_CSS" | awk '{print $1}')"
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
[ "$HOME_JSX_BEFORE" = "$HOME_JSX_AFTER" ] || { echo "ERROR: HomePage.jsx changed unexpectedly" >&2; false; }
[ "$HOME_CSS_BEFORE" = "$HOME_CSS_AFTER" ] || { echo "ERROR: HomePage.css changed unexpectedly" >&2; false; }
[ "$HERO_BEFORE" = "$HERO_AFTER" ] || { echo "ERROR: hero-car.jpg changed unexpectedly" >&2; false; }

if [ -n "$HBR_JSX_BEFORE" ]; then
  [ "$HBR_JSX_BEFORE" = "$(sha256sum "$HBR_JSX" | awk '{print $1}')" ] || { echo "ERROR: HomeBelowHero.jsx changed unexpectedly" >&2; false; }
fi
if [ -n "$HBR_CSS_BEFORE" ]; then
  [ "$HBR_CSS_BEFORE" = "$(sha256sum "$HBR_CSS" | awk '{print $1}')" ] || { echo "ERROR: HomeBelowHero.css changed unexpectedly" >&2; false; }
fi

FINAL_LOGO_SHA="$(sha256sum "$LOGO" | awk '{print $1}')"
[ "$FINAL_LOGO_SHA" = "$EXPECTED_LOGO_SHA" ] || { echo "ERROR: installed exact logo SHA mismatch" >&2; false; }

grep -q 'logo-67.png?v=20260916-v812' "$HEADER_JSX" || { echo "ERROR: live cache-busted logo URL missing" >&2; false; }
grep -q '67_HOME_HEADER_STABLE_V8_12_START' "$HEADER_CSS" || { echo "ERROR: live V8.12 CSS block missing" >&2; false; }
! grep -q '!important !important' "$HEADER_CSS" || { echo "ERROR: invalid duplicate !important found" >&2; false; }

trap - ERR
echo "HOME_HEADER_STABLE_V8_12_APPLIED"
echo "Exact logo SHA: $FINAL_LOGO_SHA"
echo "Changed only:"
echo "  src/components/HomeStoreHeader.css"
echo "  src/components/HomeStoreHeader.jsx (logo URL cache-bust only)"
echo "  public/assets/logo-67.png (exact approved 946x567 asset)"
echo "Protected unchanged: HomePage.jsx, HomePage.css, hero-car.jpg, HomeBelowHero files if present"
