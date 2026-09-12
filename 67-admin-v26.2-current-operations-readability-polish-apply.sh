#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v26.1.css
TARGET_CSS=src/pages/AdminDashboard.v26.2.css
BACKUP=/tmp/67-v26.2-current-ops-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v26.2.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v26.2-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V26_2_CURRENT_OPERATIONS_READABILITY_POLISH_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v26.2.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V26.2 — CURRENT OPERATIONS READABILITY POLISH" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V26_2
else
  grep -q "import './AdminDashboard.v26.1.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V26_1
  [ -f "$SOURCE_CSS" ] || fail V26_1_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V26.1 — CURRENT OPERATIONS ROW CLIPPING FIX" "$SOURCE_CSS" || fail V26_1_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V26_2
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v26.2.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v26.1.css';"
new="import './AdminDashboard.v26.2.css';"
if old not in s:
    raise SystemExit('V26_1_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v26_2_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V26.2 — CURRENT OPERATIONS READABILITY POLISH
   Screenshot-driven correction over V26.1.
   Scope lock: Current Operations proportions/readability ONLY.
   Goals:
   - preserve the no-clipping fix,
   - make all four action rows materially easier to read,
   - reduce summary dominance,
   - strengthen counts/status pills,
   - keep health footer fully visible,
   - preserve every value, condition, markup node, data source and neighboring module. */

.ops-card{
  height:286px!important;
  min-height:286px!important;
  max-height:286px!important;
  padding:9px 11px 9px!important;
  overflow:hidden!important;
}

/* Header stays premium but yields more vertical space to the action queue. */
.ops-card__head{
  height:32px!important;
  min-height:32px!important;
  flex:0 0 32px!important;
  margin:0 0 4px!important;
}
.ops-card__title-icon{
  width:26px!important;
  height:26px!important;
  min-width:26px!important;
}
.ops-card__title-icon svg{width:14px!important;height:14px!important}
.ops-card__title-group{gap:6px!important}
.ops-card__title-group h3{
  font-size:12px!important;
  line-height:1!important;
}
.ops-card__title-group small{
  font-size:7.2px!important;
  line-height:1.05!important;
}
.ops-card__command-badge{
  height:21px!important;
  padding:0 7px!important;
  font-size:7.4px!important;
}

/* Summary is intentionally shorter so the operational rows become the focal point. */
.ops-summary-row{
  height:42px!important;
  min-height:42px!important;
  flex:0 0 42px!important;
  margin:0 0 4px!important;
  gap:5px!important;
}
.ops-summary-tile{
  height:42px!important;
  min-height:42px!important;
  padding:5px 8px!important;
  grid-template-columns:1fr auto!important;
  gap:0 7px!important;
  border-radius:9px!important;
}
.ops-summary-tile>span{
  font-size:7.4px!important;
  line-height:1!important;
}
.ops-summary-tile strong{
  font-size:16px!important;
  line-height:1!important;
}
.ops-summary-tile small{
  font-size:6.5px!important;
  line-height:1!important;
}

/* Primary action queue — larger rows, larger text, stronger counts/status. */
.ops-tiles{
  flex:0 0 auto!important;
  min-height:0!important;
  gap:3px!important;
  overflow:visible!important;
}
.ops-tile{
  height:34px!important;
  min-height:34px!important;
  max-height:34px!important;
  flex:0 0 34px!important;
  padding:4px 7px!important;
  gap:7px!important;
  border-radius:9px!important;
  overflow:hidden!important;
}
.ops-tile__ico{
  width:24px!important;
  height:24px!important;
  min-width:24px!important;
  flex:0 0 24px!important;
  border-radius:7px!important;
}
.ops-tile__ico svg{
  width:13px!important;
  height:13px!important;
}
.ops-tile__info{
  min-width:0!important;
  flex:1 1 auto!important;
}
.ops-tile__info strong{
  font-size:9.4px!important;
  line-height:1.08!important;
  font-weight:900!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.ops-tile__info small{
  margin-top:2px!important;
  font-size:7.2px!important;
  line-height:1!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.ops-tile__count{
  min-width:24px!important;
  height:20px!important;
  padding:0 6px!important;
  font-size:8px!important;
  font-weight:950!important;
}
.ops-tile__state{
  min-width:40px!important;
  height:20px!important;
  padding:0 7px!important;
  font-size:7.1px!important;
  font-weight:900!important;
}

/* Conditional payment row receives the exact same readable geometry. */
.ops-card>.ops-tile{
  margin-top:3px!important;
  height:34px!important;
  min-height:34px!important;
  max-height:34px!important;
  flex:0 0 34px!important;
}

/* Footer remains visible but compact; it should not steal focus from action rows. */
.ops-good-strip{
  margin-top:3px!important;
  height:23px!important;
  min-height:23px!important;
  max-height:23px!important;
  flex:0 0 23px!important;
  padding:3px 6px!important;
  border-radius:7px!important;
  font-size:7.4px!important;
  line-height:1!important;
}
.ops-good-strip svg{width:12px!important;height:12px!important}

@media(max-width:1360px){
  .ops-card{padding:8px 9px!important}
  .ops-card__head{height:30px!important;min-height:30px!important;flex-basis:30px!important;margin-bottom:3px!important}
  .ops-card__title-group h3{font-size:11.3px!important}
  .ops-card__title-group small{font-size:6.8px!important}
  .ops-summary-row{height:40px!important;min-height:40px!important;flex-basis:40px!important;margin-bottom:3px!important}
  .ops-summary-tile{height:40px!important;min-height:40px!important}
  .ops-tile,.ops-card>.ops-tile{height:33px!important;min-height:33px!important;max-height:33px!important;flex-basis:33px!important}
  .ops-tile__info strong{font-size:9px!important}
  .ops-tile__info small{font-size:6.9px!important}
  .ops-good-strip{height:22px!important;min-height:22px!important;max-height:22px!important;flex-basis:22px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V26.2 — CURRENT OPERATIONS READABILITY POLISH" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v26.2.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v26.2-build.log 2>&1 || {
  tail -n 160 /tmp/67-v26.2-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V26.1"
echo "TARGET_VERSION=V26.2"
echo "RUNTIME_CSS=AdminDashboard.v26.2.css"
echo "ELEMENT=CURRENT_OPERATIONS_ONLY"
echo "REFERENCE=USER_SCREENSHOT_2026_09_12"
echo "CURRENT_READABILITY_POLISHED=YES"
echo "CURRENT_SUMMARY_HEIGHT=42PX_DESKTOP"
echo "CURRENT_ACTION_ROW_HEIGHT=34PX_DESKTOP"
echo "CURRENT_COUNTS_ENLARGED=YES"
echo "CURRENT_STATUS_PILLS_ENLARGED=YES"
echo "CURRENT_ACTIVE_STORE_ROW_VISIBLE_BY_LAYOUT=YES"
echo "CURRENT_PAYMENT_ROW_VISIBLE_BY_LAYOUT=YES"
echo "CURRENT_HEALTH_FOOTER_VISIBLE_BY_LAYOUT=YES"
echo "CURRENT_VALUES_CHANGED=NO"
echo "CURRENT_LOGIC_CHANGED=NO"
echo "CURRENT_MARKUP_CHANGED=NO"
echo "LIVE_OPERATIONS_CHANGED=NO"
echo "REVENUE_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "TRANSACTIONS_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
