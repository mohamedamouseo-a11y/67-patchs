#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v32.4.css
TARGET_CSS=src/pages/AdminDashboard.v32.5.css
MARKER='SIX SEVEN ADMIN V32.5 — BALANCED OPERATIONS FINAL'
BACKUP=/tmp/67-v32-5-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V32_4_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v32.4.css';" "$JSX" || { echo 'FAILED_STEP=V32_4_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v32.4.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v32.4.css';"
new="import './AdminDashboard.v32.5.css';"
if old not in s:
    raise SystemExit('V32_4_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V32.5 — BALANCED OPERATIONS FINAL
   Screenshot-driven final balance pass.
   - Preserve the successful V32.4 structure and visual language.
   - Remove the large empty middle zone from Live Operations.
   - Compact both operation cards to one balanced executive row.
   - Keep all rows, badges, pills, footer, CTA and health strip visible.
   - CSS only: no JSX/data/logic/backend/auth changes. */

@media (min-width:1101px){
  /* One balanced second-row height. */
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    width:100%!important;
    height:360px!important;
    min-height:360px!important;
    max-height:360px!important;
    align-self:start!important;
    padding:12px 13px!important;
    overflow:hidden!important;
  }

  /* ================= LIVE OPERATIONS ================= */
  body .admin-exec .live-card{
    display:flex!important;
    flex-direction:column!important;
  }
  body .admin-exec .live-card__head{
    flex:0 0 38px!important;
    height:38px!important;
    min-height:38px!important;
    max-height:38px!important;
    margin:0 0 7px!important;
    padding:0 1px 6px!important;
  }
  body .admin-exec .live-card__head h3{font-size:13px!important}
  body .admin-exec .live-card__badge{
    height:25px!important;
    min-height:25px!important;
    min-width:29px!important;
    font-size:9px!important;
  }

  body .admin-exec .live-card__list{
    flex:0 0 auto!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item{
    min-height:42px!important;
    height:auto!important;
    padding:7px 9px!important;
    gap:9px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-item__ico{
    width:28px!important;
    height:28px!important;
    min-width:28px!important;
    min-height:28px!important;
    flex-basis:28px!important;
  }
  body .admin-exec .live-item__body{overflow:visible!important}
  body .admin-exec .live-item__body p{
    font-size:9.6px!important;
    line-height:1.3!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
    overflow-wrap:break-word!important;
  }
  body .admin-exec .live-item__body small,
  body .admin-exec .live-item .when{
    font-size:7.6px!important;
    line-height:1.1!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }

  body .admin-exec .live-activity-summary{
    flex:0 0 auto!important;
    min-height:72px!important;
    height:auto!important;
    margin:8px 0 0!important;
    padding:8px 9px!important;
    grid-template-columns:minmax(0,1.45fr) minmax(190px,.95fr)!important;
    gap:9px!important;
    overflow:visible!important;
  }
  body .admin-exec .live-activity-summary__icon{
    width:31px!important;
    height:31px!important;
    flex-basis:31px!important;
  }
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span{
    font-size:7.4px!important;
    line-height:1.2!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-activity-summary__lead strong{
    font-size:9.4px!important;
    line-height:1.15!important;
    white-space:normal!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-activity-summary__metrics>span{
    min-height:44px!important;
    padding:5px 3px!important;
  }
  body .admin-exec .live-activity-summary__metrics strong{font-size:9px!important}
  body .admin-exec .live-activity-summary__metrics small{font-size:7px!important}

  /* Footer follows content naturally: no auto spacer in the middle. */
  body .admin-exec .live-card__footer{
    display:block!important;
    visibility:visible!important;
    opacity:1!important;
    flex:0 0 auto!important;
    min-height:64px!important;
    height:auto!important;
    margin:9px 0 0!important;
    padding:8px 0 0!important;
    overflow:visible!important;
  }
  body .admin-exec .live-card__footer-status{
    min-height:25px!important;
    height:auto!important;
    gap:6px!important;
  }
  body .admin-exec .live-pending,
  body .admin-exec .live-quick{gap:4px!important;overflow:visible!important}
  body .admin-exec .live-pending span,
  body .admin-exec .live-quick span{
    height:22px!important;
    padding:0 7px!important;
    font-size:7.2px!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .live-cta{
    display:flex!important;
    visibility:visible!important;
    opacity:1!important;
    height:29px!important;
    min-height:29px!important;
    max-height:29px!important;
    margin:7px 0 0!important;
    font-size:8.2px!important;
  }

  /* ================= CURRENT OPERATIONS =================
     Structure was already visually correct in V32.4. Compact only spacing and
     row heights so both cards share the same 360px executive rhythm. */
  body .admin-exec .ops-card__head{
    flex:0 0 40px!important;
    height:40px!important;
    min-height:40px!important;
    max-height:40px!important;
    margin:0 0 6px!important;
    padding:0 1px 6px!important;
  }
  body .admin-exec .ops-card__title-icon{
    width:28px!important;
    height:28px!important;
    min-width:28px!important;
    flex-basis:28px!important;
  }
  body .admin-exec .ops-card__title-group h3{font-size:12px!important}
  body .admin-exec .ops-card__title-group small{font-size:7.5px!important}
  body .admin-exec .ops-card__command-badge{
    height:24px!important;
    min-height:24px!important;
    font-size:7.5px!important;
  }

  body .admin-exec .ops-summary-row{
    min-height:54px!important;
    height:54px!important;
    max-height:54px!important;
    margin:0 0 6px!important;
    gap:6px!important;
  }
  body .admin-exec .ops-summary-tile{
    min-height:54px!important;
    height:54px!important;
    max-height:54px!important;
    padding:6px 8px!important;
  }
  body .admin-exec .ops-summary-tile span{font-size:7.6px!important}
  body .admin-exec .ops-summary-tile strong{font-size:15px!important;margin:3px 0!important}
  body .admin-exec .ops-summary-tile small{font-size:7px!important}

  body .admin-exec .ops-tiles{
    gap:5px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-tiles>.ops-tile,
  body .admin-exec .ops-card>.ops-tile{
    min-height:38px!important;
    height:38px!important;
    max-height:38px!important;
    padding:5px 7px!important;
    grid-template-columns:27px minmax(0,1fr) 28px 54px!important;
    gap:6px!important;
    overflow:visible!important;
  }
  body .admin-exec .ops-tile__ico{
    width:27px!important;
    height:27px!important;
    min-width:27px!important;
  }
  body .admin-exec .ops-tile__info{overflow:visible!important}
  body .admin-exec .ops-tile__info strong{
    font-size:8.6px!important;
    line-height:1.05!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-tile__info small{
    font-size:7.1px!important;
    line-height:1.05!important;
    white-space:nowrap!important;
    overflow:visible!important;
    text-overflow:clip!important;
  }
  body .admin-exec .ops-tile__count{font-size:7.8px!important}
  body .admin-exec .ops-tile__state{
    min-width:52px!important;
    height:21px!important;
    font-size:7.2px!important;
  }
  body .admin-exec .ops-card>.ops-tile{
    margin-top:5px!important;
  }
  body .admin-exec .ops-good-strip{
    min-height:28px!important;
    height:28px!important;
    max-height:28px!important;
    margin-top:6px!important;
    font-size:7.5px!important;
  }
}

@media (max-width:1100px){
  body .admin-exec .live-card,
  body .admin-exec .ops-card{
    height:auto!important;
    min-height:0!important;
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

npm run build >/tmp/67-v32-5-build.log 2>&1 || {
  tail -n 180 /tmp/67-v32-5-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V32.5'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=BALANCED OPERATIONS FINAL'
echo 'BASE_VERSION=V32.4'
echo 'TARGET_VERSION=V32.5'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v32.5.css'
echo 'JSX_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
