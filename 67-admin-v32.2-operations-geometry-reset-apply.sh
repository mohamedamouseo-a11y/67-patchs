#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v32.1.css
TARGET_CSS=src/pages/AdminDashboard.v32.2.css
MARKER='SIX SEVEN ADMIN V32.2 — OPERATIONS GEOMETRY RESET'
BACKUP=/tmp/67-v32-2-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V32_1_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v32.1.css';" "$JSX" || { echo 'FAILED_STEP=V32_1_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v32.1.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v32.1.css';"
new="import './AdminDashboard.v32.2.css';"
if old not in s:
    raise SystemExit('V32_1_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V32.2 — OPERATIONS GEOMETRY RESET
   Final geometry reset over V32/V32.1. CSS-only.
   Goal: every real Live + Current Operations child physically fits inside its
   card at 1920x1080, without hiding/removing data or altering logic. */

@media (min-width:1101px){
  /* Keep the second command row compact enough for the executive overview. */
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    width:100%!important;
    height:258px!important;
    min-height:258px!important;
    max-height:258px!important;
    margin:0!important;
    padding:8px 10px!important;
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
    flex:0 0 28px!important;
    width:100%!important;
    height:28px!important;
    min-height:28px!important;
    max-height:28px!important;
    margin:0 0 4px!important;
    padding:0 1px 4px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-card__head h3{
    min-width:0!important;
    font-size:11px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-card__head h3 svg{width:14px!important;height:14px!important;flex:0 0 14px!important}
  body .admin-exec .live-card__badge{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    height:20px!important;
    min-height:20px!important;
    min-width:22px!important;
    padding:0 6px!important;
    font-size:7.5px!important;
  }

  body .admin-exec .live-card__list{
    flex:1 1 auto!important;
    min-height:0!important;
    width:100%!important;
    display:flex!important;
    flex-direction:column!important;
    justify-content:flex-start!important;
    gap:3px!important;
    margin:0!important;
    padding:0!important;
    overflow:hidden!important;
  }
  body .admin-exec .live-item{
    flex:0 0 27px!important;
    width:100%!important;
    height:27px!important;
    min-height:27px!important;
    max-height:27px!important;
    padding:3px 6px!important;
    gap:6px!important;
    display:flex!important;
    align-items:center!important;
    overflow:hidden!important;
  }
  body .admin-exec .live-item__ico{
    flex:0 0 21px!important;
    width:21px!important;
    height:21px!important;
    min-width:21px!important;
    min-height:21px!important;
  }
  body .admin-exec .live-item__ico svg{width:12px!important;height:12px!important}
  body .admin-exec .live-item__body{
    flex:1 1 auto!important;
    min-width:0!important;
    height:21px!important;
    display:flex!important;
    flex-direction:column!important;
    justify-content:center!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item__body p{
    width:100%!important;
    margin:0!important;
    font-size:7.5px!important;
    line-height:1.05!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-item__body small,
  body .admin-exec .live-item .when{
    margin:1px 0 0!important;
    font-size:5.8px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .live-activity-summary{
    flex:0 0 42px!important;
    width:100%!important;
    height:42px!important;
    min-height:42px!important;
    max-height:42px!important;
    margin:4px 0 0!important;
    padding:4px 6px!important;
    display:grid!important;
    grid-template-columns:minmax(0,1.5fr) minmax(112px,.9fr)!important;
    gap:5px!important;
    overflow:hidden!important;
  }
  body .admin-exec .live-activity-summary__lead{min-width:0!important;gap:5px!important}
  body .admin-exec .live-activity-summary__icon{width:22px!important;height:22px!important;flex:0 0 22px!important}
  body .admin-exec .live-activity-summary__lead>div{min-width:0!important}
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span,
  body .admin-exec .live-activity-summary__lead strong{
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span{font-size:5.5px!important;line-height:1!important}
  body .admin-exec .live-activity-summary__lead strong{font-size:6.8px!important;line-height:1.05!important;margin:1px 0!important}
  body .admin-exec .live-activity-summary__metrics{grid-template-columns:repeat(3,minmax(0,1fr))!important;gap:3px!important}
  body .admin-exec .live-activity-summary__metrics>span{
    min-width:0!important;
    height:30px!important;
    min-height:30px!important;
    padding:2px!important;
  }
  body .admin-exec .live-activity-summary__metrics svg{width:9px!important;height:9px!important}
  body .admin-exec .live-activity-summary__metrics strong{font-size:6.8px!important;line-height:1!important}
  body .admin-exec .live-activity-summary__metrics small{font-size:4.9px!important;line-height:1!important}

  body .admin-exec .live-card__footer{
    display:block!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 48px!important;
    width:100%!important;
    height:48px!important;
    min-height:48px!important;
    max-height:48px!important;
    margin:4px 0 0!important;
    padding:4px 0 0!important;
    overflow:hidden!important;
  }
  body .admin-exec .live-card__footer-status{
    width:100%!important;
    height:19px!important;
    min-height:19px!important;
    display:grid!important;
    grid-template-columns:minmax(0,1fr) minmax(0,1fr)!important;
    gap:4px!important;
    align-items:center!important;
    overflow:visible!important;
  }
  body .admin-exec .live-pending,
  body .admin-exec .live-quick{
    min-width:0!important;
    height:19px!important;
    margin:0!important;
    display:flex!important;
    flex-wrap:nowrap!important;
    align-items:center!important;
    gap:2px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-pending span,
  body .admin-exec .live-quick span{
    flex:0 1 auto!important;
    min-width:0!important;
    height:18px!important;
    padding:0 4px!important;
    font-size:5.5px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-pending span svg,
  body .admin-exec .live-quick span svg{width:9px!important;height:9px!important;flex:0 0 9px!important}
  body .admin-exec .live-cta{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    height:21px!important;
    min-height:21px!important;
    max-height:21px!important;
    margin:4px 0 0!important;
    padding:0 7px!important;
    font-size:6px!important;
    line-height:1!important;
    overflow:hidden!important;
  }

  /* ================= CURRENT OPERATIONS ================= */
  body .admin-exec .ops-card{
    display:grid!important;
    grid-template-rows:30px 42px 94px 28px 22px!important;
    grid-auto-rows:0!important;
    row-gap:4px!important;
    align-content:start!important;
  }
  body .admin-exec .ops-card__head{
    width:100%!important;
    height:30px!important;
    min-height:30px!important;
    max-height:30px!important;
    margin:0!important;
    padding:0 1px 4px!important;
    display:flex!important;
    align-items:center!important;
    justify-content:space-between!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-card__title-group{min-width:0!important;gap:5px!important;overflow:visible!important}
  body .admin-exec .ops-card__title-icon{width:23px!important;height:23px!important;min-width:23px!important;flex:0 0 23px!important}
  body .admin-exec .ops-card__title-icon svg{width:12px!important;height:12px!important}
  body .admin-exec .ops-card__title-group>div{min-width:0!important}
  body .admin-exec .ops-card__title-group h3{
    margin:0!important;
    font-size:9.8px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-card__title-group small{
    display:block!important;
    margin-top:1px!important;
    font-size:5.3px!important;
    line-height:1!important;
    white-space:nowrap!important;
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
    height:19px!important;
    min-height:19px!important;
    padding:0 6px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:5.4px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .ops-summary-row{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    height:42px!important;
    min-height:42px!important;
    max-height:42px!important;
    margin:0!important;
    grid-template-columns:repeat(2,minmax(0,1fr))!important;
    gap:4px!important;
    overflow:hidden!important;
  }
  body .admin-exec .ops-summary-tile{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    min-width:0!important;
    height:42px!important;
    min-height:42px!important;
    max-height:42px!important;
    padding:4px 6px!important;
    justify-content:center!important;
    overflow:hidden!important;
  }
  body .admin-exec .ops-summary-tile span{font-size:5.4px!important;line-height:1!important;white-space:nowrap!important}
  body .admin-exec .ops-summary-tile strong{font-size:10.5px!important;line-height:1!important;margin:1px 0!important}
  body .admin-exec .ops-summary-tile small{font-size:5px!important;line-height:1!important;white-space:nowrap!important;overflow:visible!important}

  body .admin-exec .ops-tiles{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    height:94px!important;
    min-height:94px!important;
    max-height:94px!important;
    margin:0!important;
    grid-template-rows:repeat(3,29px)!important;
    gap:3px!important;
    overflow:hidden!important;
  }
  body .admin-exec .ops-tile{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    min-width:0!important;
    height:29px!important;
    min-height:29px!important;
    max-height:29px!important;
    margin:0!important;
    padding:3px 5px!important;
    grid-template-columns:21px minmax(0,1fr) 19px 34px!important;
    align-items:center!important;
    gap:4px!important;
    overflow:hidden!important;
  }
  body .admin-exec .ops-tile__ico{width:21px!important;height:21px!important;min-width:21px!important}
  body .admin-exec .ops-tile__ico svg{width:11px!important;height:11px!important}
  body .admin-exec .ops-tile__info{min-width:0!important;overflow:visible!important}
  body .admin-exec .ops-tile__info strong,
  body .admin-exec .ops-tile__info small{
    display:block!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-tile__info strong{font-size:6.5px!important;line-height:1!important}
  body .admin-exec .ops-tile__info small{font-size:5.1px!important;line-height:1!important;margin-top:1px!important}
  body .admin-exec .ops-tile__count{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:19px!important;
    min-width:19px!important;
    height:17px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:6.2px!important;
    line-height:1!important;
  }
  body .admin-exec .ops-tile__state{
    display:inline-flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:34px!important;
    min-width:34px!important;
    height:17px!important;
    padding:0 3px!important;
    align-items:center!important;
    justify-content:center!important;
    font-size:5px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:hidden!important;
  }

  body .admin-exec .ops-card>.ops-tile{
    display:grid!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    height:28px!important;
    min-height:28px!important;
    max-height:28px!important;
    margin:0!important;
    grid-template-columns:21px minmax(0,1fr) 19px 34px!important;
  }
  body .admin-exec .ops-good-strip{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    width:100%!important;
    height:22px!important;
    min-height:22px!important;
    max-height:22px!important;
    margin:0!important;
    padding:0 6px!important;
    align-items:center!important;
    justify-content:center!important;
    gap:3px!important;
    font-size:5.6px!important;
    line-height:1!important;
    white-space:nowrap!important;
    overflow:hidden!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-good-strip svg{width:10px!important;height:10px!important;flex:0 0 10px!important}
}

@media (max-width:1100px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    height:auto!important;
    min-height:258px!important;
    max-height:none!important;
  }
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v32-2-build.log 2>&1 || {
  tail -n 180 /tmp/67-v32-2-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V32.2'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=OPERATIONS GEOMETRY RESET'
echo 'BASE_VERSION=V32.1'
echo 'TARGET_VERSION=V32.2'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v32.2.css'
echo 'JSX_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
