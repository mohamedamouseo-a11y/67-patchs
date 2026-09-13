#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
TARGET=src/pages/AdminDashboard.v36.css
MASTER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v36-reference-structural-master.css
BACKUP=/tmp/67-v36-structural-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"

curl -fsSL "$MASTER_URL" -o "$TARGET"
grep -q 'SIX SEVEN ADMIN V36 — STRUCTURAL REFERENCE MASTER' "$TARGET" || { echo 'FAILED_STEP=MASTER_CSS_DOWNLOAD_FAILED'; exit 1; }

python3 - <<'PY'
from pathlib import Path
import re
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# active version stylesheet -> V36
pat=r"import './AdminDashboard\.v(?:32\.5|33|34(?:\.\d+)?|35)\.css';"
if not re.search(pat,s):
    raise SystemExit('ACTIVE_VERSION_IMPORT_NOT_FOUND')
s=re.sub(pat,"import './AdminDashboard.v36.css';",s,count=1)

# Search icon for exact reference hero tools
s=s.replace('Layers, Eye, RefreshCw, Activity,', 'Layers, Eye, Search, RefreshCw, Activity,', 1)

# Overview root gets explicit structural scope
s=s.replace('<div className="animate-fadeIn" style={{ display: \'flex\', flexDirection: \'column\', gap: \'10px\' }}>',
            '<div className="animate-fadeIn ref-v36-dashboard" style={{ display: \'flex\', flexDirection: \'column\', gap: \'10px\' }}>',1)

# Hero tools as real DOM (not pseudo/QA guess).
hero_anchor='''                <div className="ov-header__zone-center" aria-hidden="true">\n                  <div className={`ov-header__motif ${heroImageReady ? 'hero-image-ready' : 'hero-image-pending'}`} style={{ '--hero-v295-image': `url(${heroHighResV295})` }} />\n                </div>\n'''
hero_tools='''                <div className="ov-header__zone-center" aria-hidden="true">\n                  <div className={`ov-header__motif ${heroImageReady ? 'hero-image-ready' : 'hero-image-pending'}`} style={{ '--hero-v295-image': `url(${heroHighResV295})` }} />\n                </div>\n\n                <div className="ref-v36-hero-tools">\n                  <span className="ref-v36-hero-admin">\n                    <span className="ref-v36-hero-avatar"><Users size={13} /></span>\n                    <span><b>مرحبا بك مجددًا</b><small>Super Admin</small></span>\n                  </span>\n                  <span className="ref-v36-hero-icon"><Search size={13} /></span>\n                  <span className="ref-v36-hero-icon"><Bell size={13} /></span>\n                  <span className="ref-v36-hero-icon"><Settings size={13} /></span>\n                </div>\n'''
if 'className="ref-v36-hero-tools"' not in s:
    if hero_anchor not in s:
        raise SystemExit('HERO_ZONE_ANCHOR_NOT_FOUND')
    s=s.replace(hero_anchor,hero_tools,1)

# Exact reference hero copy.
s=s.replace('<span className="ov-header__eyebrow">منصة تشغيل ذكية لسوق قطع السيارات في المملكة</span>',
            '<span className="ov-header__eyebrow">منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</span>',1)
s=s.replace('<h1>قيادة المستقبل <span>تبدأ من هنا</span></h1>',
            '<h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>',1)
s=s.replace('<p>رؤية تنفيذية موحدة للأداء، الإيرادات، واستقرار المنصة لحظة بلحظة.</p>',
            '<p>منصة متكاملة لعمليات الدفع والخدمات الرقمية لقطاع السيارات</p>',1)
s=s.replace('<span>سوق أكثر ذكاء،</span>\n                  <strong>مستقبل أكثر تميزًا</strong>\n                  <small><CarFront size={14} /> SIX SEVEN Executive Command</small>',
            '<span>سرعة أكبر</span>\n                  <strong>فرص أوسع</strong>\n                  <small><CarFront size={14} /> DRIVE A BRIGHTER TOMORROW</small>',1)
# if V35 already changed title/right copy, normalize to same target
s=s.replace('<h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>', '<h1>قيادة اليوم .. <span>لمستقبل أكثر تميزًا</span></h1>',1)

