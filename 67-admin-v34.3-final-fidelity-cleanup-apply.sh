#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE=src/pages/AdminDashboard.v34.2.css
TARGET=src/pages/AdminDashboard.v34.3.css
BACKUP=/tmp/67-v34-3-$$
MARKER='SIX SEVEN ADMIN V34.3 — FINAL FIDELITY CLEANUP'

cd "$ROOT"
[ -f "$JSX" ] || { echo FAILED_STEP=JSX_MISSING; exit 1; }
[ -f "$SOURCE" ] || { echo FAILED_STEP=V34_2_CSS_MISSING; exit 1; }
grep -q "import './AdminDashboard.v34.2.css';" "$JSX" || { echo FAILED_STEP=V34_2_RUNTIME_NOT_ACTIVE; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE" "$BACKUP/AdminDashboard.v34.2.css"
cp "$SOURCE" "$TARGET"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v34.2.css';"
new="import './AdminDashboard.v34.3.css';"
if old not in s:
    raise SystemExit('V34_2_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

cat >> "$TARGET" <<'CSS'

/* SIX SEVEN ADMIN V34.3 — FINAL FIDELITY CLEANUP
   Scope: fix only the two remaining real V34.2 fidelity defects:
   1) System Health text clipping.
   2) Sidebar horizontal overflow at 1448 reference viewport.
   No data, JSX, logic, auth, routing, API, permissions or calculations change.
*/

/* ===== SIDEBAR HORIZONTAL CONTAINMENT ===== */
body .admin-exec .admin-sidebar{
  overflow-x:hidden!important;
  scrollbar-gutter:stable!important;
  box-sizing:border-box!important;
}
body .admin-exec .admin-sidebar *,
body .admin-exec .admin-sidebar *::before,
body .admin-exec .admin-sidebar *::after{
  box-sizing:border-box!important;
}
body .admin-exec .admin-sidebar__brand,
body .admin-exec .admin-sidebar__nav-group,
body .admin-exec .admin-sidebar__footer,
body .admin-exec .admin-sidebar__identity,
body .admin-exec .admin-sidebar-button{
  width:100%!important;
  max-width:100%!important;
  min-width:0!important;
}
body .admin-exec .admin-sidebar__nav-group{overflow:hidden!important}
body .admin-exec .admin-sidebar-button{
  display:flex!important;
  align-items:center!important;
  gap:8px!important;
  overflow:hidden!important;
}
body .admin-exec .admin-sidebar-button .sb-ico{
  flex:0 0 17px!important;
  width:17px!important;
  height:17px!important;
  min-width:17px!important;
}
body .admin-exec .admin-sidebar-button>span{
  flex:1 1 auto!important;
  min-width:0!important;
  max-width:100%!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
body .admin-exec .admin-sidebar__group-label,
body .admin-exec .admin-sidebar__brand-text,
body .admin-exec .admin-sidebar__identity-info{
  min-width:0!important;
  max-width:100%!important;
  overflow:hidden!important;
}
body .admin-exec .admin-sidebar__official-logo{
  max-width:calc(100% - 28px)!important;
}
body .admin-exec .admin-sidebar__footer::before{
  left:0!important;
  right:0!important;
  width:100%!important;
  max-width:100%!important;
}
body .admin-exec .admin-sidebar__identity{gap:8px!important;overflow:hidden!important}
body .admin-exec .admin-sidebar__identity-info strong,
body .admin-exec .admin-sidebar__identity-info small{
  display:block!important;
  max-width:100%!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}

/* ===== SYSTEM HEALTH READABILITY / NO CLIPPING ===== */
body .admin-exec .syshealth{
  height:112px!important;
  min-height:112px!important;
  max-height:112px!important;
  overflow:hidden!important;
}
body .admin-exec .syshealth__layout{
  height:100%!important;
  min-height:0!important;
  grid-template-columns:20% 50% 30%!important;
  gap:7px!important;
  padding:8px 10px!important;
  align-items:stretch!important;
}
body .admin-exec .syshealth__zone-left,
body .admin-exec .syshealth__zone-center,
body .admin-exec .syshealth__zone-right,
body .admin-exec .syshealth__metrics,
body .admin-exec .syshealth__grid{
  min-width:0!important;
  min-height:0!important;
  max-height:100%!important;
}
body .admin-exec .syshealth__zone-left{
  justify-content:center!important;
  padding-right:8px!important;
  overflow:hidden!important;
}
body .admin-exec .syshealth__head{
  min-width:0!important;
  min-height:0!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__title{
  margin:0 0 4px!important;
  font-size:9.6px!important;
  line-height:1.22!important;
  white-space:normal!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__title>span:last-child{
  min-width:0!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__title small{
  display:block!important;
  margin-top:2px!important;
  font-size:7.1px!important;
  line-height:1.18!important;
  white-space:normal!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__status{
  display:inline-flex!important;
  align-items:center!important;
  min-height:18px!important;
  font-size:7.3px!important;
  line-height:1!important;
  white-space:nowrap!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__status-text{
  margin-top:3px!important;
  font-size:6.6px!important;
  line-height:1.18!important;
  white-space:normal!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__status-text p{
  margin:0!important;
  padding:0!important;
  line-height:1.18!important;
  white-space:normal!important;
}
body .admin-exec .syshealth__grid{
  height:100%!important;
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:6px!important;
  align-items:stretch!important;
}
body .admin-exec .syshealth__metric{
  height:94px!important;
  min-height:94px!important;
  max-height:94px!important;
  padding:8px 8px 7px!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:space-between!important;
  overflow:hidden!important;
}
body .admin-exec .syshealth__metric label{
  display:block!important;
  min-height:16px!important;
  font-size:7.15px!important;
  line-height:1.12!important;
  white-space:normal!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__metric strong{
  font-size:15.5px!important;
  line-height:1!important;
  white-space:nowrap!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__metric small{
  display:block!important;
  min-height:14px!important;
  font-size:6.15px!important;
  line-height:1.12!important;
  white-space:normal!important;
  overflow:visible!important;
}
body .admin-exec .syshealth__bar{
  flex:0 0 3px!important;
  height:3px!important;
  min-height:3px!important;
  margin:1px 0!important;
}

/* Keep all already-approved V34.2 geometry untouched outside the two targets. */
CSS

grep -q "$MARKER" "$TARGET" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET"
  echo FAILED_STEP=CSS_MARKER_MISSING
  exit 1
}

npm run build >/tmp/67-v34-3-build.log 2>&1 || {
  tail -n 160 /tmp/67-v34-3-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET"
  echo FAILED_STEP=BUILD_FAILED
  exit 1
}

echo PATCH_APPLIED=YES
echo BUILD=PASS
echo RUNTIME_CSS=AdminDashboard.v34.3.css
echo DATA_CHANGED=NO
echo LOGIC_CHANGED=NO
echo BACKEND_CHANGED=NO
echo AUTH_CHANGED=NO
echo SOURCE_PROJECT_PUSHED=NO
