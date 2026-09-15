#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
HP_CSS="$ROOT/src/pages/HomePage.css"
HDR_JSX="$ROOT/src/components/HomeStoreHeader.jsx"
HDR_CSS="$ROOT/src/components/HomeStoreHeader.css"
ASSET_DIR="$ROOT/public/assets"
BACKUP="/tmp/67-home-hero-perfect-v2-backup-$(date +%Y%m%d-%H%M%S)"

for f in "$HP_CSS" "$HDR_JSX" "$HDR_CSS"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 20
  fi
done

find_asset() {
  local name="$1" minbytes="$2"
  python3 - "$name" "$minbytes" <<'PY'
import os, sys
name=sys.argv[1]; minbytes=int(sys.argv[2])
roots=['/67','/tmp']
items=[]
for root in roots:
    if not os.path.isdir(root): continue
    for dp, dns, fns in os.walk(root):
        dns[:] = [d for d in dns if d not in {'node_modules','.git','dist','build'}]
        if name in fns:
            p=os.path.join(dp,name)
            try: s=os.path.getsize(p)
            except OSError: continue
            if s >= minbytes: items.append((s,p))
items.sort(reverse=True)
if items: print(items[0][1])
PY
}

HERO_SRC="$(find_asset hero-car.jpg 100000 || true)"
LOGO_SRC="$(find_asset logo-67.png 20000 || true)"

if [ -z "$HERO_SRC" ]; then
  echo "ERROR: no trustworthy hero-car.jpg (>=100 KB) found under /67 or /tmp. STOPPING before modifications." >&2
  exit 21
fi
if [ -z "$LOGO_SRC" ]; then
  echo "ERROR: no trustworthy logo-67.png (>=20 KB) found under /67 or /tmp. STOPPING before modifications." >&2
  exit 22
fi

echo "Using hero: $HERO_SRC ($(stat -c%s "$HERO_SRC") bytes)"
echo "Using logo: $LOGO_SRC ($(stat -c%s "$LOGO_SRC") bytes)"

mkdir -p "$BACKUP/src/pages" "$BACKUP/src/components" "$BACKUP/public/assets" "$ASSET_DIR"
cp -a "$HP_CSS" "$BACKUP/src/pages/HomePage.css"
cp -a "$HDR_JSX" "$BACKUP/src/components/HomeStoreHeader.jsx"
cp -a "$HDR_CSS" "$BACKUP/src/components/HomeStoreHeader.css"
[ -f "$ASSET_DIR/hero-car.jpg" ] && cp -a "$ASSET_DIR/hero-car.jpg" "$BACKUP/public/assets/hero-car.jpg" || true
[ -f "$ASSET_DIR/logo-67.png" ] && cp -a "$ASSET_DIR/logo-67.png" "$BACKUP/public/assets/logo-67.png" || true

cp -f "$HERO_SRC" "$ASSET_DIR/hero-car.jpg"
cp -f "$LOGO_SRC" "$ASSET_DIR/logo-67.png"

cat > "$HDR_JSX" <<'JSX'
import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Bell, LogIn, LogOut, Search } from 'lucide-react';
import './HomeStoreHeader.css';

const NAV_ITEMS = [
  { label: 'الرئيسية', path: '/store' },
  { label: 'قطع الغيار', path: '/top-parts' },
  { label: 'طلباتي', path: '/orders' },
  { label: 'السلة', path: '/cart', badge: 2 },
  { label: 'حسابي', path: '/profile' },
];