# Sidebar promo panel as real DOM before footer.
footer_anchor='''        {/* Bottom utility — logout only (logo switcher moved to Settings) */}\n        <div className="admin-sidebar__footer">\n'''
promo='''        <div className="ref-v36-sidebar-promo" aria-hidden="true">\n          <Award size={20} />\n          <strong>تميّز في كل خطوة</strong>\n          <span>معًا نحو مستقبل أكثر تميزًا</span>\n        </div>\n\n        {/* Bottom utility — logout only (logo switcher moved to Settings) */}\n        <div className="admin-sidebar__footer">\n'''
if 'className="ref-v36-sidebar-promo"' not in s:
    if footer_anchor not in s:
        raise SystemExit('SIDEBAR_FOOTER_ANCHOR_NOT_FOUND')
    s=s.replace(footer_anchor,promo,1)
s=s.replace('className="admin-sidebar__identity"','className="admin-sidebar__identity ref-v36-admin"',1)

# Dedicated System Health visual scene as real DOM.
right_anchor='''                <div className="syshealth__zone-right">\n                  <div className="syshealth__center-scene" aria-hidden="true">\n'''
right_insert='''                <div className="syshealth__zone-right">\n                  <div className="ref-v36-health-scene" aria-hidden="true">\n                    <strong>أداء مستقر<br/>لرحلة أكثر سلاسة</strong>\n                    <span>STABLE TODAY • SMOOTHER TOMORROW</span>\n                  </div>\n                  <div className="syshealth__center-scene" aria-hidden="true">\n'''
if 'className="ref-v36-health-scene"' not in s:
    if right_anchor not in s:
        raise SystemExit('SYSTEM_HEALTH_RIGHT_ANCHOR_NOT_FOUND')
    s=s.replace(right_anchor,right_insert,1)

# Donut legend is real DOM; ring stays dynamic.
copy_anchor='''                    <div className="rev-total__copy">\n                      <span>ملخص الفترة</span>\n                      <strong>{periodPlatformRevenue.toLocaleString()} ر.س</strong>\n                      <small>إيراد عمولة المنصة (1%)</small>\n                      <em className={trendDelta >= 0 ? 'up' : 'down'}><TrendingUp size={12} /> {trendDelta >= 0 ? '+' : ''}{trendDelta}%</em>\n                    </div>\n'''
legend='''                    <div className="rev-total__copy">\n                      <span>ملخص الفترة</span>\n                      <strong>{periodPlatformRevenue.toLocaleString()} ر.س</strong>\n                      <small>إيراد عمولة المنصة (1%)</small>\n                      <em className={trendDelta >= 0 ? 'up' : 'down'}><TrendingUp size={12} /> {trendDelta >= 0 ? '+' : ''}{trendDelta}%</em>\n                    </div>\n                    <div className="ref-v36-donut-legend" aria-label="توزيع الإيرادات">\n                      <span><i className="g" />62% بطاقات مدى</span>\n                      <span><i className="c" />28% بطاقات ائتمانية</span>\n                      <span><i className="b" />10% محافظ رقمية</span>\n                    </div>\n'''
if 'className="ref-v36-donut-legend"' not in s:
    if copy_anchor not in s:
        raise SystemExit('REVENUE_COPY_ANCHOR_NOT_FOUND')
    s=s.replace(copy_anchor,legend,1)

p.write_text(s)
PY

npm run build >/tmp/67-v36-build.log 2>&1 || {
  tail -n 180 /tmp/67-v36-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V36'
echo 'ELEMENT=STRUCTURAL REFERENCE REBUILD'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v36.css'
echo 'VISUAL_STRATEGY=STRUCTURAL_JSX_PLUS_MASTER_CSS'
echo 'LEGACY_OVERRIDE_STACK_USED=NO'
echo 'REFERENCE_HERO_TOOLS_REAL_DOM=YES'
echo 'REFERENCE_SIDEBAR_PROMO_REAL_DOM=YES'
echo 'REFERENCE_HEALTH_SCENE_REAL_DOM=YES'
echo 'REFERENCE_DONUT_LEGEND_REAL_DOM=YES'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
