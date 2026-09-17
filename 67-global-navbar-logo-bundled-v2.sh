#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
cd "$ROOT"

LOGO_COMPONENT="src/components/Logo67.jsx"
HOME_HEADER="src/components/HomeStoreHeader.jsx"
HOME_HEADER_CSS="src/components/HomeStoreHeader.css"
LEGACY_HEADER="src/components/Header.jsx"
CHECKOUT="src/pages/CheckoutPage.jsx"
OFFICIAL_ASSET="src/assets/sixty-seven-official-logo.png"
PUBLIC_LOGO="public/assets/logo-67.png"
WORKSHOPS_CSS="src/pages/WorkshopsPage.css"

for f in "$LOGO_COMPONENT" "$HOME_HEADER" "$HOME_HEADER_CSS" "$LEGACY_HEADER" "$OFFICIAL_ASSET" "$PUBLIC_LOGO"; do
  [[ -f "$f" ]] || { echo "ERROR: missing required file: $f" >&2; exit 1; }
done

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-global-navbar-logo-bundled-v2-$STAMP"
mkdir -p "$BACKUP"

cp -a "$LOGO_COMPONENT" "$BACKUP/Logo67.jsx"
cp -a "$HOME_HEADER" "$BACKUP/HomeStoreHeader.jsx"
cp -a "$HOME_HEADER_CSS" "$BACKUP/HomeStoreHeader.css"
cp -a "$LEGACY_HEADER" "$BACKUP/Header.jsx"
[[ -f "$CHECKOUT" ]] && cp -a "$CHECKOUT" "$BACKUP/CheckoutPage.jsx"
[[ -f "$WORKSHOPS_CSS" ]] && cp -a "$WORKSHOPS_CSS" "$BACKUP/WorkshopsPage.css"

# protect data and binary assets
sha256sum src/data/mockOffers.js src/data/brands.js "$OFFICIAL_ASSET" "$PUBLIC_LOGO" > "$BACKUP/protected.sha256"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/Logo67.jsx" "$LOGO_COMPONENT" || true
  cp -f "$BACKUP/HomeStoreHeader.jsx" "$HOME_HEADER" || true
  cp -f "$BACKUP/HomeStoreHeader.css" "$HOME_HEADER_CSS" || true
  cp -f "$BACKUP/Header.jsx" "$LEGACY_HEADER" || true
  [[ -f "$BACKUP/CheckoutPage.jsx" ]] && cp -f "$BACKUP/CheckoutPage.jsx" "$CHECKOUT" || true
  [[ -f "$BACKUP/WorkshopsPage.css" ]] && cp -f "$BACKUP/WorkshopsPage.css" "$WORKSHOPS_CSS" || true
  echo "ERROR: GLOBAL_NAVBAR_LOGO_BUNDLED_V2 failed; source restored" >&2
  exit "$code"
}
trap rollback ERR

cat > "$LOGO_COMPONENT" <<'EOF'
import officialLogo67 from '../assets/sixty-seven-official-logo.png';

const Logo67 = ({ size, width, height, className = '', alt = '67 Six Seven', style = {} }) => {
  const finalWidth = Number(width || size || 150);
  const finalHeight = height ? Number(height) : Math.round(finalWidth * (104 / 180));

  return (
    <img
      className={className}
      src={officialLogo67}
      alt={alt}
      draggable="false"
      style={{
        display: 'block',
        width: `${finalWidth}px`,
        height: `${finalHeight}px`,
        objectFit: 'contain',
        objectPosition: 'center',
        maxWidth: '100%',
        ...style,
      }}
    />
  );
};

export default Logo67;
EOF

python3 - <<'PY'
from pathlib import Path
import re

p = Path('src/components/HomeStoreHeader.jsx')
s = p.read_text(encoding='utf-8')

if 'import Logo67 from "./Logo67";' not in s and "import Logo67 from './Logo67';" not in s:
    anchor = 'import "./HomeStoreHeader.css";'
    if anchor not in s:
        raise SystemExit('ERROR: HomeStoreHeader css import anchor missing')
    s = s.replace(anchor, 'import Logo67 from "./Logo67";\n' + anchor, 1)

# Replace any direct logo image inside h67-logo button.
pattern = re.compile(r'(<button[^>]*className="h67-logo"[\s\S]*?>)[\s\S]*?(</button>)', re.M)
m = pattern.search(s)
if not m:
    raise SystemExit('ERROR: h67-logo button not found')
block = m.group(0)
if '<Logo67' not in block:
    replacement_inner = '\n          <Logo67 width={155} className="h67-logo-image" />\n        '
    new_block = re.sub(r'(<button[^>]*className="h67-logo"[\s\S]*?>)[\s\S]*?(</button>)', lambda mm: mm.group(1) + replacement_inner + mm.group(2), block, count=1)
    s = s[:m.start()] + new_block + s[m.end():]

# Ensure no broken public URL remains in the shared customer header.
s = re.sub(r'<img[^>]+/assets/logo-67\.png[^>]*>', '<Logo67 width={155} className="h67-logo-image" />', s)

p.write_text(s, encoding='utf-8')
PY

