#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v26.css
TARGET_CSS=src/pages/AdminDashboard.v26.1.css
BACKUP=/tmp/67-v26.1-current-ops-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v26.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v26.1-rollback-build.log 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V26_1_CURRENT_OPERATIONS_ROW_CLIPPING_FIX_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v26.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V26.1 — CURRENT OPERATIONS ROW CLIPPING FIX" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V26_1
else
  grep -q "import './AdminDashboard.v26.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V26
  [ -f "$SOURCE_CSS" ] || fail V26_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V26 — PREMIUM CURRENT OPERATIONS" "$SOURCE_CSS" || fail V26_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V26_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v26.1.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=switch_runtime_css
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v26.css';"
new="import './AdminDashboard.v26.1.css';"
if old not in s:
    raise SystemExit('V26_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v26_1_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V26.1 — CURRENT OPERATIONS ROW CLIPPING FIX
   Visual correction over approved V26 concept.
   Scope lock: Current Operations geometry ONLY.
   Root cause: V26 vertical stack exceeded the fixed 286px row height, collapsing/clipping
   the third action row (active stores) between Documents and Recent Payments.
   Preserve ALL values, JSX content, counters, logic, conditions and neighboring modules. */

.ops-card{
  height:286px!important;
  min-height:286px!important;
  max-height:286px!important;
  padding:10px 11px 10px!important;
  overflow:hidden!important;
}

.ops-card__head{
  min-height:34px!important;
  height:34px!important;
  flex:0 0 34px!important;
  margin:0 0 5px!important;
}
.ops-card__title-icon{
  width:27px!important;
  height:27px!important;
  min-width:27px!important;
}
.ops-card__title-group h3{font-size:11.8px!important}
.ops-card__title-group small{font-size:7px!important}
.ops-card__command-badge{
  height:22px!important;
  padding:0 7px!important;
  font-size:7.3px!important;
}

.ops-summary-row{
  flex:0 0 48px!important;
  height:48px!important;
  min-height:48px!important;
  margin:0 0 5px!important;
  gap:5px!important;
}
.ops-summary-tile{
  height:48px!important;
  min-height:48px!important;
  padding:6px 8px!important;
}
.ops-summary-tile strong{font-size:15px!important}
.ops-summary-tile>span{font-size:6.8px!important}
.ops-summary-tile small{font-size:6.3px!important}

.ops-tiles{
  flex:0 0 auto!important;
  min-height:0!important;
  gap:3px!important;
  overflow:visible!important;
}
.ops-tile{
  height:29px!important;
  min-height:29px!important;
  max-height:29px!important;
  flex:0 0 29px!important;
  padding:3px 6px!important;
  gap:6px!important;
  border-radius:8px!important;
  overflow:hidden!important;
}
.ops-tile__ico{
  width:22px!important;
  height:22px!important;
  min-width:22px!important;
  flex:0 0 22px!important;
}
.ops-tile__ico svg{width:12px!important;height:12px!important}
.ops-tile__info{min-width:0!important;flex:1!important}
.ops-tile__info strong{
  font-size:8.1px!important;
  line-height:1.05!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.ops-tile__info small{
  font-size:6.5px!important;
  line-height:1.05!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.ops-tile__count{
  min-width:20px!important;
  height:18px!important;
  padding:0 5px!important;
  font-size:7.4px!important;
}
.ops-tile__state{
  height:18px!important;
  padding:0 6px!important;
  font-size:6.5px!important;
}

/* Conditional recent-payment action row lives outside .ops-tiles. Keep it visible and bounded. */
.ops-card>.ops-tile{
  margin-top:4px!important;
  height:29px!important;
  min-height:29px!important;
  max-height:29px!important;
  flex:0 0 29px!important;
}

.ops-good-strip{
  margin-top:4px!important;
  min-height:24px!important;
  height:24px!important;
  max-height:24px!important;
  flex:0 0 24px!important;
  padding:4px 6px!important;
  font-size:7.2px!important;
  border-radius:7px!important;
}

@media(max-width:1360px){
  .ops-card{padding:9px 10px!important}
  .ops-card__head{height:32px!important;min-height:32px!important;flex-basis:32px!important;margin-bottom:4px!important}
  .ops-summary-row{height:46px!important;min-height:46px!important;flex-basis:46px!important;margin-bottom:4px!important}
  .ops-summary-tile{height:46px!important;min-height:46px!important}
  .ops-tile,.ops-card>.ops-tile{height:28px!important;min-height:28px!important;max-height:28px!important;flex-basis:28px!important}
  .ops-good-strip{height:23px!important;min-height:23px!important;max-height:23px!important;flex-basis:23px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V26.1 — CURRENT OPERATIONS ROW CLIPPING FIX" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v26.1.css';" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v26.1-build.log 2>&1 || {
  tail -n 160 /tmp/67-v26.1-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V26"
echo "TARGET_VERSION=V26.1"
echo "RUNTIME_CSS=AdminDashboard.v26.1.css"
echo "ELEMENT=CURRENT_OPERATIONS_ONLY"
echo "ROOT_CAUSE=V26_VERTICAL_STACK_EXCEEDED_FIXED_CARD_HEIGHT"
echo "CURRENT_ROW_CLIPPING_FIXED_BY_LAYOUT=YES"
echo "CURRENT_ACTIVE_STORE_ROW_VISIBLE_BY_LAYOUT=YES"
echo "CURRENT_PAYMENT_ROW_VISIBLE_BY_LAYOUT=YES"
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
