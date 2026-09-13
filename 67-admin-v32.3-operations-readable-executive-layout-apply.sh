#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v32.2.css
TARGET_CSS=src/pages/AdminDashboard.v32.3.css
MARKER='SIX SEVEN ADMIN V32.3 — OPERATIONS READABLE EXECUTIVE LAYOUT'
BACKUP=/tmp/67-v32-3-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V32_2_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v32.2.css';" "$JSX" || { echo 'FAILED_STEP=V32_2_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v32.2.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v32.2.css';"
new="import './AdminDashboard.v32.3.css';"
if old not in s:
    raise SystemExit('V32_2_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V32.3 — OPERATIONS READABLE EXECUTIVE LAYOUT
   Final readable reset for Live Operations + Current Operations only.
   Principle: do not compress real operational information into microscopic
   typography. Allow the second command row to grow naturally while preserving
   the V32 premium visual language and all existing data/logic/DOM. */

@media (min-width:1101px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    width:100%!important;
    height:auto!important;
    min-height:400px!important;
    max-height:none!important;
    margin:0!important;
    padding:14px 15px 13px!important;
    overflow:hidden!important;
    box-sizing:border-box!important;
  }
  body .admin-exec .live-card *,
  body .admin-exec .ops-card *{box-sizing:border-box!important}

  /* ================= LIVE OPERATIONS ================= */
  body .admin-exec .live-card{
    display:flex!important;
    flex-direction:column!important;
    gap:0!important;
  }
  body .admin-exec .live-card__head{
    flex:0 0 42px!important;
    width:100%!important;
    height:42px!important;
    min-height:42px!important;
    max-height:42px!important;
    margin:0 0 9px!important;
    padding:0 2px 8px!important;
    display:flex!important;
    align-items:center!important;
    justify-content:space-between!important;
    gap:10px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-card__head h3{
    min-width:0!important;
    margin:0!important;
    font-size:13px!important;
    line-height:1.1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-card__head h3 svg{
    width:17px!important;
    height:17px!important;
    flex:0 0 17px!important;
  }
  body .admin-exec .live-card__badge{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    min-width:30px!important;
    width:auto!important;
    height:26px!important;
    min-height:26px!important;
    padding:0 9px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:9px!important;
    line-height:1!important;
  }

  body .admin-exec .live-card__list{
    flex:0 0 auto!important;
    width:100%!important;
    min-height:0!important;
    margin:0!important;
    padding:0!important;
    display:flex!important;
    flex-direction:column!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item{
    flex:0 0 auto!important;
    width:100%!important;
    min-height:40px!important;
    height:auto!important;
    max-height:none!important;
    padding:7px 9px!important;
    display:flex!important;
    align-items:center!important;
    gap:9px!important;
    overflow:visible!important;
    border-radius:10px!important;
  }
  body .admin-exec .live-item__ico{
    flex:0 0 28px!important;
    width:28px!important;
    height:28px!important;
    min-width:28px!important;
    min-height:28px!important;
    border-radius:9px!important;
  }
  body .admin-exec .live-item__ico svg{width:14px!important;height:14px!important}
  body .admin-exec .live-item__body{
    flex:1 1 auto!important;
    min-width:0!important;
    height:auto!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item__body p{
    width:100%!important;
    margin:0!important;
    color:#edf1f5!important;
    font-size:9.5px!important;
    line-height:1.35!important;
    font-weight:720!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
    overflow-wrap:break-word!important;
  }
  body .admin-exec .live-item__body small,
  body .admin-exec .live-item .when{
    display:block!important;
    margin:3px 0 0!important;
    color:#7f8a96!important;
    font-size:7.5px!important;
    line-height:1.15!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .live-activity-summary{
    flex:0 0 auto!important;
    width:100%!important;
    min-height:72px!important;
    height:auto!important;
    max-height:none!important;
    margin:9px 0 0!important;
    padding:9px 10px!important;
    display:grid!important;
    grid-template-columns:minmax(0,1.45fr) minmax(185px,.95fr)!important;
    gap:10px!important;
    align-items:center!important;
    overflow:visible!important;
    border-radius:11px!important;
  }
  body .admin-exec .live-activity-summary__lead{min-width:0!important;gap:9px!important}
  body .admin-exec .live-activity-summary__icon{
    width:32px!important;
    height:32px!important;
    flex:0 0 32px!important;
    border-radius:9px!important;
  }
  body .admin-exec .live-activity-summary__lead>div{min-width:0!important}
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span,
  body .admin-exec .live-activity-summary__lead strong{
    display:block!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span{
    font-size:7.5px!important;
    line-height:1.25!important;
  }
  body .admin-exec .live-activity-summary__lead strong{
    margin:2px 0!important;
    font-size:9px!important;
    line-height:1.2!important;
  }
  body .admin-exec .live-activity-summary__metrics{
    min-width:0!important;
    display:grid!important;
    grid-template-columns:repeat(3,minmax(0,1fr))!important;
    gap:5px!important;
  }
  body .admin-exec .live-activity-summary__metrics>span{
    min-width:0!important;
    min-height:46px!important;
    height:auto!important;
    padding:5px 3px!important;
  }
  body .admin-exec .live-activity-summary__metrics svg{width:11px!important;height:11px!important}
  body .admin-exec .live-activity-summary__metrics strong{font-size:9px!important;line-height:1!important}
  body .admin-exec .live-activity-summary__metrics small{font-size:6.5px!important;line-height:1!important}

  body .admin-exec .live-card__footer{
    display:block!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:100%!important;
    height:auto!important;
    min-height:62px!important;
    max-height:none!important;
    margin:10px 0 0!important;
    padding:8px 0 0!important;
    overflow:visible!important;
  }
  body .admin-exec .live-card__footer-status{
    width:100%!important;
    min-height:25px!important;
    height:auto!important;
    display:flex!important;
    align-items:center!important;
    justify-content:space-between!important;
    gap:7px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-pending,
  body .admin-exec .live-quick{
    min-width:0!important;
    margin:0!important;
    display:flex!important;
    flex-wrap:wrap!important;
    align-items:center!important;
    gap:4px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-pending span,
  body .admin-exec .live-quick span{
    min-width:0!important;
    width:auto!important;
    height:22px!important;
    padding:0 7px!important;
    display:inline-flex!important;
    align-items:center!important;
    gap:4px!important;
    font-size:7px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-pending span svg,
  body .admin-exec .live-quick span svg{
    width:11px!important;
    height:11px!important;
    flex:0 0 11px!important;
  }
  body .admin-exec .live-cta{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    min-height:30px!important;
    height:30px!important;
    max-height:30px!important;
    margin:7px 0 0!important;
    padding:0 10px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:8px!important;
    line-height:1!important;
    overflow:hidden!important;
    border-radius:9px!important;
  }

  /* ================= CURRENT OPERATIONS ================= */
  body .admin-exec .ops-card{
    display:flex!important;
    flex-direction:column!important;
    gap:0!important;
    align-content:initial!important;
    grid-template-rows:none!important;
    grid-auto-rows:auto!important;
  }
  body .admin-exec .ops-card__head{
    flex:0 0 44px!important;
    width:100%!important;
    height:44px!important;
    min-height:44px!important;
    max-height:44px!important;
    margin:0 0 9px!important;
    padding:0 2px 8px!important;
    display:flex!important;
    align-items:center!important;
    justify-content:space-between!important;
    gap:10px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-card__title-group{
    min-width:0!important;
    display:flex!important;
    align-items:center!important;
    gap:8px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-card__title-icon{
    width:30px!important;
    height:30px!important;
    min-width:30px!important;
    flex:0 0 30px!important;
    border-radius:9px!important;
  }
  body .admin-exec .ops-card__title-icon svg{width:14px!important;height:14px!important}
  body .admin-exec .ops-card__title-group>div{min-width:0!important}
  body .admin-exec .ops-card__title-group h3{
    margin:0!important;
    color:#151b23!important;
    font-size:12px!important;
    line-height:1.05!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-card__title-group small{
    display:block!important;
    margin-top:3px!important;
    color:#958a7b!important;
    font-size:7.5px!important;
    line-height:1.1!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-card__command-badge{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:auto!important;
    max-width:none!important;
    height:25px!important;
    min-height:25px!important;
    padding:0 9px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:7.5px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .ops-summary-row{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:100%!important;
    height:auto!important;
    min-height:62px!important;
    max-height:none!important;
    margin:0 0 9px!important;
    grid-template-columns:repeat(2,minmax(0,1fr))!important;
    gap:7px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-summary-tile{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    min-width:0!important;
    min-height:62px!important;
    height:auto!important;
    max-height:none!important;
    padding:8px 10px!important;
    justify-content:center!important;
    overflow:visible!important;
    border-radius:10px!important;
  }
  body .admin-exec .ops-summary-tile span{font-size:7.5px!important;line-height:1!important;white-space:nowrap!important}
  body .admin-exec .ops-summary-tile strong{font-size:15px!important;line-height:1!important;margin:4px 0!important}
  body .admin-exec .ops-summary-tile small{
    font-size:7px!important;
    line-height:1.1!important;
    white-space:normal!important;
    overflow:visible!important;
  }

  body .admin-exec .ops-tiles{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:100%!important;
    height:auto!important;
    min-height:0!important;
    max-height:none!important;
    margin:0!important;
    flex-direction:column!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-tile{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:100%!important;
    min-width:0!important;
    min-height:42px!important;
    height:auto!important;
    max-height:none!important;
    margin:0!important;
    padding:6px 8px!important;
    grid-template-columns:29px minmax(0,1fr) 30px 58px!important;
    align-items:center!important;
    gap:7px!important;
    overflow:visible!important;
    border-radius:9px!important;
  }
  body .admin-exec .ops-tile__ico{
    width:29px!important;
    height:29px!important;
    min-width:29px!important;
    border-radius:8px!important;
  }
  body .admin-exec .ops-tile__ico svg{width:13px!important;height:13px!important}
  body .admin-exec .ops-tile__info{min-width:0!important;overflow:visible!important}
  body .admin-exec .ops-tile__info strong,
  body .admin-exec .ops-tile__info small{
    display:block!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-tile__info strong{font-size:9px!important;line-height:1.1!important}
  body .admin-exec .ops-tile__info small{font-size:7px!important;line-height:1.1!important;margin-top:2px!important}
  body .admin-exec .ops-tile__count{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:30px!important;
    min-width:30px!important;
    height:24px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:9px!important;
    line-height:1!important;
  }
  body .admin-exec .ops-tile__state{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:58px!important;
    min-width:58px!important;
    height:24px!important;
    padding:0 7px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:7.5px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:hidden!important;
  }

  body .admin-exec .ops-card>.ops-tile{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:100%!important;
    min-height:42px!important;
    height:auto!important;
    max-height:none!important;
    margin:7px 0 0!important;
    grid-template-columns:29px minmax(0,1fr) 30px 58px!important;
  }
  body .admin-exec .ops-good-strip{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    width:100%!important;
    min-height:34px!important;
    height:34px!important;
    max-height:34px!important;
    margin:9px 0 0!important;
    padding:0 10px!important;
    align-items:center!important;
    justify-content:center!important;
    gap:6px!important;
    font-size:8px!important;
    line-height:1.1!important;
    white-space:normal!important;
    overflow:hidden!important;
    text-overflow:clip!important;
    border-radius:9px!important;
  }
  body .admin-exec .ops-good-strip svg{
    width:13px!important;
    height:13px!important;
    flex:0 0 13px!important;
  }
}

@media (max-width:1100px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    height:auto!important;
    min-height:360px!important;
    max-height:none!important;
    overflow:hidden!important;
  }
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v32-3-build.log 2>&1 || {
  tail -n 180 /tmp/67-v32-3-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V32.3'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=OPERATIONS READABLE EXECUTIVE LAYOUT'
echo 'BASE_VERSION=V32.2'
echo 'TARGET_VERSION=V32.3'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v32.3.css'
echo 'JSX_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
