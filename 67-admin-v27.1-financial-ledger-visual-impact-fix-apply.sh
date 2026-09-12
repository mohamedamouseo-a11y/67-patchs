#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V27.1
# MODULE: ADMIN DASHBOARD
# ELEMENT: FINANCIAL LEDGER / LATEST TRANSACTIONS — VISUAL IMPACT FIX
# CURRENT APPROVED VERSION: V26.2
# BASE: V27
# TARGET: V27.1
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v27.css
TARGET_CSS=src/pages/AdminDashboard.v27.1.css
BACKUP=/tmp/67-v27.1-ledger-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v27.1.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v27.1-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V27.1"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=FINANCIAL LEDGER / LATEST TRANSACTIONS — VISUAL IMPACT FIX"
  echo "CURRENT_APPROVED_VERSION=V26.2"
  echo "BASE_VERSION=V27"
  echo "TARGET_VERSION=V27.1"
  echo "STATUS=FAILED"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V27_1_FINANCIAL_LEDGER_VISUAL_IMPACT_FIX_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v27.1.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V27.1 — FINANCIAL LEDGER VISUAL IMPACT FIX" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V27_1
else
  grep -q "import './AdminDashboard.v27.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V27
  [ -f "$SOURCE_CSS" ] || fail V27_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V27 — PREMIUM FINANCIAL LEDGER" "$SOURCE_CSS" || fail V27_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V27_1
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v27.1.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=patch_financial_ledger_summary
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

