#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/HomePage.css"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-hero-content-front-v5-backup-$(date +%Y%m%d-%H%M%S)"

# Approved full Six Seven logo already hosted in the public patch repo.
LOGO_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/home-assets-v2/logo-67.png"
LOGO_SHA256="a593aa152ca36f6ff704efb1b716ff3c637fd352e130892874cb74574c12bd08"

for f in "$CSS" "$HEADER_CSS" "$HERO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 50
  fi
done

mkdir -p "$BACKUP/src/pages" "$BACKUP/public/assets" "$ROOT/public/assets"
cp -a "$CSS" "$BACKUP/src/pages/HomePage.css"
[ -f "$LOGO" ] && cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png" || true

# These two hashes are guards: this hotfix must NOT alter the approved hero image or navbar CSS.
HERO_BEFORE="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_CSS_BEFORE="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

echo "Backup: $BACKUP"
echo "Hero guard SHA: $HERO_BEFORE"
echo "Navbar CSS guard SHA: $HEADER_CSS_BEFORE"

# Install the approved full logo without changing navbar layout/CSS.
TMP_LOGO="/tmp/67-logo-full-approved-v5.png"
curl -fL --retry 3 --retry-delay 1 "$LOGO_URL" -o "$TMP_LOGO"
ACTUAL_LOGO_SHA="$(sha256sum "$TMP_LOGO" | awk '{print $1}')"
if [ "$ACTUAL_LOGO_SHA" != "$LOGO_SHA256" ]; then
  echo "ERROR: logo checksum mismatch. Expected $LOGO_SHA256 got $ACTUAL_LOGO_SHA" >&2
  exit 51
fi
cp -f "$TMP_LOGO" "$LOGO"

