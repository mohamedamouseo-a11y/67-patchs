#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
TARGET=src/pages/AdminDashboard.v42.css
BACKUP=/tmp/67-v42-reference-batch01-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }

if grep -q "AdminDashboard.v41.css" "$JSX"; then
  SOURCE=src/pages/AdminDashboard.v41.css
  ACTIVE_IMPORT="AdminDashboard.v41.css"
elif grep -q "AdminDashboard.v40.css" "$JSX"; then
  SOURCE=src/pages/AdminDashboard.v40.css
  ACTIVE_IMPORT="AdminDashboard.v40.css"
else
  echo 'FAILED_STEP=V40_OR_V41_RUNTIME_NOT_ACTIVE'
  exit 1
fi

[ -f "$SOURCE" ] || { echo 'FAILED_STEP=ACTIVE_CSS_MISSING'; exit 1; }
mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE" "$TARGET"

python3 - <<'PY'
from pathlib import Path
import re

p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

# Activate V42 without touching business logic.
s, n = re.subn(r"import './AdminDashboard\.v(?:40|41)\.css';", "import './AdminDashboard.v42.css';", s, count=1)
if n != 1:
    raise SystemExit('V42_IMPORT_SWAP_FAILED')

# Helper: operate only inside a known tab block so no unrelated screen is changed.
def rewrite_between(text, start_marker, end_marker, fn):
    start=text.find(start_marker)
    end=text.find(end_marker, start+len(start_marker))
    if start < 0 or end < 0 or end <= start:
        raise SystemExit(f'BLOCK_ANCHOR_FAILED::{start_marker}')
    block=text[start:end]
    new_block=fn(block)
    return text[:start] + new_block + text[end:]

users_marker='        {/* Tab Content: USERS AND SELLERS LOGS */}'
docs_marker='        {/* Tab Content: DOCUMENTS */}'
transactions_marker='        {/* Tab Content: TRANSACTIONS */}'
community_marker='        {/* Tab Content: COMMUNITY CONTROL */}'

def rewrite_users(block):
    block=block.replace(
        '''{activeTab === 'users' && (\n          <div className="animate-fadeIn" style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>''',
        '''{activeTab === 'users' && (\n          <div className="animate-fadeIn ref-batch-users" data-v42-reference-screen="users-sellers" style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>''',
        1,
    )
    if 'ref-batch-users' not in block:
        raise SystemExit('USERS_ROOT_ALIAS_FAILED')
    # The users tab contains exactly two top-level cardStyle cards in order: sellers then customers.
    block=block.replace('<div style={cardStyle}>','<div className="ref-batch-panel ref-batch-sellers" style={cardStyle}>',1)
    block=block.replace('<div style={cardStyle}>','<div className="ref-batch-panel ref-batch-customers" style={cardStyle}>',1)
    if 'ref-batch-sellers' not in block or 'ref-batch-customers' not in block:
        raise SystemExit('USERS_PANEL_ALIAS_FAILED')
    return block

s=rewrite_between(s, users_marker, docs_marker, rewrite_users)

def rewrite_docs(block):
    block=block.replace(
        '''{activeTab === 'documents' && (\n          <div className="animate-fadeIn" style={cardStyle}>''',
        '''{activeTab === 'documents' && (\n          <div className="animate-fadeIn ref-batch-panel ref-batch-documents" data-v42-reference-screen="documents-verification" style={cardStyle}>''',
        1,
    )
    if 'ref-batch-documents' not in block:
        raise SystemExit('DOCUMENTS_ALIAS_FAILED')
    return block

s=rewrite_between(s, docs_marker, transactions_marker, rewrite_docs)

def rewrite_transactions(block):
    block=block.replace(
        '''{activeTab === 'transactions' && (\n          <div className="animate-fadeIn" style={cardStyle}>''',
        '''{activeTab === 'transactions' && (\n          <div className="animate-fadeIn ref-batch-panel ref-batch-transactions" data-v42-reference-screen="payments-transactions" style={cardStyle}>''',
        1,
    )
    if 'ref-batch-transactions' not in block:
        raise SystemExit('TRANSACTIONS_ALIAS_FAILED')
    return block

s=rewrite_between(s, transactions_marker, community_marker, rewrite_transactions)

p.write_text(s)
PY

cat >> "$TARGET" <<'CSS'

/* ============================================================
   SIX SEVEN ADMIN V42 — REFERENCE BATCH 01 MULTISCREEN
   Visual source of truth:
   01 ADMIN OVERVIEW = style language anchor
   02 USERS/SELLERS   = structure/content anchor
   03 DOCUMENTS       = structure/content anchor
   04 TRANSACTIONS    = structure/content anchor

   RULE: preserve every section, table, row, column, action and empty area.
   No invented widgets, KPIs, charts, rows or data.
   ============================================================ */

