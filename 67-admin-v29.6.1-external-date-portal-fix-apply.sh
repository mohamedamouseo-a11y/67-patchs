#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v29.6.css
TARGET_CSS=src/pages/AdminDashboard.v29.6.1.css
MARKER='SIX SEVEN ADMIN V29.6.1 — EXTERNAL DATE PORTAL FIX'
BACKUP=/tmp/67-v29.6.1-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V29_6_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v29.6.css';" "$JSX" || { echo 'FAILED_STEP=V29_6_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v29.6.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# React Portal import — keeps the popup physically outside the hero DOM tree.
portal_import="import { createPortal } from 'react-dom';"
if portal_import not in s:
    anchor="import React, { useState, useEffect, useCallback } from 'react';"
    if anchor not in s:
        raise SystemExit('REACT_IMPORT_ANCHOR_NOT_FOUND')
    s=s.replace(anchor, anchor+'\n'+portal_import, 1)

old_import="import './AdminDashboard.v29.6.css';"
new_import="import './AdminDashboard.v29.6.1.css';"
if old_import not in s:
    raise SystemExit('V29_6_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

# Convert the existing conditional popup into a body-level portal.
open_old="                    {datePopoverOpen && (\n                      <div className=\"executive-date-popover\" role=\"dialog\" aria-label=\"اختيار نطاق زمني مخصص\">"
open_new="                    {datePopoverOpen && createPortal((\n                      <div className=\"executive-date-popover\" role=\"dialog\" aria-label=\"اختيار نطاق زمني مخصص\">"
if open_old not in s:
    raise SystemExit('DATE_POPOVER_OPEN_ANCHOR_NOT_FOUND')
s=s.replace(open_old,open_new,1)

close_old="                      </div>\n                    )}\n                  </div>\n                </div>\n\n                <div className=\"ov-header__copy-left\">"
close_new="                      </div>\n                    ), document.body)}\n                  </div>\n                </div>\n\n                <div className=\"ov-header__copy-left\">"
if close_old not in s:
    raise SystemExit('DATE_POPOVER_CLOSE_ANCHOR_NOT_FOUND')
s=s.replace(close_old,close_new,1)

p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V29.6.1 — EXTERNAL DATE PORTAL FIX
   The date panel is rendered through React Portal directly under document.body.
   This removes transformed/backdrop-filter ancestors from the fixed-position
   containing block and makes hero-bottom viewport coordinates authoritative.
*/

body > .executive-date-popover{
  position:fixed!important;
  top:var(--v296-date-panel-top,220px)!important;
  left:var(--v296-date-panel-left,420px)!important;
  right:auto!important;
  margin:0!important;
  width:min(500px,calc(100vw - 340px))!important;
  max-height:min(470px,calc(100vh - var(--v296-date-panel-top,220px) - 18px))!important;
  overflow:auto!important;
  z-index:2147483000!important;
  transform:none!important;
  animation:none!important;
  direction:rtl!important;
  text-align:right!important;
  color:#f5eee2!important;
  background:
    radial-gradient(circle at 84% 6%,rgba(225,184,84,.11),transparent 26%),
    linear-gradient(180deg,rgba(9,14,21,.99),rgba(3,7,12,.99))!important;
  border:1px solid rgba(226,185,88,.38)!important;
  border-radius:18px!important;
  box-shadow:
    0 30px 70px rgba(0,0,0,.62),
    0 0 0 1px rgba(255,255,255,.02) inset,
    0 0 34px rgba(188,126,16,.08)!important;
  backdrop-filter:blur(28px) saturate(145%)!important;
  -webkit-backdrop-filter:blur(28px) saturate(145%)!important;
  isolation:isolate!important;
}

/* Restore the V29.5 executive material treatment explicitly in portal context. */
body > .executive-date-popover::before{
  content:""!important;
  position:absolute!important;
  inset:0 auto 0 0!important;
  width:3px!important;
  height:auto!important;
  background:linear-gradient(180deg,transparent,#e2b94f 28%,#9c6712 72%,transparent)!important;
  border:0!important;
  transform:none!important;
  box-shadow:0 0 20px rgba(222,177,66,.25)!important;
}
body > .executive-date-popover::after{
  content:""!important;
  position:absolute!important;
  left:24px!important;
  right:24px!important;
  top:0!important;
  height:1px!important;
  background:linear-gradient(90deg,transparent,rgba(247,214,128,.88),transparent)!important;
  opacity:.88!important;
}
body > .executive-date-popover .executive-date-popover__head{
  padding-bottom:14px!important;
  margin-bottom:14px!important;
  border-bottom:1px solid rgba(255,255,255,.06)!important;
}
body > .executive-date-popover .executive-date-popover__head strong{font-size:14px!important;color:#fff7e8!important;font-weight:900!important}
body > .executive-date-popover .executive-date-popover__head span{font-size:8.5px!important;color:#929aa5!important}
body > .executive-date-popover .executive-date-popover__badge{
  height:30px!important;min-width:66px!important;padding:0 12px!important;border-radius:999px!important;
  color:#f0cf73!important;background:linear-gradient(180deg,rgba(215,173,81,.16),rgba(215,173,81,.06))!important;
  border:1px solid rgba(226,185,88,.28)!important;
}
body > .executive-date-popover .executive-date-fields{gap:12px!important;margin-bottom:14px!important}
body > .executive-date-popover .executive-date-field-card{
  padding:10px!important;border-radius:14px!important;
  background:linear-gradient(180deg,rgba(18,27,39,.92),rgba(9,15,23,.96))!important;
  border:1px solid rgba(255,255,255,.07)!important;
}
body > .executive-date-popover .executive-date-field-label{display:block!important;margin:0 0 6px!important;color:#d7b65d!important;font-size:8px!important;font-weight:900!important}
body > .executive-date-popover .executive-date-picker{
  position:relative!important;min-height:66px!important;padding:9px 10px!important;border-radius:11px!important;
  background:linear-gradient(180deg,#111a25,#0b121b)!important;border:1px solid rgba(218,177,77,.16)!important;
}
body > .executive-date-popover .executive-date-picker__icon{
  width:38px!important;height:38px!important;border-radius:10px!important;display:grid!important;place-items:center!important;
  color:#1b1305!important;background:linear-gradient(145deg,#f3d57d,#c99129)!important;
  border:1px solid rgba(255,227,146,.44)!important;
}
body > .executive-date-popover .executive-date-picker__copy small{font-size:7.5px!important;color:#7f8995!important}
body > .executive-date-popover .executive-date-picker__copy strong{font-size:10.5px!important;color:#f5eee2!important;font-weight:900!important}
body > .executive-date-popover .executive-date-picker__chevron{color:#d5ad4a!important}
body > .executive-date-popover .executive-date-native{position:absolute!important;inset:0!important;width:100%!important;height:100%!important;opacity:0!important;cursor:pointer!important;z-index:5!important}
body > .executive-date-popover .executive-date-popover__footer{padding-top:13px!important;min-height:44px!important;border-top:1px solid rgba(255,255,255,.055)!important}
body > .executive-date-popover .executive-date-cancel{height:36px!important;padding:0 14px!important;border-radius:10px!important;color:#b7bec7!important;background:rgba(255,255,255,.035)!important;border:1px solid rgba(255,255,255,.08)!important}
body > .executive-date-popover .executive-date-apply{height:36px!important;padding:0 18px!important;border-radius:10px!important;color:#171006!important;background:linear-gradient(180deg,#f0cf72,#c58c24)!important;box-shadow:inset 0 1px rgba(255,255,255,.5),0 8px 20px rgba(190,129,27,.20)!important}
body > .executive-date-popover .executive-date-popover__hint{color:#7d8691!important;font-size:7.7px!important;line-height:1.55!important}

@media(max-width:1360px){
  body > .executive-date-popover{width:min(440px,calc(100vw - 300px))!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

grep -q "createPortal" "$JSX" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=PORTAL_NOT_INSTALLED'
  exit 1
}

npm run build >/tmp/67-v29.6.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v29.6.1-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

rm -rf "$BACKUP"

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V29.6.1'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=EXTERNAL LUXURY DATE PORTAL'
echo 'BASE_VERSION=V29.6'
echo 'TARGET_VERSION=V29.6.1'
echo 'STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v29.6.1.css'
echo 'DATE_PANEL_PORTAL_TO_BODY=YES'
echo 'DATE_PANEL_POSITION_MODE=FIXED_VIEWPORT_TRUE_PORTAL'
echo 'DATE_PICKER_LUXURY_STYLE_RESTORED=YES'
echo 'DATE_TRIGGER_POSITION_CHANGED=NO'
echo 'HERO_HEIGHT_CHANGED=NO'
echo 'HERO_IMAGE_CHANGED=NO'
echo 'HERO_COPY_CHANGED=NO'
echo 'DATE_LOGIC_CHANGED=NO'
echo 'KPI_LAYOUT_CHANGED=NO'
echo 'SIDEBAR_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
echo 'FAILED_STEP=NONE'
echo 'ERROR=NONE'