# Header.jsx already uses Logo67; ensure it still does.
grep -q "import Logo67 from './Logo67'" "$LEGACY_HEADER" || grep -q 'import Logo67 from "./Logo67"' "$LEGACY_HEADER" || {
  echo 'ERROR: legacy Header does not use Logo67 component' >&2
  false
}

# Checkout has its own custom top bar; if present, wire it to the same canonical Logo67 component.
if [[ -f "$CHECKOUT" ]] && grep -q 'co67-header' "$CHECKOUT"; then
python3 - <<'PY'
from pathlib import Path
import re
p = Path('src/pages/CheckoutPage.jsx')
s = p.read_text(encoding='utf-8')

if "import Logo67 from '../components/Logo67';" not in s:
    # place after router import when possible
    anchors = [
        "import { useNavigate } from 'react-router-dom';",
        'import { useNavigate } from "react-router-dom";'
    ]
    for a in anchors:
        if a in s:
            s = s.replace(a, a + "\nimport Logo67 from '../components/Logo67';", 1)
            break
    else:
        raise SystemExit('ERROR: Checkout navigate import anchor missing')

# Replace direct logo img in custom checkout header only.
s = re.sub(
    r'<img\s+src=["\']/assets/logo-67\.png(?:\?[^"\']*)?["\']\s+alt=["\'][^"\']*["\']\s*/>',
    '<Logo67 width={120} className="co67-header-logo-img" />',
    s
)

p.write_text(s, encoding='utf-8')
PY
fi

# Canonical shared-header CSS: rely on the actual img emitted by Logo67, not a public URL/background.
cat >> "$HOME_HEADER_CSS" <<'CSS'

/* GLOBAL_NAVBAR_LOGO_BUNDLED_V2 */
.h67-header .h67-logo {
  opacity: 1 !important;
  visibility: visible !important;
  overflow: visible !important;
  background: transparent !important;
  background-image: none !important;
  border: 0 !important;
  box-shadow: none !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
}

.h67-header .h67-logo .h67-logo-image {
  display: block !important;
  width: 155px !important;
  height: auto !important;
  aspect-ratio: 180 / 104 !important;
  max-width: 155px !important;
  max-height: 90px !important;
  object-fit: contain !important;
  object-position: center !important;
  opacity: 1 !important;
  visibility: visible !important;
  filter: none !important;
  clip: auto !important;
  clip-path: none !important;
}

@media (max-width: 1280px) and (min-width: 821px) {
  .h67-header .h67-logo .h67-logo-image {
    width: 108px !important;
    max-width: 108px !important;
    max-height: 70px !important;
  }
}

@media (max-width: 820px) {
  .h67-header .h67-logo .h67-logo-image {
    width: 78px !important;
    max-width: 78px !important;
    max-height: 54px !important;
  }
}
CSS

# Workshops had old local hacks; append a final explicit handoff to canonical shared behavior.
if [[ -f "$WORKSHOPS_CSS" ]]; then
cat >> "$WORKSHOPS_CSS" <<'CSS'

/* GLOBAL_NAVBAR_LOGO_BUNDLED_V2_WORKSHOPS_HANDOFF */
.ws67-page .h67-header .h67-logo {
  display: flex !important;
  background-image: none !important;
  opacity: 1 !important;
  visibility: visible !important;
}
.ws67-page .h67-header .h67-logo .h67-logo-image {
  display: block !important;
  opacity: 1 !important;
  visibility: visible !important;
}
CSS
fi

# Validate canonical bundled wiring.
grep -q "sixty-seven-official-logo.png" "$LOGO_COMPONENT"
grep -q 'className="h67-logo-image"' "$HOME_HEADER"
grep -q '<Logo67' "$HOME_HEADER"
if grep -q '/assets/logo-67.png' "$HOME_HEADER"; then
  echo 'ERROR: HomeStoreHeader still references broken public logo URL' >&2
  false
fi

grep -q 'GLOBAL_NAVBAR_LOGO_BUNDLED_V2' "$HOME_HEADER_CSS"
sha256sum -c "$BACKUP/protected.sha256" >/dev/null || { echo 'ERROR: data or logo assets changed unexpectedly' >&2; false; }

# Report any remaining direct public-logo references so they can be reviewed; do not silently rewrite page content.
echo 'REMAINING_DIRECT_PUBLIC_LOGO_REFS:'
grep -RIl --include='*.jsx' '/assets/logo-67.png' src 2>/dev/null || true

echo 'CANONICAL_LOGO_COMPONENT_REFS:'
grep -RIl --include='*.jsx' 'Logo67' src 2>/dev/null || true

trap - ERR
rm -rf "$BACKUP"

echo 'GLOBAL_NAVBAR_LOGO_BUNDLED_V2_APPLIED'
echo 'OFFICIAL_PROJECT_LOGO_BUNDLED_THROUGH_VITE'
echo 'HOME_STORE_HEADER_USES_CANONICAL_LOGO_COMPONENT'
echo 'LEGACY_HEADER_USES_CANONICAL_LOGO_COMPONENT'
echo 'CHECKOUT_HEADER_CANONICALIZED_IF_PRESENT'
echo 'WORKSHOPS_LOCAL_LOGO_HACKS_OVERRIDDEN'
echo 'NO_DATA_OR_API_CHANGED'
