#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.6.2.css
TARGET_CSS=src/pages/AdminDashboard.v29.6.3.css
MARKER='SIX SEVEN ADMIN V29.6.3 — DATE STRIP FINAL POLISH'
BACKUP=/tmp/67-v29.6.3-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V29_6_2_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.6.2.css';" "$JSX" || { echo 'FAILED_STEP=V29_6_2_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v29.6.2.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v29.6.2.css';"
new="import './AdminDashboard.v29.6.3.css';"
if old not in s:
    raise SystemExit('V29_6_2_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.6.3 — DATE STRIP FINAL POLISH
   Final visual pass only: remove action-button clipping, rebalance the 3-column
   composition, tighten spacing, preserve the flow-below-hero behavior, and add
   a restrained open transition. No date logic, hero geometry or KPI logic changes. */

body .admin-exec .executive-date-flow-slot{
  box-sizing:border-box!important;
  padding:0 20px!important;
  overflow:visible!important;
  animation:v2963StripIn .18s cubic-bezier(.2,.75,.25,1) both!important;
}

@keyframes v2963StripIn{
  from{opacity:0;transform:translateY(-4px)}
  to{opacity:1;transform:translateY(0)}
}

body .admin-exec .executive-date-flow-slot .executive-date-popover.executive-date-popover--flow{
  box-sizing:border-box!important;
  width:min(940px,100%)!important;
  max-width:940px!important;
  min-height:138px!important;
  padding:14px 18px!important;
  gap:16px!important;
  grid-template-columns:minmax(200px,.9fr) minmax(420px,1.7fr) minmax(220px,1fr)!important;
  grid-template-areas:'head fields footer'!important;
  align-items:center!important;
  overflow:hidden!important;
  border-radius:16px!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-popover__head,
body .admin-exec .executive-date-flow-slot .executive-date-fields,
body .admin-exec .executive-date-flow-slot .executive-date-popover__footer{
  box-sizing:border-box!important;
  min-width:0!important;
  width:100%!important;
  max-width:100%!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-popover__head{
  padding:0 0 0 16px!important;
  gap:6px!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__head strong{
  font-size:13.2px!important;
  line-height:1.25!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__head span{
  font-size:7.7px!important;
  line-height:1.55!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__badge{
  height:26px!important;
  min-width:60px!important;
  padding:0 11px!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-fields{
  grid-template-columns:minmax(0,1fr) minmax(0,1fr)!important;
  gap:10px!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-field-card{
  box-sizing:border-box!important;
  min-width:0!important;
  width:100%!important;
  padding:9px!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-picker{
  box-sizing:border-box!important;
  width:100%!important;
  min-width:0!important;
  min-height:52px!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-picker__copy{
  min-width:0!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-picker__copy strong{
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-popover__footer{
  padding:0 16px 0 0!important;
  gap:9px!important;
  overflow:visible!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__hint{
  box-sizing:border-box!important;
  width:100%!important;
  max-width:100%!important;
  margin:0!important;
  font-size:7.15px!important;
  line-height:1.55!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__buttons{
  box-sizing:border-box!important;
  display:grid!important;
  grid-template-columns:minmax(0,1fr) minmax(0,1.28fr)!important;
  gap:7px!important;
  width:100%!important;
  min-width:0!important;
  max-width:100%!important;
  margin:0!important;
  padding:0!important;
  overflow:visible!important;
  transform:none!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-cancel,
body .admin-exec .executive-date-flow-slot .executive-date-apply{
  box-sizing:border-box!important;
  position:relative!important;
  inset:auto!important;
  width:100%!important;
  min-width:0!important;
  max-width:100%!important;
  height:34px!important;
  margin:0!important;
  padding:0 10px!important;
  transform:none!important;
  overflow:hidden!important;
  white-space:nowrap!important;
  text-overflow:ellipsis!important;
  border-radius:9px!important;
  font-size:8.1px!important;
  line-height:1!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-apply{
  box-shadow:inset 0 1px rgba(255,255,255,.46),0 7px 18px rgba(190,129,27,.16)!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-cancel:hover,
body .admin-exec .executive-date-flow-slot .executive-date-apply:hover{
  transform:translateY(-1px)!important;
}

@media(max-width:1500px){
  body .admin-exec .executive-date-flow-slot .executive-date-popover.executive-date-popover--flow{
    width:min(900px,100%)!important;
    grid-template-columns:minmax(190px,.9fr) minmax(390px,1.65fr) minmax(210px,1fr)!important;
    gap:14px!important;
    padding:13px 16px!important;
  }
}

@media(max-width:1180px){
  body .admin-exec .executive-date-flow-slot .executive-date-popover.executive-date-popover--flow{
    width:min(820px,100%)!important;
    grid-template-columns:minmax(190px,.9fr) minmax(0,1.6fr)!important;
    grid-template-areas:'head fields' 'footer footer'!important;
  }
  body .admin-exec .executive-date-flow-slot .executive-date-popover__footer{
    border-right:0!important;
    border-top:1px solid rgba(255,255,255,.055)!important;
    padding:10px 0 0!important;
    display:grid!important;
    grid-template-columns:minmax(0,1fr) minmax(250px,.75fr)!important;
    align-items:center!important;
  }
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v29.6.3-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.6.3-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V29.6.3'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=DATE STRIP FINAL POLISH'
echo 'BASE_VERSION=V29.6.2'
echo 'TARGET_VERSION=V29.6.3'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v29.6.3.css'
echo 'ACTION_BUTTON_CLIPPING_FIX=YES'
echo 'DATE_STRIP_COLUMN_REBALANCE=YES'
echo 'DATE_STRIP_SPACING_POLISH=YES'
echo 'DATE_STRIP_OPEN_TRANSITION=YES'
echo 'DATE_PANEL_IN_DOCUMENT_FLOW=YES'
echo 'DATE_LOGIC_CHANGED=NO'
echo 'HERO_HEIGHT_CHANGED=NO'
echo 'HERO_IMAGE_CHANGED=NO'
echo 'HERO_COPY_CHANGED=NO'
echo 'KPI_FLOW_BEHAVIOR_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