# Append a final, high-specificity desktop-only override. It does NOT redefine the
# hero background, gradient values, hero height, navbar layout, or navbar spacing.
python3 - "$CSS" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
s = re.sub(r'\n?/\* 67_HERO_CONTENT_FRONT_V5_START \*/.*?/\* 67_HERO_CONTENT_FRONT_V5_END \*/\n?', '\n', s, flags=re.S)
block = r'''
/* 67_HERO_CONTENT_FRONT_V5_START */
/* Desktop-only final fix: bring the existing RIGHT hero content in front of the approved shadow. */
@media (min-width: 1281px) {
  .home67-page .home67-hero {
    position: relative !important;
    isolation: isolate !important;
  }

  /* Keep ALL existing shadow/gradient visuals unchanged; only force them behind copy. */
  .home67-page .home67-hero::before,
  .home67-page .home67-hero::after {
    z-index: 0 !important;
    pointer-events: none !important;
  }
  .home67-page .home67-hero .home67-hero-overlay {
    position: absolute !important;
    inset: 0 !important;
    z-index: 1 !important;
    pointer-events: none !important;
  }

  /* Full-size transparent content layer above the shadow. */
  .home67-page .home67-hero .home67-hero-shell,
  .home67-page .home67-hero .home67-hero-content {
    position: absolute !important;
    inset: 0 !important;
    z-index: 6 !important;
    width: 100% !important;
    max-width: none !important;
    height: 100% !important;
    margin: 0 !important;
    padding: 0 !important;
    pointer-events: none !important;
    overflow: visible !important;
  }

  /* Exact approved desktop placement: right-side 620px content block. */
  .home67-page .home67-hero .home67-hero-copy {
    position: absolute !important;
    z-index: 10 !important;
    top: 142px !important;
    right: clamp(110px, 10vw, 185px) !important;
    left: auto !important;
    bottom: auto !important;
    width: 620px !important;
    max-width: 620px !important;
    min-width: 0 !important;
    margin: 0 !important;
    padding: 0 !important;
    transform: none !important;
    direction: rtl !important;
    text-align: right !important;
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    mix-blend-mode: normal !important;
    pointer-events: auto !important;
    overflow: visible !important;
  }

  .home67-page .home67-hero .home67-hero-copy,
  .home67-page .home67-hero .home67-hero-copy * {
    opacity: 1 !important;
    visibility: visible !important;
    filter: none !important;
    mix-blend-mode: normal !important;
  }

  /* Eyebrow: one gold line only. */
  .home67-page .home67-hero .home67-hero-kicker,
  .home67-page .home67-hero .home67-hero-eyebrow,
  .home67-page .home67-hero .home67-eyebrow {
    display: flex !important;
    align-items: center !important;
    justify-content: flex-start !important;
    gap: 14px !important;
    width: max-content !important;
    max-width: 100% !important;
    margin: 0 0 30px auto !important;
    color: #d5ad2d !important;
    font-size: 15px !important;
    line-height: 1 !important;
    font-weight: 900 !important;
    direction: rtl !important;
  }
  .home67-page .home67-hero .home67-hero-kicker::before,
  .home67-page .home67-hero .home67-hero-eyebrow::before,
  .home67-page .home67-hero .home67-eyebrow::before {
    content: '' !important;
    display: block !important;
    width: 38px !important;
    height: 2px !important;
    flex: 0 0 38px !important;
    border-radius: 99px !important;
    background: #d5ad2d !important;
  }
  .home67-page .home67-hero .home67-hero-kicker::after,
  .home67-page .home67-hero .home67-hero-eyebrow::after,
  .home67-page .home67-hero .home67-eyebrow::after {
    display: none !important;
    content: none !important;
  }

  /* Main title exactly on the RIGHT and fully visible. */
  .home67-page .home67-hero .home67-hero-copy h1 {
    display: block !important;
    width: 100% !important;
    max-width: 620px !important;
    margin: 0 !important;
    padding: 0 !important;
    color: #ffffff !important;
    font-size: clamp(68px, 4.2vw, 78px) !important;
    line-height: 1.13 !important;
    letter-spacing: -1.6px !important;
    font-weight: 950 !important;
    text-align: right !important;
    text-shadow: none !important;
    white-space: normal !important;
  }
  .home67-page .home67-hero .home67-hero-copy h1 span,
  .home67-page .home67-hero .home67-hero-copy .home67-hero-highlight,
  .home67-page .home67-hero .home67-hero-copy .home67-gold {
    display: block !important;
    margin-top: 13px !important;
    color: #d5ad2d !important;
    font-size: .84em !important;
    line-height: 1.12 !important;
    font-weight: 950 !important;
    white-space: nowrap !important;
  }

  .home67-page .home67-hero .home67-hero-copy > p,
  .home67-page .home67-hero .home67-hero-description {
    width: 580px !important;
    max-width: 100% !important;
    margin: 24px 0 0 auto !important;
    color: rgba(255,255,255,.80) !important;
    font-size: 16px !important;
    line-height: 1.9 !important;
    font-weight: 450 !important;
    text-align: right !important;
  }

  .home67-page .home67-hero .home67-hero-actions,
  .home67-page .home67-hero .home67-hero-buttons {
    display: flex !important;
    flex-direction: row !important;
    flex-wrap: nowrap !important;
    align-items: center !important;
    justify-content: flex-start !important;
    direction: rtl !important;
    gap: 14px !important;
    width: 100% !important;
    margin: 30px 0 0 !important;
  }
  .home67-page .home67-hero .home67-hero-actions button,
  .home67-page .home67-hero .home67-hero-actions a,
  .home67-page .home67-hero .home67-hero-buttons button,
  .home67-page .home67-hero .home67-hero-buttons a {
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    flex: 0 0 auto !important;
    width: auto !important;
    min-width: 184px !important;
    height: 58px !important;
    min-height: 58px !important;
    margin: 0 !important;
    padding: 0 26px !important;
    border-radius: 30px !important;
  }

  .home67-page .home67-hero .home67-hero-trust {
    display: block !important;
    width: max-content !important;
    max-width: 100% !important;
    margin: 36px 0 0 auto !important;
    padding: 0 16px 0 0 !important;
    border-right: 3px solid #d5ad2d !important;
    text-align: right !important;
    direction: rtl !important;
    color: #ffffff !important;
  }
  .home67-page .home67-hero .home67-hero-trust::before,
  .home67-page .home67-hero .home67-hero-trust::after {
    display: none !important;
    content: none !important;
  }
  .home67-page .home67-hero .home67-hero-trust strong,
  .home67-page .home67-hero .home67-hero-trust b {
    color: #ffffff !important;
    font-size: 14px !important;
    font-weight: 900 !important;
  }
  .home67-page .home67-hero .home67-hero-trust span,
  .home67-page .home67-hero .home67-hero-trust p {
    color: rgba(255,255,255,.62) !important;
    font-size: 12px !important;
  }
}
/* 67_HERO_CONTENT_FRONT_V5_END */
'''
s = s.rstrip() + '\n' + block + '\n'
p.write_text(s, encoding='utf-8')
PY

# Guard checks: fail if this hotfix altered approved background asset or navbar CSS.
HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_CSS_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"
if [ "$HERO_BEFORE" != "$HERO_AFTER" ]; then
  echo "ERROR: hero image changed unexpectedly" >&2
  exit 52
fi
if [ "$HEADER_CSS_BEFORE" != "$HEADER_CSS_AFTER" ]; then
  echo "ERROR: navbar CSS changed unexpectedly" >&2
  exit 53
fi

echo "CONTENT_FRONT_V5_APPLIED"
echo "Hero image unchanged: $HERO_AFTER"
echo "Navbar CSS unchanged: $HEADER_CSS_AFTER"
echo "Logo installed: $LOGO ($(stat -c%s "$LOGO") bytes)"
echo "Changed only:"
echo "- src/pages/HomePage.css"
echo "- public/assets/logo-67.png"
