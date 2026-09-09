#!/usr/bin/env python3
from pathlib import Path
import hashlib
import re

ROOT = Path('/67')
JSX = ROOT / 'src/pages/AdminDashboard.jsx'
CSS9 = ROOT / 'src/pages/AdminDashboard.v9.css'
CSS11 = ROOT / 'src/pages/AdminDashboard.v11.css'
BASE_COMMIT = 'b90c537d905559a3dbbf146e0c0b7e1ceb667778'
EXPECTED_JSX = '47f3d1daf40d98329d0848b2628b01728e5cec85'
EXPECTED_CSS9 = '817469d19bcb46e2dfdce94b96a1bbe490c6b9c3'

def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

def require_blob(path: Path, expected: str):
    actual = git_blob_sha(path.read_bytes())
    if actual != expected:
        raise SystemExit(f'BASE_MISMATCH:{path}:{actual}:expected:{expected}')

require_blob(JSX, EXPECTED_JSX)
require_blob(CSS9, EXPECTED_CSS9)

jsx = JSX.read_text()
if "import './AdminDashboard.v11.css';" in jsx:
    raise SystemExit('V11_ALREADY_PRESENT')
jsx = jsx.replace("import './AdminDashboard.v9.css';", "import './AdminDashboard.v9.css';\nimport './AdminDashboard.v11.css';", 1)

