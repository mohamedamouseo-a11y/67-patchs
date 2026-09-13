#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v32.css
TARGET_CSS=src/pages/AdminDashboard.v32.1.css
MARKER='SIX SEVEN ADMIN V32.1 — OPERATIONS VISIBILITY + CONTAINMENT FIX'
BACKUP=/tmp/67-v32-1-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V32_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v32.css';" "$JSX" || { echo 'FAILED_STEP=V32_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v32.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v32.css';"
new="import './AdminDashboard.v32.1.css';"
if old not in s:
    raise SystemExit('V32_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V32.1 — OPERATIONS VISIBILITY + CONTAINMENT FIX
   Corrective CSS-only layer over V32.
   Fixes: Live text clipping/footer visibility + Current Operations missing
   badge/rows/status/health visibility. No JSX/data/logic changes. */

@media (min-width:1101px){
  /* Re-lock the approved V31.2 row geometry. V32 had released the two cards
     to auto-height, which allowed internal flex content to compete with the
     command-grid row. Keep both operations cards physically deterministic. */
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    height:286px!important;
    min-height:286px!important;
    max-height:286px!important;
    padding:9px 10px 8px!important;
    overflow:hidden!important;
  }

  /* ================= LIVE OPERATIONS ================= */
  body .admin-exec .live-card__head{
    flex:0 0 31px!important;
    height:31px!important;
    min-height:31px!important;
    margin:0 0 4px!important;
    padding:0 1px 4px!important;
  }
  body .admin-exec .live-card__head h3{
    font-size:11.5px!important;
    line-height:1.1!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-card__badge{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    height:22px!important;
    min-width:24px!important;
    padding:0 7px!important;
  }

  body .admin-exec .live-card__list{
    flex:0 1 auto!important;
    min-height:0!important;
    max-height:none!important;
    gap:3px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item{
    flex:0 0 auto!important;
    min-height:30px!important;
    height:auto!important;
    padding:4px 6px!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item__ico{
    width:22px!important;
    height:22px!important;
    flex:0 0 22px!important;
  }
  body .admin-exec .live-item__body{
    min-width:0!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item__body p{
    margin:0!important;
    font-size:7.9px!important;
    line-height:1.25!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
    overflow-wrap:anywhere!important;
    word-break:normal!important;
  }
  body .admin-exec .live-item__body small,
  body .admin-exec .live-item .when{
    margin-top:1px!important;
    font-size:6.5px!important;
    line-height:1.15!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .live-activity-summary{
    flex:0 0 auto!important;
    min-height:44px!important;
    margin-top:4px!important;
    padding:5px 6px!important;
    grid-template-columns:minmax(0,1.45fr) minmax(118px,.9fr)!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-activity-summary__icon{
    width:23px!important;
    height:23px!important;
    flex:0 0 23px!important;
  }
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead strong,
  body .admin-exec .live-activity-summary__lead span{
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span{font-size:6px!important;line-height:1.1!important}
  body .admin-exec .live-activity-summary__lead strong{font-size:7.3px!important;line-height:1.15!important}
  body .admin-exec .live-activity-summary__metrics{gap:3px!important}
  body .admin-exec .live-activity-summary__metrics>span{
    min-height:30px!important;
    height:30px!important;
    padding:2px!important;
  }
  body .admin-exec .live-activity-summary__metrics strong{font-size:7.2px!important}
  body .admin-exec .live-activity-summary__metrics small{font-size:5.3px!important}

  body .admin-exec .live-card__footer{
    display:block!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    margin-top:auto!important;
    padding-top:4px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-card__footer-status{
    display:grid!important;
    grid-template-columns:minmax(0,1fr) minmax(0,1fr)!important;
    align-items:center!important;
    gap:5px!important;
    min-height:21px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-pending,
  body .admin-exec .live-quick{
    min-width:0!important;
    display:flex!important;
    flex-wrap:nowrap!important;
    gap:3px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-pending span,
  body .admin-exec .live-quick span{
    min-width:0!important;
    height:19px!important;
    padding:0 5px!important;
    font-size:6.1px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-pending span svg,
  body .admin-exec .live-quick span svg{width:10px!important;height:10px!important;flex:0 0 10px!important}
  body .admin-exec .live-cta{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    min-height:24px!important;
    height:24px!important;
    margin-top:4px!important;
    padding:0 8px!important;
    font-size:6.8px!important;
    overflow:visible!important;
  }

  /* ================= CURRENT OPERATIONS ================= */
  body .admin-exec .ops-card__head{
    flex:0 0 33px!important;
    height:33px!important;
    min-height:33px!important;
    margin:0 0 4px!important;
    padding:0 1px 4px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-card__title-group{gap:6px!important;overflow:visible!important}
  body .admin-exec .ops-card__title-icon{
    width:25px!important;
    height:25px!important;
    flex:0 0 25px!important;
  }
  body .admin-exec .ops-card__title-group h3{
    font-size:10.7px!important;
    line-height:1.05!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-card__title-group small{
    margin-top:1px!important;
    font-size:5.9px!important;
    line-height:1.05!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-card__command-badge{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    min-width:0!important;
    max-width:42%!important;
    height:21px!important;
    padding:0 7px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:5.9px!important;
    line-height:1!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .ops-summary-row{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 43px!important;
    height:43px!important;
    min-height:43px!important;
    grid-template-columns:repeat(2,minmax(0,1fr))!important;
    gap:5px!important;
    margin:0 0 4px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-summary-tile{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    min-height:43px!important;
    height:43px!important;
    padding:5px 7px!important;
    justify-content:center!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-summary-tile span{font-size:5.7px!important;line-height:1!important}
  body .admin-exec .ops-summary-tile strong{font-size:11px!important;line-height:1!important;margin:1px 0!important}
  body .admin-exec .ops-summary-tile small{
    font-size:5.6px!important;
    line-height:1!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .ops-tiles{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 98px!important;
    height:98px!important;
    min-height:98px!important;
    grid-template-rows:repeat(3,30px)!important;
    gap:4px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-tile{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    min-height:30px!important;
    height:30px!important;
    max-height:30px!important;
    padding:3px 5px!important;
    grid-template-columns:22px minmax(0,1fr) auto auto!important;
    align-items:center!important;
    gap:5px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-tile__ico{
    width:22px!important;
    height:22px!important;
    min-width:22px!important;
  }
  body .admin-exec .ops-tile__info{
    min-width:0!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-tile__info strong,
  body .admin-exec .ops-tile__info small{
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
    overflow-wrap:anywhere!important;
  }
  body .admin-exec .ops-tile__info strong{font-size:7px!important;line-height:1.05!important}
  body .admin-exec .ops-tile__info small{font-size:5.6px!important;line-height:1.05!important;margin-top:1px!important}
  body .admin-exec .ops-tile__count{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    align-items:center!important;
    justify-content:center!important;
    min-width:18px!important;
    height:18px!important;
    font-size:7px!important;
  }
  body .admin-exec .ops-tile__state{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    align-items:center!important;
    justify-content:center!important;
    min-width:34px!important;
    height:18px!important;
    padding:0 5px!important;
    font-size:5.6px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
  }

  body .admin-exec .ops-card>.ops-tile{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 30px!important;
    min-height:30px!important;
    height:30px!important;
    max-height:30px!important;
    margin-top:4px!important;
  }
  body .admin-exec .ops-good-strip{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 24px!important;
    min-height:24px!important;
    height:24px!important;
    margin-top:4px!important;
    padding:0 7px!important;
    align-items:center!important;
    justify-content:center!important;
    gap:4px!important;
    font-size:6.2px!important;
    line-height:1.1!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-good-strip svg{width:11px!important;height:11px!important;flex:0 0 11px!important}
}

/* At narrower stacked layouts keep natural height; only remove text clipping and
   force structural visibility. */
@media (max-width:1100px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{height:auto!important;min-height:286px!important;max-height:none!important;overflow:hidden!important}
  body .admin-exec .live-item__body p,
  body .admin-exec .live-item__body small,
  body .admin-exec .ops-tile__info strong,
  body .admin-exec .ops-tile__info small{
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
    overflow-wrap:anywhere!important;
  }
  body .admin-exec .live-card__footer,
  body .admin-exec .ops-card__command-badge,
  body .admin-exec .ops-summary-row,
  body .admin-exec .ops-tiles,
  body .admin-exec .ops-tile,
  body .admin-exec .ops-tile__state,
  body .admin-exec .ops-good-strip{
    visibility:visible!important;
    opacity:1!important;
  }
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v32-1-build.log 2>&1 || {
  tail -n 180 /tmp/67-v32-1-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V32.1'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=OPERATIONS VISIBILITY + CONTAINMENT FIX'
echo 'BASE_VERSION=V32'
echo 'TARGET_VERSION=V32.1'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v32.1.css'
echo 'LIVE_TEXT_CLIPPING_FIX=YES'
echo 'LIVE_FOOTER_VISIBILITY_FIX=YES'
echo 'OPS_COMMAND_BADGE_VISIBILITY_FIX=YES'
echo 'OPS_ROWS_VISIBILITY_FIX=YES'
echo 'OPS_STATUS_PILLS_VISIBILITY_FIX=YES'
echo 'OPS_HEALTH_STRIP_VISIBILITY_FIX=YES'
echo 'JSX_CHANGED=IMPORT_ONLY'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
