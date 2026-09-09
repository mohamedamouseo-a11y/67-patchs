#!/usr/bin/env python3
from pathlib import Path
import hashlib

ROOT = Path('/67')
JSX = ROOT / 'src/pages/AdminDashboard.jsx'
CSS = ROOT / 'src/pages/AdminDashboard.v9.css'

EXPECTED = {
    JSX: '5a75c672b93cf5b23f09b7bb054db8e89d973582',
    CSS: '8f322a1e5590d513dd9f5f44dd5aa34f42f19e44',
}

def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'PATCH_CONTEXT_MISMATCH:{label}:count={count}')
    return text.replace(old, new, 1)

for path, expected in EXPECTED.items():
    actual = git_blob_sha(path.read_bytes())
    if actual != expected:
        raise SystemExit(f'PATCH_BASE_MISMATCH:{path}:{actual}:expected:{expected}')

jsx = JSX.read_text()
css = CSS.read_text()

jsx = replace_once(
    jsx,
    "<div style={{ flex: 1, marginRight: '264px', padding: '30px', minHeight: '100vh', overflowY: 'auto' }}>",
    "<div style={{ flex: 1, marginRight: '278px', padding: '20px 18px', minHeight: '100vh', overflowY: 'auto' }}>",
    'main-content-layout',
)
jsx = replace_once(
    jsx,
    "<div className=\"animate-fadeIn\" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>",
    "<div className=\"animate-fadeIn\" style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>",
    'overview-gap',
)