hero_svg = r'''<svg className="v11-hero-scene" viewBox="0 0 1200 260" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
<defs>
  <linearGradient id="v11Sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor="#020509"/><stop offset="0.56" stopColor="#0a111a"/><stop offset="1" stopColor="#151009"/></linearGradient>
  <radialGradient id="v11Horizon" cx="0.56" cy="0.62" r="0.52"><stop offset="0" stopColor="#d0a34d" stopOpacity="0.28"/><stop offset="0.45" stopColor="#8a6225" stopOpacity="0.08"/><stop offset="1" stopColor="#020509" stopOpacity="0"/></radialGradient>
  <linearGradient id="v11Road" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor="#111217"/><stop offset="1" stopColor="#030405"/></linearGradient>
  <linearGradient id="v11Car" x1="0" y1="0" x2="0.2" y2="1"><stop offset="0" stopColor="#34363a"/><stop offset="0.23" stopColor="#141619"/><stop offset="0.66" stopColor="#08090a"/><stop offset="1" stopColor="#020303"/></linearGradient>
  <linearGradient id="v11Glass" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#283545"/><stop offset="0.52" stopColor="#101923"/><stop offset="1" stopColor="#05090d"/></linearGradient>
  <linearGradient id="v11Chrome" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stopColor="#76521c" stopOpacity="0"/><stop offset="0.5" stopColor="#e4c16e" stopOpacity="0.76"/><stop offset="1" stopColor="#76521c" stopOpacity="0"/></linearGradient>
  <filter id="v11Soft"><feGaussianBlur stdDeviation="7"/></filter>
  <filter id="v11Glow"><feGaussianBlur stdDeviation="2.4" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
</defs>
<rect width="1200" height="260" fill="url(#v11Sky)"/>
<rect width="1200" height="260" fill="url(#v11Horizon)"/>
<!-- warm atmospheric glow -->
<ellipse cx="670" cy="158" rx="330" ry="75" fill="#c79b45" opacity="0.045" filter="url(#v11Soft)"/>
<!-- Riyadh skyline kept above the car, readable at dashboard scale -->
<g opacity="0.82">
  <path d="M635 160V66 Q650 37 665 66V160Z" fill="#060b11" stroke="#c89b43" strokeWidth="1.2"/>
  <path d="M642 69 Q650 52 658 69" fill="none" stroke="#e0b85f" strokeWidth="1.3" opacity="0.9"/>
  <rect x="688" y="94" width="30" height="66" rx="2" fill="#080d13"/>
  <path d="M704 94L708 73L712 94Z" fill="#101721" stroke="#b88934" strokeWidth="0.7"/>
  <rect x="566" y="111" width="24" height="49" rx="2" fill="#070c12"/>
  <rect x="594" y="89" width="29" height="71" rx="2" fill="#080e15"/>
  <rect x="728" y="116" width="22" height="44" rx="2" fill="#070b11"/>
  <rect x="754" y="101" width="26" height="59" rx="2" fill="#080d13"/>
  <rect x="785" y="124" width="18" height="36" rx="2" fill="#060a0f"/>
  <g fill="#dcb55e" opacity="0.48">
    <circle cx="603" cy="104" r="1.5"/><circle cx="603" cy="119" r="1.5"/><circle cx="603" cy="135" r="1.5"/>
    <circle cx="699" cy="109" r="1.5"/><circle cx="708" cy="123" r="1.5"/><circle cx="699" cy="139" r="1.5"/>
    <circle cx="763" cy="115" r="1.5"/><circle cx="770" cy="132" r="1.5"/>
  </g>
</g>
<!-- palms -->
<g strokeLinecap="round" fill="none">
  <g transform="translate(515 111)" opacity="0.55"><path d="M0 51Q3 25 2 0" stroke="#8d7345" strokeWidth="3"/><path d="M2 3Q-22-7-37 5M2 3Q-16-19-29-12M2 3Q18-18 32-10M2 3Q24-5 39 8" stroke="#667845" strokeWidth="2"/></g>
  <g transform="translate(836 118)" opacity="0.44"><path d="M0 42Q2 21 1 0" stroke="#8d7345" strokeWidth="2.5"/><path d="M1 2Q-18-7-30 4M1 2Q-13-16-24-10M1 2Q15-16 27-8M1 2Q20-4 33 7" stroke="#667845" strokeWidth="1.7"/></g>
</g>
<!-- road -->
<path d="M0 168H1200V260H0Z" fill="url(#v11Road)"/>
<path d="M0 169H1200" stroke="#d1a44d" strokeWidth="1.3" opacity="0.24"/>
<path d="M150 225L480 212M760 212L1080 225" stroke="#d4b163" strokeWidth="1.3" opacity="0.16"/>
<ellipse cx="465" cy="225" rx="255" ry="21" fill="#000" opacity="0.58" filter="url(#v11Soft)"/>
<!-- luxury sedan: intentionally smaller than V10 and placed away from title -->
<g transform="translate(205 111)">
  <path d="M40 65Q72 35 128 28L303 23Q363 26 397 52L431 73Q443 82 438 94L418 101H377Q366 80 342 80Q316 80 305 101H157Q145 80 120 80Q95 80 83 101H42Q22 97 19 86Q18 75 40 65Z" fill="url(#v11Car)" stroke="#393a3c" strokeWidth="0.8"/>
  <path d="M132 31L292 27Q338 30 370 54L375 63L107 63Q112 43 132 31Z" fill="url(#v11Glass)" stroke="#45484d" strokeWidth="0.7"/>
  <path d="M151 34L219 31L215 59H121Q128 41 151 34ZM229 31L286 30Q323 32 350 55L353 59H225Z" fill="#0b1118" opacity="0.88"/>
  <path d="M45 68Q177 62 417 69" fill="none" stroke="url(#v11Chrome)" strokeWidth="1.6"/>
  <path d="M71 77Q205 72 393 76" fill="none" stroke="#fff" strokeOpacity="0.045" strokeWidth="2"/>
  <ellipse cx="421" cy="76" rx="13" ry="5" fill="#fff1c1" opacity="0.88" filter="url(#v11Glow)"/>
  <path d="M25 75h23v9H29Q24 82 25 75Z" fill="#b80e17" opacity="0.85"/>
  <g><circle cx="120" cy="96" r="22" fill="#020303" stroke="#22262a" strokeWidth="2"/><circle cx="120" cy="96" r="13" fill="#0b0d0f" stroke="#8d7138" strokeWidth="1"/><circle cx="120" cy="96" r="4" fill="#353535"/><circle cx="342" cy="96" r="22" fill="#020303" stroke="#22262a" strokeWidth="2"/><circle cx="342" cy="96" r="13" fill="#0b0d0f" stroke="#8d7138" strokeWidth="1"/><circle cx="342" cy="96" r="4" fill="#353535"/></g>
</g>
<!-- controlled official-logo red sweep -->
<path d="M125 213Q350 191 596 205Q816 218 1038 193" fill="none" stroke="#d71920" strokeWidth="2.6" opacity="0.48" strokeLinecap="round"/>
<path d="M150 218Q370 201 590 211Q790 221 1002 202" fill="none" stroke="#d71920" strokeWidth="0.8" opacity="0.22" strokeLinecap="round"/>
</svg>'''

