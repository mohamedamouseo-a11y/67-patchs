#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HP_CSS="$ROOT/src/pages/HomePage.css"
HDR_CSS="$ROOT/src/components/HomeStoreHeader.css"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-hero-reference-lock-v4-backup-$(date +%Y%m%d-%H%M%S)"
LOGO_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/home-assets-v2/logo-67.png"
LOGO_SHA256="a593aa152ca36f6ff704efb1b716ff3c637fd352e130892874cb74574c12bd08"

for f in "$HP_CSS" "$HDR_CSS"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 40
  fi
done

mkdir -p "$BACKUP/src/pages" "$BACKUP/src/components" "$BACKUP/public/assets" "$ROOT/public/assets"
cp -a "$HP_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HDR_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
[ -f "$LOGO" ] && cp -a "$LOGO" "$BACKUP/public/assets/logo-67.png" || true

echo "Backup: $BACKUP"

TMP_LOGO="/tmp/67-logo-approved-v4.png"
curl -fL --retry 3 --retry-delay 1 "$LOGO_URL" -o "$TMP_LOGO"
ACTUAL_SHA="$(sha256sum "$TMP_LOGO" | awk '{print $1}')"
if [ "$ACTUAL_SHA" != "$LOGO_SHA256" ]; then
  echo "ERROR: exact logo checksum mismatch. Expected $LOGO_SHA256 got $ACTUAL_SHA" >&2
  exit 41
fi
cp -f "$TMP_LOGO" "$LOGO"
echo "Exact approved logo installed: $LOGO"

python3 - "$HP_CSS" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
s=re.sub(r'\n?/\* 67_HERO_REFERENCE_LOCK_V4_START \*/.*?/\* 67_HERO_REFERENCE_LOCK_V4_END \*/\n?','\n',s,flags=re.S)
block=r'''
/* 67_HERO_REFERENCE_LOCK_V4_START */
/* Final desktop correction based on the approved reference screenshot. */
@media (min-width: 1281px) {
  .home67-hero {
    overflow:hidden!important;
    background-image:url('/assets/hero-car.jpg')!important;
    background-size:cover!important;
    background-position:center center!important;
  }

  /* Keep every darkening layer BEHIND the content. */
  .home67-hero::before {
    z-index:0!important;
    background:linear-gradient(90deg,
      rgba(0,0,0,.02) 0%,
      rgba(0,0,0,.07) 34%,
      rgba(0,0,0,.23) 50%,
      rgba(0,0,0,.58) 68%,
      rgba(0,0,0,.88) 84%,
      rgba(0,0,0,.96) 100%)!important;
  }
  .home67-hero::after {display:none!important;content:none!important}
  .home67-hero .home67-hero-overlay,
  .home67-hero [class*="hero-overlay"],
  .home67-hero [class*="hero-shade"] {
    z-index:1!important;
    pointer-events:none!important;
  }

  .home67-hero-shell,
  .home67-hero-content {
    position:relative!important;
    z-index:10!important;
    width:100%!important;
    max-width:none!important;
    height:100%!important;
    overflow:visible!important;
  }

  /* Match the approved reference: copy block sits clearly inside the RIGHT side. */
  .home67-hero-copy {
    position:absolute!important;
    z-index:20!important;
    top:138px!important;
    right:max(165px,calc((100vw - 1480px)/2))!important;
    left:auto!important;
    width:625px!important;
    max-width:625px!important;
    height:auto!important;
    margin:0!important;
    padding:0!important;
    opacity:1!important;
    visibility:visible!important;
    filter:none!important;
    mix-blend-mode:normal!important;
    transform:none!important;
    text-align:right!important;
    direction:rtl!important;
    color:#fff!important;
  }
  .home67-hero-copy,
  .home67-hero-copy * {
    opacity:1!important;
    visibility:visible!important;
    filter:none!important;
    mix-blend-mode:normal!important;
  }

  .home67-hero-kicker,
  .home67-hero-eyebrow,
  .home67-eyebrow {
    color:#d7ae2e!important;
    margin:0 0 31px auto!important;
    font-size:14px!important;
    font-weight:900!important;
  }

  .home67-hero-copy h1,
  .home67-hero-title {
    color:#fff!important;
    width:100%!important;
    max-width:none!important;
    margin:0!important;
    font-size:78px!important;
    line-height:1.17!important;
    font-weight:950!important;
    letter-spacing:-1.8px!important;
    text-align:right!important;
    text-shadow:0 2px 18px rgba(0,0,0,.18)!important;
  }
  .home67-hero-copy h1 span,
  .home67-hero-highlight,
  .home67-gold {
    display:block!important;
    color:#d7ae2e!important;
    margin-top:15px!important;
    font-size:66px!important;
    line-height:1.12!important;
    white-space:nowrap!important;
  }

  .home67-hero-copy p,
  .home67-hero-description {
    color:rgba(255,255,255,.79)!important;
    width:590px!important;
    max-width:100%!important;
    margin:29px 0 0 auto!important;
    font-size:16px!important;
    line-height:2!important;
    text-align:right!important;
  }

  .home67-hero-actions,
  .home67-hero-buttons {
    position:relative!important;
    z-index:21!important;
    margin-top:31px!important;
    display:flex!important;
    flex-direction:row!important;
    flex-wrap:nowrap!important;
    justify-content:flex-start!important;
    align-items:center!important;
    gap:13px!important;
    direction:rtl!important;
  }
  .home67-hero-actions button,
  .home67-hero-actions a,
  .home67-hero-buttons button,
  .home67-hero-buttons a {
    opacity:1!important;
    visibility:visible!important;
    min-width:184px!important;
    height:58px!important;
    min-height:58px!important;
  }

  .home67-hero-trust {
    position:relative!important;
    z-index:21!important;
    opacity:1!important;
    visibility:visible!important;
    margin:38px 0 0 auto!important;
    color:#fff!important;
  }

  /* Approved desktop reference has no floating mobile bottom nav. */
  .home67-page .bottom-nav {display:none!important}
}
/* 67_HERO_REFERENCE_LOCK_V4_END */
'''
p.write_text(s.rstrip()+"\n"+block+"\n",encoding='utf-8')
PY

