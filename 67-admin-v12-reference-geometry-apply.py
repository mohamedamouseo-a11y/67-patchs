#!/usr/bin/env python3
from pathlib import Path
import hashlib

ROOT = Path('/67')
CSS = ROOT / 'src/pages/AdminDashboard.v11.css'
BASE_COMMIT = 'b64a50bb8bca72c5a18442a55d3f90a297444c88'
MARKER = '/* SIX SEVEN ADMIN V11 — OFFICIAL REFERENCE HERO / HEALTH LOCK */'
V12_MARKER = '/* SIX SEVEN ADMIN V12 — REFERENCE GEOMETRY / CINEMATIC POLISH */'

if not CSS.exists():
    raise SystemExit('V12_BASE_MISSING:AdminDashboard.v11.css')
text = CSS.read_text()
if MARKER not in text:
    raise SystemExit('V12_BASE_MARKER_MISMATCH')
if V12_MARKER in text:
    raise SystemExit('V12_ALREADY_PRESENT')
if "admin-v8-hero.jpg" in text or "admin-v8-health.jpg" in text:
    raise SystemExit('V12_BASE_HAS_FORBIDDEN_ASSET_REFERENCE')
if '.v11-hero-scene' not in text or '.v11-health-scene' not in text:
    raise SystemExit('V12_SCENE_SELECTORS_MISSING')

