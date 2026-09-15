#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
CSS="$ROOT/src/pages/HomePage.css"
HEADER_CSS="$ROOT/src/components/HomeStoreHeader.css"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-hero-content-front-v6-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$CSS" "$HEADER_CSS" "$HERO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 60
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

# Restore the exact full Six Seven logo from the existing OpenHands backups.
# Approved original is the 946x567 RGBA PNG that existed before the bad logo replacement.
RESTORED_LOGO="$(python3 - <<'PY'
from pathlib import Path
import os, struct
candidates=[]
for p in Path('/tmp').glob('67-home-hero-*-backup-*/public/assets/logo-67.png'):
    try:
        b=p.read_bytes()
        if len(b) < 24 or b[:8] != b'\x89PNG\r\n\x1a\n':
            continue
        w,h=struct.unpack('>II', b[16:24])
        size=len(b)
        if (w,h)==(946,567) and size > 100000:
            candidates.append((p.stat().st_mtime,p,size))
    except Exception:
        pass
if not candidates:
    print('')
else:
    candidates.sort(reverse=True,key=lambda x:x[0])
    print(candidates[0][1])
PY
)"

if [ -z "$RESTORED_LOGO" ] || [ ! -f "$RESTORED_LOGO" ]; then
  echo "ERROR: approved 946x567 full logo not found in /tmp backups. STOP; do not substitute another logo." >&2
  exit 61
fi

cp -f "$RESTORED_LOGO" "$LOGO"
python3 - "$LOGO" <<'PY'
from pathlib import Path
import struct,sys
p=Path(sys.argv[1]); b=p.read_bytes(); w,h=struct.unpack('>II',b[16:24])
print(f"Restored full logo: {p} | {w}x{h} | {len(b)} bytes")
if (w,h)!=(946,567) or len(b)<=100000:
    raise SystemExit(62)
PY

# Only append a final desktop layering/positioning override.
# IMPORTANT: no hero background/gradient/navbar CSS values are changed here.
python3 - "$CSS" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
for marker in ('67_HERO_CONTENT_FRONT_V5','67_HERO_CONTENT_FRONT_V6'):
    s=re.sub(r'\n?/\* '+marker+r'_START \*/.*?/\* '+marker+r'_END \*/\n?','\n',s,flags=re.S)
