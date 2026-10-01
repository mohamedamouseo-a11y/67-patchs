#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
cd "$ROOT"

FILES=(
  src/pages/TopPartsPage.jsx
  src/components/HomeBelowHero.jsx
  src/pages/OfferDetailPage.jsx
  src/pages/CartPage.jsx
  src/pages/CheckoutPage.jsx
)

BACKUP="$(mktemp -d /tmp/67-phase3b-frontend-hotfix.XXXXXX)"
for f in "${FILES[@]}"; do
  mkdir -p "$BACKUP/$(dirname "$f")"
  cp "$f" "$BACKUP/$f"
done

restore() {
  for f in "${FILES[@]}"; do cp "$BACKUP/$f" "$f"; done
}
trap restore ERR

python3 - <<'PY'
from pathlib import Path

root = Path("/67")

def ensure_hook(path, anchor, declaration):
    p = root / path
    s = p.read_text()
    if declaration not in s:
        if anchor not in s:
            raise SystemExit(f"anchor missing in {path}: {anchor}")
        s = s.replace(anchor, anchor + "\n" + declaration, 1)
        p.write_text(s)

ensure_hook(
    "src/pages/TopPartsPage.jsx",
    "  const [favoriteIds, setFavoriteIds] = useState(() => new Set());",
    "  const { offers: mockOffers, loading, error } = useMarketplaceProducts();"
)

ensure_hook(
    "src/components/HomeBelowHero.jsx",
    "  const navigate = useNavigate();",
    "  const { offers: mockOffers } = useMarketplaceProducts();"
)

# HomeBelowHero also needs derived homeProducts.
p = root / "src/components/HomeBelowHero.jsx"
s = p.read_text()
decl = "  const homeProducts = useMemo(() => buildHomeProducts(mockOffers), [mockOffers]);"
if decl not in s:
    anchor = "  const { offers: mockOffers } = useMarketplaceProducts();"
    if anchor not in s:
        raise SystemExit("HomeBelowHero marketplace hook missing")
    s = s.replace(anchor, anchor + "\n" + decl, 1)
    p.write_text(s)

ensure_hook(
    "src/pages/OfferDetailPage.jsx",
    "  const navigate = useNavigate();",
    "  const { offers: mockOffers, loading, error } = useMarketplaceProducts();"
)

ensure_hook(
    "src/pages/CartPage.jsx",
    "  const navigate = useNavigate();",
    "  const { offers: mockOffers, loading, error } = useMarketplaceProducts();"
)

ensure_hook(
    "src/pages/CheckoutPage.jsx",
    "  const navigate = useNavigate();",
    "  const { offers: mockOffers, loading: catalogLoading, error: catalogError, reload: reloadCatalog } = useMarketplaceProducts();"
)
PY

grep -q "const { offers: mockOffers, loading, error } = useMarketplaceProducts();" src/pages/TopPartsPage.jsx
grep -q "const { offers: mockOffers } = useMarketplaceProducts();" src/components/HomeBelowHero.jsx
grep -q "const { offers: mockOffers, loading, error } = useMarketplaceProducts();" src/pages/OfferDetailPage.jsx
grep -q "const { offers: mockOffers, loading, error } = useMarketplaceProducts();" src/pages/CartPage.jsx
grep -q "const { offers: mockOffers, loading: catalogLoading, error: catalogError, reload: reloadCatalog } = useMarketplaceProducts();" src/pages/CheckoutPage.jsx

npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-PHASE3B-FRONTEND-MARKETPLACE-HOOK-HOTFIX-V1"
echo "BUILD=PASS"
echo "TOP_PARTS_MOCKOFFERS_DEFINED=YES"
echo "HOME_MARKETPLACE_HOOK=YES"
echo "OFFER_DETAIL_MARKETPLACE_HOOK=YES"
echo "CART_MARKETPLACE_HOOK=YES"
echo "CHECKOUT_MARKETPLACE_HOOK=YES"
echo "BACKEND_CHANGED=NO"
echo "DEVELOPER_HUB_CHANGED=NO"
echo "READY_FOR_RETEST=YES"
echo "ERROR=NONE"
