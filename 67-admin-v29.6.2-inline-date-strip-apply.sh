#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.6.1.css
TARGET_CSS=src/pages/AdminDashboard.v29.6.2.css
MARKER='SIX SEVEN ADMIN V29.6.2 — INLINE DATE STRIP'
BACKUP=/tmp/67-v29.6.2-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V29_6_1_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.6.1.css';" "$JSX" || { echo 'FAILED_STEP=V29_6_1_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v29.6.1.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# Runtime CSS cutover.
old_import="import './AdminDashboard.v29.6.1.css';"
new_import="import './AdminDashboard.v29.6.2.css';"
if old_import not in s:
    raise SystemExit('V29_6_1_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

# Move the existing luxury panel OUT of the hero shell and INTO normal document flow.
# This intentionally removes the body portal so opening the panel pushes KPI content down.
open_token='                    {datePopoverOpen && createPortal((\n'
close_token='                    ), document.body)}'
start=s.find(open_token)
if start < 0:
    raise SystemExit('PORTAL_OPEN_NOT_FOUND')
content_start=start+len(open_token)
end=s.find(close_token,content_start)
if end < 0:
    raise SystemExit('PORTAL_CLOSE_NOT_FOUND')
panel_markup=s[content_start:end]
# Add flow modifier to the existing outer panel node.
panel_markup=panel_markup.replace('className="executive-date-popover"','className="executive-date-popover executive-date-popover--flow"',1)
# Remove portal conditional from inside the hero toolbar.
s=s[:start]+'                    {/* V29.6.2: custom date panel is rendered below the hero in normal flow. */}\n'+s[end+len(close_token):]

insert_anchor='            {/* KPI row */}'
idx=s.find(insert_anchor)
if idx < 0:
    raise SystemExit('KPI_ANCHOR_NOT_FOUND')
flow_block=(
"            {datePopoverOpen && (\n"
"              <div className=\"executive-date-flow-slot\" aria-live=\"polite\">\n"
+ panel_markup + "\n"
"              </div>\n"
"            )}\n\n"
)
s=s[:idx]+flow_block+s[idx:]

# createPortal is no longer used in this version.
s=s.replace("import { createPortal } from 'react-dom';\n",'',1)

p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.6.2 — INLINE DATE STRIP
   The luxury date-range panel is now a real document-flow strip directly below
   the hero. It never overlaps the hero or KPI cards. Opening it intentionally
   pushes the KPI row down; closing it restores the original layout. */

body .admin-exec .ov-header,
body .admin-exec .ov-header.date-control-open{
  height:172px!important;
  min-height:172px!important;
  overflow:hidden!important;
  transform:none!important;
  animation:none!important;
}

body .admin-exec .executive-date-flow-slot{
  position:relative!important;
  width:100%!important;
  min-width:0!important;
  display:flex!important;
  justify-content:center!important;
  align-items:stretch!important;
  margin:0!important;
  padding:0 16px!important;
  z-index:30!important;
  overflow:visible!important;
  animation:v2962StripReveal .16s ease-out both!important;
}

@keyframes v2962StripReveal{
  from{opacity:0;transform:translateY(-5px)}
  to{opacity:1;transform:translateY(0)}
}

/* Override V29.6/V29.6.1 fixed portal positioning. */
body .admin-exec .executive-date-flow-slot .executive-date-popover.executive-date-popover--flow{
  position:relative!important;
  inset:auto!important;
  top:auto!important;
  left:auto!important;
  right:auto!important;
  bottom:auto!important;
  margin:0 auto!important;
  width:min(980px,100%)!important;
  max-width:980px!important;
  max-height:none!important;
  min-height:126px!important;
  overflow:hidden!important;
  z-index:31!important;
  transform:none!important;
  animation:none!important;
  direction:rtl!important;
  text-align:right!important;
  display:grid!important;
  grid-template-columns:minmax(190px,.95fr) minmax(390px,1.8fr) minmax(190px,.95fr)!important;
  grid-template-areas:'head fields footer'!important;
  align-items:center!important;
  gap:14px!important;
  padding:14px 16px!important;
  border-radius:16px!important;
  color:#f5eee2!important;
  background:
    radial-gradient(circle at 84% 5%,rgba(225,184,84,.10),transparent 28%),
    linear-gradient(180deg,rgba(9,14,21,.995),rgba(3,7,12,.995))!important;
  border:1px solid rgba(226,185,88,.38)!important;
  box-shadow:0 18px 42px rgba(0,0,0,.28),0 0 0 1px rgba(255,255,255,.02) inset,0 0 28px rgba(188,126,16,.06)!important;
  backdrop-filter:blur(24px) saturate(145%)!important;
  -webkit-backdrop-filter:blur(24px) saturate(145%)!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-popover--flow::before{
  content:""!important;
  position:absolute!important;
  inset:0 auto 0 0!important;
  width:3px!important;
  height:auto!important;
  background:linear-gradient(180deg,transparent,#e2b94f 28%,#9c6712 72%,transparent)!important;
  border:0!important;
  transform:none!important;
  box-shadow:0 0 18px rgba(222,177,66,.22)!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover--flow::after{
  content:""!important;
  position:absolute!important;
  left:24px!important;
  right:24px!important;
  top:0!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,rgba(247,214,128,.82),transparent)!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-popover__head{
  grid-area:head!important;
  min-width:0!important;
  margin:0!important;
  padding:0 0 0 14px!important;
  border:0!important;
  border-left:1px solid rgba(255,255,255,.055)!important;
  align-self:stretch!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:center!important;
  gap:7px!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__head>div{min-width:0!important}
body .admin-exec .executive-date-flow-slot .executive-date-popover__head strong{font-size:13px!important;color:#fff7e8!important;font-weight:900!important}
body .admin-exec .executive-date-flow-slot .executive-date-popover__head span{font-size:7.8px!important;line-height:1.5!important;color:#8c949f!important}
body .admin-exec .executive-date-flow-slot .executive-date-popover__badge{
  width:max-content!important;height:26px!important;min-width:58px!important;padding:0 10px!important;
  display:grid!important;place-items:center!important;border-radius:999px!important;
  color:#f0cf73!important;background:rgba(215,173,81,.09)!important;border:1px solid rgba(226,185,88,.24)!important;
}

body .admin-exec .executive-date-flow-slot .executive-date-fields{
  grid-area:fields!important;
  display:grid!important;
  grid-template-columns:1fr 1fr!important;
  gap:9px!important;
  margin:0!important;
  min-width:0!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-field-card{
  min-width:0!important;padding:8px!important;border-radius:12px!important;
  background:linear-gradient(180deg,rgba(18,27,39,.92),rgba(9,15,23,.96))!important;
  border:1px solid rgba(255,255,255,.065)!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-field-label{display:block!important;margin:0 0 4px!important;color:#d7b65d!important;font-size:7.6px!important;font-weight:900!important}
body .admin-exec .executive-date-flow-slot .executive-date-picker{
  position:relative!important;min-height:50px!important;padding:6px 8px!important;border-radius:10px!important;
  background:linear-gradient(180deg,#111a25,#0b121b)!important;border:1px solid rgba(218,177,77,.16)!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-picker__icon{width:32px!important;height:32px!important;border-radius:9px!important}
body .admin-exec .executive-date-flow-slot .executive-date-picker__copy small{font-size:7px!important}
body .admin-exec .executive-date-flow-slot .executive-date-picker__copy strong{font-size:9.6px!important}

body .admin-exec .executive-date-flow-slot .executive-date-popover__footer{
  grid-area:footer!important;
  min-width:0!important;
  min-height:0!important;
  margin:0!important;
  padding:0 14px 0 0!important;
  border:0!important;
  border-right:1px solid rgba(255,255,255,.055)!important;
  align-self:stretch!important;
  display:flex!important;
  flex-direction:column!important;
  align-items:stretch!important;
  justify-content:center!important;
  gap:8px!important;
}
body .admin-exec .executive-date-flow-slot .executive-date-popover__hint{max-width:none!important;font-size:7.2px!important;line-height:1.5!important;color:#7d8691!important}
body .admin-exec .executive-date-flow-slot .executive-date-popover__buttons{display:grid!important;grid-template-columns:1fr 1.35fr!important;gap:6px!important;width:100%!important;margin:0!important}
body .admin-exec .executive-date-flow-slot .executive-date-cancel,
body .admin-exec .executive-date-flow-slot .executive-date-apply{height:32px!important;padding:0 10px!important;border-radius:9px!important;font-size:8px!important}

@media(max-width:1320px){
  body .admin-exec .executive-date-flow-slot .executive-date-popover.executive-date-popover--flow{
    grid-template-columns:1fr 1.6fr!important;
    grid-template-areas:'head fields' 'footer footer'!important;
    width:min(820px,100%)!important;
  }
  body .admin-exec .executive-date-flow-slot .executive-date-popover__footer{
    border-right:0!important;border-top:1px solid rgba(255,255,255,.055)!important;padding:9px 0 0!important;
    flex-direction:row!important;align-items:center!important;
  }
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

grep -q 'executive-date-flow-slot' "$JSX" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=FLOW_SLOT_MISSING'
  exit 1
}

if grep -q 'createPortal' "$JSX"; then
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=PORTAL_STILL_PRESENT'
  exit 1
fi

npm run build >/tmp/67-v29.6.2-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.6.2-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V29.6.2'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=INLINE LUXURY DATE STRIP'
echo 'BASE_VERSION=V29.6.1'
echo 'TARGET_VERSION=V29.6.2'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v29.6.2.css'
echo 'DATE_PANEL_IN_DOCUMENT_FLOW=YES'
echo 'DATE_PANEL_PORTAL_TO_BODY=NO'
echo 'DATE_PANEL_POSITION_MODE=FLOW_BELOW_HERO'
echo 'DATE_PANEL_COMPACT_HORIZONTAL=YES'
echo 'DATE_PICKER_LUXURY_STYLE_PRESERVED=YES'
echo 'KPI_PUSHES_DOWN_WHEN_OPEN=YES_EXPECTED'
echo 'KPI_RETURNS_WHEN_CLOSED=YES_EXPECTED'
echo 'HERO_HEIGHT_CHANGED=NO'
echo 'HERO_IMAGE_CHANGED=NO'
echo 'HERO_COPY_CHANGED=NO'
echo 'DATE_LOGIC_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
