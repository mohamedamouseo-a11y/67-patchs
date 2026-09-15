#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HP_CSS="$ROOT/src/pages/HomePage.css"
HDR_CSS="$ROOT/src/components/HomeStoreHeader.css"
HDR_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HERO="$ROOT/public/assets/hero-car.jpg"
LOGO="$ROOT/public/assets/logo-67.png"
BACKUP="/tmp/67-home-hero-reference-lock-v3-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$HP_CSS" "$HDR_CSS" "$HDR_JSX" "$HERO" "$LOGO"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 30
  fi
done

mkdir -p "$BACKUP/src/pages" "$BACKUP/src/components"
cp -a "$HP_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HDR_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
cp -a "$HDR_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"

echo "Backup: $BACKUP"
echo "Hero: $(stat -c%s "$HERO") bytes"
echo "Logo: $(stat -c%s "$LOGO") bytes"

cat > "$HDR_CSS" <<'CSS'
/* 67 HOME HEADER — locked to approved desktop reference */
.h67-header{
  position:absolute!important;
  top:0!important;left:0!important;right:0!important;
  width:100%!important;height:106px!important;
  z-index:80!important;
  color:#fff!important;
  border-bottom:1px solid rgba(255,255,255,.14)!important;
  background:linear-gradient(to bottom,rgba(4,5,5,.66),rgba(4,5,5,.18))!important;
  backdrop-filter:blur(3px)!important;
  -webkit-backdrop-filter:blur(3px)!important;
  box-sizing:border-box!important;
}
.h67-navbar{
  position:relative!important;
  width:min(1500px,calc(100% - 48px))!important;
  height:100%!important;
  margin:0 auto!important;
  display:block!important;
  box-sizing:border-box!important;
  direction:rtl!important;
}
.h67-logo{
  position:absolute!important;
  top:9px!important;right:0!important;
  width:132px!important;height:88px!important;
  margin:0!important;padding:0!important;
  border:0!important;background:transparent!important;
  display:flex!important;align-items:center!important;justify-content:center!important;
  cursor:pointer!important;
}
.h67-logo img{
  display:block!important;
  width:126px!important;height:auto!important;
  max-width:100%!important;max-height:84px!important;
  object-fit:contain!important;
  opacity:1!important;visibility:visible!important;
}
.h67-nav{
  position:absolute!important;
  top:0!important;left:50%!important;
  height:100%!important;
  transform:translateX(-50%)!important;
  display:flex!important;align-items:center!important;justify-content:center!important;
  gap:40px!important;
  direction:rtl!important;
  white-space:nowrap!important;
}
.h67-nav-link{
  position:relative!important;
  border:0!important;background:transparent!important;
  margin:0!important;padding:10px 0!important;
  color:rgba(255,255,255,.72)!important;
  font:inherit!important;font-size:15px!important;font-weight:700!important;line-height:1!important;
  cursor:pointer!important;white-space:nowrap!important;
  transition:color .2s ease!important;
}
.h67-nav-link:hover,.h67-nav-link.is-active{color:#fff!important}
.h67-nav-link.is-active::after{
  content:''!important;
  position:absolute!important;
  right:50%!important;bottom:-17px!important;
  width:29px!important;height:2px!important;
  border-radius:10px!important;
  background:#d7ae2e!important;
  transform:translateX(50%)!important;
}
.h67-cart-badge{
  position:absolute!important;
  top:-10px!important;right:-14px!important;
  width:18px!important;height:18px!important;
  padding:0!important;border-radius:50%!important;
  display:grid!important;place-items:center!important;
  background:#ef4d54!important;color:#fff!important;
  font-size:10px!important;font-weight:900!important;line-height:1!important;
  box-shadow:0 0 0 2px rgba(9,10,10,.78)!important;
}
.h67-actions{
  position:absolute!important;
  left:0!important;top:50%!important;
  transform:translateY(-50%)!important;
  display:flex!important;align-items:center!important;
  gap:10px!important;
  direction:ltr!important;
}
.h67-icon-btn{
  position:relative!important;
  width:46px!important;height:46px!important;
  min-width:46px!important;padding:0!important;
  border-radius:50%!important;
  display:grid!important;place-items:center!important;
  color:#fff!important;
  background:rgba(255,255,255,.075)!important;
  border:1px solid rgba(255,255,255,.26)!important;
  backdrop-filter:blur(8px)!important;-webkit-backdrop-filter:blur(8px)!important;
  cursor:pointer!important;
}
.h67-icon-btn:hover{background:rgba(255,255,255,.13)!important;border-color:rgba(255,255,255,.42)!important;color:#fff!important}
.h67-notice-dot{
  position:absolute!important;
  top:4px!important;right:4px!important;
  width:8px!important;height:8px!important;border-radius:50%!important;
  background:#ef4d54!important;
  box-shadow:0 0 0 2px rgba(8,8,8,.86)!important;
}
.h67-auth{
  min-width:148px!important;height:48px!important;
  padding:0 21px!important;margin:0!important;
  border:0!important;border-radius:999px!important;
  display:inline-flex!important;align-items:center!important;justify-content:center!important;
  gap:9px!important;
  background:#d7ae2e!important;color:#111!important;
  font:inherit!important;font-size:14px!important;font-weight:900!important;
  cursor:pointer!important;direction:rtl!important;
  box-shadow:0 10px 28px rgba(215,174,46,.16)!important;
}
.h67-auth:hover{background:#e0b93a!important;transform:none!important}

@media(max-width:1100px){
  .h67-navbar{width:calc(100% - 32px)!important}
  .h67-nav{gap:22px!important}
  .h67-nav-link{font-size:13px!important}
  .h67-logo{width:104px!important}.h67-logo img{width:100px!important}
  .h67-auth{min-width:46px!important;width:46px!important;padding:0!important}.h67-auth span{display:none!important}
}
@media(max-width:820px){
  .h67-header{height:76px!important}
  .h67-navbar{width:calc(100% - 24px)!important}
  .h67-nav{display:none!important}
  .h67-logo{top:6px!important;width:82px!important;height:64px!important}.h67-logo img{width:78px!important;max-height:62px!important}
  .h67-icon-btn,.h67-auth{width:40px!important;height:40px!important;min-width:40px!important}
  .h67-actions{gap:7px!important}
}
CSS

python3 - "$HP_CSS" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
for marker in ('67_HERO_PERFECT_V2','67_HERO_REFERENCE_LOCK_V3'):
    s=re.sub(r'\n?/\* '+marker+r'_START \*/.*?/\* '+marker+r'_END \*/\n?','\n',s,flags=re.S)
block=r'''
/* 67_HERO_REFERENCE_LOCK_V3_START */
.home67-page{background:#080808!important}
.home67-hero{
  position:relative!important;
  isolation:isolate!important;
  overflow:hidden!important;
  width:100%!important;
  height:100vh!important;
  min-height:820px!important;
  max-height:none!important;
  margin:0!important;padding:0!important;
  display:block!important;
  color:#fff!important;
  background-color:#080808!important;
  background-image:url('/assets/hero-car.jpg')!important;
  background-repeat:no-repeat!important;
  background-size:cover!important;
  background-position:center center!important;
}
.home67-hero::before{
  content:''!important;
  position:absolute!important;inset:0!important;
  z-index:0!important;pointer-events:none!important;
  background:
    linear-gradient(90deg,
      rgba(0,0,0,.03) 0%,
      rgba(0,0,0,.08) 31%,
      rgba(0,0,0,.27) 49%,
      rgba(0,0,0,.66) 67%,
      rgba(0,0,0,.91) 83%,
      rgba(0,0,0,.97) 100%),
    linear-gradient(180deg,rgba(0,0,0,.06) 0%,rgba(0,0,0,.10) 58%,rgba(0,0,0,.35) 100%)!important;
}
.home67-hero::after{display:none!important;content:none!important}
.home67-hero>*{position:relative;z-index:2}
.home67-hero .home67-hero-overlay{position:absolute!important;inset:0!important;background:transparent!important;opacity:1!important;pointer-events:none!important}
.home67-hero .home67-hero-car,
.home67-hero .home67-hero-media,
.home67-hero img.home67-hero-car,
.home67-hero picture.home67-hero-car{display:none!important}

.home67-hero-shell,.home67-hero-content{
  position:static!important;
  width:100%!important;max-width:none!important;height:100%!important;
  margin:0!important;padding:0!important;
  display:block!important;
  box-sizing:border-box!important;
}
.home67-hero-copy{
  position:absolute!important;
  z-index:4!important;
  top:clamp(132px,16vh,148px)!important;
  right:max(34px,calc((100vw - 1500px)/2))!important;
  width:620px!important;
  max-width:42vw!important;
  margin:0!important;padding:0!important;
  text-align:right!important;
  direction:rtl!important;
  color:#fff!important;
  transform:none!important;
}
.home67-hero-kicker,.home67-hero-eyebrow,.home67-eyebrow{
  display:flex!important;
  align-items:center!important;
  justify-content:flex-start!important;
  gap:14px!important;
  width:max-content!important;
  max-width:100%!important;
  margin:0 0 33px auto!important;
  color:#d7ae2e!important;
  font-size:14px!important;font-weight:900!important;line-height:1!important;
  direction:rtl!important;
}
.home67-hero-kicker::before,.home67-hero-eyebrow::before,.home67-eyebrow::before{
  content:''!important;
  display:block!important;
  width:42px!important;height:2px!important;
  flex:0 0 42px!important;
  border-radius:99px!important;
  background:#d7ae2e!important;
}
.home67-hero-kicker::after,.home67-hero-eyebrow::after,.home67-eyebrow::after{display:none!important;content:none!important}

.home67-hero-copy h1{
  width:100%!important;
  margin:0!important;padding:0!important;
  color:#fff!important;
  font-size:clamp(62px,4.25vw,80px)!important;
  font-weight:950!important;
  line-height:1.18!important;
  letter-spacing:-1.8px!important;
  text-align:right!important;
}
.home67-hero-copy h1 span,
.home67-hero-copy .home67-hero-highlight,
.home67-hero-copy .home67-gold{
  display:block!important;
  margin-top:16px!important;
  color:#d7ae2e!important;
  font-size:.86em!important;
  line-height:1.13!important;
  white-space:nowrap!important;
}
.home67-hero-copy p,.home67-hero-description{
  width:100%!important;max-width:590px!important;
  margin:29px 0 0 auto!important;
  color:rgba(255,255,255,.75)!important;
  font-size:16px!important;font-weight:450!important;line-height:2!important;
  text-align:right!important;
}
.home67-hero-actions,.home67-hero-buttons{
  width:100%!important;
  margin:31px 0 0!important;
  display:flex!important;
  flex-direction:row!important;
  flex-wrap:nowrap!important;
  align-items:center!important;
  justify-content:flex-start!important;
  gap:13px!important;
  direction:rtl!important;
}
.home67-hero-actions button,.home67-hero-actions a,.home67-hero-buttons button,.home67-hero-buttons a{
  width:auto!important;min-width:184px!important;height:58px!important;min-height:58px!important;
  padding:0 26px!important;margin:0!important;
  border-radius:30px!important;
  display:inline-flex!important;align-items:center!important;justify-content:center!important;
  flex:0 0 auto!important;
  font-size:14px!important;font-weight:900!important;line-height:1!important;
}
.home67-hero-actions .home67-primary,.home67-hero-actions .home67-btn-primary,.home67-hero-buttons .home67-primary,.home67-hero-buttons .home67-btn-primary{
  background:#d7ae2e!important;color:#111!important;border:1px solid #d7ae2e!important;
  box-shadow:0 12px 32px rgba(215,174,46,.18)!important;
}
.home67-hero-actions .home67-secondary,.home67-hero-actions .home67-btn-secondary,.home67-hero-buttons .home67-secondary,.home67-hero-buttons .home67-btn-secondary{
  background:rgba(7,7,7,.34)!important;color:#fff!important;
  border:1px solid rgba(255,255,255,.34)!important;
  backdrop-filter:blur(5px)!important;-webkit-backdrop-filter:blur(5px)!important;
}
.home67-hero-trust{
  width:max-content!important;max-width:100%!important;
  margin:39px 0 0 auto!important;
  padding:0 17px 0 0!important;
  border-right:3px solid #d7ae2e!important;
  display:block!important;
  text-align:right!important;
  direction:rtl!important;
}
.home67-hero-trust::before,.home67-hero-trust::after{display:none!important;content:none!important}
.home67-hero-trust strong,.home67-hero-trust b{display:block!important;color:#fff!important;font-size:14px!important;font-weight:900!important;margin-bottom:7px!important}
.home67-hero-trust span,.home67-hero-trust p{color:rgba(255,255,255,.58)!important;font-size:12px!important;line-height:1.6!important;margin:0!important}

/* The approved desktop reference has no floating BottomNav over the hero. */
@media(min-width:821px){.home67-page .bottom-nav{display:none!important}}

@media(max-width:1280px) and (min-width:821px){
  .home67-hero-copy{right:48px!important;width:560px!important;max-width:46vw!important;top:132px!important}
  .home67-hero-copy h1{font-size:clamp(54px,5vw,67px)!important}
  .home67-hero-copy h1 span{font-size:.86em!important}
}
@media(max-width:820px){
  .home67-hero{height:auto!important;min-height:760px!important;background-position:38% center!important}
  .home67-hero::before{background:linear-gradient(180deg,rgba(0,0,0,.42) 0%,rgba(0,0,0,.69) 52%,rgba(0,0,0,.93) 100%)!important}
  .home67-hero-copy{
    position:relative!important;
    top:auto!important;right:auto!important;
    width:100%!important;max-width:none!important;
    min-height:760px!important;
    margin:0!important;padding:118px 22px 104px!important;
    display:flex!important;flex-direction:column!important;justify-content:flex-end!important;
    box-sizing:border-box!important;
  }
  .home67-hero-kicker,.home67-hero-eyebrow,.home67-eyebrow{margin:0 0 22px auto!important}
  .home67-hero-copy h1{font-size:clamp(42px,12vw,60px)!important;letter-spacing:-1px!important}
  .home67-hero-copy h1 span{white-space:normal!important;margin-top:10px!important}
  .home67-hero-copy p,.home67-hero-description{font-size:14px!important;line-height:1.85!important;margin-top:20px!important}
  .home67-hero-actions,.home67-hero-buttons{margin-top:24px!important;gap:10px!important;flex-wrap:wrap!important}
  .home67-hero-actions button,.home67-hero-actions a,.home67-hero-buttons button,.home67-hero-buttons a{min-width:0!important;flex:1 1 160px!important;height:52px!important;min-height:52px!important}
  .home67-hero-trust{margin-top:28px!important}
}
/* 67_HERO_REFERENCE_LOCK_V3_END */
'''
s=s.rstrip()+"\n"+block+"\n"
p.write_text(s,encoding='utf-8')
PY

echo "REFERENCE_LOCK_V3_APPLIED"
echo "Changed only:"
echo "- src/components/HomeStoreHeader.css"
echo "- src/pages/HomePage.css"
echo "No JSX, routes, backend, database, env, admin, seller, checkout or payment files were modified."
