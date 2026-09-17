#!/usr/bin/env bash
set -euo pipefail

cd /67

CSS="src/pages/WorkshopsPage.css"
JSX="src/pages/WorkshopsPage.jsx"
HEADER_JSX="src/components/HomeStoreHeader.jsx"
HEADER_CSS="src/components/HomeStoreHeader.css"
LOGO="public/assets/logo-67.png"

for f in "$CSS" "$JSX" "$HEADER_JSX" "$HEADER_CSS" "$LOGO"; do
  [[ -f "$f" ]] || { echo "ERROR: missing required file: $f" >&2; exit 1; }
done

grep -q 'className="ws67-page"' "$JSX" || { echo "ERROR: Workshops redesign markup missing" >&2; exit 1; }
grep -q 'className="h67-logo"' "$HEADER_JSX" || { echo "ERROR: shared header logo button missing" >&2; exit 1; }
grep -q '/assets/logo-67.png' "$HEADER_JSX" || { echo "ERROR: original logo asset reference missing" >&2; exit 1; }

jsx_before="$(sha256sum "$JSX" | awk '{print $1}')"
header_jsx_before="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
header_css_before="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
logo_before="$(sha256sum "$LOGO" | awk '{print $1}')"

backup="$(mktemp)"
cp "$CSS" "$backup"

rollback() {
  cp "$backup" "$CSS" || true
  rm -f "$backup"
  echo "ERROR: WORKSHOPS_HEADER_LOGO_VISIBLE_V1 failed; WorkshopsPage.css restored" >&2
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path
p = Path('src/pages/WorkshopsPage.css')
s = p.read_text(encoding='utf-8')
marker = '/* WORKSHOPS_HEADER_LOGO_VISIBLE_V1 */'
if marker not in s:
    s += r'''

/* WORKSHOPS_HEADER_LOGO_VISIBLE_V1 */
/* Workshops-only safety override: keep the existing shared 67 logo visible
   on the far-right of the desktop header without touching shared header source. */
.ws67-page .h67-logo {
  opacity: 1 !important;
  visibility: visible !important;
  pointer-events: auto !important;
  overflow: visible !important;
  background: transparent !important;
}

.ws67-page .h67-logo img {
  display: block !important;
  opacity: 1 !important;
  visibility: visible !important;
  object-fit: contain !important;
  object-position: center !important;
  filter: none !important;
  clip: auto !important;
  clip-path: none !important;
}

@media (min-width: 1281px) {
  .ws67-page .h67-navbar {
    grid-template-areas: "actions nav logo" !important;
  }

  .ws67-page .h67-logo {
    grid-area: logo !important;
    justify-self: end !important;
    align-self: center !important;
    position: static !important;
    inset: auto !important;
    transform: none !important;
    translate: none !important;
    width: 155px !important;
    height: 92px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    background-image: none !important;
  }

  .ws67-page .h67-logo img {
    width: 155px !important;
    height: auto !important;
    max-width: none !important;
    max-height: 88px !important;
  }
}

@media (max-width: 1280px) and (min-width: 821px) {
  .ws67-page .h67-logo {
    display: flex !important;
  }

  .ws67-page .h67-logo img {
    width: 104px !important;
    height: auto !important;
    max-height: 78px !important;
  }
}
'''
    p.write_text(s, encoding='utf-8')
PY

grep -q 'WORKSHOPS_HEADER_LOGO_VISIBLE_V1' "$CSS"
grep -q '.ws67-page .h67-logo img' "$CSS"

[[ "$jsx_before" == "$(sha256sum "$JSX" | awk '{print $1}')" ]] || { echo "ERROR: WorkshopsPage.jsx changed unexpectedly" >&2; false; }
[[ "$header_jsx_before" == "$(sha256sum "$HEADER_JSX" | awk '{print $1}')" ]] || { echo "ERROR: HomeStoreHeader.jsx changed unexpectedly" >&2; false; }
[[ "$header_css_before" == "$(sha256sum "$HEADER_CSS" | awk '{print $1}')" ]] || { echo "ERROR: HomeStoreHeader.css changed unexpectedly" >&2; false; }
[[ "$logo_before" == "$(sha256sum "$LOGO" | awk '{print $1}')" ]] || { echo "ERROR: logo-67.png changed unexpectedly" >&2; false; }

rm -f "$backup"
trap - ERR

echo "WORKSHOPS_HEADER_LOGO_VISIBLE_V1_APPLIED"
echo "WORKSHOPS_EXISTING_67_LOGO_VISIBLE"
echo "SHARED_HEADER_SOURCE_UNCHANGED"
echo "LOGO_ASSET_UNCHANGED"
