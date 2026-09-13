#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
TARGET=src/pages/AdminDashboard.v35.css
MASTER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v35-reference-master.css
BACKUP=/tmp/67-v35-full-reference-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"

# V35 is a clean visual rebuild. Do NOT copy or append any V34.x stylesheet.
curl -fsSL "$MASTER_URL" -o "$TARGET"
grep -q 'SIX SEVEN ADMIN V35 — FULL REFERENCE MASTER' "$TARGET" || { echo 'FAILED_STEP=MASTER_CSS_DOWNLOAD_FAILED'; exit 1; }

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# Replace exactly one active version stylesheet import with V35.
pat=r"import './AdminDashboard\.v(?:33|34(?:\.\d+)?)\.css';"
m=list(re.finditer(pat,s))
if not m:
    raise SystemExit('ACTIVE_VERSION_IMPORT_NOT_FOUND')
# Keep only the last active version import if multiple stale ones somehow exist.
first=m[-1]
for old in reversed(m[:-1]):
    s=s[:old.start()]+s[old.end():]
# m positions may have shifted after deletion; replace by regex once now.
s=re.sub(pat,"import './AdminDashboard.v35.css';",s,count=1)

# Add the reference hero utility strip exactly once.
needle='''                <div className="ov-header__zone-center" aria-hidden="true">\n                  <div className={`ov-header__motif ${heroImageReady ? 'hero-image-ready' : 'hero-image-pending'}`} style={{ '--hero-v295-image': `url(${heroHighResV295})` }} />\n                </div>\n'''
insert='''                <div className="ov-header__zone-center" aria-hidden="true">\n                  <div className={`ov-header__motif ${heroImageReady ? 'hero-image-ready' : 'hero-image-pending'}`} style={{ '--hero-v295-image': `url(${heroHighResV295})` }} />\n                </div>\n\n                <div className="ref-hero-tools" aria-hidden="true">\n                  <span className="ref-hero-admin">\n                    <span className="ref-hero-admin__avatar"><Users size={13} /></span>\n                    <span><b>مرحبا بك مجددًا</b><small>Super Admin</small></span>\n                  </span>\n                  <span className="ref-hero-icon"><Eye size={13} /></span>\n                  <span className="ref-hero-icon"><Bell size={13} /></span>\n                  <span className="ref-hero-icon"><Settings size={13} /></span>\n                </div>\n'''
if 'className="ref-hero-tools"' not in s:
    if needle not in s:
        raise SystemExit('HERO_ZONE_ANCHOR_NOT_FOUND')
    s=s.replace(needle,insert,1)

# Match static hero copy to the approved reference while preserving all dynamic data/logic.
s=s.replace('<span className="ov-header__eyebrow">منصة تشغيل ذكية لسوق قطع السيارات في المملكة</span>',
            '<span className="ov-header__eyebrow">منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</span>',1)
s=s.replace('<h1>قيادة المستقبل <span>تبدأ من هنا</span></h1>',
            '<h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>',1)
s=s.replace('<p>رؤية تنفيذية موحدة للأداء، الإيرادات، واستقرار المنصة لحظة بلحظة.</p>',
            '<p>منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</p>',1)
s=s.replace('<span>سوق أكثر ذكاء،</span>\n                  <strong>مستقبل أكثر تميزًا</strong>\n                  <small><CarFront size={14} /> SIX SEVEN Executive Command</small>',
            '<span>سرعة أكبر</span>\n                  <strong>فرص أوسع</strong>\n                  <small><CarFront size={14} /> DRIVE A BRIGHTER TOMORROW</small>',1)

p.write_text(s)
PY

npm run build >/tmp/67-v35-build.log 2>&1 || {
  tail -n 180 /tmp/67-v35-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V35'
echo 'ELEMENT=FULL REFERENCE REBUILD 1TO1'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v35.css'
echo 'VISUAL_STRATEGY=ONE_SHOT_CONSOLIDATED_REBUILD'
echo 'V34_OVERRIDE_STACK_USED=NO'
echo 'JSX_PRESENTATION_RECOMPOSED=YES'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
