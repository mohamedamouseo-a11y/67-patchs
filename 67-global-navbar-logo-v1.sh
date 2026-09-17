#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
WORKSHOPS_CSS="$ROOT/src/pages/WorkshopsPage.css"
LOGO="$ROOT/public/assets/logo-67.png"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-global-navbar-logo-v1-$STAMP"

cd "$ROOT"

for f in "$HEADER_JSX" "$HEADER_CSS" "$WORKSHOPS_CSS" "$LOGO"; do
  [[ -f "$f" ]] || { echo "ERROR: missing required file: $f" >&2; exit 1; }
done

grep -q 'className="h67-logo"' "$HEADER_JSX" || { echo "ERROR: shared logo button missing" >&2; exit 1; }
grep -q '/assets/logo-67.png' "$HEADER_JSX" || { echo "ERROR: shared logo asset reference missing" >&2; exit 1; }

mkdir -p "$BACKUP"
cp -a "$HEADER_JSX" "$BACKUP/HomeStoreHeader.jsx"
cp -a "$HEADER_CSS" "$BACKUP/HomeStoreHeader.css"
cp -a "$WORKSHOPS_CSS" "$BACKUP/WorkshopsPage.css"

# Protect all source files except the three intended targets.
find "$ROOT/src" -type f \
  ! -path "$HEADER_JSX" \
  ! -path "$HEADER_CSS" \
  ! -path "$WORKSHOPS_CSS" \
  -print0 | sort -z | xargs -0 sha256sum > "$BACKUP/protected-src.sha256"
sha256sum "$LOGO" > "$BACKUP/logo.sha256"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/HomeStoreHeader.jsx" "$HEADER_JSX" || true
  cp -f "$BACKUP/HomeStoreHeader.css" "$HEADER_CSS" || true
  cp -f "$BACKUP/WorkshopsPage.css" "$WORKSHOPS_CSS" || true
  echo "ERROR: GLOBAL_NAVBAR_LOGO_V1 failed; target files restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path
import re

p = Path('/67/src/components/HomeStoreHeader.jsx')
s = p.read_text(encoding='utf-8')

if 'h67-logo-image' not in s:
    pattern = re.compile(r'<img\s+src="/assets/logo-67\.png([^\"]*)"\s+alt="67 Six Seven"\s*/>')
    m = pattern.search(s)
    if not m:
        raise SystemExit('ERROR: logo img marker not found in HomeStoreHeader.jsx')
    suffix = m.group(1)
    repl = f'<img className="h67-logo-image" src="/assets/logo-67.png{suffix}" alt="67 Six Seven" />'
    s = s[:m.start()] + repl + s[m.end():]

p.write_text(s, encoding='utf-8')
PY

cat >> "$HEADER_CSS" <<'CSS'

/* GLOBAL_NAVBAR_LOGO_V1 */
/* Canonical customer navbar logo treatment for every page using HomeStoreHeader. */
.h67-header .h67-logo {
  opacity: 1 !important;
  visibility: visible !important;
  overflow: visible !important;
  pointer-events: auto !important;
  border: 0 !important;
  background: transparent !important;
  box-shadow: none !important;
  z-index: 120 !important;
}

.h67-header .h67-logo .h67-logo-image {
  display: block !important;
  width: 155px !important;
  height: auto !important;
  max-width: none !important;
  max-height: 88px !important;
  object-fit: contain !important;
  object-position: center !important;
  opacity: 1 !important;
  visibility: visible !important;
  filter: none !important;
  clip: auto !important;
  clip-path: none !important;
}

@media (min-width: 1281px) {
  .h67-header .h67-navbar {
    position: relative !important;
  }

  .h67-header .h67-logo {
    position: absolute !important;
    top: 7px !important;
    right: max(32px, calc((100vw - 1360px) / 2)) !important;
    left: auto !important;
    bottom: auto !important;
    width: 155px !important;
    height: 92px !important;
    margin: 0 !important;
    padding: 0 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    transform: none !important;
    translate: none !important;
    background-image: none !important;
  }
}

@media (max-width: 1280px) and (min-width: 821px) {
  .h67-header .h67-navbar {
    position: relative !important;
  }

  .h67-header .h67-logo {
    position: absolute !important;
    top: 6px !important;
    right: 20px !important;
    left: auto !important;
    width: 112px !important;
    height: 76px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    background-image: none !important;
  }

  .h67-header .h67-logo .h67-logo-image {
    width: 108px !important;
    max-height: 74px !important;
  }
}

@media (max-width: 820px) {
  .h67-header .h67-logo {
    position: absolute !important;
    top: 6px !important;
    right: 12px !important;
    left: auto !important;
    width: 82px !important;
    height: 64px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    background-image: none !important;
  }

  .h67-header .h67-logo .h67-logo-image {
    width: 78px !important;
    max-height: 62px !important;
  }
}
CSS

# Workshops had older page-specific logo overrides. Add a final handoff rule so the shared canonical logo wins there too.
cat >> "$WORKSHOPS_CSS" <<'CSS'

/* GLOBAL_NAVBAR_LOGO_V1_WORKSHOPS_HANDOFF */
.ws67-page .h67-header .h67-logo {
  display: flex !important;
  opacity: 1 !important;
  visibility: visible !important;
  background: transparent !important;
  background-image: none !important;
}

.ws67-page .h67-header .h67-logo .h67-logo-image {
  display: block !important;
  opacity: 1 !important;
  visibility: visible !important;
}
CSS

# Validate expected markers.
grep -q 'GLOBAL_NAVBAR_LOGO_V1' "$HEADER_CSS"
grep -q 'className="h67-logo-image"' "$HEADER_JSX"
grep -q 'GLOBAL_NAVBAR_LOGO_V1_WORKSHOPS_HANDOFF' "$WORKSHOPS_CSS"

# Ensure all unrelated source files and the logo binary are unchanged.
sha256sum -c "$BACKUP/protected-src.sha256" >/dev/null || { echo 'ERROR: unrelated source file changed unexpectedly' >&2; false; }
sha256sum -c "$BACKUP/logo.sha256" >/dev/null || { echo 'ERROR: logo-67.png changed unexpectedly' >&2; false; }

trap - ERR
rm -rf "$BACKUP"

echo 'GLOBAL_NAVBAR_LOGO_V1_APPLIED'
echo 'SHARED_HOME_STORE_HEADER_LOGO_ENABLED_GLOBALLY'
echo 'ALL_HOME_STORE_HEADER_PAGES_REUSE_ORIGINAL_LOGO_ASSET'
echo 'WORKSHOPS_OLD_LOGO_OVERRIDE_NEUTRALIZED'
echo 'LOGO_ASSET_UNCHANGED'
echo 'NO_PAGE_DATA_OR_API_CHANGED'
echo 'CHANGED_FILES:'
echo '  src/components/HomeStoreHeader.jsx'
echo '  src/components/HomeStoreHeader.css'
echo '  src/pages/WorkshopsPage.css'