hero_pattern = r'(<div className="ov-header__motif" aria-hidden="true">\s*)<svg.*?</svg>'
jsx, count = re.subn(hero_pattern, lambda m: m.group(1) + hero_svg, jsx, count=1, flags=re.S)
if count != 1:
    raise SystemExit(f'HERO_SVG_REPLACE_FAILED:{count}')

health_svg = r'''<svg className="v11-health-scene" viewBox="0 0 360 150" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
<defs>
  <linearGradient id="v11hSky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor="#101a26"/><stop offset="1" stopColor="#05090e"/></linearGradient>
  <linearGradient id="v11hCar" x1="0" y1="0" x2="0.3" y2="1"><stop offset="0" stopColor="#282a2d"/><stop offset="0.55" stopColor="#0c0e10"/><stop offset="1" stopColor="#030404"/></linearGradient>
  <radialGradient id="v11hGlow" cx="0.53" cy="0.68" r="0.5"><stop offset="0" stopColor="#d0a34d" stopOpacity="0.2"/><stop offset="1" stopColor="#d0a34d" stopOpacity="0"/></radialGradient>
</defs>
<rect width="360" height="150" fill="url(#v11hSky)"/>
<rect width="360" height="150" fill="url(#v11hGlow)"/>
<g opacity="0.34" fill="#060b10" stroke="#a67c34" strokeWidth="0.45"><path d="M277 106V42Q287 24 297 42V106Z"/><rect x="307" y="63" width="16" height="43"/><rect x="329" y="76" width="12" height="30"/></g>
<path d="M0 111H360V150H0Z" fill="#05070a"/><path d="M12 112H348" stroke="#c69a42" strokeWidth="0.7" opacity="0.25"/>
<ellipse cx="176" cy="126" rx="122" ry="10" fill="#000" opacity="0.55"/>
<g transform="translate(48 52)">
  <path d="M24 46Q45 25 80 20L190 18Q224 22 246 42L265 55Q271 62 266 69H240Q232 55 218 55Q201 55 193 70H91Q82 55 67 55Q50 55 42 70H20Q10 66 12 57Q13 51 24 46Z" fill="url(#v11hCar)" stroke="#383b3e" strokeWidth="0.65"/>
  <path d="M84 23L184 21Q213 24 231 43L69 44Q74 29 84 23Z" fill="#0d1721" stroke="#3b4148" strokeWidth="0.5"/>
  <path d="M30 49Q112 45 251 49" stroke="#d1aa58" strokeWidth="0.8" opacity="0.43" fill="none"/>
  <ellipse cx="254" cy="53" rx="9" ry="4" fill="#fff0b8" opacity="0.74"/><rect x="14" y="50" width="13" height="6" rx="2" fill="#c5141b" opacity="0.78"/>
  <circle cx="67" cy="68" r="14" fill="#030404" stroke="#24282d"/><circle cx="67" cy="68" r="8" fill="#101215" stroke="#8b7036" strokeWidth="0.7"/><circle cx="218" cy="68" r="14" fill="#030404" stroke="#24282d"/><circle cx="218" cy="68" r="8" fill="#101215" stroke="#8b7036" strokeWidth="0.7"/>
</g>
<path d="M31 135Q128 125 214 132Q279 137 340 128" stroke="#d71920" strokeWidth="1.25" fill="none" opacity="0.34"/>
</svg>'''

health_pattern = r'(<div className="syshealth__center-scene" aria-hidden="true">\s*)<svg.*?</svg>'
jsx, count = re.subn(health_pattern, lambda m: m.group(1) + health_svg, jsx, count=1, flags=re.S)
if count != 1:
    raise SystemExit(f'HEALTH_SVG_REPLACE_FAILED:{count}')

