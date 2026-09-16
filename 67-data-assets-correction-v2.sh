#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
STAMP="$(date +%Y%m%d-%H%M%S)"
BASE="/tmp/67-data-assets-correction-v1-$STAMP.sh"
PATCHED="/tmp/67-data-assets-correction-v2-$STAMP.sh"
RAW="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-data-assets-correction-v1.sh"

cd "$ROOT"

curl -fsSL -H "Cache-Control: no-cache" "$RAW?v=$(date +%s%N)" -o "$BASE"
cp "$BASE" "$PATCHED"

python3 - "$PATCHED" <<'PY'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

start = s.find('# ---------------- CART ----------------')
end_marker = "cart.write_text(cs, encoding='utf-8')"
end = s.find(end_marker, start)
if start < 0 or end < 0:
    raise SystemExit('ERROR: unable to locate CART correction block in base script')
end += len(end_marker)

robust = r'''# ---------------- CART ----------------
cs = cart.read_text(encoding='utf-8')

# Match the original cart records structurally instead of depending on quote style
# or exact whitespace/commas. Only the existing image:null field is replaced.
cart_rules = [
    (
        r"(\{\s*id\s*:\s*['\"]1['\"]\s*,\s*name\s*:\s*['\"]كمبروسر مكيف كامري 2020['\"](?:(?!\}\s*,?).)*?image\s*:\s*)null",
        r"\1'/images/parts/ac_new.jpg'",
        'cart item 1 compressor',
    ),
    (
        r"(\{\s*id\s*:\s*['\"]2['\"]\s*,\s*name\s*:\s*['\"]فحمات فرامل أمامية['\"](?:(?!\}\s*,?).)*?image\s*:\s*)null",
        r"\1'/images/parts/brakes.jpg'",
        'cart item 2 brake pads',
    ),
]

for pattern, replacement, label in cart_rules:
    cs, count = re.subn(pattern, replacement, cs, count=1, flags=re.S)
    if count != 1:
        # Idempotent safety: accept an already-correct original asset reference.
        expected = '/images/parts/ac_new.jpg' if 'compressor' in label else '/images/parts/brakes.jpg'
        if expected not in cs:
            raise SystemExit(f'ERROR: robust Cart marker missing: {label}')

for marker in ('/images/parts/ac_new.jpg', '/images/parts/brakes.jpg'):
    if marker not in cs:
        raise SystemExit(f'ERROR: Cart original image was not applied: {marker}')

cart.write_text(cs, encoding='utf-8')'''

s = s[:start] + robust + s[end:]
p.write_text(s, encoding='utf-8')
print('ROBUST_CART_MATCHER_V2_READY')
PY

bash -n "$PATCHED"
echo 'DATA_ASSETS_CORRECTION_V2_SYNTAX_PASS'

bash "$PATCHED"

echo 'DATA_ASSETS_CORRECTION_V2_APPLIED'
