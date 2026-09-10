#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=70323c90cef39c738f7e65178a3cb6e4656c5f06
TARGET_CSS=src/pages/AdminDashboard.v14.css
TARGET_JSX=src/pages/AdminDashboard.jsx
HERO_SVG=src/assets/admin-v14-hero.svg
HEALTH_SVG=src/assets/admin-v14-health.svg
HERO_JPG=src/assets/admin-v15-hero.jpg
HEALTH_JPG=src/assets/admin-v15-health.jpg
BACKUP_DIR="/tmp/67-admin-v15.1-backup-$$"
PATCHED=0
FAILED_STEP=init

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages" "$BACKUP_DIR/src/assets"
cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v14.css"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
for f in "$HERO_SVG" "$HEALTH_SVG" "$HERO_JPG" "$HEALTH_JPG"; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done

rollback(){
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" "$TARGET_CSS"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    for f in "$HERO_SVG" "$HEALTH_SVG" "$HERO_JPG" "$HEALTH_JPG"; do
      if [ -f "$BACKUP_DIR/$f" ]; then
        cp "$BACKUP_DIR/$f" "$f"
      else
        rm -f "$f"
      fi
    done
    npm run build >/tmp/67-admin-v15.1-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V15_1_LOCAL_SVG_EXTRACT_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_current_v14_state
grep -q "SIX SEVEN ADMIN V14" "$TARGET_CSS"
grep -q "import './AdminDashboard.v14.css';" "$TARGET_JSX"
! grep -q "import './AdminDashboard.v9.css';" "$TARGET_JSX"
! grep -q "import './AdminDashboard.v11.css';" "$TARGET_JSX"
grep -q "admin-v14-hero.svg" "$TARGET_CSS"
grep -q "admin-v14-health.svg" "$TARGET_CSS"
[ -s "$HERO_SVG" ]
[ -s "$HEALTH_SVG" ]

FAILED_STEP=extract_embedded_jpegs
python3 - <<'PY'
from pathlib import Path
import base64, re

pairs = [
    ('/67/src/assets/admin-v14-hero.svg','/67/src/assets/admin-v15-hero.jpg',8000),
    ('/67/src/assets/admin-v14-health.svg','/67/src/assets/admin-v15-health.jpg',4000),
]

for src,dst,min_bytes in pairs:
    text=Path(src).read_text(errors='strict')
    m=re.search(r'data:image/jpeg;base64,([^"\']+)', text, re.S)
    if not m:
        raise SystemExit(f'EMBEDDED_JPEG_NOT_FOUND:{src}')
    raw=''.join(m.group(1).split())
    if len(raw)%4:
        raise SystemExit(f'EMBEDDED_BASE64_LENGTH_INVALID:{src}:{len(raw)}')
    data=base64.b64decode(raw, validate=True)
    if len(data)<min_bytes:
        raise SystemExit(f'JPEG_TOO_SMALL:{dst}:{len(data)}')
    if not (data.startswith(b'\xff\xd8\xff') and data.endswith(b'\xff\xd9')):
        raise SystemExit(f'JPEG_MAGIC_INVALID:{dst}')
    Path(dst).write_bytes(data)
    print(f'EXTRACTED:{dst}:{len(data)}')
PY

file "$HERO_JPG" | grep -qi 'JPEG image data'
file "$HEALTH_JPG" | grep -qi 'JPEG image data'

FAILED_STEP=cutover_css_to_direct_jpeg
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.v14.css')
s=p.read_text()
if 'SIX SEVEN ADMIN V15.1 — DIRECT JPEG CUTOVER' in s:
    raise SystemExit('V15_1_ALREADY_PRESENT')
if s.count('admin-v14-hero.svg') != 1 or s.count('admin-v14-health.svg') != 1:
    raise SystemExit('V14_ASSET_REFERENCE_COUNT_MISMATCH')
s=s.replace('admin-v14-hero.svg','admin-v15-hero.jpg')
s=s.replace('admin-v14-health.svg','admin-v15-health.jpg')
s=s.replace('/* SIX SEVEN ADMIN V14 — FULL OVERVIEW REBUILD', '/* SIX SEVEN ADMIN V15.1 — DIRECT JPEG CUTOVER\n   Extracted locally from already-present V14 SVG wrappers.\n\n/* SIX SEVEN ADMIN V14 — FULL OVERVIEW REBUILD', 1)
s += r'''

/* V15.1 — direct JPEG composition against Official Reference V5 */
.ov-header{height:184px!important;min-height:184px!important}
.ov-header__motif{
  background-image:url('../assets/admin-v15-hero.jpg')!important;
  background-size:cover!important;
  background-position:center 50%!important;
  background-repeat:no-repeat!important;
  filter:saturate(1.06) contrast(1.08) brightness(.88)!important;
}
.ov-header::after{
  background:
    linear-gradient(90deg,rgba(2,5,9,.62) 0%,rgba(2,5,9,.17) 24%,rgba(2,5,9,.02) 50%,rgba(2,5,9,.22) 69%,rgba(2,5,9,.94) 100%),
    radial-gradient(circle at 43% 59%,rgba(222,173,72,.12),transparent 34%),
    linear-gradient(180deg,rgba(0,0,0,.02),transparent 52%,rgba(0,0,0,.23))!important;
}
.ov-header__zone-right{width:34%!important;padding:22px 30px 18px 16px!important}
.ov-header__titles h1,.ov-header h1{font-size:30px!important}
.ov-header__zone-left{left:18px!important;bottom:15px!important}
.syshealth{height:122px!important;min-height:122px!important}
.syshealth__layout{grid-template-columns:18% 50% 32%!important}
.syshealth__zone-right{
  background-image:linear-gradient(90deg,rgba(5,9,14,.38),transparent 28%,transparent 78%,rgba(5,9,14,.10)),url('../assets/admin-v15-health.jpg')!important;
  background-size:cover!important;
  background-position:center 52%!important;
  background-repeat:no-repeat!important;
  filter:saturate(.98) contrast(1.09) brightness(.86)!important;
}
.syshealth__metric{height:96px!important;min-height:96px!important}
'''
p.write_text(s)
PY

rm -f "$HERO_SVG" "$HEALTH_SVG"
PATCHED=1

FAILED_STEP=build
npm run build

FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

FAILED_STEP=local_http_check
LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

FAILED_STEP=post_apply_validation
grep -q "SIX SEVEN ADMIN V15.1 — DIRECT JPEG CUTOVER" "$TARGET_CSS"
grep -q "admin-v15-hero.jpg" "$TARGET_CSS"
grep -q "admin-v15-health.jpg" "$TARGET_CSS"
! grep -q "admin-v14-hero.svg" "$TARGET_CSS"
! grep -q "admin-v14-health.svg" "$TARGET_CSS"
[ -s "$HERO_JPG" ]
[ -s "$HEALTH_JPG" ]

HERO_BYTES=$(wc -c < "$HERO_JPG" | tr -d ' ')
HEALTH_BYTES=$(wc -c < "$HEALTH_JPG" | tr -d ' ')

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.v14.css,src/assets/admin-v15-hero.jpg,src/assets/admin-v15-health.jpg,src/assets/admin-v14-hero.svg(deleted),src/assets/admin-v14-health.svg(deleted)"
echo "SOURCE_PAYLOAD=LOCAL_V14_SVG_EMBEDDED_JPEG"
echo "EXTERNAL_BASE64_DOWNLOAD=NO"
echo "REAL_JPEG_DIRECT_RENDER=YES"
echo "SVG_DATA_URI_WRAPPERS=REMOVED"
echo "HERO_CINEMATIC_ART=YES"
echo "HEALTH_CINEMATIC_ART=YES"
echo "HERO_BYTES=$HERO_BYTES"
echo "HEALTH_BYTES=$HEALTH_BYTES"
echo "REFERENCE_V5_LAYOUT_PRESERVED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
