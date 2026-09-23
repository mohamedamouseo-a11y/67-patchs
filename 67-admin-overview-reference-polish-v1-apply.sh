#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
CSS="$ROOT/src/pages/AdminDashboard.overview-reference-v1.css"
BACKUP="$(mktemp -d /tmp/67-admin-overview-v1.XXXXXX)"
CSS_EXISTED=0

cd "$ROOT"
test -f "$JSX"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
if [ -f "$CSS" ]; then
  CSS_EXISTED=1
  cp "$CSS" "$BACKUP/AdminDashboard.overview-reference-v1.css"
fi

restore() {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  if [ "$CSS_EXISTED" = "1" ]; then
    cp "$BACKUP/AdminDashboard.overview-reference-v1.css" "$CSS"
  else
    rm -f "$CSS"
  fi
}
trap restore ERR

python3 - "$JSX" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text()
imp="import './AdminDashboard.overview-reference-v1.css';"
if imp not in s:
    anchors=[
        "import './AdminDashboard.login-luxury-v1.1.css';",
        "import './AdminDashboard.theme-v1.css';",
        "import './AdminDashboard.v45.css';",
    ]
    for a in anchors:
        if a in s:
            s=s.replace(a,a+"\n"+imp,1)
            break
    else:
        raise SystemExit("CSS import anchor missing")
p.write_text(s)
PY

cat > "$CSS" <<'CSS'
/* 67 ADMIN OVERVIEW REFERENCE POLISH V1
   Scope: admin overview only. No business/auth/backend changes. */

.admin-exec[data-admin-theme="light"]{
  --ov-bg:#f6f2e8;--ov-surface:#fffdfa;--ov-surface-2:#fff;
  --ov-border:rgba(190,145,40,.18);--ov-border-strong:rgba(190,145,40,.28);
  --ov-text:#091421;--ov-soft:#556173;--ov-muted:#7f8998;
  --ov-gold:#c8951e;--ov-gold-wash:rgba(201,151,31,.08);
  --ov-shadow:0 14px 38px rgba(62,43,12,.07);--ov-shadow-soft:0 8px 24px rgba(62,43,12,.045);
}
.admin-exec[data-admin-theme="dark"]{
  --ov-bg:#07111d;--ov-surface:#0c1825;--ov-surface-2:#101e2d;
  --ov-border:rgba(220,174,63,.17);--ov-border-strong:rgba(220,174,63,.29);
  --ov-text:#f4f1e8;--ov-soft:#d1d8e2;--ov-muted:#8f9caf;
  --ov-gold:#d6ae47;--ov-gold-wash:rgba(220,174,63,.08);
  --ov-shadow:0 16px 42px rgba(0,0,0,.30);--ov-shadow-soft:0 9px 26px rgba(0,0,0,.22);
}

.admin-exec .v38-dashboard{
  gap:14px!important;
  padding:0!important;
}
.admin-exec .v38-hero{
  min-height:184px!important;
  border-radius:24px!important;
  overflow:hidden!important;
  border:1px solid var(--ov-border-strong)!important;
  box-shadow:var(--ov-shadow)!important;
}
.admin-exec .v38-hero:after{
  content:"";position:absolute;inset:0;pointer-events:none;
  background:linear-gradient(90deg,rgba(4,12,22,.62),rgba(4,12,22,.12) 45%,rgba(4,12,22,.42)),
             linear-gradient(180deg,rgba(224,178,66,.06),transparent 45%);
}
.admin-exec .v38-hero>*{position:relative;z-index:1}
.admin-exec .v38-hero h1{letter-spacing:-.7px;text-shadow:0 6px 22px rgba(0,0,0,.3)}
.admin-exec .v38-datebar{
  border-radius:14px!important;
  border:1px solid rgba(255,255,255,.10)!important;
  background:rgba(5,13,23,.76)!important;
  backdrop-filter:blur(12px)!important;
  box-shadow:0 10px 26px rgba(0,0,0,.16)!important;
}
.admin-exec .v38-datebar button{border-radius:10px!important}