v12 = r'''

/* SIX SEVEN ADMIN V12 — REFERENCE GEOMETRY / CINEMATIC POLISH */
/* Locked against Official Reference V5 + authenticated V11.1 screenshot. */
.ov-header{
  height:194px!important;
  min-height:194px!important;
  border:1px solid rgba(215,173,81,.38)!important;
  box-shadow:0 20px 46px rgba(0,0,0,.24),inset 0 1px 0 rgba(255,255,255,.025)!important;
  background:
    radial-gradient(circle at 56% 66%,rgba(218,169,72,.11),transparent 31%),
    linear-gradient(180deg,#020408 0%,#070c13 56%,#06070a 100%)!important;
}
.ov-header::before{
  height:2px!important;
  opacity:.94!important;
  background:linear-gradient(90deg,transparent 1%,#9d1117 17%,#d71920 38%,#d71920 68%,#831015 86%,transparent 99%)!important;
  box-shadow:0 0 14px rgba(215,25,32,.34)!important;
}
.ov-header::after{
  content:""!important;
  display:block!important;
  position:absolute!important;
  inset:0!important;
  z-index:3!important;
  pointer-events:none!important;
  background:
    radial-gradient(circle at 83% 55%,rgba(211,164,68,.16),transparent 23%),
    radial-gradient(circle at 38% 81%,rgba(255,238,189,.05),transparent 21%),
    linear-gradient(173deg,transparent 0 73%,rgba(215,25,32,.16) 73.4%,rgba(215,25,32,.34) 73.8%,transparent 74.3%),
    linear-gradient(90deg,rgba(2,5,9,.54) 0%,transparent 24%,transparent 65%,rgba(2,5,9,.16) 72%,rgba(2,5,9,.72) 100%),
    linear-gradient(180deg,rgba(0,0,0,.02),transparent 52%,rgba(0,0,0,.24))!important;
}
.ov-header__layout{
  display:block!important;
  position:relative!important;
  height:100%!important;
  z-index:5!important;
}
.ov-header [class*="zone-center"]{
  position:absolute!important;
  inset:0!important;
  width:100%!important;
  height:100%!important;
  z-index:1!important;
}
.ov-header .v11-hero-scene{
  transform:scale(1.045) translate(-1.4%,1.2%)!important;
  transform-origin:center 62%!important;
  filter:contrast(1.08) saturate(.92) brightness(1.04)!important;
}
.ov-header [class*="zone-right"]{
  position:absolute!important;
  inset-block:0!important;
  inset-inline-end:0!important;
  width:36%!important;
  z-index:7!important;
  display:flex!important;
  align-items:flex-start!important;
  justify-content:center!important;
  padding:19px 34px 18px 18px!important;
  background:linear-gradient(90deg,transparent 0%,rgba(2,5,9,.24) 23%,rgba(2,5,9,.78) 72%,rgba(2,5,9,.92) 100%)!important;
}
.ov-header__titles{max-width:430px!important;margin-inline-start:auto!important}
.ov-header h1{
  font-size:30px!important;
  line-height:1.12!important;
  margin:0 0 7px!important;
  text-shadow:0 4px 20px rgba(0,0,0,.66)!important;
}
.ov-header h1+p{
  font-size:11.8px!important;
  line-height:1.65!important;
  max-width:420px!important;
  color:rgba(255,255,255,.82)!important;
}
.ov-header__subtitle-saudi{font-size:10.8px!important;color:#e0bd68!important;text-shadow:0 1px 12px rgba(0,0,0,.45)!important}
.ov-header [class*="zone-left"]{
  position:absolute!important;
  inset-inline-start:18px!important;
  inset-block-end:14px!important;
  width:auto!important;
  height:auto!important;
  z-index:8!important;
  padding:0!important;
  align-items:flex-end!important;
  justify-content:flex-start!important;
}
.ov-toolbar{
  background:rgba(4,7,11,.69)!important;
  border:1px solid rgba(215,173,81,.16)!important;
  box-shadow:0 10px 28px rgba(0,0,0,.28),inset 0 1px rgba(255,255,255,.035)!important;
  backdrop-filter:blur(11px)!important;
}
.ov-header__chip,.ov-header__btn{height:31px!important;min-height:31px!important}
.ov-header__chip.active{box-shadow:inset 0 -2px #d7ad51!important}

/* KPI cards: tighten vertical rhythm and increase reference-like authority. */
.kpi-grid{gap:9px!important;margin-bottom:9px!important}
.kpi-card{height:110px!important;min-height:110px!important;padding:13px 15px 12px!important}
.kpi-card__top{align-items:center!important}
.kpi-card__value{margin-top:7px!important}
.kpi-card__note{margin-top:auto!important}

/* Health band: status left, four metrics center, stronger automotive scene right. */
.syshealth{
  height:126px!important;
  min-height:126px!important;
  border-color:rgba(215,173,81,.22)!important;
  box-shadow:0 15px 34px rgba(0,0,0,.15),inset 0 1px rgba(255,255,255,.02)!important;
}
.syshealth__layout{
  grid-template-columns:18% 50% 32%!important;
  gap:9px!important;
  padding:9px 11px!important;
}
.syshealth [class*="zone-left"]{display:flex!important;align-items:center!important;padding-inline-end:12px!important}
.syshealth [class*="zone-center"]{align-items:center!important}
.syshealth .syshealth__grid{gap:8px!important}
.syshealth__metric{min-height:94px!important;padding:11px 10px!important;border-radius:12px!important}
.syshealth__metric strong{font-size:21px!important;letter-spacing:-.02em!important}
.syshealth [class*="zone-right"]{
  overflow:hidden!important;
  background:
    radial-gradient(circle at 54% 72%,rgba(215,173,81,.18),transparent 38%),
    linear-gradient(122deg,#07101a 0%,#0c1622 52%,#05090e 100%)!important;
}
.syshealth .v11-health-scene{
  transform:scale(1.13) translate(-1%,2.5%)!important;
  transform-origin:center 68%!important;
  filter:contrast(1.09) saturate(.9) brightness(1.05)!important;
}
.syshealth [class*="zone-right"]::after{
  content:"";
  position:absolute;
  inset:0;
  pointer-events:none;
  background:linear-gradient(90deg,rgba(5,9,14,.52),transparent 27%,transparent 76%,rgba(5,9,14,.18)),linear-gradient(180deg,transparent 50%,rgba(0,0,0,.18));
}

/* Keep command center and ledger dense; polish only, no structural reorder. */
.admin-command-grid{gap:9px!important;margin-bottom:9px!important}
.admin-command-grid> *{box-shadow:0 10px 26px rgba(74,51,12,.07)!important;border-color:rgba(186,131,28,.25)!important}
.ledger-card,.financial-ledger{box-shadow:0 9px 24px rgba(74,51,12,.055)!important}

@media(max-width:1180px){
  .ov-header [class*="zone-right"]{width:39%!important;padding-inline-end:24px!important}
  .ov-header .v11-hero-scene{transform:scale(1.07) translate(-1.5%,1.5%)!important}
  .syshealth__layout{grid-template-columns:20% 52% 28%!important}
  .syshealth .v11-health-scene{transform:scale(1.08) translateY(2%)!important}
}
'''

CSS.write_text(text.rstrip() + v12 + '\n')
print('PATCH_TRANSFORM=PASS')
print(f'BASE_COMMIT={BASE_COMMIT}')
print('FILES_CHANGED=src/pages/AdminDashboard.v11.css')
print('V12_REFERENCE_GEOMETRY=YES')
