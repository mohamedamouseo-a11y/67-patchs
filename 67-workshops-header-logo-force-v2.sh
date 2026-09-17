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

grep -q 'className="ws67-page"' "$JSX" || { echo "ERROR: Workshops page marker missing" >&2; exit 1; }
grep -q 'className="h67-logo"' "$HEADER_JSX" || { echo "ERROR: shared header logo button missing" >&2; exit 1; }
grep -q '/assets/logo-67.png' "$HEADER_JSX" || { echo "ERROR: existing logo reference missing" >&2; exit 1; }

jsx_before="$(sha256sum "$JSX" | awk '{print $1}')"
header_jsx_before="$(sha256sum "$HEADER_JSX" | awk '{print $1}')"
header_css_before="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
logo_before="$(sha256sum "$LOGO" | awk '{print $1}')"

backup="$(mktemp)"
cp "$CSS" "$backup"

rollback() {
  cp "$backup" "$CSS" || true
  rm -f "$backup"
  echo "ERROR: WORKSHOPS_HEADER_LOGO_FORCE_V2 failed; WorkshopsPage.css restored" >&2
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path
p = Path('src/pages/WorkshopsPage.css')
s = p.read_text(encoding='utf-8')
marker = '/* WORKSHOPS_HEADER_LOGO_FORCE_V2 */'
if marker not in s:
    s += r'''

/* WORKSHOPS_HEADER_LOGO_FORCE_V2 */
/* Hard fallback for Workshops desktop header: render the EXISTING 67 logo
   as the logo button background so visibility no longer depends on the img rule
   inside the shared header stylesheet. */
@media (min-width: 1281px) {
  .ws67-page .h67-header .h67-navbar {
    position: relative !important;
  }

  .ws67-page .h67-header .h67-logo {
    position: absolute !important;
    top: 7px !important;
    right: max(32px, calc((100vw - 1360px) / 2)) !important;
    left: auto !important;
    bottom: auto !important;
    width: 155px !important;
    height: 92px !important;
    margin: 0 !important;
    padding: 0 !important;
    display: block !important;
    opacity: 1 !important;
    visibility: visible !important;
    overflow: visible !important;
    border: 0 !important;
    border-radius: 0 !important;
    background-color: transparent !important;
    background-image: url('/assets/logo-67.png?v=ws67-logo-force-v2') !important;
    background-repeat: no-repeat !important;
    background-position: center !important;
    background-size: contain !important;
    box-shadow: none !important;
    transform: none !important;
    translate: none !important;
    z-index: 999 !important;
    cursor: pointer !important;
  }

  .ws67-page .h67-header .h67-logo img {
    display: none !important;
  }
}

@media (max-width: 1280px) and (min-width: 821px) {
  .ws67-page .h67-header .h67-navbar {
    position: relative !important;
  }

  .ws67-page .h67-header .h67-logo {
    position: absolute !important;
    top: 6px !important;
    right: 20px !important;
    left: auto !important;
    width: 112px !important;
    height: 76px !important;
    display: block !important;
    opacity: 1 !important;
    visibility: visible !important;
    background-color: transparent !important;
    background-image: url('/assets/logo-67.png?v=ws67-logo-force-v2') !important;
    background-repeat: no-repeat !important;
    background-position: center !important;
    background-size: contain !important;
    z-index: 999 !important;
  }

  .ws67-page .h67-header .h67-logo img {
    display: none !important;
  }
}
'''
    p.write_text(s, encoding='utf-8')
PY

grep -q 'WORKSHOPS_HEADER_LOGO_FORCE_V2' "$CSS"
grep -q "ws67-logo-force-v2" "$CSS"

grep -q "background-image: url('/assets/logo-67.png?v=ws67-logo-force-v2')" "$CSS"

[[ "$jsx_before" == "$(sha256sum "$JSX" | awk '{print $1}')" ]] || { echo "ERROR: WorkshopsPage.jsx changed unexpectedly" >&2; false; }
[[ "$header_jsx_before" == "$(sha256sum "$HEADER_JSX" | awk '{print $1}')" ]] || { echo "ERROR: HomeStoreHeader.jsx changed unexpectedly" >&2; false; }
[[ "$header_css_before" == "$(sha256sum "$HEADER_CSS" | awk '{print $1}')" ]] || { echo "ERROR: HomeStoreHeader.css changed unexpectedly" >&2; false; }
[[ "$logo_before" == "$(sha256sum "$LOGO" | awk '{print $1}')" ]] || { echo "ERROR: logo asset changed unexpectedly" >&2; false; }

rm -f "$backup"
trap - ERR

echo "WORKSHOPS_HEADER_LOGO_FORCE_V2_APPLIED"
echo "WORKSHOPS_LOGO_RENDERED_AS_EXISTING_ASSET_BACKGROUND"
echo "SHARED_HEADER_SOURCE_UNCHANGED"
echo "LOGO_ASSET_UNCHANGED"