.admin-exec .v38-kpis{gap:14px!important}
.admin-exec .v38-kpi{
  border-radius:18px!important;
  border:1px solid var(--ov-border)!important;
  background:linear-gradient(180deg,var(--ov-surface),color-mix(in srgb,var(--ov-surface) 92%,var(--ov-gold) 8%))!important;
  box-shadow:var(--ov-shadow-soft)!important;
  padding:16px 17px!important;
}
.admin-exec .v38-kpi__top{color:var(--ov-soft)!important;font-weight:800!important}
.admin-exec .v38-kpi__value{color:var(--ov-text)!important;font-weight:900!important;letter-spacing:-.4px}
.admin-exec .v38-kpi__ico{
  width:36px!important;height:36px!important;border-radius:11px!important;
  display:grid!important;place-items:center!important;
  background:var(--ov-gold-wash)!important;border:1px solid var(--ov-border)!important;color:var(--ov-gold)!important;
}
.admin-exec .v38-kpi__foot span{color:var(--ov-muted)!important}

.admin-exec .v38-health{
  border-radius:20px!important;
  border:1px solid var(--ov-border)!important;
  box-shadow:var(--ov-shadow-soft)!important;
  overflow:hidden!important;
}
.admin-exec[data-admin-theme="light"] .v38-health{
  background:linear-gradient(135deg,#0a1725,#0d2134)!important;
}
.admin-exec[data-admin-theme="dark"] .v38-health{
  background:linear-gradient(135deg,#06111c,#0b1c2d)!important;
}
.admin-exec .v38-health-metric{
  border-radius:14px!important;
  border:1px solid rgba(255,255,255,.07)!important;
  background:rgba(255,255,255,.025)!important;
}
.admin-exec .v38-health__scene{border-radius:15px!important;overflow:hidden!important}

.admin-exec .v38-revenue,
.admin-exec .v38-live,
.admin-exec .v38-current,
.admin-exec .v38-ledger{
  border-radius:22px!important;
  border:1px solid var(--ov-border)!important;
  background:linear-gradient(180deg,var(--ov-surface),color-mix(in srgb,var(--ov-surface) 96%,var(--ov-gold) 4%))!important;
  box-shadow:var(--ov-shadow-soft)!important;
}
.admin-exec .v38-revenue{padding:17px!important}
.admin-exec .v38-section-head{
  padding-bottom:12px!important;margin-bottom:12px!important;
  border-bottom:1px solid rgba(128,140,156,.10)!important;
}
.admin-exec .v38-section-title h3,
.admin-exec .v38-ops-head h3,
.admin-exec .v38-ledger-title h3{color:var(--ov-text)!important;font-weight:900!important}
.admin-exec .v38-section-title small,
.admin-exec .v38-ops-head small,
.admin-exec .v38-ledger-title small,
.admin-exec .v38-period{color:var(--ov-muted)!important}

.admin-exec .v38-rev-stats{gap:10px!important}
.admin-exec .v38-rev-stat{
  border-radius:13px!important;
  background:var(--ov-surface-2)!important;
  border:1px solid rgba(128,140,156,.10)!important;
}
.admin-exec .v38-rev-stat span{color:var(--ov-muted)!important}
.admin-exec .v38-rev-stat strong{color:var(--ov-text)!important}

.admin-exec .v38-chart{
  border-radius:17px!important;
  border:1px solid rgba(128,140,156,.10)!important;
  background:var(--ov-surface-2)!important;
  overflow:hidden!important;
}
.admin-exec .recharts-cartesian-grid line{stroke:rgba(128,140,156,.12)!important}
.admin-exec .recharts-cartesian-axis-tick-value{fill:var(--ov-muted)!important}

.admin-exec .v38-ops-grid{gap:14px!important}
.admin-exec .v38-live,
.admin-exec .v38-current{padding:15px!important}
.admin-exec .v38-ops-head{
  padding-bottom:11px!important;margin-bottom:10px!important;
  border-bottom:1px solid rgba(128,140,156,.10)!important;
}
.admin-exec .v38-ops-head button{
  min-height:34px!important;padding:0 12px!important;border-radius:10px!important;
  border:1px solid var(--ov-border)!important;background:var(--ov-surface-2)!important;color:var(--ov-text)!important;
  font-weight:800!important;
}
.admin-exec .v38-live-row{
  min-height:46px!important;padding:10px 11px!important;margin-bottom:7px!important;
  border-radius:12px!important;border:1px solid rgba(128,140,156,.09)!important;background:var(--ov-surface-2)!important;
}
.admin-exec .v38-live-row__text{color:var(--ov-text)!important;font-weight:700!important}
.admin-exec .v38-live-row__time{color:var(--ov-muted)!important}
.admin-exec .v38-live-summary,
.admin-exec .v38-current-summary{
  border-radius:14px!important;border:1px solid rgba(128,140,156,.10)!important;overflow:hidden!important;
  background:var(--ov-surface-2)!important;
}
.admin-exec .v38-current-table th,
.admin-exec .v38-ledger-table th{color:var(--ov-muted)!important;font-size:12px!important;font-weight:800!important}
.admin-exec .v38-current-table td,
.admin-exec .v38-ledger-table td{color:var(--ov-soft)!important;border-color:rgba(128,140,156,.10)!important}
.admin-exec .v38-mini-status{
  border-radius:999px!important;padding:4px 9px!important;font-weight:900!important;
  background:rgba(27,171,111,.10)!important;color:#1a9f69!important;border:1px solid rgba(27,171,111,.15)!important;
}
.admin-exec .v38-mini-status.pending{
  background:rgba(230,158,28,.10)!important;color:#c98913!important;border-color:rgba(230,158,28,.17)!important;
}

.admin-exec .v38-ledger{padding:15px!important}
.admin-exec .v38-ledger-head{
  padding-bottom:11px!important;margin-bottom:10px!important;border-bottom:1px solid rgba(128,140,156,.10)!important;
}
.admin-exec .v38-ledger-search,
.admin-exec .v38-ledger-filter,
.admin-exec .v38-ledger-export{
  min-height:38px!important;border-radius:10px!important;
  border:1px solid var(--ov-border)!important;background:var(--ov-surface-2)!important;color:var(--ov-text)!important;box-shadow:none!important;
}
.admin-exec .v38-ledger-search::placeholder{color:var(--ov-muted)!important}
.admin-exec .v38-ledger-table-wrap{
  border-radius:14px!important;overflow:hidden!important;border:1px solid rgba(128,140,156,.10)!important;background:var(--ov-surface-2)!important;
}
.admin-exec .v38-tx-id{
  border-radius:999px!important;background:var(--ov-gold-wash)!important;color:var(--ov-gold)!important;font-weight:900!important;
}
.admin-exec .v38-amount{color:var(--ov-gold)!important;font-weight:900!important}

.admin-exec .v38-kpi,
.admin-exec .v38-revenue,
.admin-exec .v38-live,
.admin-exec .v38-current,
.admin-exec .v38-ledger,
.admin-exec .v38-live-row{
  transition:transform .2s ease,border-color .2s ease,box-shadow .2s ease,background-color .2s ease!important;
}
.admin-exec .v38-kpi:hover,
.admin-exec .v38-live-row:hover{transform:translateY(-1px)}

@media(max-width:1200px){
  .admin-exec .v38-ops-grid{grid-template-columns:1fr!important}
}
@media(max-width:900px){
  .admin-exec .v38-hero{border-radius:18px!important}
  .admin-exec .v38-kpi,.admin-exec .v38-revenue,.admin-exec .v38-live,.admin-exec .v38-current,.admin-exec .v38-ledger{border-radius:17px!important}
}
CSS

grep -q "AdminDashboard.overview-reference-v1.css" "$JSX"
grep -q "67 ADMIN OVERVIEW REFERENCE POLISH V1" "$CSS"
npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-ADMIN-OVERVIEW-REFERENCE-POLISH-V1"
echo "BUILD=PASS"
echo "SCOPE=OVERVIEW_ONLY"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "ERROR=NONE"