block=r'''
/* 67_HERO_CONTENT_FRONT_V6_START */
@media (min-width:1281px) {
  /* Preserve the approved background exactly; this block only fixes stacking/content placement. */
  .home67-page .home67-hero {
    position:relative!important;
    isolation:isolate!important;
  }

  /* Existing shadow stays visually unchanged, but must sit behind the copy. */
  .home67-page .home67-hero::before,
  .home67-page .home67-hero::after {
    z-index:0!important;
    pointer-events:none!important;
  }
  .home67-page .home67-hero .home67-hero-overlay,
  .home67-page .home67-hero [class*="hero-overlay"],
  .home67-page .home67-hero [class*="hero-shade"] {
    z-index:1!important;
    pointer-events:none!important;
  }

  /* Lift the whole content layer above every shadow/overlay. */
  .home67-page .home67-hero .home67-hero-shell,
  .home67-page .home67-hero .home67-hero-content {
    position:absolute!important;
    inset:0!important;
    z-index:100!important;
    width:100%!important;
    max-width:none!important;
    height:100%!important;
    margin:0!important;
    padding:0!important;
    opacity:1!important;
    visibility:visible!important;
    filter:none!important;
    mix-blend-mode:normal!important;
    pointer-events:none!important;
    overflow:visible!important;
  }

  /* Approved desktop placement from the reference: right-side content only. */
  .home67-page .home67-hero .home67-hero-copy {
    position:absolute!important;
    z-index:110!important;
    top:138px!important;
    right:clamp(145px,10.35vw,190px)!important;
    left:auto!important;
    bottom:auto!important;
    width:620px!important;
    max-width:620px!important;
    min-width:0!important;
    margin:0!important;
    padding:0!important;
    transform:none!important;
    direction:rtl!important;
    text-align:right!important;
    opacity:1!important;
    visibility:visible!important;
    filter:none!important;
    mix-blend-mode:normal!important;
    pointer-events:auto!important;
    overflow:visible!important;
    color:#fff!important;
  }

  .home67-page .home67-hero .home67-hero-copy * {
    position:relative!important;
    z-index:111!important;
    opacity:1!important;
    visibility:visible!important;
    filter:none!important;
    mix-blend-mode:normal!important;
  }

  .home67-page .home67-hero .home67-hero-kicker,
  .home67-page .home67-hero .home67-hero-eyebrow,
  .home67-page .home67-hero .home67-eyebrow {
    display:flex!important;
    align-items:center!important;
    justify-content:flex-start!important;
    gap:14px!important;
    width:max-content!important;
    max-width:100%!important;
    margin:0 0 30px auto!important;
    color:#d5ad2d!important;
    font-size:15px!important;
    line-height:1!important;
    font-weight:900!important;
    direction:rtl!important;
  }
  .home67-page .home67-hero .home67-hero-kicker::before,
  .home67-page .home67-hero .home67-hero-eyebrow::before,
  .home67-page .home67-hero .home67-eyebrow::before {
    content:''!important;
    display:block!important;
    width:38px!important;
    height:2px!important;
    flex:0 0 38px!important;
    border-radius:99px!important;
    background:#d5ad2d!important;
  }
  .home67-page .home67-hero .home67-hero-kicker::after,
  .home67-page .home67-hero .home67-hero-eyebrow::after,
  .home67-page .home67-hero .home67-eyebrow::after {
    display:none!important;
    content:none!important;
  }

  .home67-page .home67-hero .home67-hero-copy h1,
  .home67-page .home67-hero .home67-hero-title {
    width:100%!important;
    max-width:620px!important;
    margin:0!important;
    padding:0!important;
    color:#fff!important;
    font-size:76px!important;
    line-height:1.13!important;
    letter-spacing:-1.6px!important;
    font-weight:950!important;
    text-align:right!important;
    text-shadow:none!important;
    white-space:normal!important;
  }
  .home67-page .home67-hero .home67-hero-copy h1 span,
  .home67-page .home67-hero .home67-hero-highlight,
  .home67-page .home67-hero .home67-gold {
    display:block!important;
    margin-top:13px!important;
    color:#d5ad2d!important;
    font-size:64px!important;
    line-height:1.12!important;
    font-weight:950!important;
    white-space:nowrap!important;
  }

  .home67-page .home67-hero .home67-hero-copy > p,
  .home67-page .home67-hero .home67-hero-description {
    width:580px!important;
    max-width:100%!important;
    margin:24px 0 0 auto!important;
    color:rgba(255,255,255,.80)!important;
    font-size:16px!important;
    line-height:1.9!important;
    font-weight:450!important;
    text-align:right!important;
  }

  .home67-page .home67-hero .home67-hero-actions,
  .home67-page .home67-hero .home67-hero-buttons {
    display:flex!important;
    flex-direction:row!important;
    flex-wrap:nowrap!important;
    align-items:center!important;
    justify-content:flex-start!important;
    direction:rtl!important;
    gap:14px!important;
    width:100%!important;
    margin:30px 0 0!important;
  }
  .home67-page .home67-hero .home67-hero-actions button,
  .home67-page .home67-hero .home67-hero-actions a,
  .home67-page .home67-hero .home67-hero-buttons button,
  .home67-page .home67-hero .home67-hero-buttons a {
    display:inline-flex!important;
    align-items:center!important;
    justify-content:center!important;
    flex:0 0 auto!important;
    width:auto!important;
    min-width:184px!important;
    height:58px!important;
    min-height:58px!important;
    margin:0!important;
    padding:0 26px!important;
    border-radius:30px!important;
  }

  .home67-page .home67-hero .home67-hero-trust {
    display:block!important;
    width:max-content!important;
    max-width:100%!important;
    margin:36px 0 0 auto!important;
    padding:0 16px 0 0!important;
    border-right:3px solid #d5ad2d!important;
    text-align:right!important;
    direction:rtl!important;
    color:#fff!important;
    opacity:1!important;
    visibility:visible!important;
  }
  .home67-page .home67-hero .home67-hero-trust::before,
  .home67-page .home67-hero .home67-hero-trust::after {
    display:none!important;
    content:none!important;
  }
}
/* 67_HERO_CONTENT_FRONT_V6_END */
'''
p.write_text(s.rstrip()+"\n"+block+"\n",encoding='utf-8')
PY

HERO_AFTER="$(sha256sum "$HERO" | awk '{print $1}')"
HEADER_AFTER="$(sha256sum "$HEADER_CSS" | awk '{print $1}')"

if [ "$HERO_BEFORE" != "$HERO_AFTER" ]; then
  echo "ERROR: hero image changed unexpectedly" >&2
  exit 63
fi
if [ "$HEADER_BEFORE" != "$HEADER_AFTER" ]; then
  echo "ERROR: navbar CSS changed unexpectedly" >&2
  exit 64
fi

echo "CONTENT_FRONT_V6_APPLIED"
echo "Hero unchanged: $HERO_AFTER"
echo "Navbar CSS unchanged: $HEADER_AFTER"
echo "Restored logo source: $RESTORED_LOGO"
echo "Changed only:"
echo "- src/pages/HomePage.css"
echo "- public/assets/logo-67.png"