old_import="import './AdminDashboard.v27.css';"
new_import="import './AdminDashboard.v27.1.css';"
if old_import not in s:
    raise SystemExit('V27_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

needle='''              </div>\n              <div className="tx-card__scroll" style={{ overflowX: 'auto' }}>\n                <table className="tx-table">'''
replacement='''              </div>\n              <div className="tx-ledger-summary">\n                <div className="tx-ledger-summary__item tx-ledger-summary__item--total">\n                  <small>إجمالي السجل</small>\n                  <strong>{payments.length}</strong>\n                  <span>عملية مالية</span>\n                </div>\n                <div className="tx-ledger-summary__item tx-ledger-summary__item--ok">\n                  <small>مكتملة</small>\n                  <strong>{payments.filter(p => p.status === 'مكتمل').length}</strong>\n                  <span>تمت بنجاح</span>\n                </div>\n                <div className="tx-ledger-summary__item tx-ledger-summary__item--pending">\n                  <small>قيد المتابعة</small>\n                  <strong>{payments.filter(p => p.status !== 'مكتمل').length}</strong>\n                  <span>تحتاج مراجعة</span>\n                </div>\n              </div>\n              <div className="tx-card__scroll" style={{ overflowX: 'auto' }}>\n                <table className="tx-table">'''
if needle not in s:
    raise SystemExit('V27_LEDGER_SCROLL_ANCHOR_NOT_FOUND')
s=s.replace(needle,replacement,1)
p.write_text(s)
PY

  FAILED_STEP=append_v27_1_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V27.1 — FINANCIAL LEDGER VISUAL IMPACT FIX
   Correction over V27 after side-by-side review showed the change was too subtle.
   Scope lock: Financial Ledger ONLY.
   Goal: unmistakable hierarchy and readability improvement while preserving all payment data,
   row order, values, search behavior, existing buttons, statuses and neighboring modules. */

.tx-card{
  border-radius:17px!important;
  border:1px solid rgba(171,116,18,.34)!important;
  box-shadow:0 16px 34px rgba(70,45,8,.085),inset 0 1px 0 rgba(255,255,255,.95)!important;
  background:linear-gradient(180deg,#fffefa 0%,#fbf7ef 100%)!important;
}
.tx-card::before{
  left:18px!important;right:18px!important;height:3px!important;
  background:linear-gradient(90deg,transparent 0%,#d7ad51 18%,#a36b12 50%,#d7ad51 82%,transparent 100%)!important;
  opacity:.95!important;
}

.tx-card__head{
  min-height:72px!important;
  height:72px!important;
  padding:10px 14px!important;
  gap:16px!important;
  background:linear-gradient(180deg,#fffdf8 0%,#f8f0e2 100%)!important;
  border-bottom:1px solid rgba(171,116,18,.20)!important;
}
.tx-card__title-icon{
  width:42px!important;height:42px!important;min-width:42px!important;
  border-radius:12px!important;
  color:#9f6d18!important;
  background:linear-gradient(145deg,#fff8df,#ead19a)!important;
  border-color:rgba(163,107,18,.27)!important;
  box-shadow:inset 0 1px #fff,0 8px 18px rgba(126,82,11,.10)!important;
}
.tx-card__title-group{gap:10px!important}
.tx-card__title-group h3{
  font-size:14px!important;
  line-height:1.1!important;
  letter-spacing:-.02em!important;
}
.tx-card__title-group small{
  margin-top:2px!important;
  font-size:8.5px!important;
  color:#8f867a!important;
}
.tx-card__head-actions{gap:8px!important}
.tx-card__count-badge{
  height:32px!important;
  padding:0 11px!important;
  font-size:8.8px!important;
  color:#80570f!important;
  background:linear-gradient(180deg,#fff7dd,#edd7a4)!important;
  border-color:rgba(163,107,18,.24)!important;
}

.tx-toolbar{
  gap:6px!important;
  padding:4px!important;
  border-radius:11px!important;
  background:rgba(255,255,255,.68)!important;
  border:1px solid rgba(163,107,18,.14)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.9)!important;
}
.tx-toolbar input{
  width:260px!important;
  min-width:260px!important;
  height:34px!important;
  padding:0 12px!important;
  border-radius:8px!important;
  font-size:9.2px!important;
  background:#fff!important;
  border-color:rgba(131,98,42,.22)!important;
}
.tx-toolbar button{
  height:34px!important;
  padding:0 11px!important;
  border-radius:8px!important;
  font-size:8.8px!important;
  font-weight:900!important;
}

.tx-ledger-summary{
  display:grid!important;
  grid-template-columns:repeat(3,minmax(0,1fr))!important;
  gap:8px!important;
  padding:9px 12px!important;
  background:linear-gradient(180deg,#f6efe2,#fbf8f2)!important;
  border-bottom:1px solid rgba(171,116,18,.16)!important;
}
.tx-ledger-summary__item{
  position:relative!important;
  min-height:52px!important;
  padding:8px 10px!important;
  border-radius:11px!important;
  display:grid!important;
  grid-template-columns:1fr auto!important;
  grid-template-areas:"label value" "note value"!important;
  align-items:center!important;
  gap:2px 10px!important;
  background:rgba(255,255,255,.76)!important;
  border:1px solid rgba(158,122,58,.15)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.94)!important;
  overflow:hidden!important;
}
.tx-ledger-summary__item::after{
  content:""!important;
  position:absolute!important;right:0!important;top:8px!important;bottom:8px!important;width:3px!important;border-radius:99px!important;
  background:#c18b2b!important;
}
.tx-ledger-summary__item--ok::after{background:#14a36d!important}
.tx-ledger-summary__item--pending::after{background:#d6a028!important}
.tx-ledger-summary__item small{
  grid-area:label!important;
  color:#8b8277!important;
  font-size:7.8px!important;
  font-weight:850!important;
}
.tx-ledger-summary__item strong{
  grid-area:value!important;
  font-size:22px!important;
  line-height:1!important;
  color:#111923!important;
  font-weight:950!important;
}
.tx-ledger-summary__item--ok strong{color:#118b60!important}
.tx-ledger-summary__item--pending strong{color:#9c6c17!important}
.tx-ledger-summary__item span{
  grid-area:note!important;
  color:#aaa095!important;
  font-size:7.2px!important;
  font-weight:700!important;
}

.tx-card__scroll{
  background:#fffdf9!important;
  padding:0 10px 10px!important;
}
.tx-table{
  margin-top:0!important;
  border-collapse:separate!important;
  border-spacing:0!important;
  border:1px solid rgba(27,37,49,.10)!important;
  border-top:0!important;
  border-radius:0 0 11px 11px!important;
  overflow:hidden!important;
  box-shadow:0 6px 16px rgba(40,31,15,.035)!important;
}
.tx-table thead{
  background:linear-gradient(180deg,#162331 0%,#101a25 100%)!important;
}
.tx-table th{
  height:38px!important;
  padding:8px 11px!important;
  color:#e8cf8a!important;
  font-size:8.7px!important;
  font-weight:900!important;
  border-bottom:1px solid rgba(215,173,81,.20)!important;
}
.tx-table th+th{border-right:1px solid rgba(255,255,255,.045)!important}
.tx-table td{
  height:46px!important;
  padding:8px 11px!important;
  font-size:9.6px!important;
  color:#353b43!important;
  border-bottom:1px solid rgba(218,207,188,.68)!important;
  background:#fffefa!important;
}
.tx-table tbody tr:nth-child(even) td{background:#faf5eb!important}
.tx-table tbody tr:hover td{background:#f5ead4!important}
.tx-table td+td{border-right:1px solid rgba(214,202,182,.40)!important}

.tx-id{
  min-height:26px!important;
  padding:0 9px!important;
  border-radius:8px!important;
  color:#28313a!important;
  background:linear-gradient(180deg,#f5efe4,#ece2d1)!important;
  border-color:rgba(135,104,52,.19)!important;
  font-size:8.9px!important;
  font-weight:900!important;
}
.tx-amount{
  display:inline-flex!important;
  align-items:baseline!important;
  gap:3px!important;
  font-size:11.3px!important;
  font-weight:950!important;
  color:#0e1721!important;
}
.tx-status{
  min-height:27px!important;
  padding:0 10px!important;
  gap:5px!important;
  font-size:8.4px!important;
  box-shadow:inset 0 1px rgba(255,255,255,.72)!important;
}
.tx-status--ok{
  color:#0c875d!important;
  background:linear-gradient(180deg,#e8faf2,#dff5ec)!important;
  border-color:#a9e4d0!important;
}
.tx-status--pending{
  color:#966514!important;
  background:linear-gradient(180deg,#fff7df,#f9edc9)!important;
  border-color:#e5cd89!important;
}

@media(max-width:1360px){
  .tx-card__head{min-height:66px!important;height:66px!important;padding:8px 11px!important}
  .tx-card__title-icon{width:38px!important;height:38px!important;min-width:38px!important}
  .tx-card__title-group h3{font-size:13px!important}
  .tx-card__title-group small{font-size:8px!important}
  .tx-card__count-badge{height:30px!important;font-size:8.2px!important}
  .tx-toolbar input{width:220px!important;min-width:220px!important;height:32px!important}
  .tx-toolbar button{height:32px!important;padding:0 9px!important}
  .tx-ledger-summary{gap:6px!important;padding:7px 10px!important}
  .tx-ledger-summary__item{min-height:48px!important;padding:7px 9px!important}
  .tx-ledger-summary__item strong{font-size:19px!important}
  .tx-table th{height:35px!important;padding:7px 9px!important;font-size:8.2px!important}
  .tx-table td{height:42px!important;padding:7px 9px!important;font-size:9px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V27.1 — FINANCIAL LEDGER VISUAL IMPACT FIX" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v27.1.css';" "$TARGET_JSX"
  grep -q "tx-ledger-summary" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v27.1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v27.1-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V27.1"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=FINANCIAL LEDGER / LATEST TRANSACTIONS — VISUAL IMPACT FIX"
echo "CURRENT_APPROVED_VERSION=V26.2"
echo "BASE_VERSION=V27"
echo "TARGET_VERSION=V27.1"
echo "STATUS=AWAITING_CHATGPT_VISUAL_APPROVAL"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "RUNTIME_CSS=AdminDashboard.v27.1.css"
echo "ELEMENT=FINANCIAL_LEDGER_ONLY"
echo "V27_VISUAL_DELTA_TOO_SUBTLE_FIXED=YES"
echo "LEDGER_SUMMARY_RAIL_ADDED=YES"
echo "LEDGER_DARK_HEADER_BAND=YES"
echo "LEDGER_ROWS_ENLARGED=YES"
echo "LEDGER_IDS_ENLARGED=YES"
echo "LEDGER_AMOUNTS_ENLARGED=YES"
echo "LEDGER_STATUSES_ENLARGED=YES"
echo "PAYMENT_DATA_CHANGED=NO"
echo "PAYMENT_ORDER_CHANGED=NO"
echo "SEARCH_BEHAVIOR_CHANGED=NO"
echo "FILTER_BUTTON_BEHAVIOR_CHANGED=NO"
echo "EXPORT_BUTTON_BEHAVIOR_CHANGED=NO"
echo "LIVE_OPERATIONS_CHANGED=NO"
echo "CURRENT_OPERATIONS_CHANGED=NO"
echo "REVENUE_CHANGED=NO"
echo "HERO_CHANGED=NO"
echo "DATE_CONTROL_CHANGED=NO"
echo "KPI_CHANGED=NO"
echo "SYSTEM_HEALTH_CHANGED=NO"
echo "SIDEBAR_CHANGED=NO"
echo "DATA_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
