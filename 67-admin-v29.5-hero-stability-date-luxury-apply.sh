#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.4.css
TARGET_CSS=src/pages/AdminDashboard.v29.5.css
ASSET=src/assets/admin-v29.4-hero-highres.jpg
MARKER='SIX SEVEN ADMIN V29.5 — HERO STABILITY + LUXURY DATE PICKER'
BACKUP=/tmp/67-v29.5-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V29_4_CSS_MISSING'; exit 1; }
[ -f "$ASSET" ] || { echo 'FAILED_STEP=HIGHRES_ASSET_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.4.css';" "$JSX" || { echo 'FAILED_STEP=V29_4_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v29.4.css"

cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
s=s.replace("import officialLogo from '../assets/sixty-seven-official-logo.png';", "import officialLogo from '../assets/sixty-seven-official-logo.png';\nimport heroHighResV295 from '../assets/admin-v29.4-hero-highres.jpg';", 1)
s=s.replace("import './AdminDashboard.v29.4.css';", "import './AdminDashboard.v29.5.css';", 1)
needle="  const [dateError, setDateError] = useState('');"
insert="""  const [dateError, setDateError] = useState('');\n  const [heroImageReady, setHeroImageReady] = useState(false);\n\n  useEffect(() => {\n    let mounted = true;\n    const img = new Image();\n    img.src = heroHighResV295;\n    const markReady = () => { if (mounted) setHeroImageReady(true); };\n    if (img.complete && img.naturalWidth >= 2000) markReady();\n    else {\n      img.onload = markReady;\n      img.onerror = markReady;\n      if (typeof img.decode === 'function') img.decode().then(markReady).catch(() => {});\n    }\n    return () => { mounted = false; };\n  }, []);"""
if needle not in s: raise SystemExit('DATE_STATE_ANCHOR_NOT_FOUND')
s=s.replace(needle, insert, 1)
old='<div className="ov-header__motif" />'
new='<div className={`ov-header__motif ${heroImageReady ? \'hero-image-ready\' : \'hero-image-pending\'}`} style={{ \'--hero-v295-image\': `url(${heroHighResV295})` }} />'
if old not in s: raise SystemExit('HERO_MOTIF_ANCHOR_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.5 — HERO STABILITY + LUXURY DATE PICKER
   Video QA fix: never paint legacy low-res hero, no zoom/shift during decode,
   and elevate the date range control into an executive luxury console. */

body .admin-exec .ov-header .ov-header__motif.ov-header__motif,
body .admin-exec .ov-header.date-control-open .ov-header__motif.ov-header__motif{
  background-color:#070a0f!important;
  background-image:var(--hero-v295-image)!important;
  background-size:cover!important;
  background-position:56% 52%!important;
  background-repeat:no-repeat!important;
  width:100%!important;
  height:100%!important;
  inset:0!important;
  transform:none!important;
  scale:1!important;
  animation:none!important;
  transition:none!important;
  filter:saturate(.98) contrast(1.045) brightness(.92)!important;
  image-rendering:auto!important;
  backface-visibility:hidden!important;
  will-change:auto!important;
}
body .admin-exec .ov-header .ov-header__motif.hero-image-pending{opacity:0!important;visibility:hidden!important}
body .admin-exec .ov-header .ov-header__motif.hero-image-ready{opacity:1!important;visibility:visible!important}
body .admin-exec .ov-header__zone-center{overflow:hidden!important;transform:none!important;animation:none!important}
body .admin-exec .ov-header,
body .admin-exec .ov-header.date-control-open{transform:none!important;animation:none!important}

/* Executive Chronograph Date Console */
body .admin-exec .executive-date-popover{
  width:500px!important;
  padding:18px!important;
  border-radius:18px!important;
  background:
    radial-gradient(circle at 84% 6%,rgba(225,184,84,.11),transparent 26%),
    linear-gradient(180deg,rgba(9,14,21,.99),rgba(3,7,12,.99))!important;
  border:1px solid rgba(226,185,88,.38)!important;
  box-shadow:0 30px 70px rgba(0,0,0,.62),0 0 0 1px rgba(255,255,255,.02) inset,0 0 34px rgba(188,126,16,.08)!important;
  backdrop-filter:blur(28px) saturate(145%)!important;
  animation:none!important;
  transform:none!important;
  overflow:hidden!important;
}
body .admin-exec .executive-date-popover::before{
  content:""!important;position:absolute!important;inset:0 auto 0 0!important;width:3px!important;height:auto!important;
  background:linear-gradient(180deg,transparent,#e2b94f 28%,#9c6712 72%,transparent)!important;
  border:0!important;transform:none!important;box-shadow:0 0 20px rgba(222,177,66,.25)!important;
}
body .admin-exec .executive-date-popover::after{
  content:""!important;position:absolute!important;left:22px!important;right:22px!important;top:0!important;height:1px!important;
  background:linear-gradient(90deg,transparent,rgba(247,214,128,.88),transparent)!important;
}
body .admin-exec .executive-date-popover__head{padding-bottom:14px!important;margin-bottom:14px!important;border-bottom:1px solid rgba(255,255,255,.06)!important}
body .admin-exec .executive-date-popover__head strong{font-size:14px!important;color:#fff7e8!important;letter-spacing:-.015em!important}
body .admin-exec .executive-date-popover__head span{font-size:8.5px!important;color:#929aa5!important}
body .admin-exec .executive-date-popover__badge{height:30px!important;min-width:66px!important;padding:0 12px!important;border-radius:999px!important;color:#f0cf73!important;background:linear-gradient(180deg,rgba(215,173,81,.16),rgba(215,173,81,.06))!important;border:1px solid rgba(226,185,88,.28)!important;box-shadow:inset 0 1px rgba(255,255,255,.04)!important}
body .admin-exec .executive-date-fields{gap:12px!important;margin-bottom:14px!important}
body .admin-exec .executive-date-field-card{padding:10px!important;border-radius:14px!important;background:linear-gradient(180deg,rgba(18,27,39,.92),rgba(9,15,23,.96))!important;border:1px solid rgba(255,255,255,.07)!important;box-shadow:inset 0 1px rgba(255,255,255,.025),0 12px 28px rgba(0,0,0,.16)!important}
body .admin-exec .executive-date-field-label{display:block!important;margin:0 0 6px!important;color:#d7b65d!important;font-size:8px!important;font-weight:900!important;letter-spacing:.06em!important}
body .admin-exec .executive-date-picker{position:relative!important;min-height:66px!important;padding:9px 10px!important;border-radius:11px!important;background:linear-gradient(180deg,#111a25,#0b121b)!important;border:1px solid rgba(218,177,77,.16)!important;box-shadow:inset 0 1px rgba(255,255,255,.025)!important}
body .admin-exec .executive-date-picker:hover{border-color:rgba(226,185,88,.36)!important;background:linear-gradient(180deg,#14202d,#0c141e)!important}
body .admin-exec .executive-date-picker__icon{width:38px!important;height:38px!important;border-radius:10px!important;display:grid!important;place-items:center!important;color:#1b1305!important;background:linear-gradient(145deg,#f3d57d,#c99129)!important;border:1px solid rgba(255,227,146,.44)!important;box-shadow:inset 0 1px rgba(255,255,255,.5),0 7px 18px rgba(190,128,24,.18)!important}
body .admin-exec .executive-date-picker__copy small{font-size:7.5px!important;color:#7f8995!important}
body .admin-exec .executive-date-picker__copy strong{font-size:10.5px!important;color:#f5eee2!important;font-weight:900!important}
body .admin-exec .executive-date-picker__chevron{color:#d5ad4a!important}
body .admin-exec .executive-date-native{position:absolute!important;inset:0!important;width:100%!important;height:100%!important;opacity:0!important;cursor:pointer!important;z-index:5!important}
body .admin-exec .executive-date-popover__footer{padding-top:13px!important;min-height:44px!important;border-top:1px solid rgba(255,255,255,.055)!important}
body .admin-exec .executive-date-cancel{height:36px!important;padding:0 14px!important;border-radius:10px!important;color:#b7bec7!important;background:rgba(255,255,255,.035)!important;border:1px solid rgba(255,255,255,.08)!important}
body .admin-exec .executive-date-apply{height:36px!important;padding:0 18px!important;border-radius:10px!important;color:#171006!important;background:linear-gradient(180deg,#f0cf72,#c58c24)!important;box-shadow:inset 0 1px rgba(255,255,255,.5),0 8px 20px rgba(190,129,27,.20)!important}
body .admin-exec .executive-date-popover__hint{color:#7d8691!important;font-size:7.7px!important;line-height:1.55!important}

@media(max-width:1360px){body .admin-exec .executive-date-popover{width:440px!important;padding:15px!important}}
CSS

grep -q "$MARKER" "$TARGET_CSS" || { cp "$BACKUP/AdminDashboard.jsx" "$JSX"; rm -f "$TARGET_CSS"; echo 'FAILED_STEP=CSS_MARKER_MISSING'; exit 1; }

npm run build >/tmp/67-v29.5-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.5-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V29.5'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=HERO STABILITY + LUXURY DATE PICKER'
echo 'BASE_VERSION=V29.4'
echo 'TARGET_VERSION=V29.5'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v29.5.css'
echo 'HERO_HIGHRES_PRELOAD_GATE=YES'
echo 'LEGACY_FIRST_FRAME_VISIBLE=NO_EXPECTED'
echo 'HERO_SCALE_SHIFT_REMOVED=YES'
echo 'HERO_TRANSFORM_LOCKED=YES'
echo 'DATE_PICKER_LUXURY_REDESIGN=YES'
echo 'DATE_LOGIC_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'KPI_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
