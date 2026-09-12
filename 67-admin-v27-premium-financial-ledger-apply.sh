#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# PROJECT: 67 ADMIN DASHBOARD
# VERSION: V27
# MODULE: ADMIN DASHBOARD
# ELEMENT: FINANCIAL LEDGER / LATEST TRANSACTIONS
# BASE: V26.2
# TARGET: V27
# ==================================================

ROOT=/67
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v26.2.css
TARGET_CSS=src/pages/AdminDashboard.v27.css
BACKUP=/tmp/67-v27-financial-ledger-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TARGET_CSS=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/AdminDashboard.jsx" "$TARGET_JSX" 2>/dev/null || true
    if [ "$HAD_TARGET_CSS" = "YES" ]; then
      cp "$BACKUP/AdminDashboard.v27.css" "$TARGET_CSS" 2>/dev/null || true
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-v27-rollback-build.log 2>&1 || true
  fi
  echo "=================================================="
  echo "PROJECT=67 ADMIN DASHBOARD"
  echo "VERSION=V27"
  echo "MODULE=ADMIN DASHBOARD"
  echo "ELEMENT=FINANCIAL LEDGER / LATEST TRANSACTIONS"
  echo "BASE=V26.2"
  echo "TARGET=V27"
  echo "=================================================="
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V27_PREMIUM_FINANCIAL_LEDGER_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "import './AdminDashboard.v27.css';" "$TARGET_JSX" 2>/dev/null \
  && [ -f "$TARGET_CSS" ] \
  && grep -q "SIX SEVEN ADMIN V27 — PREMIUM FINANCIAL LEDGER" "$TARGET_CSS"; then
  STATE_ACTION=ALREADY_AT_V27
else
  grep -q "import './AdminDashboard.v26.2.css';" "$TARGET_JSX" || fail BASE_RUNTIME_NOT_V26_2
  [ -f "$SOURCE_CSS" ] || fail V26_2_CSS_NOT_FOUND
  grep -q "SIX SEVEN ADMIN V26.2" "$SOURCE_CSS" || fail V26_2_MARKER_NOT_FOUND

  STATE_ACTION=APPLY_V27
  APPLIED_NOW=YES
  mkdir -p "$BACKUP"
  cp "$TARGET_JSX" "$BACKUP/AdminDashboard.jsx"
  if [ -f "$TARGET_CSS" ]; then
    HAD_TARGET_CSS=YES
    cp "$TARGET_CSS" "$BACKUP/AdminDashboard.v27.css"
  fi
  cp "$SOURCE_CSS" "$TARGET_CSS"

  FAILED_STEP=patch_financial_ledger_markup
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

old_import="import './AdminDashboard.v26.2.css';"
new_import="import './AdminDashboard.v27.css';"
if old_import not in s:
    raise SystemExit('V26_2_RUNTIME_IMPORT_NOT_FOUND')
s=s.replace(old_import,new_import,1)

old='''            {/* Latest transactions */}
            <div className="tx-card">
              <div className="tx-card__head">
                <h3><CreditCard size={17} /> السجل المالي — أحدث العمليات</h3>
                <div className="tx-toolbar">
                  <span className="tx-search-glow"><input type="search" placeholder="ابحث عن معاملة أو بائع…" value={txQuery} onChange={(e) => setTxQuery(e.target.value)} /></span>
                  <button><Layers size={13} /> تصفية</button>
                  <button><Eye size={13} /> تصدير</button>
                </div>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table className="tx-table">'''

new='''            {/* Latest transactions */}
            <div className="tx-card">
              <div className="tx-card__head">
                <div className="tx-card__title-group">
                  <span className="tx-card__title-icon"><CreditCard size={16} /></span>
                  <div>
                    <h3>السجل المالي — أحدث العمليات</h3>
                    <small>متابعة حركة المدفوعات والحالات المالية الأخيرة</small>
                  </div>
                </div>
                <div className="tx-card__head-actions">
                  <span className="tx-card__count-badge">{payments.length} عملية</span>
                  <div className="tx-toolbar">
                    <span className="tx-search-glow"><input type="search" placeholder="ابحث عن معاملة أو بائع…" value={txQuery} onChange={(e) => setTxQuery(e.target.value)} /></span>
                    <button><Layers size={13} /> تصفية</button>
                    <button><Eye size={13} /> تصدير</button>
                  </div>
                </div>
              </div>
              <div className="tx-card__scroll" style={{ overflowX: 'auto' }}>
                <table className="tx-table">'''

