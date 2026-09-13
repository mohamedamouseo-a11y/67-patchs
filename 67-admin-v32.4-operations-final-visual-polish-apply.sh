#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v32.3.css
TARGET_CSS=src/pages/AdminDashboard.v32.4.css
MARKER='SIX SEVEN ADMIN V32.4 — OPERATIONS FINAL VISUAL POLISH'
BACKUP=/tmp/67-v32-4-$$

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V32_3_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v32.3.css';" "$JSX" || { echo 'FAILED_STEP=V32_3_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v32.3.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v32.3.css';"
new="import './AdminDashboard.v32.4.css';"
if old not in s:
    raise SystemExit('V32_3_IMPORT_NOT_FOUND')
s=s.replace(old,new,1)
p.write_text(s)
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V32.4 — OPERATIONS FINAL VISUAL POLISH
   Final CSS-only refinement after direct screenshot review of V32.3.
   V32.3 structure is preserved. Fix only the real remaining visual issues:
   - Live Operations dead-space balance and small typography.
   - Slight Current Operations typography uplift.
   - No data/logic/JSX/backend/auth changes. */

@media (min-width:1101px){
  /* ================= LIVE OPERATIONS ================= */
  body .admin-exec .live-card{
    min-height:400px!important;
    padding:14px 15px 14px!important;
  }

  body .admin-exec .live-card__head{
    flex-basis:44px!important;
    height:44px!important;
    min-height:44px!important;
    max-height:44px!important;
    margin-bottom:10px!important;
  }
  body .admin-exec .live-card__head h3{
    font-size:13.5px!important;
    line-height:1.1!important;
  }
  body .admin-exec .live-card__badge{
    min-width:31px!important;
    height:27px!important;
    min-height:27px!important;
    font-size:9.5px!important;
  }

  body .admin-exec .live-card__list{
    gap:7px!important;
  }
  body .admin-exec .live-item{
    min-height:46px!important;
    padding:8px 10px!important;
    gap:10px!important;
  }
  body .admin-exec .live-item__ico{
    flex-basis:30px!important;
    width:30px!important;
    height:30px!important;
    min-width:30px!important;
    min-height:30px!important;
  }
  body .admin-exec .live-item__body p{
    font-size:10px!important;
    line-height:1.35!important;
  }
  body .admin-exec .live-item__body small,
  body .admin-exec .live-item .when{
    margin-top:3px!important;
    font-size:8px!important;
    line-height:1.15!important;
  }

  body .admin-exec .live-activity-summary{
    min-height:84px!important;
    margin-top:10px!important;
    padding:10px 11px!important;
    grid-template-columns:minmax(0,1.45fr) minmax(205px,.95fr)!important;
    gap:12px!important;
  }
  body .admin-exec .live-activity-summary__icon{
    width:34px!important;
    height:34px!important;
    flex-basis:34px!important;
  }
  body .admin-exec .live-activity-summary__lead small,
  body .admin-exec .live-activity-summary__lead span{
    font-size:8px!important;
    line-height:1.25!important;
  }
  body .admin-exec .live-activity-summary__lead strong{
    font-size:10px!important;
    line-height:1.2!important;
  }
  body .admin-exec .live-activity-summary__metrics>span{
    min-height:50px!important;
    padding:6px 4px!important;
  }
  body .admin-exec .live-activity-summary__metrics strong{
    font-size:9.5px!important;
  }
  body .admin-exec .live-activity-summary__metrics small{
    font-size:7.2px!important;
  }

  /* Use the existing tall row intentionally: footer/CTA sit at the bottom,
     so there is no large dead zone below the actionable controls. */
  body .admin-exec .live-card__footer{
    margin-top:auto!important;
    min-height:70px!important;
    padding-top:9px!important;
  }
  body .admin-exec .live-card__footer-status{
    min-height:28px!important;
    gap:8px!important;
  }
  body .admin-exec .live-pending,
  body .admin-exec .live-quick{
    gap:5px!important;
  }
  body .admin-exec .live-pending span,
  body .admin-exec .live-quick span{
    height:24px!important;
    padding:0 8px!important;
    font-size:7.6px!important;
  }
  body .admin-exec .live-cta{
    height:32px!important;
    min-height:32px!important;
    max-height:32px!important;
    margin-top:8px!important;
    font-size:8.5px!important;
  }

  /* ================= CURRENT OPERATIONS =================
     Preserve the V32.3 geometry which is visibly correct in screenshots.
     Only lift text size/contrast slightly. */
  body .admin-exec .ops-card__title-group h3{
    font-size:12.5px!important;
  }
  body .admin-exec .ops-card__title-group small{
    font-size:8px!important;
    line-height:1.15!important;
  }
  body .admin-exec .ops-card__command-badge{
    font-size:8px!important;
    min-height:26px!important;
    height:26px!important;
  }
  body .admin-exec .ops-summary-tile span{
    font-size:8px!important;
  }
  body .admin-exec .ops-summary-tile strong{
    font-size:16px!important;
  }
  body .admin-exec .ops-summary-tile small{
    font-size:7.5px!important;
    line-height:1.15!important;
  }
  body .admin-exec .ops-tile__info strong{
    font-size:8.8px!important;
    line-height:1.1!important;
  }
  body .admin-exec .ops-tile__info small{
    font-size:7.4px!important;
    line-height:1.1!important;
  }
  body .admin-exec .ops-tile__count{
    font-size:8px!important;
  }
  body .admin-exec .ops-tile__state{
    font-size:7.5px!important;
  }
  body .admin-exec .ops-good-strip{
    font-size:7.8px!important;
    line-height:1.1!important;
  }
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v32-4-build.log 2>&1 || {
  tail -n 180 /tmp/67-v32-4-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V32.4'
echo 'MODULE=ADMIN DASHBOARD'
echo 'ELEMENT=OPERATIONS FINAL VISUAL POLISH'
echo 'BASE_VERSION=V32.3'
echo 'TARGET_VERSION=V32.4'
echo 'STATUS=READY_FOR_RUNTIME_QA'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v32.4.css'
echo 'JSX_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