export default function HomeStoreHeader() {
  const navigate = useNavigate();
  const location = useLocation();
  const [loggedIn, setLoggedIn] = useState(() => Boolean(localStorage.getItem('customerSession')));
  const go = (path) => navigate(path);
  const handleAuth = () => {
    if (!loggedIn) { navigate('/login'); return; }
    localStorage.removeItem('customerSession');
    localStorage.removeItem('userToken');
    setLoggedIn(false);
    navigate('/');
  };
  return (
    <header className="h67-header" dir="rtl">
      <div className="h67-navbar">
        <button className="h67-logo" type="button" onClick={() => go('/store')} aria-label="67 الرئيسية">
          <img src="/assets/logo-67.png" alt="67 Six Seven" />
        </button>
        <nav className="h67-nav" aria-label="التنقل الرئيسي">
          {NAV_ITEMS.map((item) => {
            const active = item.path === '/store' ? location.pathname === '/store' || location.pathname === '/' : location.pathname === item.path;
            return (
              <button key={item.path} type="button" className={`h67-nav-link${active ? ' is-active' : ''}`} onClick={() => go(item.path)}>
                <span>{item.label}</span>
                {item.badge ? <b className="h67-cart-badge">{item.badge}</b> : null}
              </button>
            );
          })}
        </nav>
        <div className="h67-actions">
          <button type="button" className="h67-auth" onClick={handleAuth}>
            {loggedIn ? <LogOut size={17} /> : <LogIn size={17} />}
            <span>{loggedIn ? 'تسجيل الخروج' : 'دخول'}</span>
          </button>
          <button type="button" className="h67-icon-btn" onClick={() => go('/notifications')} aria-label="الإشعارات">
            <Bell size={20} /><span className="h67-notice-dot" aria-hidden="true" />
          </button>
          <button type="button" className="h67-icon-btn" onClick={() => go('/search')} aria-label="بحث"><Search size={20} /></button>
        </div>
      </div>
    </header>
  );
}
JSX

