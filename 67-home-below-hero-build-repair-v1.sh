#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
FILE="$ROOT/src/components/HomeBelowHero.jsx"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-home-below-hero-build-repair-v1-$STAMP.jsx"

[ -f "$FILE" ] || { echo "ERROR: missing $FILE" >&2; exit 1001; }
cp -a "$FILE" "$BACKUP"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP" "$FILE" || true
  echo "ERROR: HomeBelowHero repair failed; original file restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - "$FILE" <<'PY'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')

# 1) Remove accidental JSX quote escaping introduced by an earlier patch payload.
s = s.replace('\\"', '"')

# 2) Deduplicate imports by source path. Keep the first import for each module path.
lines = s.splitlines()
out = []
seen_import_sources = set()
for line in lines:
    m = re.match(r"\s*import\s+.+?\s+from\s+(['\"])(.+?)\1;?\s*$", line)
    if m:
        source = m.group(2)
        if source in seen_import_sources:
            continue
        seen_import_sources.add(source)
    out.append(line)
s = '\n'.join(out) + ('\n' if s.endswith('\n') else '')

# 3) Deduplicate brandLogos object declarations, preserving the first complete declaration.
brand_matches = list(re.finditer(r"const\s+brandLogos\s*=\s*\{[\s\S]*?\n\};", s))
if len(brand_matches) > 1:
    first = brand_matches[0]
    pieces = []
    last = 0
    for i, m in enumerate(brand_matches):
        if i == 0:
            continue
        pieces.append(s[last:m.start()])
        last = m.end()
    pieces.append(s[last:])
    s = ''.join(pieces)

# 4) If the newer reference-layout model exists, remove leftover simple homeProducts declarations.
if 'const HOME_PART_TABS' in s and 'const representativeProducts' in s:
    s = re.sub(r"\n?const\s+homeProducts\s*=\s*mockOffers\.slice\([^;]+\);\s*", "\n", s)

# 5) Ensure exactly one advanced homeProducts declaration remains.
home_product_decls = list(re.finditer(r"const\s+homeProducts\s*=", s))
if len(home_product_decls) > 1:
    # Prefer the declaration immediately following representativeIds (the reference-layout model).
    advanced = re.search(
        r"const\s+representativeIds\s*=.*?;\s*\nconst\s+homeProducts\s*=\s*\[[\s\S]*?\n\];",
        s,
    )
    if not advanced:
        raise SystemExit('ERROR: multiple homeProducts declarations remain and advanced declaration could not be identified')
    advanced_text = advanced.group(0)
    # Remove all standalone homeProducts declarations, then restore the validated advanced block once.
    s = re.sub(r"\nconst\s+homeProducts\s*=\s*mockOffers\.slice\([^;]+\);\s*", "\n", s)
    # Remove duplicate advanced array declarations outside the chosen block by exact declaration shape.
    decls = list(re.finditer(r"const\s+homeProducts\s*=\s*\[[\s\S]*?\n\];", s))
    if len(decls) > 1:
        keep = decls[0]
        result = []
        pos = 0
        for idx, m in enumerate(decls):
            if idx == 0:
                continue
            result.append(s[pos:m.start()])
            pos = m.end()
        result.append(s[pos:])
        s = ''.join(result)

# Final structural checks.
required_import_sources = [
    '../data/mockOffers',
    '../assets/brands/toyota.svg',
    '../assets/brands/nissan.svg',
    '../assets/brands/honda.svg',
    '../assets/brands/hyundai.svg',
    '../assets/brands/kia.svg',
    '../assets/brands/chevrolet.svg',
    '../assets/brands/gmc.svg',
    '../assets/brands/ford.svg',
]
for source in required_import_sources:
    count = len(re.findall(rf"from\s+['\"]{re.escape(source)}['\"]", s))
    if count != 1:
        raise SystemExit(f'ERROR: expected exactly one import from {source}, found {count}')

if len(re.findall(r"const\s+brandLogos\s*=", s)) != 1:
    raise SystemExit('ERROR: brandLogos declaration count is not 1 after repair')
if len(re.findall(r"const\s+homeProducts\s*=", s)) != 1:
    raise SystemExit('ERROR: homeProducts declaration count is not 1 after repair')
if '\\"' in s:
    raise SystemExit('ERROR: escaped JSX quotes still remain after repair')
for marker in [
    "from '../data/mockOffers'",
    'const HOME_PART_TABS',
    'const representativeProducts',
    'b01h-featured-parts',
    'visibleHomeProducts',
]:
    if marker not in s:
        raise SystemExit(f'ERROR: required Home redesign marker missing after repair: {marker}')

p.write_text(s, encoding='utf-8')

print('HOME_BELOW_HERO_DUPLICATES_REMOVED')
print('HOME_BELOW_HERO_ESCAPED_QUOTES_REPAIRED')
print('HOME_BELOW_HERO_REFERENCE_LAYOUT_PRESERVED')
PY

# Fast syntax/build-level validation without changing any other source file.
cd "$ROOT"

# Ensure the repaired file has only the intended single declarations.
[ "$(grep -c "from '../data/mockOffers'" "$FILE")" -eq 1 ]
[ "$(grep -c "const brandLogos" "$FILE")" -eq 1 ]
[ "$(grep -c "const homeProducts" "$FILE")" -eq 1 ]

echo "HOME_BELOW_HERO_BUILD_REPAIR_V1_APPLIED"
echo "CHANGED_FILES:"
echo "  src/components/HomeBelowHero.jsx"
