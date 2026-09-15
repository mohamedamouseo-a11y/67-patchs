#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/HomePage.css"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-hero-final-v8-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$CSS" "$HEADER_CSS" "$HERO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 80
  fi
done

mkdir -p "$BACKUP/src/pages" "$BACKUP/public/assets" "$ROOT/public/assets"
cp -a "$CSS" "$BACKUP/src/pages/HomePage.css"
[ -f "$LOGO" ] && cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png" || true

HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

echo "Backup: $BACKUP"
echo "Hero guard SHA: $HERO_BEFORE"
echo "Navbar CSS guard SHA: $HEADER_BEFORE"

TMP_LOGO="/tmp/67-logo-original-v8.png"
cat > /tmp/67-logo-original-v8.b64 <<'B64'
iVBORw0KGgoAAAANSUhEUgAAA7IAA...