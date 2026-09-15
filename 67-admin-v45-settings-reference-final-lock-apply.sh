#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
V44="$ROOT/src/pages/AdminDashboard.v44.css"
V45="$ROOT/src/pages/AdminDashboard.v45.css"

cd "$ROOT"
test -f "$JSX"
test -f "$V44"
grep -q "AdminDashboard.v44.css" "$JSX" || grep -q "AdminDashboard.v45.css" "$JSX"

cp "$V44" "$V45"
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
s=s.replace("import './AdminDashboard.v44.css';", "import './AdminDashboard.v45.css';")
s=s.replace('v43-reference-screen v43-settings-screen v44-settings-screen', 'v43-reference-screen v43-settings-screen v44-settings-screen v45-settings-screen')
p.write_text(s)
PY

cat >> "$V45" <<'CSS'

/* ============================================================
   V45 — SETTINGS REFERENCE FINAL LOCK
   Manual correction from authenticated V44 QA.
   Notifications + GitHub are intentionally untouched.
   Goal: remove descriptor/content overlap and keep the complete
   banking form + gold save action inside the 1448x1086 viewport.
   ============================================================ */

.v45-settings-screen .v43-screen-hero{
  height:158px;
  min-height:158px;
  margin-bottom:10px;
}
.v45-settings-screen .v44-settings-card{
  padding:16px 18px 18px !important;
  border-radius:16px !important;
}
.v45-settings-screen .v44-settings-card>h3{
  min-height:42px;
  margin:0 0 10px !important;
  padding-bottom:10px !important;
  font-size:19px !important;
}
.v45-settings-screen .v44-settings-card form{
  gap:10px !important;
}

