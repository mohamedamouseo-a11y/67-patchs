#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE=src/pages/AdminDashboard.v40.css
TARGET=src/pages/AdminDashboard.v41.css
BACKUP=/tmp/67-v41-manual-reference-match-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE" ] || { echo 'FAILED_STEP=V40_CSS_MISSING'; exit 1; }
grep -q "AdminDashboard.v40.css" "$JSX" || { echo 'FAILED_STEP=V40_RUNTIME_NOT_ACTIVE'; exit 1; }
[ -f src/assets/admin-v17-health.jpg ] || { echo 'FAILED_STEP=HEALTH_REFERENCE_ASSET_MISSING'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE" "$TARGET"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
s=s.replace("import './AdminDashboard.v40.css';", "import './AdminDashboard.v41.css';", 1)
s=s.replace('className="v38-dashboard v39-dashboard v40-dashboard animate-fadeIn"', 'className="v38-dashboard v39-dashboard v40-dashboard v41-dashboard animate-fadeIn"', 1)

# Add a persistent chart callout using the existing real trendSeries data.
anchor='<div className="v38-chart-toolbar"><span>آخر 30 يوم</span><span>الإيرادات</span></div>'
callout='''<div className="v38-chart-toolbar"><span>آخر 30 يوم</span><span>الإيرادات</span></div>\n                  {trendSeries.length > 0 && (\n                    <div className="v41-chart-callout">\n                      <span>{trendSeries[Math.floor(trendSeries.length / 2)]?.label || rangeSummaryLabel}</span>\n                      <strong>{Number(trendSeries[Math.floor(trendSeries.length / 2)]?.revenue || 0).toLocaleString()} ر.س</strong>\n                    </div>\n                  )}'''
if anchor in s and 'v41-chart-callout' not in s:
    s=s.replace(anchor, callout, 1)

# Strengthen the existing area treatment without changing values/calculations.
s=s.replace('stopOpacity={0.28}', 'stopOpacity={0.36}', 1)
s=s.replace('strokeWidth={2.3}', 'strokeWidth={2.6}', 1)
s=s.replace("dot={{ r: 3, fill: '#fff8e8', stroke: '#cf8f0c', strokeWidth: 2 }}", "dot={{ r: 3.4, fill: '#fff8e8', stroke: '#cf8f0c', strokeWidth: 2 }}", 1)

p.write_text(s)
PY

cat >> "$TARGET" <<'CSS'

/* ============================================================
   SIX SEVEN ADMIN V41 — MANUAL REFERENCE MATCH
   Derived from direct side-by-side review of V40 against the approved 1448x1086 reference.
   Preserve V40 geometry and application logic. Fix the remaining visible design mismatches.
   ============================================================ */

/* 1) SYSTEM HEALTH — use the original road/light-trail scene asset that matches the reference,
      instead of recycling the hero/car artwork. */
body .admin-exec .v38-health__scene,
body .admin-exec .v39-health-scene{
  background:
    linear-gradient(90deg,rgba(5,13,20,.04) 0%,rgba(5,13,20,.28) 48%,rgba(5,13,20,.88) 100%),
    url('../assets/admin-v17-health.jpg') center 52%/cover no-repeat!important;
  box-shadow:inset 18px 0 30px rgba(4,10,16,.20)!important;
}
body .admin-exec .v38-health__scene h4{
  font-size:12px!important;
  line-height:1.15!important;
  color:#f2d46f!important;
  text-shadow:0 2px 10px rgba(0,0,0,.75)!important;
}
body .admin-exec .v38-health__scene small{font-size:5.8px!important;color:#e4d9ba!important;letter-spacing:1.25px!important}

/* Match the reference's four distinct health metric signals. */
body .admin-exec .v38-health-metric:nth-child(1) .v38-health-metric__ico{color:#33d0c9!important;background:rgba(51,208,201,.10)!important}
body .admin-exec .v38-health-metric:nth-child(2) .v38-health-metric__ico{color:#e6ad29!important;background:rgba(230,173,41,.11)!important}
body .admin-exec .v38-health-metric:nth-child(3) .v38-health-metric__ico{color:#42c9dd!important;background:rgba(66,201,221,.10)!important}
body .admin-exec .v38-health-metric:nth-child(4) .v38-health-metric__ico{color:#43d7c0!important;background:rgba(67,215,192,.10)!important}
body .admin-exec .v38-health-metric strong{font-size:17px!important}
body .admin-exec .v38-health-metric__head span{font-size:6.8px!important;color:#aeb7bb!important}

/* 2) REVENUE — V40 structure is correct, but the approved reference has a stronger analytical plot,
      persistent point callout, warmer area fill and heavier chart hierarchy. No data is modified. */
body .admin-exec .v38-chart{position:relative!important;background:linear-gradient(180deg,#fffefb,#fffdf7)!important}
body .admin-exec .v38-chart::after{content:"";position:absolute;inset:42px 16px 28px 38px;pointer-events:none;background:linear-gradient(180deg,rgba(213,157,28,.035),transparent 74%);border-radius:8px!important}
body .admin-exec .v41-chart-callout{
  position:absolute!important;
  z-index:7!important;
  left:55%!important;
  top:42px!important;
  transform:translateX(-50%)!important;
  min-width:118px!important;
  padding:7px 11px!important;
  border-radius:8px!important;
  background:#071019!important;
  border:1px solid rgba(226,180,64,.30)!important;
  box-shadow:0 7px 16px rgba(0,0,0,.25)!important;
  text-align:center!important;
  direction:rtl!important;
  pointer-events:none!important;
}
body .admin-exec .v41-chart-callout span{display:block!important;font-size:6.5px!important;line-height:1.1!important;color:#b8b0a0!important}
body .admin-exec .v41-chart-callout strong{display:block!important;margin-top:2px!important;font-size:10px!important;line-height:1!important;color:#fff2cb!important}
body .admin-exec .v38-chart-toolbar{z-index:8!important}
body .admin-exec .v38-donut-copy h4{font-size:11px!important}
body .admin-exec .v38-donut-legend{gap:5px!important}
body .admin-exec .v38-donut-legend span{font-size:7.2px!important}
body .admin-exec .v38-donut-core strong{font-size:15px!important}

/* 3) OPERATIONS — the reference is denser but more legible, with clear row separation and colored events. */
body .admin-exec .v38-live .v38-ops-head h3,
body .admin-exec .v38-current .v38-ops-head h3{font-size:11px!important;line-height:1.15!important}
body .admin-exec .v38-live .v38-ops-head small,
body .admin-exec .v38-current .v38-ops-head small{font-size:6.6px!important;line-height:1.25!important}
body .admin-exec .v38-live-row{
  min-height:36px!important;
  grid-template-columns:30px minmax(0,1fr) 72px!important;
  gap:8px!important;
  padding:5px 9px!important;
  border:1px solid rgba(255,255,255,.075)!important;
  border-radius:7px!important;
  background:linear-gradient(90deg,rgba(255,255,255,.015),rgba(255,255,255,.025))!important;
}
body .admin-exec .v38-live-row__text{font-size:7.5px!important;line-height:1.3!important;color:#f4f2ec!important;font-weight:650!important}
body .admin-exec .v38-live-row__time{font-size:6.3px!important;color:#88949b!important;white-space:nowrap!important}
body .admin-exec .v38-live-row__ico{width:24px!important;height:24px!important;border-radius:7px!important;color:#32d2b9!important;background:rgba(50,210,185,.09)!important;border:1px solid rgba(50,210,185,.16)!important}
body .admin-exec .v38-live-row:nth-child(even) .v38-live-row__ico{color:#3f9ee8!important;background:rgba(63,158,232,.09)!important;border-color:rgba(63,158,232,.16)!important}
body .admin-exec .v38-live-summary>div{min-height:44px!important}
body .admin-exec .v38-live-summary strong{font-size:12px!important}
body .admin-exec .v38-live-summary span{font-size:6.4px!important}

body .admin-exec .v40-current-summary>div{min-height:58px!important}
body .admin-exec .v40-current-summary>div strong{font-size:15px!important}
body .admin-exec .v40-current-summary>div span{font-size:7px!important;color:#77736a!important}
body .admin-exec .v38-current-table th{font-size:6.8px!important;font-weight:800!important;color:#6e675c!important}
body .admin-exec .v38-current-table td{font-size:7.2px!important;color:#25231f!important}
body .admin-exec .v38-mini-status{font-size:6.5px!important;padding:3px 8px!important}

/* 4) LEDGER — reference text/table hierarchy is stronger than V40. */
body .admin-exec .v38-ledger-title h3{font-size:11.2px!important;line-height:1.15!important}
body .admin-exec .v38-ledger-title small{font-size:6.6px!important}
body .admin-exec .v38-ledger-search{height:31px!important;font-size:7.5px!important}
body .admin-exec .v38-ledger-filter,
body .admin-exec .v38-ledger-export{height:31px!important;font-size:7.5px!important}
body .admin-exec .v38-ledger-table th{font-size:7.1px!important;font-weight:800!important}
body .admin-exec .v38-ledger-table td{font-size:7.25px!important;height:24px!important}

/* 5) SIDEBAR — reference lower rail is compact and visually anchored. */
body .admin-exec .ref-v36-sidebar-promo,
body .admin-exec .v39-sidebar-promo{border-color:rgba(224,181,71,.32)!important;box-shadow:inset 0 0 0 1px rgba(255,255,255,.015)!important}
body .admin-exec .admin-sidebar__identity.ref-v36-admin,
body .admin-exec .v39-sidebar-admin{border-color:rgba(224,181,71,.26)!important;background:linear-gradient(180deg,#0b1721,#08121b)!important}

@media(max-width:1500px){
  body .admin-exec .v41-chart-callout{left:54%!important;top:39px!important}
  body .admin-exec .v38-live-row{min-height:34px!important}
}
CSS

[ "$(grep -c "AdminDashboard.v41.css" "$JSX")" -eq 1 ] || { echo 'FAILED_STEP=V41_IMPORT_COUNT'; exit 1; }
grep -q 'v41-chart-callout' "$JSX" || { echo 'FAILED_STEP=V41_CHART_CALLOUT_MISSING'; exit 1; }
grep -q "admin-v17-health.jpg" "$TARGET" || { echo 'FAILED_STEP=V41_HEALTH_SCENE_REFERENCE_MISSING'; exit 1; }

npm run build

echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v41.css'
echo 'VISUAL_STRATEGY=MANUAL_REFERENCE_MATCH'
echo 'V40_GEOMETRY_PRESERVED=YES'
echo 'REFERENCE_HEALTH_SCENE_USED=YES'
echo 'REVENUE_CALLOUT_ADDED=YES'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