css11 = r'''/* SIX SEVEN ADMIN V11 — OFFICIAL REFERENCE HERO / HEALTH LOCK */
.ov-header{
  height:190px!important;min-height:190px!important;
  background:linear-gradient(180deg,#020509 0%,#080d14 56%,#050608 100%)!important;
  border-color:rgba(215,173,81,.34)!important;
  box-shadow:0 18px 42px rgba(0,0,0,.22)!important;
}
.ov-header::before{height:3px!important;opacity:.86!important;background:linear-gradient(90deg,transparent 2%,#d71920 26%,#d71920 71%,transparent 98%)!important}
.ov-header__motif{inset:0!important;z-index:1!important}
.ov-header__motif::after{background:linear-gradient(90deg,rgba(2,5,9,.52) 0%,rgba(2,5,9,.06) 24%,rgba(2,5,9,.02) 60%,rgba(2,5,9,.58) 83%,rgba(2,5,9,.88) 100%),linear-gradient(180deg,rgba(0,0,0,.04),transparent 55%,rgba(0,0,0,.19))!important;z-index:2}
.ov-header .v11-hero-scene{position:absolute!important;inset:0!important;width:100%!important;height:100%!important;transform:none!important;filter:none!important;opacity:1!important;visibility:visible!important;display:block!important}
.ov-header__layout{grid-template-columns:29% 43% 28%!important;z-index:4!important}
.ov-header [class*="zone-left"]{z-index:6!important;padding:0 0 15px 18px!important}
.ov-header [class*="zone-right"]{z-index:6!important;padding:16px 26px 16px 10px!important;background:linear-gradient(90deg,transparent 0%,rgba(3,6,10,.28) 25%,rgba(3,6,10,.83) 100%)!important}
.ov-header h1{font-size:29px!important;letter-spacing:-.025em!important;margin-bottom:6px!important}
.ov-header h1+p{font-size:11.8px!important;max-width:410px!important;color:rgba(255,255,255,.78)!important}
.ov-header__subtitle-saudi{color:#d9b45f!important;font-weight:800!important;font-size:10.8px!important}
.ov-toolbar{background:rgba(5,8,12,.36)!important;border:1px solid rgba(255,255,255,.055)!important;border-radius:11px!important;padding:4px!important;backdrop-filter:blur(9px)!important;box-shadow:0 8px 20px rgba(0,0,0,.16)!important}
.ov-header__chip,.ov-header__btn{height:30px!important;min-height:30px!important;font-size:10.5px!important}

.syshealth{height:124px!important;min-height:124px!important;background:linear-gradient(105deg,#04080d 0%,#0b131d 61%,#0b1119 100%)!important}
.syshealth__layout{grid-template-columns:19% 53% 28%!important;padding:10px 12px!important}
.syshealth [class*="zone-right"]{background:#07101a!important;border-color:rgba(215,173,81,.12)!important}
.syshealth .v11-health-scene{display:block!important;width:100%!important;height:100%!important;transform:none!important;filter:none!important;opacity:1!important}
.syshealth .syshealth__center-scene{inset:0!important}
.syshealth__metric{background:linear-gradient(180deg,#172434,#111b27)!important;border-color:rgba(255,255,255,.065)!important;box-shadow:inset 0 1px rgba(255,255,255,.025)!important}
.syshealth__metric strong{font-size:20px!important}

/* preserve the already-correct V10 geometry below the health band */
.admin-command-grid{margin-top:0!important}
@media(max-width:1180px){.ov-header .v11-hero-scene{transform:scale(1.04)!important;transform-origin:center!important}.ov-header__layout{grid-template-columns:31% 38% 31%!important}}
'''

JSX.write_text(jsx)
CSS11.write_text(css11)

print('PATCH_TRANSFORM=PASS')
print(f'BASE_COMMIT={BASE_COMMIT}')
print('FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v11.css')
print('HERO_SCENE=RIYADH_SEDAN_REFERENCE_COMPOSITION')
print('HEALTH_SCENE=PREMIUM_SEDAN_REFERENCE_COMPOSITION')