python3 - "$HDR_CSS" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
s=re.sub(r'\n?/\* 67_HEADER_REFERENCE_LOCK_V4_START \*/.*?/\* 67_HEADER_REFERENCE_LOCK_V4_END \*/\n?','\n',s,flags=re.S)
block=r'''
/* 67_HEADER_REFERENCE_LOCK_V4_START */
@media (min-width:1281px) {
  .h67-header{height:106px!important}
  .h67-navbar{width:min(1500px,calc(100% - 48px))!important;margin:0 auto!important;position:relative!important}
  .h67-logo{position:absolute!important;right:0!important;top:8px!important;width:144px!important;height:90px!important;display:flex!important;align-items:center!important;justify-content:center!important}
  .h67-logo img{display:block!important;width:136px!important;height:auto!important;max-height:86px!important;object-fit:contain!important;opacity:1!important;visibility:visible!important;filter:none!important}
  .h67-nav{position:absolute!important;left:50%!important;top:0!important;height:100%!important;transform:translateX(-50%)!important;display:flex!important;align-items:center!important;justify-content:center!important;gap:39px!important}
  .h67-actions{position:absolute!important;left:0!important;top:50%!important;transform:translateY(-50%)!important;display:flex!important;align-items:center!important;gap:10px!important}
}
/* 67_HEADER_REFERENCE_LOCK_V4_END */
'''
p.write_text(s.rstrip()+"\n"+block+"\n",encoding='utf-8')
PY

echo "REFERENCE_LOCK_V4_APPLIED"
echo "Changed only:"
echo "- public/assets/logo-67.png (exact approved logo)"
echo "- src/components/HomeStoreHeader.css"
echo "- src/pages/HomePage.css"
echo "No JSX, routes, backend, database, env, admin, seller, checkout or payments were modified."
