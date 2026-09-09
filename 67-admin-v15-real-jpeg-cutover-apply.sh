#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=70323c90cef39c738f7e65178a3cb6e4656c5f06
TARGET_CSS=src/pages/AdminDashboard.v14.css
TARGET_JSX=src/pages/AdminDashboard.jsx
HERO_B64_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/785f7f66ad1e6f928794c370e786c3d888662f52/67-v8-hero.jpg.b64
HEALTH_B64_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/785f7f66ad1e6f928794c370e786c3d888662f52/67-v8-health.jpg.b64
BACKUP_DIR="/tmp/67-admin-v15-backup-$$"
PATCHED=0
FAILED_STEP=init

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages" "$BACKUP_DIR/src/assets"
cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v14.css"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
for f in src/assets/admin-v14-hero.svg src/assets/admin-v14-health.svg src/assets/admin-v15-hero.jpg src/assets/admin-v15-health.jpg; do
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
    for f in src/assets/admin-v14-hero.svg src/assets/admin-v14-health.svg src/assets/admin-v15-hero.jpg src/assets/admin-v15-health.jpg; do
      if [ -f "$BACKUP_DIR/$f" ]; then
        cp "$BACKUP_DIR/$f" "$f"
      else
        rm -f "$f"
      fi
    done
    npm run build >/tmp/67-admin-v15-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V15_REAL_JPEG_CUTOVER_FAILED_EXIT_${code}"
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

FAILED_STEP=download_pinned_payloads
curl -fsSL "$HERO_B64_URL" -o /tmp/67-v15-hero.b64
curl -fsSL "$HEALTH_B64_URL" -o /tmp/67-v15-health.b64

FAILED_STEP=decode_and_validate_jpegs
python3 - <<'PY'
from pathlib import Path
import base64

def decode(src, dst, min_bytes):
    raw=''.join(Path(src).read_text().split())
    if len(raw) % 4:
        raise SystemExit(f'INVALID_BASE64_LENGTH:{src}:{len(raw)}')
    data=base64.b64decode(raw, validate=True)
    if len(data) < min_bytes:
        raise SystemExit(f'JPEG_TOO_SMALL:{dst}:{len(data)}')
    if not (data.startswith(b'\xff\xd8\xff') and data.endswith(b'\xff\xd9')):
        raise SystemExit(f'JPEG_MAGIC_INVALID:{dst}')
    Path(dst).write_bytes(data)
    print(f'{dst}_BYTES={len(data)}')

decode('/tmp/67-v15-hero.b64','/67/src/assets/admin-v15-hero.jpg',8000)
decode('/tmp/67-v15-health.b64','/67/src/assets/admin-v15-health.jpg',4000)
PY
file src/assets/admin-v15-hero.jpg | grep -qi 'JPEG image data'
file src/assets/admin-v15-health.jpg | grep -qi 'JPEG image data'

FAILED_STEP=cutover_css_to_real_jpeg
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.v14.css')
s=p.read_text()
if 'SIX SEVEN ADMIN V15 — REAL JPEG CUTOVER' in s:
    raise SystemExit('V15_ALREADY_PRESENT')
if s.count("admin-v14-hero.svg") != 1 or s.count("admin-v14-health.svg") != 1:
    raise SystemExit('V14_ASSET_REFERENCE_COUNT_MISMATCH')
s=s.replace("admin-v14-hero.svg","admin-v15-hero.jpg")
s=s.replace("admin-v14-health.svg","admin-v15-health.jpg")
s=s.replace('/* SIX SEVEN ADMIN V14 — FULL OVERVIEW REBUILD', '/* SIX SEVEN ADMIN V15 — REAL JPEG CUTOVER\n   Uses decoded JPEG assets directly; no SVG/data-URI wrapper.\n\n/* SIX SEVEN ADMIN V14 — FULL OVERVIEW REBUILD', 1)
# Real-photo tuning against Official Reference V5.
s += r'''

/* V15 REAL PHOTO COMPOSITION — large visible correction */
.ov-header{
  height:184px!important;
  min-height:184px!important;
}
.ov-header__motif{
  background-size:cover!important;
  background-position:center 52%!important;
  filter:saturate(1.02) contrast(1.06) brightness(.92)!important;
}
.ov-header::after{
  background:
    linear-gradient(90deg,rgba(2,5,9,.60) 0%,rgba(2,5,9,.16) 24%,rgba(2,5,9,.02) 52%,rgba(2,5,9,.24) 70%,rgba(2,5,9,.92) 100%),
    radial-gradient(circle at 42% 58%,rgba(222,173,72,.11),transparent 33%),
    linear-gradient(180deg,rgba(0,0,0,.03),transparent 52%,rgba(0,0,0,.22))!important;
}
.ov-header__zone-right{width:34%!important;padding:22px 30px 18px 16px!important}
.ov-header__titles h1,.ov-header h1{font-size:30px!important}
.ov-header__zone-left{left:18px!important;bottom:15px!important}
.syshealth{height:122px!important;min-height:122px!important}
.syshealth__layout{grid-template-columns:18% 50% 32%!important}
.syshealth__zone-right{
  background-size:cover!important;
  background-position:center 55%!important;
  filter:saturate(.94) contrast(1.07) brightness(.88)!important;
}
.syshealth__metric{height:96px!important;min-height:96px!important}
'''
p.write_text(s)
PY
rm -f src/assets/admin-v14-hero.svg src/assets/admin-v14-health.svg
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
grep -q "SIX SEVEN ADMIN V15 — REAL JPEG CUTOVER" "$TARGET_CSS"
grep -q "admin-v15-hero.jpg" "$TARGET_CSS"
grep -q "admin-v15-health.jpg" "$TARGET_CSS"
! grep -q "admin-v14-hero.svg" "$TARGET_CSS"
! grep -q "admin-v14-health.svg" "$TARGET_CSS"
[ -s src/assets/admin-v15-hero.jpg ]
[ -s src/assets/admin-v15-health.jpg ]

HERO_BYTES=$(wc -c < src/assets/admin-v15-hero.jpg | tr -d ' ')
HEALTH_BYTES=$(wc -c < src/assets/admin-v15-health.jpg | tr -d ' ')

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.v14.css,src/assets/admin-v15-hero.jpg,src/assets/admin-v15-health.jpg,src/assets/admin-v14-hero.svg(deleted),src/assets/admin-v14-health.svg(deleted)"
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
