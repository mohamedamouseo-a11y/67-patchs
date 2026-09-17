#!/usr/bin/env bash
set -euo pipefail

cd /67

CSS="src/pages/WorkshopsPage.css"
JSX="src/pages/WorkshopsPage.jsx"

[[ -f "$CSS" ]] || { echo "ERROR: $CSS missing"; exit 1; }
[[ -f "$JSX" ]] || { echo "ERROR: $JSX missing"; exit 1; }

grep -q 'className="ws67-page"' "$JSX" || { echo "ERROR: Workshops redesign markup not detected"; exit 1; }
grep -q 'ws67-hero-inner' "$CSS" || { echo "ERROR: Workshops hero CSS marker missing"; exit 1; }

jsx_before="$(sha256sum "$JSX" | awk '{print $1}')"
backup="$(mktemp)"
cp "$CSS" "$backup"

rollback() {
  cp "$backup" "$CSS"
  rm -f "$backup"
  echo "ERROR: WORKSHOPS_HERO_LOWER_V2 failed; CSS restored" >&2
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path
p = Path('src/pages/WorkshopsPage.css')
s = p.read_text(encoding='utf-8')
marker = '/* WORKSHOPS_HERO_LOWER_V2 */'
if marker not in s:
    s += r'''

/* WORKSHOPS_HERO_LOWER_V2 */
/* Desktop-only vertical alignment refinement from visual review. */
@media (min-width: 981px) {
  .ws67-hero {
    min-height: 650px;
  }

  .ws67-hero-inner {
    position: relative;
    top: 34px;
  }
}
'''
    p.write_text(s, encoding='utf-8')
PY

grep -q 'WORKSHOPS_HERO_LOWER_V2' "$CSS"
grep -q 'top: 34px' "$CSS"

jsx_after="$(sha256sum "$JSX" | awk '{print $1}')"
[[ "$jsx_before" == "$jsx_after" ]] || { echo "ERROR: WorkshopsPage.jsx changed unexpectedly"; exit 1; }

rm -f "$backup"
trap - ERR

echo "WORKSHOPS_HERO_LOWER_V2_APPLIED"
echo "WORKSHOPS_HERO_CONTENT_LOWERED"
echo "WORKSHOPS_LAYOUT_AND_DATA_UNCHANGED"
echo "WORKSHOPS_CSS_ONLY_CHANGE"
