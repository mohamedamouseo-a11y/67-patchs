#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
RAW_BASE="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/batch-03-notifications-search-profile-v1"
STAMP="$(date +%Y%m%d-%H%M%S)"
TMP="/tmp/67-batch-03-$STAMP"
BACKUP="/tmp/67-batch-03-backup-$STAMP"

NOTIF="$ROOT/src/pages/NotificationsPage.jsx"
NOTIF_CSS="$ROOT/src/pages/NotificationsPage.css"
SEARCH="$ROOT/src/pages/PartSearchPage.jsx"
SEARCH_CSS="$ROOT/src/pages/PartSearchPage.css"
PROFILE="$ROOT/src/pages/CustomerProfilePage.jsx"
PROFILE_CSS="$ROOT/src/pages/CustomerProfilePage.css"
HEADER_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HOME="$ROOT/src/pages/HomePage.jsx"
HOME_CSS="$ROOT/src/pages/HomePage.css"
HBR="$ROOT/src/components/HomeBelowHero.jsx"
HBR_CSS="$ROOT/src/components/HomeBelowHero.css"
CART="$ROOT/src/pages/CartPage.jsx"
CART_CSS="$ROOT/src/pages/CartPage.css"
ORDERS="$ROOT/src/pages/MyOrdersPage.jsx"
ORDERS_CSS="$ROOT/src/pages/MyOrdersPage.css"
TOP="$ROOT/src/pages/TopPartsPage.jsx"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"

for f in "$NOTIF" "$SEARCH" "$SEARCH_CSS" "$PROFILE" "$HEADER_JSX" "$HEADER_CSS" "$HOME" "$HOME_CSS" "$CART" "$ORDERS" "$TOP" "$HERO" "$LOGO"; do
  [ -f "$f" ] || { echo "ERROR: missing required project file: $f" >&2; exit 501; }
done

mkdir -p "$TMP" "$BACKUP/src/pages" "$BACKUP/src/components" "$BACKUP/public/assets"

# Verify the untouched original business/data behavior before redesigning presentation only.
grep -q "title: 'انخفاض في السعر!'" "$NOTIF"
grep -q "case 'orders': navigate('/orders')" "$NOTIF"
grep -q "case 'offers': navigate('/offers')" "$NOTIF"
grep -q "import { brands } from '../data/brands'" "$SEARCH"
grep -q "const { brandId, modelId, year } = useParams()" "$SEARCH"
grep -q "setTimeout" "$SEARCH"
grep -q "navigate('/offers')" "$SEARCH"
grep -q "name: 'عبدالله أحمد'" "$PROFILE"
grep -q "path: '/orders'" "$PROFILE"
grep -q "path: '/notifications'" "$PROFILE"
grep -q "localStorage.removeItem('customerSession')" "$PROFILE"

echo 'ORIGINAL_PAGE_BEHAVIOR_COMPATIBLE'

# Snapshot targets.
cp -a "$NOTIF" "$BACKUP/src/pages/NotificationsPage.jsx"
cp -a "$SEARCH" "$BACKUP/src/pages/PartSearchPage.jsx"
cp -a "$SEARCH_CSS" "$BACKUP/src/pages/PartSearchPage.css"
cp -a "$PROFILE" "$BACKUP/src/pages/CustomerProfilePage.jsx"

NOTIF_CSS_EXISTED=0
PROFILE_CSS_EXISTED=0
if [ -f "$NOTIF_CSS" ]; then NOTIF_CSS_EXISTED=1; cp -a "$NOTIF_CSS" "$BACKUP/src/pages/NotificationsPage.css"; fi
if [ -f "$PROFILE_CSS" ]; then PROFILE_CSS_EXISTED=1; cp -a "$PROFILE_CSS" "$BACKUP/src/pages/CustomerProfilePage.css"; fi

# Snapshot protected files by hash only; they must never be touched by this batch.
protected=("$HEADER_JSX" "$HEADER_CSS" "$HOME" "$HOME_CSS" "$HBR" "$HBR_CSS" "$CART" "$CART_CSS" "$ORDERS" "$ORDERS_CSS" "$TOP" "$TOP_CSS" "$HERO" "$LOGO")
declare -A BEFORE
for f in "${protected[@]}"; do
  if [ -f "$f" ]; then BEFORE["$f"]="$(sha256sum "$f" | awk '{print $1}')"; fi
done