css = replace_once(
    css,
    """  background-image:\n    linear-gradient(90deg,rgba(4,7,11,.76) 0%,rgba(4,7,11,.18) 25%,rgba(4,7,11,.04) 52%,rgba(4,7,11,.55) 78%,rgba(4,7,11,.94) 100%),\n    url('../assets/admin-v8-hero.jpg')!important;""",
    """  background-image:\n    radial-gradient(circle at 50% 54%,rgba(215,173,81,.10) 0%,rgba(215,173,81,.025) 28%,transparent 56%),\n    linear-gradient(90deg,rgba(4,7,11,.84) 0%,rgba(4,7,11,.20) 23%,rgba(4,7,11,.02) 51%,rgba(4,7,11,.42) 76%,rgba(4,7,11,.94) 100%),\n    linear-gradient(180deg,#04070b 0%,#0b121c 46%,#070b11 100%)!important;""",
    'hero-background',
)
css = replace_once(
    css,
    """.ov-header__motif,.ov-header [class*=\"zone-center\"] svg{\n  opacity:0!important;\n  visibility:hidden!important;\n}""",
    """.ov-header__motif{\n  opacity:1!important;\n  visibility:visible!important;\n  position:absolute!important;\n  inset:0!important;\n  overflow:hidden!important;\n  z-index:1!important;\n  pointer-events:none!important;\n}\n.ov-header__motif::after{\n  content:\"\";\n  position:absolute;\n  inset:0;\n  background:\n    linear-gradient(90deg,rgba(4,7,11,.72),transparent 23%,transparent 69%,rgba(4,7,11,.72)),\n    linear-gradient(180deg,rgba(255,255,255,.018),transparent 45%,rgba(0,0,0,.18));\n  pointer-events:none;\n}\n.ov-header [class*=\"zone-center\"] svg{\n  opacity:1!important;\n  visibility:visible!important;\n  display:block!important;\n  transform:scale(1.12)!important;\n  transform-origin:center 58%!important;\n  filter:contrast(1.12) saturate(.88) brightness(1.08) drop-shadow(0 12px 18px rgba(0,0,0,.42))!important;\n}""",
    'hero-motif',
)
css = replace_once(
    css,
    """  justify-content:flex-start!important;\n  padding:0 0 16px 18px!important;\n}\n.ov-header [class*=\"zone-center\"]{background:transparent!important;border:0!important;box-shadow:none!important}""",
    """  justify-content:flex-start!important;\n  padding:0 0 16px 18px!important;\n  position:relative!important;\n  z-index:4!important;\n}\n.ov-header [class*=\"zone-center\"]{\n  position:absolute!important;\n  inset:0!important;\n  z-index:1!important;\n  background:transparent!important;\n  border:0!important;\n  box-shadow:none!important;\n  pointer-events:none!important;\n}""",
    'hero-left-center-zones',
)
css = replace_once(
    css,
    """  padding:18px 24px 18px 12px!important;\n  background:linear-gradient(90deg,transparent,rgba(5,8,13,.46) 35%,rgba(5,8,13,.86) 100%)!important;\n}""",
    """  padding:18px 24px 18px 12px!important;\n  background:linear-gradient(90deg,transparent,rgba(5,8,13,.46) 35%,rgba(5,8,13,.86) 100%)!important;\n  position:relative!important;\n  z-index:4!important;\n}""",
    'hero-right-zone',
)
css = replace_once(
    css,
    ".syshealth [class*=\"zone-center\"]{display:grid!important;grid-template-columns:repeat(4,minmax(0,1fr))!important;gap:7px!important}",
    """.syshealth [class*=\"zone-center\"]{display:flex!important;align-items:stretch!important;min-width:0!important}\n.syshealth .syshealth__metrics{width:100%!important;min-width:0!important;display:flex!important}\n.syshealth .syshealth__grid{\n  width:100%!important;display:grid!important;grid-template-columns:repeat(4,minmax(0,1fr))!important;\n  gap:7px!important;align-items:stretch!important;\n}""",
    'health-metric-grid',
)
css = replace_once(
    css,
    """.syshealth [class*=\"zone-right\"]{\n  height:100%!important;border-radius:10px!important;overflow:hidden!important;\n  background-image:linear-gradient(90deg,rgba(12,19,29,.92) 0%,rgba(12,19,29,.16) 24%,transparent 50%),url('../assets/admin-v8-health.jpg')!important;\n  background-size:cover!important;background-position:center!important;background-repeat:no-repeat!important;\n}\n.syshealth [class*=\"zone-right\"] svg{display:none!important}""",
    """.syshealth [class*=\"zone-right\"]{\n  height:100%!important;border-radius:10px!important;overflow:hidden!important;\n  position:relative!important;\n  background:\n    radial-gradient(circle at 56% 70%,rgba(215,173,81,.14),transparent 38%),\n    linear-gradient(120deg,#07101a 0%,#111b27 54%,#080d14 100%)!important;\n  border:1px solid rgba(215,173,81,.08)!important;\n}\n.syshealth [class*=\"zone-right\"] svg{\n  display:block!important;\n  width:100%!important;\n  height:100%!important;\n  opacity:1!important;\n  transform:scale(1.12)!important;\n  transform-origin:center!important;\n  filter:contrast(1.16) brightness(1.12) drop-shadow(0 10px 14px rgba(0,0,0,.35))!important;\n}\n.syshealth .syshealth__center-scene{position:absolute!important;inset:0!important;width:100%!important;height:100%!important}\n\n/* V10: zero missing runtime image dependencies. The approved embedded SVG scenes are the visual source. */""",
    'health-scene',
)

if "admin-v8-hero.jpg" in css or "admin-v8-health.jpg" in css:
    raise SystemExit('PATCH_VALIDATION_FAILED:MISSING_ASSET_REFERENCE_REMAINS')
if 'transform:scale(1.12)!important' not in css:
    raise SystemExit('PATCH_VALIDATION_FAILED:HERO_SCENE_RULE_MISSING')
if 'grid-template-columns:repeat(4,minmax(0,1fr))' not in css:
    raise SystemExit('PATCH_VALIDATION_FAILED:HEALTH_GRID_RULE_MISSING')

# Write only after all exact-context transformations succeeded in memory.
JSX.write_text(jsx)
CSS.write_text(css)

print('PATCH_TRANSFORM=PASS')
print('BASE_COMMIT=e9f4be05d69fe9592f4c42f3322247b8a482a1d7')
print('FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v9.css')