cat > "$HDR_CSS" <<'CSS'
.h67-header{position:absolute;inset:0 0 auto 0;z-index:80;height:100px;color:#fff;border-bottom:1px solid rgba(255,255,255,.13);background:linear-gradient(to bottom,rgba(0,0,0,.57),rgba(0,0,0,.03));backdrop-filter:blur(4px);-webkit-backdrop-filter:blur(4px)}
.h67-navbar{width:min(1460px,calc(100% - 64px));height:100%;margin:0 auto;display:grid;grid-template-columns:auto 1fr 150px;align-items:center;column-gap:38px;direction:ltr}
.h67-logo{grid-column:3;justify-self:end;border:0;padding:0;margin:0;background:transparent;cursor:pointer;width:118px;height:82px;display:flex;align-items:center;justify-content:flex-end}
.h67-logo img{width:112px;height:auto;max-height:78px;object-fit:contain;display:block}
.h67-nav{grid-column:2;justify-self:center;display:flex;align-items:center;gap:34px;direction:rtl}
.h67-nav-link{position:relative;border:0;padding:9px 0;margin:0;background:transparent;color:rgba(255,255,255,.76);font:inherit;font-size:15px;font-weight:650;line-height:1;cursor:pointer;white-space:nowrap;transition:color .2s ease}
.h67-nav-link:hover,.h67-nav-link.is-active{color:#fff}
.h67-nav-link.is-active::after{content:'';position:absolute;right:50%;bottom:-11px;width:28px;height:2px;border-radius:99px;background:#d5ad2d;transform:translateX(50%)}
.h67-cart-badge{position:absolute;top:-8px;right:-13px;width:18px;height:18px;border-radius:50%;display:grid;place-items:center;background:#ef4b52;color:#fff;font-size:10px;font-weight:800;box-shadow:0 0 0 2px rgba(5,5,5,.65)}
.h67-actions{grid-column:1;justify-self:start;display:flex;align-items:center;gap:10px;direction:ltr}
.h67-icon-btn{position:relative;width:46px;height:46px;border-radius:50%;display:grid;place-items:center;padding:0;color:#fff;background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.23);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);cursor:pointer;transition:.2s ease}
.h67-icon-btn:hover{color:#111;background:#d5ad2d;border-color:#d5ad2d}.h67-notice-dot{position:absolute;top:5px;right:5px;width:7px;height:7px;border-radius:50%;background:#ef4b52;box-shadow:0 0 0 2px rgba(8,8,8,.8)}
.h67-auth{min-width:142px;height:48px;padding:0 20px;border:0;border-radius:999px;display:inline-flex;align-items:center;justify-content:center;gap:9px;background:#d5ad2d;color:#111;font:inherit;font-size:14px;font-weight:800;cursor:pointer;box-shadow:0 10px 30px rgba(213,173,45,.18);transition:.2s ease;direction:rtl}.h67-auth:hover{transform:translateY(-2px);background:#e2bc3b}
@media(max-width:1020px){.h67-navbar{width:min(100% - 32px,960px);grid-template-columns:auto 1fr 105px;column-gap:18px}.h67-nav{gap:20px}.h67-nav-link{font-size:13px}.h67-logo,.h67-logo img{width:96px}.h67-auth{min-width:46px;width:46px;padding:0}.h67-auth span{display:none}}
@media(max-width:760px){.h67-header{height:76px}.h67-navbar{width:calc(100% - 24px);grid-template-columns:auto 1fr 82px}.h67-nav{display:none}.h67-logo,.h67-logo img{width:78px;max-height:62px}.h67-icon-btn,.h67-auth{width:40px;height:40px;min-width:40px}.h67-actions{gap:7px}}
CSS

python3 - "$HP_CSS" <<'PY'
from pathlib import Path
import re, sys
p=Path(sys.argv[1]); s=p.read_text(encoding='utf-8')
s=re.sub(r'\n?/\* 67_HERO_PERFECT_V2_START \*/.*?/\* 67_HERO_PERFECT_V2_END \*/\n?','\n',s,flags=re.S)
block=r'''
/* 67_HERO_PERFECT_V2_START */
.home67-page{background:#080808!important}
.home67-hero{position:relative!important;isolation:isolate!important;overflow:hidden!important;height:100vh!important;min-height:720px!important;max-height:940px!important;margin:0!important;padding:0!important;display:flex!important;align-items:center!important;color:#fff!important;background-color:#080808!important;background-image:url('/assets/hero-car.jpg')!important;background-repeat:no-repeat!important;background-size:cover!important;background-position:center center!important}
.home67-hero::before{content:''!important;position:absolute!important;inset:0!important;z-index:0!important;pointer-events:none!important;background:linear-gradient(90deg,rgba(0,0,0,.10) 0%,rgba(0,0,0,.23) 36%,rgba(0,0,0,.72) 70%,rgba(0,0,0,.95) 100%),linear-gradient(180deg,rgba(0,0,0,.06),rgba(0,0,0,.43))!important}
.home67-hero::after{content:''!important;position:absolute!important;inset:0!important;z-index:1!important;pointer-events:none!important;opacity:.045!important;background-image:linear-gradient(rgba(255,255,255,.1) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.1) 1px,transparent 1px)!important;background-size:70px 70px!important;-webkit-mask-image:linear-gradient(to left,#000,transparent 68%);mask-image:linear-gradient(to left,#000,transparent 68%)}
.home67-hero>*{position:relative;z-index:2}.home67-hero .home67-hero-overlay{background:transparent!important;opacity:1!important}.home67-hero .home67-hero-car,.home67-hero .home67-hero-media,.home67-hero img.home67-hero-car,.home67-hero picture.home67-hero-car{display:none!important}
.home67-hero-shell,.home67-hero-content{width:min(1460px,calc(100% - 64px))!important;max-width:none!important;height:100%!important;margin:0 auto!important;padding:126px 0 66px!important;display:flex!important;grid-template-columns:none!important;align-items:center!important;justify-content:flex-end!important;direction:ltr!important;box-sizing:border-box!important}
.home67-hero-copy{width:610px!important;max-width:42%!important;margin:0!important;padding:0!important;align-self:center!important;text-align:right!important;direction:rtl!important;color:#fff!important;transform:none!important}
.home67-hero-copy h1{margin:0!important;color:#fff!important;font-size:clamp(52px,5.35vw,82px)!important;line-height:1.08!important;letter-spacing:-2px!important;font-weight:900!important;text-align:right!important}.home67-hero-copy h1 span,.home67-hero-copy .home67-hero-highlight,.home67-hero-copy .home67-gold{color:#d5ad2d!important;display:block!important;margin-top:7px!important}
.home67-hero-copy p,.home67-hero-description{width:520px!important;max-width:100%!important;margin:24px 0 0!important;color:rgba(255,255,255,.74)!important;font-size:16px!important;line-height:1.95!important;text-align:right!important}.home67-hero-kicker,.home67-hero-eyebrow,.home67-eyebrow{color:#d5ad2d!important;font-size:14px!important;font-weight:800!important;margin-bottom:24px!important}
.home67-hero-actions,.home67-hero-buttons{width:auto!important;margin-top:34px!important;display:flex!important;flex-direction:row!important;flex-wrap:nowrap!important;align-items:center!important;justify-content:flex-start!important;gap:13px!important}.home67-hero-actions button,.home67-hero-actions a,.home67-hero-buttons button,.home67-hero-buttons a{width:auto!important;min-width:170px!important;min-height:54px!important;padding:0 24px!important;border-radius:30px!important;font-size:14px!important;font-weight:800!important;flex:0 0 auto!important}
.home67-hero-actions .home67-primary,.home67-hero-actions .home67-btn-primary,.home67-hero-buttons .home67-primary,.home67-hero-buttons .home67-btn-primary{background:#d5ad2d!important;color:#111!important;border-color:#d5ad2d!important;box-shadow:0 14px 35px rgba(213,173,45,.22)!important}.home67-hero-actions .home67-secondary,.home67-hero-actions .home67-btn-secondary,.home67-hero-buttons .home67-secondary,.home67-hero-buttons .home67-btn-secondary{background:rgba(255,255,255,.055)!important;color:#fff!important;border:1px solid rgba(255,255,255,.32)!important;backdrop-filter:blur(8px)!important}
.home67-hero-trust{width:auto!important;margin-top:38px!important;display:flex!important;align-items:center!important;gap:14px!important;text-align:right!important}.home67-hero-trust::before{content:''!important;width:3px!important;height:44px!important;flex:0 0 3px!important;border-radius:20px!important;background:#d5ad2d!important}
@media(max-width:1100px){.home67-hero-shell,.home67-hero-content{width:calc(100% - 40px)!important}.home67-hero-copy{max-width:48%!important}.home67-hero-copy h1{font-size:clamp(46px,6vw,66px)!important}}
@media(max-width:820px){.home67-hero{min-height:760px!important;height:auto!important;background-position:38% center!important}.home67-hero::before{background:linear-gradient(180deg,rgba(0,0,0,.58) 0%,rgba(0,0,0,.76) 55%,rgba(0,0,0,.92) 100%)!important}.home67-hero-shell,.home67-hero-content{width:calc(100% - 32px)!important;min-height:760px!important;padding:116px 0 92px!important;align-items:flex-end!important;justify-content:flex-start!important;direction:rtl!important}.home67-hero-copy{width:100%!important;max-width:100%!important}.home67-hero-copy h1{font-size:clamp(43px,11vw,62px)!important}.home67-hero-actions,.home67-hero-buttons{flex-wrap:wrap!important}}
@media(max-width:520px){.home67-hero{min-height:700px!important;background-position:35% center!important}.home67-hero-shell,.home67-hero-content{min-height:700px!important;padding-top:105px!important}.home67-hero-copy h1{font-size:43px!important;letter-spacing:-1px!important}.home67-hero-copy p,.home67-hero-description{font-size:14px!important}.home67-hero-actions,.home67-hero-buttons{display:grid!important;grid-template-columns:1fr 1fr!important;width:100%!important;gap:9px!important}.home67-hero-actions button,.home67-hero-actions a,.home67-hero-buttons button,.home67-hero-buttons a{min-width:0!important;width:100%!important;padding:0 12px!important}}
/* 67_HERO_PERFECT_V2_END */
'''
p.write_text(s.rstrip()+"\n\n"+block.strip()+"\n",encoding='utf-8')
PY

echo "HOTFIX_APPLIED"
echo "Backup: $BACKUP"
echo "Hero installed: $ASSET_DIR/hero-car.jpg ($(stat -c%s "$ASSET_DIR/hero-car.jpg") bytes)"
echo "Logo installed: $ASSET_DIR/logo-67.png ($(stat -c%s "$ASSET_DIR/logo-67.png") bytes)"
