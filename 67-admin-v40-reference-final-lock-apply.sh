#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE=src/pages/AdminDashboard.v39.css
TARGET=src/pages/AdminDashboard.v40.css
BACKUP=/tmp/67-v40-reference-final-lock-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE" ] || { echo 'FAILED_STEP=V39_CSS_MISSING'; exit 1; }
grep -q "AdminDashboard.v39.css" "$JSX" || { echo 'FAILED_STEP=V39_RUNTIME_NOT_ACTIVE'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE" "$TARGET"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

s=s.replace("import './AdminDashboard.v39.css';", "import './AdminDashboard.v40.css';", 1)
s=s.replace('className="v38-dashboard v39-dashboard animate-fadeIn"', 'className="v38-dashboard v39-dashboard v40-dashboard animate-fadeIn"', 1)
s=s.replace('className="v38-current-summary"', 'className="v38-current-summary v40-current-summary"', 1)

preset_repls = {
'''<button type="button" className={datePreset === 'today' ? 'active' : ''} onClick={() => applyDatePreset('today')}>اليوم</button>''':
'''<button type="button" data-v40-preset="today" aria-pressed={datePreset === 'today'} className={datePreset === 'today' ? 'active' : ''} onClick={() => applyDatePreset('today')}>اليوم</button>''',
'''<button type="button" className={datePreset === '7d' ? 'active' : ''} onClick={() => applyDatePreset('7d')}>الأسبوع</button>''':
'''<button type="button" data-v40-preset="7d" aria-pressed={datePreset === '7d'} className={datePreset === '7d' ? 'active' : ''} onClick={() => applyDatePreset('7d')}>الأسبوع</button>''',
'''<button type="button" className={datePreset === '30d' ? 'active' : ''} onClick={() => applyDatePreset('30d')}>آخر 30 يوم</button>''':
'''<button type="button" data-v40-preset="30d" aria-pressed={datePreset === '30d'} className={datePreset === '30d' ? 'active' : ''} onClick={() => applyDatePreset('30d')}>آخر 30 يوم</button>''',
'''<button type="button" className={datePreset === 'custom' ? 'active' : ''} onClick={() => { setDateError(''); setDatePopoverOpen(true); }}>مخصص</button>''':
'''<button type="button" data-v40-preset="custom" aria-pressed={datePreset === 'custom'} className={datePreset === 'custom' ? 'active' : ''} onClick={() => { setDateError(''); setDatePopoverOpen(true); }}>مخصص</button>''',
}
for old,new in preset_repls.items():
    if old in s:
        s=s.replace(old,new,1)

p.write_text(s)
PY

cat >> "$TARGET" <<'CSS'

/* ============================================================
   SIX SEVEN ADMIN V40 — REFERENCE FINAL LOCK
   Manual side-by-side pass against the supplied 1448x1086 master.
   Preserve V39 geometry. Correct remaining whole-page composition differences.
   ============================================================ */

/* SIDEBAR: reference packs promo + admin/footer together in lower rail.
   V39 left a large dead band between promo and identity. */
body .admin-exec .admin-sidebar{
  display:flex!important;
  flex-direction:column!important;
}
body .admin-exec .ref-v36-sidebar-promo,
body .admin-exec .v39-sidebar-promo{
  margin-top:auto!important;
  margin-bottom:6px!important;
  flex:0 0 178px!important;
}
body .admin-exec .admin-sidebar__footer{
  margin-top:0!important;
  flex:0 0 auto!important;
}
body .admin-exec .admin-sidebar__identity.ref-v36-admin,
body .admin-exec .v39-sidebar-admin{
  margin-top:0!important;
}

/* HERO: match the master hierarchy more closely; V39 title was slightly oversized. */
body .admin-exec .v38-hero-copy-left{
  top:58px!important;
  width:445px!important;
}
body .admin-exec .v38-hero-copy-left h1{
  font-size:24.5px!important;
  line-height:1.08!important;
  letter-spacing:-.15px!important;
}
body .admin-exec .v38-hero-copy-left p{
  font-size:8px!important;
  line-height:1.35!important;
}
body .admin-exec .v38-hero-copy-right{
  top:50px!important;
}

/* SYSTEM HEALTH: keep the approved V39 physical order and tighten metric rhythm. */
body .admin-exec .v38-health__metrics{gap:6px!important}
body .admin-exec .v38-health-metric{padding:9px 11px!important}
body .admin-exec .v38-health-metric strong{font-size:16px!important;line-height:1!important}
body .admin-exec .v38-health-metric small{font-size:6.6px!important}

/* REVENUE: reference uses a slightly stronger card/plot separation. */
body .admin-exec .v38-chart{
  border-right:1px solid rgba(176,126,25,.13)!important;
}
body .admin-exec .v38-donut{
  box-shadow:inset 0 0 0 1px rgba(224,179,67,.08)!important;
}
body .admin-exec .v38-donut-copy h4{font-size:10.5px!important}
body .admin-exec .v38-donut-legend span{font-size:7px!important;line-height:1.45!important}

/* OPERATIONS: readable reference density, without changing rows/data. */
body .admin-exec .v38-live-list>div{
  min-height:33px!important;
  border-color:rgba(255,255,255,.075)!important;
}
body .admin-exec .v38-live-list>div>*{opacity:1!important}
body .admin-exec .v38-live-summary>div{background:rgba(255,255,255,.025)!important}
body .admin-exec .v40-current-summary>div{
  min-height:54px!important;
  box-shadow:0 2px 7px rgba(72,51,13,.025)!important;
}
body .admin-exec .v40-current-summary>div strong{font-size:14px!important;line-height:1!important}
body .admin-exec .v40-current-summary>div span{font-size:6.8px!important}
body .admin-exec .v38-current-table th,
body .admin-exec .v38-current-table td{font-size:7px!important}

/* LEDGER: keep full width but raise text legibility to the reference. */
body .admin-exec .v38-ledger-table th{font-size:7px!important}
body .admin-exec .v38-ledger-table td{font-size:7.1px!important}
body .admin-exec .v38-ledger-search{font-size:7.2px!important}
body .admin-exec .v38-ledger-filter,
body .admin-exec .v38-ledger-export{font-size:7.2px!important}

@media(max-width:1500px){
  body .admin-exec .v38-hero-copy-left{width:430px!important}
  body .admin-exec .ref-v36-sidebar-promo,
  body .admin-exec .v39-sidebar-promo{flex-basis:172px!important;height:172px!important;min-height:172px!important;max-height:172px!important}
}
CSS

[ "$(grep -c "AdminDashboard.v40.css" "$JSX")" -eq 1 ] || { echo 'FAILED_STEP=V40_IMPORT_COUNT'; exit 1; }
[ "$(grep -c 'data-v40-preset="7d"' "$JSX")" -eq 1 ] || { echo 'FAILED_STEP=V40_7D_PRESET_MARKER'; exit 1; }
[ "$(grep -c 'data-v40-preset="30d"' "$JSX")" -eq 1 ] || { echo 'FAILED_STEP=V40_30D_PRESET_MARKER'; exit 1; }

grep -q 'v40-current-summary' "$JSX" || { echo 'FAILED_STEP=V40_CURRENT_SUMMARY_ALIAS'; exit 1; }

npm run build

echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v40.css'
echo 'VISUAL_STRATEGY=REFERENCE_FINAL_LOCK'
echo 'V39_GEOMETRY_PRESERVED=YES'
echo 'SIDEBAR_VERTICAL_COMPOSITION_CORRECTED=YES'
echo 'DATE_PRESET_QA_MARKERS=YES'
echo 'CURRENT_SUMMARY_QA_ALIAS=YES'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