if old not in s:
    raise SystemExit('FINANCIAL_LEDGER_HEADER_BLOCK_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

  FAILED_STEP=append_v27_css
  cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V27 — PREMIUM FINANCIAL LEDGER
   Sequential element upgrade over approved V26.2.
   Scope lock: Financial Ledger / Latest Transactions ONLY.
   Preserve payment source data, filter/search behavior, row order, values, statuses,
   transaction ids, buyers, sellers, methods, timestamps, amounts and neighboring modules. */

.tx-card{
  position:relative!important;
  isolation:isolate!important;
  border-radius:15px!important;
  overflow:hidden!important;
  background:
    radial-gradient(circle at 98% -18%,rgba(215,173,81,.10),transparent 30%),
    linear-gradient(180deg,#fffefa 0%,#faf6ee 100%)!important;
  border:1px solid rgba(186,131,28,.27)!important;
  box-shadow:0 13px 30px rgba(76,51,9,.065),inset 0 1px 0 rgba(255,255,255,.9)!important;
}
.tx-card::before{
  content:""!important;
  position:absolute!important;
  z-index:2!important;
  left:22px!important;right:22px!important;top:0!important;height:2px!important;
  background:linear-gradient(90deg,transparent,#d7ad51 24%,#a87116 63%,transparent)!important;
  opacity:.76!important;
  pointer-events:none!important;
}

.tx-card__head{
  min-height:58px!important;
  height:58px!important;
  padding:8px 12px!important;
  margin:0!important;
  display:flex!important;
  align-items:center!important;
  justify-content:space-between!important;
  gap:14px!important;
  border-bottom:1px solid rgba(186,131,28,.15)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.64),rgba(249,244,234,.46))!important;
}
.tx-card__title-group{
  display:flex!important;
  align-items:center!important;
  gap:9px!important;
  min-width:0!important;
}
.tx-card__title-icon{
  width:34px!important;height:34px!important;min-width:34px!important;
  display:grid!important;place-items:center!important;
  border-radius:10px!important;
  color:#ae7819!important;
  background:linear-gradient(145deg,#fff9e9,#efdbad)!important;
  border:1px solid rgba(184,127,23,.19)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.9),0 5px 12px rgba(156,104,8,.06)!important;
}
.tx-card__title-group>div{display:grid!important;gap:3px!important;min-width:0!important}
.tx-card__title-group h3{
  margin:0!important;
  font-size:12.2px!important;
  line-height:1.05!important;
  font-weight:950!important;
  color:#161c24!important;
  letter-spacing:-.014em!important;
}
.tx-card__title-group small{
  font-size:7.8px!important;
  line-height:1.15!important;
  color:#9b9388!important;
  font-weight:700!important;
  white-space:nowrap!important;
}
.tx-card__head-actions{
  display:flex!important;
  align-items:center!important;
  gap:7px!important;
  min-width:0!important;
}
.tx-card__count-badge{
  height:27px!important;
  padding:0 9px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  border-radius:999px!important;
  white-space:nowrap!important;
  color:#8f671c!important;
  background:linear-gradient(180deg,#fff9e8,#f2e4c4)!important;
  border:1px solid rgba(184,128,24,.18)!important;
  font-size:8px!important;
  font-weight:900!important;
}

.tx-toolbar{
  display:flex!important;
  align-items:center!important;
  gap:5px!important;
}
.tx-search-glow{display:inline-flex!important;position:relative!important}
.tx-toolbar input{
  width:230px!important;
  min-width:230px!important;
  height:31px!important;
  padding:0 11px!important;
  border-radius:9px!important;
  border:1px solid rgba(166,133,72,.22)!important;
  background:rgba(255,255,255,.78)!important;
  color:#232932!important;
  font-size:8.8px!important;
  outline:none!important;
  box-shadow:inset 0 1px 2px rgba(67,48,12,.025)!important;
}
.tx-toolbar input:focus{
  border-color:rgba(184,128,24,.48)!important;
  box-shadow:0 0 0 3px rgba(215,173,81,.10)!important;
}
.tx-toolbar button{
  height:31px!important;
  padding:0 9px!important;
  display:inline-flex!important;
  align-items:center!important;
  gap:5px!important;
  border-radius:8px!important;
  border:1px solid rgba(166,133,72,.19)!important;
  background:linear-gradient(180deg,#fff,#f8f2e7)!important;
  color:#645c51!important;
  font-size:8.3px!important;
  font-weight:850!important;
  box-shadow:inset 0 1px rgba(255,255,255,.88)!important;
}
.tx-toolbar button:hover{border-color:rgba(184,128,24,.36)!important;color:#8f671c!important}

.tx-card__scroll{width:100%!important;overflow-x:auto!important}
.tx-table{
  width:100%!important;
  border-collapse:separate!important;
  border-spacing:0!important;
  table-layout:fixed!important;
  font-size:9.2px!important;
  color:#3a3e43!important;
}
.tx-table thead{background:linear-gradient(180deg,#f7f1e6,#f3ecdf)!important}
.tx-table th{
  height:31px!important;
  padding:6px 10px!important;
  border-bottom:1px solid rgba(186,131,28,.15)!important;
  color:#8d857b!important;
  font-size:8px!important;
  font-weight:900!important;
  white-space:nowrap!important;
}
.tx-table td{
  height:39px!important;
  padding:7px 10px!important;
  border-top:0!important;
  border-bottom:1px solid rgba(226,216,200,.66)!important;
  background:rgba(255,255,255,.42)!important;
  font-size:9.25px!important;
  vertical-align:middle!important;
  white-space:nowrap!important;
  overflow:hidden!important;
  text-overflow:ellipsis!important;
}
.tx-table tbody tr{transition:background .16s ease,transform .16s ease!important}
.tx-table tbody tr:hover td{background:rgba(249,241,224,.78)!important}
.tx-table tbody tr:last-child td{border-bottom:0!important}
.tx-id{
  display:inline-flex!important;
  align-items:center!important;
  min-height:22px!important;
  padding:0 7px!important;
  border-radius:7px!important;
  color:#32373d!important;
  background:#f4eee3!important;
  border:1px solid rgba(172,135,67,.13)!important;
  font-family:ui-monospace,SFMono-Regular,Menlo,monospace!important;
  font-size:8.4px!important;
  font-weight:850!important;
}
.tx-amount{
  font-size:10.2px!important;
  font-weight:950!important;
  color:#111821!important;
  letter-spacing:-.012em!important;
}
.tx-status{
  min-height:23px!important;
  padding:0 8px!important;
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  gap:4px!important;
  border-radius:999px!important;
  font-size:7.8px!important;
  font-weight:900!important;
  border:1px solid transparent!important;
}
.tx-status--ok{
  color:#0f8c61!important;
  background:#e9f8f2!important;
  border-color:#b8ead9!important;
}
.tx-status--pending{
  color:#9b6b16!important;
  background:#fff5dc!important;
  border-color:#ead59d!important;
}

@media(max-width:1360px){
  .tx-card__head{min-height:54px!important;height:54px!important;padding:7px 10px!important}
  .tx-card__title-icon{width:31px!important;height:31px!important;min-width:31px!important}
  .tx-card__title-group h3{font-size:11.4px!important}
  .tx-card__title-group small{font-size:7.2px!important}
  .tx-card__count-badge{height:25px!important;font-size:7.6px!important}
  .tx-toolbar input{width:205px!important;min-width:205px!important;height:29px!important}
  .tx-toolbar button{height:29px!important;padding:0 8px!important}
  .tx-table th{height:29px!important;padding:5px 8px!important}
  .tx-table td{height:36px!important;padding:6px 8px!important;font-size:8.8px!important}
}
CSS

  grep -q "SIX SEVEN ADMIN V27 — PREMIUM FINANCIAL LEDGER" "$TARGET_CSS"
  grep -q "import './AdminDashboard.v27.css';" "$TARGET_JSX"
  grep -q "tx-card__title-group" "$TARGET_JSX"
  grep -q "tx-card__count-badge" "$TARGET_JSX"
fi

FAILED_STEP=build
npm run build >/tmp/67-v27-build.log 2>&1 || {
  tail -n 180 /tmp/67-v27-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"

echo "=================================================="
echo "PROJECT=67 ADMIN DASHBOARD"
echo "VERSION=V27"
echo "MODULE=ADMIN DASHBOARD"
echo "ELEMENT=FINANCIAL LEDGER / LATEST TRANSACTIONS"
echo "BASE=V26.2"
echo "TARGET=V27"
echo "STATUS=PATCH COMPLETE — AWAITING VISUAL QA"
echo "=================================================="
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "CURRENT_APPROVED_VERSION=V26.2"
echo "WORKING_VERSION=V27"
echo "RUNTIME_CSS=AdminDashboard.v27.css"
echo "ELEMENT=FINANCIAL_LEDGER_ONLY"
echo "FINANCIAL_LEDGER_PREMIUM=YES"
echo "LEDGER_HEADER_REDESIGNED=YES"
echo "LEDGER_TOOLBAR_REDESIGNED=YES"
echo "LEDGER_TABLE_HIERARCHY_REDESIGNED=YES"
echo "LEDGER_TRANSACTION_IDS_RESTYLED=YES"
echo "LEDGER_AMOUNTS_RESTYLED=YES"
echo "LEDGER_STATUSES_RESTYLED=YES"
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