rollback(){
  code=$?
  trap - ERR
  echo 'ERROR: Batch 03 failed; restoring target page files' >&2
  cp -f "$BACKUP/src/pages/NotificationsPage.jsx" "$NOTIF" || true
  cp -f "$BACKUP/src/pages/PartSearchPage.jsx" "$SEARCH" || true
  cp -f "$BACKUP/src/pages/PartSearchPage.css" "$SEARCH_CSS" || true
  cp -f "$BACKUP/src/pages/CustomerProfilePage.jsx" "$PROFILE" || true
  if [ "$NOTIF_CSS_EXISTED" -eq 1 ]; then cp -f "$BACKUP/src/pages/NotificationsPage.css" "$NOTIF_CSS" || true; else rm -f "$NOTIF_CSS"; fi
  if [ "$PROFILE_CSS_EXISTED" -eq 1 ]; then cp -f "$BACKUP/src/pages/CustomerProfilePage.css" "$PROFILE_CSS" || true; else rm -f "$PROFILE_CSS"; fi
  exit "$code"
}
trap rollback ERR

for name in NotificationsPage.jsx NotificationsPage.css PartSearchPage.jsx PartSearchPage.css CustomerProfilePage.jsx CustomerProfilePage.css; do
  curl -fsSL -H 'Cache-Control: no-cache' "$RAW_BASE/$name?v=$(date +%s%N)" -o "$TMP/$name"
  [ -s "$TMP/$name" ] || { echo "ERROR: empty payload $name" >&2; false; }
done

python3 - "$TMP" <<'PY'
from pathlib import Path
import sys
base=Path(sys.argv[1])
checks={
 'NotificationsPage.jsx':["title: 'انخفاض في السعر!'","case 'orders': navigate('/orders')","case 'offers': navigate('/offers')",'<HomeStoreHeader />','n67-page'],
 'PartSearchPage.jsx':["from '../data/brands'",'useParams()','setTimeout',"navigate('/offers')",'s67-page'],
 'CustomerProfilePage.jsx':["name: 'عبدالله أحمد'","path: '/orders'","path: '/notifications'","localStorage.removeItem('customerSession')",'p67-page'],
 'NotificationsPage.css':['.n67-page','@media'],
 'PartSearchPage.css':['.s67-page','@media'],
 'CustomerProfilePage.css':['.p67-page','@media'],
}
for name, markers in checks.items():
    text=(base/name).read_text(encoding='utf-8')
    for marker in markers:
        if marker not in text:
            raise SystemExit(f'ERROR: payload marker missing {name}: {marker}')
# No replacement API/data service is introduced by this redesign batch.
for name in ('NotificationsPage.jsx','PartSearchPage.jsx','CustomerProfilePage.jsx'):
    text=(base/name).read_text(encoding='utf-8')
    if 'axios' in text or 'fetch(' in text or '/api/' in text:
        raise SystemExit(f'ERROR: unexpected new API/data implementation in {name}')
print('BATCH_03_PAYLOADS_VALID')
print('ORIGINAL_DATA_LAYER_PRESERVED_NO_NEW_API')
PY

cp -f "$TMP/NotificationsPage.jsx" "$NOTIF"
cp -f "$TMP/NotificationsPage.css" "$NOTIF_CSS"
cp -f "$TMP/PartSearchPage.jsx" "$SEARCH"
cp -f "$TMP/PartSearchPage.css" "$SEARCH_CSS"
cp -f "$TMP/CustomerProfilePage.jsx" "$PROFILE"
cp -f "$TMP/CustomerProfilePage.css" "$PROFILE_CSS"

# Re-validate original data/behavior markers after the visual redesign.
grep -q "title: 'انخفاض في السعر!'" "$NOTIF"
grep -q "case 'orders': navigate('/orders')" "$NOTIF"
grep -q "case 'offers': navigate('/offers')" "$NOTIF"
grep -q "import { brands } from '../data/brands'" "$SEARCH"
grep -q "const { brandId, modelId, year } = useParams()" "$SEARCH"
grep -q "navigate('/offers')" "$SEARCH"
grep -q "name: 'عبدالله أحمد'" "$PROFILE"
grep -q "path: '/orders'" "$PROFILE"
grep -q "path: '/notifications'" "$PROFILE"
grep -q "localStorage.removeItem('customerSession')" "$PROFILE"

# Shared pages/assets must remain byte-identical.
for f in "${protected[@]}"; do
  if [ -f "$f" ] && [ -n "${BEFORE[$f]:-}" ]; then
    after="$(sha256sum "$f" | awk '{print $1}')"
    [ "${BEFORE[$f]}" = "$after" ] || { echo "ERROR: protected file changed: $f" >&2; false; }
  fi
done

echo 'BATCH_03_NOTIFICATIONS_SEARCH_PROFILE_V1_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/pages/NotificationsPage.jsx'
echo '  src/pages/NotificationsPage.css'
echo '  src/pages/PartSearchPage.jsx'
echo '  src/pages/PartSearchPage.css'
echo '  src/pages/CustomerProfilePage.jsx'
echo '  src/pages/CustomerProfilePage.css'
echo 'PROTECTED_SHARED_PAGES_AND_ASSETS_UNCHANGED'