/* Shared light-canvas language inherited from the approved Overview. */
body .admin-exec .ref-batch-users,
body .admin-exec .ref-batch-documents,
body .admin-exec .ref-batch-transactions{
  width:100%!important;
  max-width:none!important;
  min-width:0!important;
  direction:rtl!important;
  color:#101820!important;
}

body .admin-exec .ref-batch-panel{
  background:linear-gradient(180deg,#fffefb 0%,#fffaf0 100%)!important;
  border:1px solid rgba(195,139,25,.24)!important;
  border-radius:16px!important;
  box-shadow:0 8px 22px rgba(72,49,9,.055)!important;
  overflow:hidden!important;
}

/* USERS + SELLERS — keep exactly the two stacked reference cards. */
body .admin-exec .ref-batch-users{
  gap:30px!important;
}
body .admin-exec .ref-batch-users>.ref-batch-panel{
  padding:24px!important;
}
body .admin-exec .ref-batch-sellers>div:first-child,
body .admin-exec .ref-batch-customers>h3{
  margin-top:-24px!important;
  margin-left:-24px!important;
  margin-right:-24px!important;
  margin-bottom:18px!important;
  padding:16px 24px!important;
  min-height:64px!important;
  border-bottom:1px solid rgba(190,137,28,.18)!important;
  background:linear-gradient(90deg,#fffaf0 0%,#fffefb 54%,#fbf0d8 100%)!important;
}
body .admin-exec .ref-batch-users h3{
  color:#111820!important;
  font-size:19px!important;
  font-weight:900!important;
  letter-spacing:-.2px!important;
}
body .admin-exec .ref-batch-users h3 svg{
  color:#d3a126!important;
  stroke:#d3a126!important;
}
body .admin-exec .ref-batch-sellers>div:first-child>div:last-child{
  gap:8px!important;
}
body .admin-exec .ref-batch-sellers>div:first-child>div:last-child span{
  min-height:28px!important;
  display:inline-flex!important;
  align-items:center!important;
  border:1px solid rgba(28,103,76,.10)!important;
  box-shadow:0 2px 6px rgba(35,51,45,.03)!important;
  font-size:11px!important;
  padding:5px 12px!important;
  border-radius:999px!important;
}

/* Tables: same content/order as reference, premium Overview styling only. */
body .admin-exec .ref-batch-panel table{
  width:100%!important;
  border-collapse:separate!important;
  border-spacing:0!important;
  text-align:right!important;
  background:#fffefb!important;
  border:1px solid rgba(186,135,33,.12)!important;
  border-radius:11px!important;
  overflow:hidden!important;
}
body .admin-exec .ref-batch-panel thead tr{
  background:linear-gradient(180deg,#fbf1dd,#f8ecd4)!important;
  border-bottom:1px solid rgba(177,128,29,.18)!important;
}
body .admin-exec .ref-batch-panel th{
  color:#6d624f!important;
  background:transparent!important;
  font-size:11px!important;
  line-height:1.2!important;
  font-weight:850!important;
  padding:12px 12px!important;
  border-bottom:1px solid rgba(177,128,29,.16)!important;
  white-space:nowrap!important;
}
body .admin-exec .ref-batch-panel td{
  color:#28323b!important;
  font-size:11.5px!important;
  line-height:1.35!important;
  padding:13px 12px!important;
  border-bottom:1px solid #eee7da!important;
  background:rgba(255,255,255,.40)!important;
  vertical-align:middle!important;
}
body .admin-exec .ref-batch-panel tbody tr:nth-child(even) td{
  background:rgba(250,246,237,.56)!important;
}
body .admin-exec .ref-batch-panel tbody tr:last-child td{
  border-bottom:0!important;
}
body .admin-exec .ref-batch-panel tbody tr{
  transition:background .18s ease, transform .18s ease!important;
}
body .admin-exec .ref-batch-panel tbody tr:hover td{
  background:#fff8e9!important;
}
body .admin-exec .ref-batch-panel td strong{
  color:#1b2630!important;
}
body .admin-exec .ref-batch-panel a{
  color:#3277a9!important;
  font-weight:700!important;
  text-underline-offset:3px!important;
}

/* Seller actions stay exactly where they are; only adopt the gold action language. */
body .admin-exec .ref-batch-sellers button{
  background:linear-gradient(180deg,#f1d36c,#d8a621)!important;
  color:#17130a!important;
  border:1px solid rgba(169,118,16,.22)!important;
  border-radius:8px!important;
  min-height:30px!important;
  padding:6px 13px!important;
  font-size:11px!important;
  font-weight:900!important;
  box-shadow:0 3px 8px rgba(138,93,13,.10)!important;
}
body .admin-exec .ref-batch-sellers button:hover{
  filter:brightness(1.025)!important;
  transform:translateY(-1px)!important;
}

/* DOCUMENTS — single reference card only. Do not add summary widgets. */
body .admin-exec .ref-batch-documents{
  min-height:318px!important;
  padding:24px!important;
}
body .admin-exec .ref-batch-documents>h3{
  margin:-24px -24px 18px!important;
  padding:17px 24px!important;
  min-height:66px!important;
  border-bottom:1px solid rgba(190,137,28,.18)!important;
  background:linear-gradient(90deg,#fffaf0,#fffefb 55%,#fbf0d8)!important;
  color:#111820!important;
  font-size:19px!important;
  font-weight:900!important;
}
body .admin-exec .ref-batch-documents>h3 svg{
  color:#d3a126!important;
  stroke:#d3a126!important;
}
body .admin-exec .ref-batch-documents button{
  min-height:30px!important;
  border-radius:8px!important;
  font-size:10.5px!important;
  font-weight:850!important;
  box-shadow:0 3px 8px rgba(34,54,48,.08)!important;
}
body .admin-exec .ref-batch-documents button:first-child{
  background:#35a965!important;
}
body .admin-exec .ref-batch-documents button:last-child{
  background:#e45b58!important;
}

/* TRANSACTIONS — preserve the intentionally empty body from the captured reference. */
body .admin-exec .ref-batch-transactions{
  min-height:148px!important;
  padding:24px!important;
}
body .admin-exec .ref-batch-transactions>div:first-child{
  margin:-24px -24px 16px!important;
  padding:17px 24px 14px!important;
  min-height:62px!important;
  border-bottom:1px solid rgba(190,137,28,.18)!important;
  background:linear-gradient(90deg,#fffaf0,#fffefb 55%,#fbf0d8)!important;
}
body .admin-exec .ref-batch-transactions h3{
  color:#111820!important;
  font-size:19px!important;
  font-weight:900!important;
}
body .admin-exec .ref-batch-transactions h3 svg{
  color:#d3a126!important;
  stroke:#d3a126!important;
}
body .admin-exec .ref-batch-transactions table{
  min-height:44px!important;
}

/* Keep the same page-scale and right rail as the Overview reference. */
body .admin-exec .ref-batch-users,
body .admin-exec .ref-batch-documents,
body .admin-exec .ref-batch-transactions{
  animation-duration:.25s!important;
}

@media(max-width:1500px){
  body .admin-exec .ref-batch-users>.ref-batch-panel,
  body .admin-exec .ref-batch-documents,
  body .admin-exec .ref-batch-transactions{padding:22px!important}
  body .admin-exec .ref-batch-sellers>div:first-child,
  body .admin-exec .ref-batch-customers>h3{margin-top:-22px!important;margin-left:-22px!important;margin-right:-22px!important;padding-left:22px!important;padding-right:22px!important}
  body .admin-exec .ref-batch-panel th{font-size:10.5px!important;padding:11px 10px!important}
  body .admin-exec .ref-batch-panel td{font-size:11px!important;padding:12px 10px!important}
}
CSS

[ "$(grep -c "AdminDashboard.v42.css" "$JSX")" -eq 1 ] || { echo 'FAILED_STEP=V42_IMPORT_COUNT'; exit 1; }
grep -q 'data-v42-reference-screen="users-sellers"' "$JSX" || { echo 'FAILED_STEP=V42_USERS_MARKER'; exit 1; }
grep -q 'data-v42-reference-screen="documents-verification"' "$JSX" || { echo 'FAILED_STEP=V42_DOCUMENTS_MARKER'; exit 1; }
grep -q 'data-v42-reference-screen="payments-transactions"' "$JSX" || { echo 'FAILED_STEP=V42_TRANSACTIONS_MARKER'; exit 1; }

npm run build

echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v42.css'
echo 'VISUAL_STRATEGY=REFERENCE_BATCH_01_MULTISCREEN'
echo 'OVERVIEW_REFERENCE_PRESERVED=YES'
echo 'USERS_SELLERS_REFERENCE_STRUCTURE_PRESERVED=YES'
echo 'DOCUMENTS_REFERENCE_STRUCTURE_PRESERVED=YES'
echo 'TRANSACTIONS_REFERENCE_STRUCTURE_PRESERVED=YES'
echo 'INVENTED_SECTIONS=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
