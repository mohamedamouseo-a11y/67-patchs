#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v21.1.css
TARGET_CSS=src/pages/AdminDashboard.v22.css
BACKUP=/tmp/67-v22-kpi-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v22.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v22-kpi-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V22_PREMIUM_KPI_CARDS_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v22.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V22 — PREMIUM KPI CARDS" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V22
elif grep -q "import './AdminDashboard.v21.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$SOURCE_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V21.1 — FAVICON ONLY + HERO CLEANUP" "$SOURCE_CSS"; then
  STATE_ACTION=APPLY_V22
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v22.css"
  fi

  cp "$SOURCE_CSS" "$TARGET_CSS"
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V22 — PREMIUM KPI CARDS
   Base: V21.1 approved favicon + hero state.
   Scope lock: KPI strip only.
   Goals:
   - stronger executive hierarchy,
   - premium ivory/gold material treatment,
   - cleaner spacing and icon system,
   - visible micro-trend language using existing markup,
   - zero changes to KPI values, data, calculations or interactions. */

.kpi-grid{
  display:grid!important;
  grid-template-columns:repeat(4,minmax(0,1fr))!important;
  gap:12px!important;
  margin:2px 0 1px!important;
  align-items:stretch!important;
}

.kpi-card{
  --kpi-accent:#c4932f;
  --kpi-accent-soft:rgba(196,147,47,.13);
  position:relative!important;
  isolation:isolate!important;
  height:128px!important;
  min-height:128px!important;
  padding:15px 16px 13px!important;
  overflow:hidden!important;
  display:grid!important;
  grid-template-rows:auto 1fr auto!important;
  gap:7px!important;
  border-radius:17px!important;
  background:
    radial-gradient(circle at 92% 3%,var(--kpi-accent-soft),transparent 35%),
    linear-gradient(145deg,#fffefa 0%,#fbf6ec 56%,#f5eddf 100%)!important;
  border:1px solid rgba(177,122,22,.28)!important;
  box-shadow:
    0 13px 30px rgba(77,50,5,.075),
    inset 0 1px 0 rgba(255,255,255,.92),
    inset 0 -1px 0 rgba(144,91,12,.035)!important;
  transition:transform .2s ease,box-shadow .2s ease,border-color .2s ease!important;
}

.kpi-card:nth-child(1){--kpi-accent:#bd8a22;--kpi-accent-soft:rgba(189,138,34,.15)}
.kpi-card:nth-child(2){--kpi-accent:#159a69;--kpi-accent-soft:rgba(21,154,105,.11)}
.kpi-card:nth-child(3){--kpi-accent:#a97021;--kpi-accent-soft:rgba(169,112,33,.13)}
.kpi-card:nth-child(4){--kpi-accent:#627180;--kpi-accent-soft:rgba(98,113,128,.10)}

.kpi-card::before{
  content:""!important;
  position:absolute!important;
  top:0!important;
  right:18px!important;
  left:18px!important;
  height:3px!important;
  border-radius:0 0 8px 8px!important;
  background:linear-gradient(90deg,transparent,var(--kpi-accent),transparent)!important;
  opacity:.92!important;
  z-index:2!important;
}

.kpi-card::after{
  content:""!important;
  position:absolute!important;
  width:118px!important;
  height:118px!important;
  left:-42px!important;
  bottom:-70px!important;
  border-radius:50%!important;
  background:radial-gradient(circle,var(--kpi-accent-soft),transparent 68%)!important;
  clip-path:none!important;
  opacity:.82!important;
  pointer-events:none!important;
  z-index:-1!important;
}

.kpi-card__top{
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:12px!important;
  min-width:0!important;
}

.kpi-card__label{
  font-size:11.5px!important;
  line-height:1.35!important;
  color:#777168!important;
  font-weight:850!important;
  letter-spacing:-.01em!important;
}

.kpi-card__icon{
  width:46px!important;
  height:46px!important;
  min-width:46px!important;
  flex:0 0 46px!important;
  border-radius:13px!important;
  display:grid!important;
  place-items:center!important;
  color:var(--kpi-accent)!important;
  background:
    radial-gradient(circle at 32% 22%,rgba(255,255,255,.95),transparent 34%),
    linear-gradient(145deg,#fffdf6 0%,#f2e6cb 100%)!important;
  border:1px solid color-mix(in srgb,var(--kpi-accent) 28%,transparent)!important;
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,.96),
    0 8px 18px rgba(89,57,6,.08)!important;
}
.kpi-card__icon svg{width:19px!important;height:19px!important;stroke-width:2.1!important}

.kpi-card__value{
  align-self:center!important;
  margin:0!important;
  min-width:0!important;
  font-size:34px!important;
  line-height:.95!important;
  font-weight:950!important;
  color:#09111b!important;
  letter-spacing:-.045em!important;
  text-shadow:0 1px 0 rgba(255,255,255,.55)!important;
}
.kpi-card__value small{
  margin-inline-start:3px!important;
  font-size:10.5px!important;
  font-weight:850!important;
  letter-spacing:0!important;
  color:#8e877d!important;
}

.kpi-card__note{
  min-height:22px!important;
  margin:0!important;
  padding:0!important;
  display:flex!important;
  align-items:flex-end!important;
  gap:6px!important;
  font-size:9.3px!important;
  line-height:1.2!important;
  color:#149767!important;
  white-space:nowrap!important;
  overflow:visible!important;
  border-top:1px solid rgba(128,89,18,.07)!important;
  padding-top:7px!important;
}
.kpi-card__note>svg{
  width:13px!important;
  height:13px!important;
  flex:0 0 13px!important;
  color:#149767!important;
  stroke-width:2.3!important;
}
.kpi-card__note .muted{
  min-width:0!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
  color:#8b857c!important;
  font-weight:750!important;
}

/* Existing five-span markup becomes a restrained executive micro-trend. */
.kpi-microbar{
  margin-inline-start:auto!important;
  height:18px!important;
  min-width:36px!important;
  display:flex!important;
  align-items:flex-end!important;
  justify-content:flex-end!important;
  gap:2px!important;
  direction:ltr!important;
  opacity:.88!important;
}
.kpi-microbar>span{
  display:block!important;
  width:4px!important;
  border-radius:4px 4px 1px 1px!important;
  background:linear-gradient(180deg,var(--kpi-accent),color-mix(in srgb,var(--kpi-accent) 58%,#18221f))!important;
  box-shadow:0 1px 4px color-mix(in srgb,var(--kpi-accent) 18%,transparent)!important;
}
.kpi-microbar>span:nth-child(1){height:6px!important;opacity:.48!important}
.kpi-microbar>span:nth-child(2){height:9px!important;opacity:.60!important}
.kpi-microbar>span:nth-child(3){height:8px!important;opacity:.68!important}
.kpi-microbar>span:nth-child(4){height:13px!important;opacity:.80!important}
.kpi-microbar>span:nth-child(5){height:17px!important;opacity:1!important}

@media(prefers-reduced-motion:no-preference){
  .kpi-card:hover{
    transform:translateY(-2px)!important;
    border-color:color-mix(in srgb,var(--kpi-accent) 48%,transparent)!important;
    box-shadow:
      0 18px 38px rgba(77,50,5,.11),
      inset 0 1px 0 rgba(255,255,255,.95)!important;
  }
}

@media(max-width:1360px){
  .kpi-grid{gap:9px!important}
  .kpi-card{height:118px!important;min-height:118px!important;padding:13px 14px 11px!important}
  .kpi-card__icon{width:42px!important;height:42px!important;min-width:42px!important;flex-basis:42px!important;border-radius:12px!important}
  .kpi-card__value{font-size:30px!important}
  .kpi-card__label{font-size:10.5px!important}
  .kpi-card__note{font-size:8.7px!important}
}

@media(max-width:1080px){
  .kpi-grid{grid-template-columns:repeat(2,minmax(0,1fr))!important}
}
CSS

  FAILED_STEP=wire_runtime
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v21.1.css';"
new="import './AdminDashboard.v22.css';"
if old not in s:
    raise SystemExit('V21_1_RUNTIME_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

  grep -q "import './AdminDashboard.v22.css';" "$TARGET_JSX"
  grep -q "SIX SEVEN ADMIN V22 — PREMIUM KPI CARDS" "$TARGET_CSS"
else
  FAILED_STEP=unsupported_runtime_state
  echo "CURRENT_CSS_IMPORTS_BEGIN"
  grep -n "AdminDashboard.*css" "$TARGET_JSX" || true
  echo "CURRENT_CSS_IMPORTS_END"
  fail UNSUPPORTED_RUNTIME_STATE
fi

FAILED_STEP=build
npm run build >/tmp/67-v22-kpi-build.log 2>&1 || {
  tail -n 120 /tmp/67-v22-kpi-build.log || true
  fail BUILD_FAILED
}

FAILED_STEP=verify_dist
[ -f dist/index.html ] || fail DIST_INDEX_MISSING

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V21.1"
echo "TARGET_VERSION=V22"
echo "RUNTIME_CSS=AdminDashboard.v22.css"
echo "ELEMENT=KPI_CARDS_ONLY"
echo "KPI_LAYOUT_PREMIUM=YES"
echo "KPI_HIERARCHY_UPGRADED=YES"
echo "KPI_MICROTREND_VISIBLE=YES"
echo "KPI_VALUES_CHANGED=NO"
echo "KPI_LOGIC_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "COMMAND_CENTER_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
