#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
LOGO="$ROOT/public/assets/logo-67.png"
TMP_V812="/tmp/67-home-header-stable-v8.12-padded.sh"
BACKUP="/tmp/67-home-header-v8-13-backup-$(date +%Y%m%d-%H%M%S)"
RAW_V812="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-home-header-stable-v8.12.sh"

for f in "$HEADER_JSX" "$HEADER_CSS" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 231; }
done

mkdir -p "$BACKUP/src/components" "$BACKUP/public/assets"
cp -a "$HEADER_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png"

echo "Backup: $BACKUP"

rollback() {
  code=$?
  echo "ERROR: V8.13 failed; restoring header/logo from wrapper backup" >&2
  cp -f "$BACKUP/src/components/HomeStoreHeader.jsx" "$HEADER_JSX" || true
  cp -f "$BACKUP/src/components/HomeStoreHeader.css" "$HEADER_CSS" || true
  cp -f "$BACKUP/public/assets/logo-67.png" "$LOGO" || true
  exit "$code"
}
trap rollback ERR

rm -f "$TMP_V812"
curl -fsSL -H "Cache-Control: no-cache" "$RAW_V812?v=$(date +%s)" -o "$TMP_V812"

# V8.12 was correct structurally but its embedded exact-logo decoder rejected
# unpadded base64. Patch ONLY that decoder in the temporary installer.
python3 - "$TMP_V812" <<'PY_PATCH'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
old = "data = base64.b64decode(compact, validate=True)"
new = "compact += '=' * (-len(compact) % 4)\n    data = base64.b64decode(compact, validate=True)"
if old not in s:
    raise SystemExit('ERROR: V8.12 decoder line not found')
s = s.replace(old, new, 1)
p.write_text(s, encoding='utf-8')
print('V8_12_BASE64_PADDING_PATCHED')
PY_PATCH

bash -n "$TMP_V812"
bash "$TMP_V812"

# V8.12 keeps the real header behavior/routes and fixes the three-column layout.
# Add the exact physical left-control order requested by the design:
# Logout | Search | Notification
python3 - "$HEADER_CSS" <<'PY_CSS'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
name = '67_HOME_HEADER_ACTION_ORDER_V8_13'
pattern = rf'\n?/\* {name}_START \*/.*?/\* {name}_END \*/\n?'
s = re.sub(pattern, '\n', s, flags=re.S)
block = r'''
/* 67_HOME_HEADER_ACTION_ORDER_V8_13_START */
@media (min-width: 1281px) {
  .h67-actions {
    display: flex !important;
    flex-direction: row !important;
    direction: ltr !important;
    align-items: center !important;
    justify-content: flex-start !important;
  }

  .h67-actions .h67-auth {
    order: 0 !important;
    flex: 0 0 auto !important;
  }

  .h67-actions [aria-label="بحث"] {
    order: 1 !important;
    flex: 0 0 auto !important;
  }

  .h67-actions [aria-label="الإشعارات"] {
    order: 2 !important;
    flex: 0 0 auto !important;
  }
}
/* 67_HOME_HEADER_ACTION_ORDER_V8_13_END */
'''
out = s.rstrip() + '\n\n' + block + '\n'
p.write_text(out, encoding='utf-8')
print('HEADER_ACTION_ORDER_V8_13_WRITTEN')
PY_CSS

grep -q '67_HOME_HEADER_STABLE_V8_12_START' "$HEADER_CSS" || { echo "ERROR: V8.12 stable layout block missing" >&2; false; }
grep -q '67_HOME_HEADER_ACTION_ORDER_V8_13_START' "$HEADER_CSS" || { echo "ERROR: V8.13 action order block missing" >&2; false; }
grep -q 'logo-67.png?v=20260916-v812' "$HEADER_JSX" || { echo "ERROR: cache-busted exact logo URL missing" >&2; false; }

FINAL_LOGO_SHA="$(sha256sum "$LOGO" | awk '{print $1}')"
[ "$FINAL_LOGO_SHA" = "5f097e4cfe7802a2baa8b1440bcfe27eb1c37484a1cafb9c006e446624ce6090" ] || {
  echo "ERROR: exact approved logo SHA mismatch after V8.13: $FINAL_LOGO_SHA" >&2
  false
}

trap - ERR
echo "HOME_HEADER_STABLE_V8_13_APPLIED"
echo "Exact logo SHA: $FINAL_LOGO_SHA"
echo "Desktop physical control order: Logout | Search | Notification"
echo "No HomePage/hero/content files are edited by this wrapper beyond the protected checks already enforced by V8.12."