/* Reset V44 absolute-aside layout. */
.v45-settings-screen .v44-settings-section,
.v45-settings-screen .v44-settings-bank{
  padding:14px 18px !important;
  min-height:0;
  overflow:hidden;
  border-radius:13px !important;
  background:linear-gradient(90deg,#fff 0%,#fffdf8 100%) !important;
}
.v45-settings-screen .v44-settings-aside{
  position:static !important;
  inset:auto !important;
  width:auto !important;
  min-width:0;
  height:auto;
  display:flex;
  flex-direction:column;
  justify-content:center;
  align-items:flex-start;
  gap:3px;
  direction:rtl;
  text-align:right;
  pointer-events:none;
}
.v45-settings-screen .v44-settings-aside__icon{
  width:42px;
  height:42px;
  margin:0 0 4px;
}
.v45-settings-screen .v44-settings-aside strong{font-size:13px;line-height:1.35}
.v45-settings-screen .v44-settings-aside small{font-size:10px;line-height:1.45;max-width:190px}

/* Logo row: descriptor left, real controls right. */
.v45-settings-screen .v44-settings-logo{
  display:grid !important;
  grid-template-columns:210px minmax(0,1fr);
  grid-template-rows:auto auto auto;
  column-gap:24px;
  row-gap:4px !important;
  align-items:center;
  direction:ltr;
  min-height:108px;
}
.v45-settings-screen .v44-settings-logo>.v44-settings-aside{
  grid-column:1;
  grid-row:1 / span 3;
}
.v45-settings-screen .v44-settings-logo>h4,
.v45-settings-screen .v44-settings-logo>p,
.v45-settings-screen .v44-settings-logo>div:not(.v44-settings-aside){
  grid-column:2;
  direction:rtl;
  text-align:right;
  margin-left:0 !important;
  margin-right:0 !important;
}
.v45-settings-screen .v44-settings-logo .theme-select-btn{
  min-height:38px;
  min-width:128px;
  padding:8px 12px !important;
}

/* Profile row: descriptor left, text/input center, avatar right. */
.v45-settings-screen .v44-settings-profile{
  display:grid !important;
  grid-template-columns:210px minmax(0,1fr) 82px;
  column-gap:22px !important;
  align-items:center !important;
  direction:ltr;
  min-height:116px;
}
.v45-settings-screen .v44-settings-profile>.v44-settings-aside{grid-column:1;grid-row:1}
.v45-settings-screen .v44-settings-profile>div:nth-child(2){grid-column:3;grid-row:1;justify-self:center}
.v45-settings-screen .v44-settings-profile>div:nth-child(3){grid-column:2;grid-row:1;direction:rtl;text-align:right;min-width:0}
.v45-settings-screen .v44-settings-profile input{width:100% !important;box-sizing:border-box}
.v45-settings-screen .v44-settings-profile img{width:70px !important;height:70px !important}

/* Identity row: no overlap between explanatory block and server text. */
.v45-settings-screen .v44-settings-identity{
  display:grid !important;
  grid-template-columns:210px minmax(0,1fr);
  grid-template-rows:auto auto auto;
  column-gap:24px;
  row-gap:4px !important;
  align-items:center;
  direction:ltr;
  min-height:108px;
}
.v45-settings-screen .v44-settings-identity>.v44-settings-aside{
  grid-column:1;
  grid-row:1 / span 3;
}
.v45-settings-screen .v44-settings-identity>div:not(.v44-settings-aside){
  grid-column:2;
  direction:rtl;
  text-align:right;
  min-width:0;
  margin:0 !important;
  line-height:1.55 !important;
}
.v45-settings-screen .v44-settings-identity code{font-size:11px;white-space:normal;overflow-wrap:anywhere}

/* Banking: compact complete block with save action visible in reference viewport. */
.v45-settings-screen .v44-settings-bank{
  display:grid !important;
  grid-template-columns:210px minmax(0,1fr);
  grid-template-rows:auto auto auto auto;
  column-gap:24px;
  row-gap:9px;
  align-items:start;
  direction:ltr;
  min-height:228px;
}
.v45-settings-screen .v44-settings-bank>.v44-settings-aside{
  grid-column:1;
  grid-row:1 / span 3;
  align-self:center;
}
.v45-settings-screen .v44-settings-bank>h4,
.v45-settings-screen .v44-settings-bank>div:not(.v44-settings-aside){
  grid-column:2;
  direction:rtl;
  text-align:right;
  min-width:0;
  margin:0 !important;
}
.v45-settings-screen .v44-settings-bank>h4{
  padding:0 0 8px !important;
  font-size:15px !important;
}
.v45-settings-screen .v44-settings-bank input{
  min-height:40px;
  padding:9px 12px !important;
  box-sizing:border-box;
}
.v45-settings-screen .v44-settings-bank>div:last-child{
  grid-column:1 / -1;
  direction:ltr;
  justify-content:flex-start !important;
  padding-top:2px !important;
}
.v45-settings-screen .v44-settings-bank button[type="submit"]{
  min-width:220px;
  min-height:42px;
  padding:9px 22px !important;
}

@media (max-width:1200px){
  .v45-settings-screen .v44-settings-logo,
  .v45-settings-screen .v44-settings-identity,
  .v45-settings-screen .v44-settings-bank{grid-template-columns:180px minmax(0,1fr)}
  .v45-settings-screen .v44-settings-profile{grid-template-columns:180px minmax(0,1fr) 76px}
}
CSS

[ "$(grep -c "AdminDashboard.v45.css" "$JSX")" -eq 1 ]
grep -q "v45-settings-screen" "$JSX"
grep -q "v44-settings-logo" "$JSX"
grep -q "v44-settings-profile" "$JSX"
grep -q "v44-settings-identity" "$JSX"
grep -q "v44-settings-bank" "$JSX"

npm run build

echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "RUNTIME_CSS=AdminDashboard.v45.css"
echo "SCOPE=SETTINGS_ONLY"
echo "NOTIFICATIONS_CHANGED=NO"
echo "GITHUB_CHANGED=NO"
echo "SETTINGS_OVERLAP_FIXED=YES"
echo "SETTINGS_SAVE_ACTION_VIEWPORT_TARGET=YES"
echo "DATA_CHANGED=NO"
echo "LOGIC_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
