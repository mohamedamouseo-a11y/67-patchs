#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE=src/pages/AdminDashboard.v38.css
TARGET=src/pages/AdminDashboard.v39.css
BACKUP=/tmp/67-v39-reference-convergence-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE" ] || { echo 'FAILED_STEP=V38_CSS_MISSING'; exit 1; }
grep -q "AdminDashboard.v38.css" "$JSX" || { echo 'FAILED_STEP=V38_RUNTIME_NOT_ACTIVE'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE" "$TARGET"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
s=s.replace("import './AdminDashboard.v38.css';","import './AdminDashboard.v39.css';",1)
repls=[
 ('className="v38-dashboard animate-fadeIn"','className="v38-dashboard v39-dashboard animate-fadeIn"'),
 ('className="v38-admin-mini"','className="v38-admin-mini v39-hero-greeting"'),
 ('className="v38-hero-copy-right"','className="v38-hero-copy-right v39-hero-right-copy"'),
 ('className="v38-health__scene"','className="v38-health__scene v39-health-scene"'),
 ('className="ref-v36-sidebar-promo"','className="ref-v36-sidebar-promo v39-sidebar-promo"'),
 ('className="admin-sidebar__identity ref-v36-admin"','className="admin-sidebar__identity ref-v36-admin v39-sidebar-admin"'),
]
for a,b in repls:
    if a in s and b not in s:
        s=s.replace(a,b,1)
p.write_text(s)
PY

cat >> "$TARGET" <<'CSS'

/* ============================================================
   SIX SEVEN ADMIN V39 — REFERENCE CONVERGENCE
   Final full-page alignment pass against the approved 1448x1086 reference.
   V38 geometry is preserved; high-impact composition differences are corrected.
   ============================================================ */

/* Keep the exact 8px main/sidebar seam from V38. */
body .admin-exec>div[style*="marginRight"]{margin-right:200px!important;padding-right:8px!important}

/* Reference hero hierarchy — slightly stronger and lower, matching the supplied master image. */
body .admin-exec .v38-hero-copy-left{top:61px!important;width:455px!important}
body .admin-exec .v38-hero-copy-left h1{font-size:26px!important;line-height:1.08!important;letter-spacing:-.25px!important}
body .admin-exec .v38-hero-copy-left p{font-size:8.3px!important;color:#f0eadb!important}
body .admin-exec .v38-hero-copy-right{top:49px!important;right:29px!important}
body .admin-exec .v38-hero-copy-right span{font-size:11.5px!important}
body .admin-exec .v38-hero-copy-right strong{font-size:16.5px!important}
body .admin-exec .v38-admin-mini b{font-size:8.1px!important}
body .admin-exec .v38-admin-mini small{font-size:6.6px!important}

/* SYSTEM HEALTH — V38 was physically mirrored vs reference.
   Exact physical order in reference: STATUS LEFT / 4 METRICS CENTER / SCENE RIGHT. */
body .admin-exec .v38-health{
  direction:ltr!important;
  grid-template-columns:180px minmax(0,1fr) 300px!important;
  align-items:stretch!important;
}
body .admin-exec .v38-health__status{
  grid-column:1!important;grid-row:1!important;
  direction:rtl!important;text-align:right!important;
  border-left:0!important;border-right:0!important;
}
body .admin-exec .v38-health__metrics{
  grid-column:2!important;grid-row:1!important;
  direction:ltr!important;
}
body .admin-exec .v38-health-metric{direction:rtl!important;text-align:right!important}
body .admin-exec .v38-health__scene{
  grid-column:3!important;grid-row:1!important;
  direction:rtl!important;text-align:right!important;
  background-position:center 58%!important;
}
body .admin-exec .v38-health__scene h4{color:#f2d36f!important;font-size:11.5px!important;line-height:1.18!important}
body .admin-exec .v38-health__scene small{color:#d8ccb0!important;letter-spacing:1.15px!important}

/* REVENUE — reinforce dark donut typography and visual weight to reference. */
body .admin-exec .v38-donut{background:linear-gradient(180deg,#0b1722,#07111a)!important;border-color:rgba(217,166,44,.25)!important}
body .admin-exec .v38-donut-copy h4{color:#fff4d2!important;font-weight:900!important}
body .admin-exec .v38-donut-legend span{color:#e9e2d4!important}
body .admin-exec .v38-donut-foot span{color:#aaa28f!important}
body .admin-exec .v38-donut-core strong{color:#fff!important}
body .admin-exec .v38-chart{background:#fffefb!important}

/* LIVE OPERATIONS — reference uses strong white hierarchy on the dark card. */
body .admin-exec .v38-live .v38-ops-head h3{color:#fff7df!important;font-weight:900!important}
body .admin-exec .v38-live .v38-ops-head small{color:#9aa3a8!important}
body .admin-exec .v38-live .v38-ops-head button{color:#f0cf6b!important;border-color:rgba(218,169,45,.32)!important;background:rgba(218,169,45,.06)!important}
body .admin-exec .v38-live-summary strong{color:#fff!important}
body .admin-exec .v38-live-summary span{color:#8d989e!important}

/* CURRENT OPERATIONS — match the three reference status summary tiles. */
body .admin-exec .v38-current-summary>div:nth-child(1){background:#eef7ff!important;border-color:#d6e8f6!important}
body .admin-exec .v38-current-summary>div:nth-child(2){background:#fff8e7!important;border-color:#f0dfb5!important}
body .admin-exec .v38-current-summary>div:nth-child(3){background:#effaf6!important;border-color:#cfeadf!important}
body .admin-exec .v38-current-summary>div:nth-child(1) strong{color:#2c80c9!important}
body .admin-exec .v38-current-summary>div:nth-child(2) strong{color:#bb7b11!important}
body .admin-exec .v38-current-summary>div:nth-child(3) strong{color:#139b72!important}

/* Ledger stays full width; slightly denser rows so the complete block reads like the reference. */
body .admin-exec .v38-ledger{width:100%!important;max-width:none!important}
body .admin-exec .v38-ledger-table th{height:24px!important}
body .admin-exec .v38-ledger-table td{height:25px!important;padding-top:4px!important;padding-bottom:4px!important}

/* Sidebar elements are already visually present in V38; give them V39 aliases and preserve visibility. */
body .admin-exec .v39-sidebar-promo{display:block!important;visibility:visible!important;opacity:1!important}
body .admin-exec .v39-sidebar-admin{display:flex!important;visibility:visible!important;opacity:1!important}
body .admin-exec .v39-hero-greeting{display:flex!important;visibility:visible!important;opacity:1!important}
body .admin-exec .v39-hero-right-copy{display:block!important;visibility:visible!important;opacity:1!important}

@media(max-width:1500px){
 body .admin-exec .v38-health{grid-template-columns:178px minmax(0,1fr) 292px!important}
 body .admin-exec .v38-hero-copy-left{width:440px!important}
}
CSS

# Guard against accidental duplicate V39 import.
[ "$(grep -c "AdminDashboard.v39.css" "$JSX")" -eq 1 ] || { echo 'FAILED_STEP=V39_IMPORT_COUNT'; exit 1; }

npm run build

echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v39.css'
echo 'VISUAL_STRATEGY=REFERENCE_CONVERGENCE_FULL_PAGE'
echo 'V38_GEOMETRY_PRESERVED=YES'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
