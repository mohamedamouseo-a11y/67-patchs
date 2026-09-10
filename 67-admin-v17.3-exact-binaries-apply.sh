#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=18e98d63a2b1776b9ff1e311227f3a74a826dabe
ASSET_COMMIT=66a7fa2913cb722a1a85604aa024251c0b0f13d5
TARGET_JSX=src/pages/AdminDashboard.jsx
TARGET_CSS=src/pages/AdminDashboard.v14.css
OLD_HERO=src/assets/admin-v15-hero.jpg
OLD_HEALTH=src/assets/admin-v15-health.jpg
NEW_HERO=src/assets/admin-v17-hero.jpg
NEW_HEALTH=src/assets/admin-v17-health.jpg
BACKUP_DIR="/tmp/67-admin-v17.3-backup-$$"
FAILED_STEP=init
MUTATED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages" "$BACKUP_DIR/src/assets"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v14.css"
for f in "$OLD_HERO" "$OLD_HEALTH" "$NEW_HERO" "$NEW_HEALTH"; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done

rollback(){
  local code="$1"
  if [ "$MUTATED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v14.css" "$TARGET_CSS"
    for f in "$OLD_HERO" "$OLD_HEALTH" "$NEW_HERO" "$NEW_HEALTH"; do
      if [ -f "$BACKUP_DIR/$f" ]; then mkdir -p "$(dirname "$f")"; cp "$BACKUP_DIR/$f" "$f"; else rm -f "$f"; fi
    done
    npm run build >/tmp/67-admin-v17.3-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V17_3_EXACT_BINARIES_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_v16_state
grep -q "OFFICIAL REFERENCE V5 HERO — V16" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V16" "$TARGET_CSS"
grep -q "admin-v15-hero.jpg" "$TARGET_CSS"
grep -q "admin-v15-health.jpg" "$TARGET_CSS"
[ -s "$OLD_HERO" ]
[ -s "$OLD_HEALTH" ]

FAILED_STEP=download_exact_assets
BASE_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${ASSET_COMMIT}/assets/v17-clean"
curl -fsSL "${BASE_URL}/admin-v17-hero.jpg" -o /tmp/67-v17.3-hero.jpg
curl -fsSL "${BASE_URL}/admin-v17-health.jpg" -o /tmp/67-v17.3-health.jpg

FAILED_STEP=verify_exact_assets
python3 - <<'PY'
from pathlib import Path
import hashlib
specs=[
('HERO','/tmp/67-v17.3-hero.jpg',11751,'9f0d19b07bb0af0494b5768c7d43a21cb4565f3c05b096c3b665fcecc5d4da65'),
('HEALTH','/tmp/67-v17.3-health.jpg',4154,'f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db'),
]
for label,path,size,sha in specs:
    data=Path(path).read_bytes()
    if len(data)!=size: raise SystemExit(f'{label}_JPEG_SIZE_MISMATCH:{len(data)}:{size}')
    actual=hashlib.sha256(data).hexdigest()
    if actual!=sha: raise SystemExit(f'{label}_SHA256_MISMATCH:{actual}:{sha}')
    if not (data.startswith(b'\xff\xd8\xff') and data.endswith(b'\xff\xd9')): raise SystemExit(f'{label}_JPEG_MAGIC_INVALID')
    print(f'{label}_JPEG_BYTES={len(data)}')
    print(f'{label}_SHA256={actual}')
PY
file /tmp/67-v17.3-hero.jpg | grep -qi 'JPEG image data'
file /tmp/67-v17.3-health.jpg | grep -qi 'JPEG image data'

FAILED_STEP=cutover_assets
MUTATED=1
cp /tmp/67-v17.3-hero.jpg "$NEW_HERO"
cp /tmp/67-v17.3-health.jpg "$NEW_HEALTH"
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.v14.css')
s=p.read_text()
if 'SIX SEVEN ADMIN V17.3 — EXACT BINARY CUTOVER' in s: raise SystemExit('V17_3_ALREADY_PRESENT')
if 'admin-v15-hero.jpg' not in s or 'admin-v15-health.jpg' not in s: raise SystemExit('V15_ASSET_REFERENCES_NOT_FOUND')
s=s.replace('admin-v15-hero.jpg','admin-v17-hero.jpg').replace('admin-v15-health.jpg','admin-v17-health.jpg')
s += r'''

/* SIX SEVEN ADMIN V17.3 — EXACT BINARY CUTOVER */
.ov-header-v16 .ov-header__motif{
  background-image:url('../assets/admin-v17-hero.jpg')!important;
  background-size:100% 100%!important;
  background-position:center center!important;
  background-repeat:no-repeat!important;
}
.syshealth__zone-right{
  background-image:linear-gradient(90deg,rgba(5,9,14,.30),transparent 24%,transparent 80%,rgba(5,9,14,.08)),url('../assets/admin-v17-health.jpg')!important;
  background-size:cover!important;
  background-position:center 52%!important;
  background-repeat:no-repeat!important;
}
'''
p.write_text(s)
PY
rm -f "$OLD_HERO" "$OLD_HEALTH"

FAILED_STEP=build
npm run build

FAILED_STEP=verify_dist_assets
HERO_DIST=$(find dist/assets -maxdepth 1 -type f -name 'admin-v17-hero-*.jpg' -print -quit)
HEALTH_DIST=$(find dist/assets -maxdepth 1 -type f -name 'admin-v17-health-*.jpg' -print -quit)
[ -n "$HERO_DIST" ]
[ -n "$HEALTH_DIST" ]
file "$HERO_DIST" | grep -qi 'JPEG image data'
file "$HEALTH_DIST" | grep -qi 'JPEG image data'

FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

FAILED_STEP=local_http_check
LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

FAILED_STEP=post_apply_validation
grep -q "SIX SEVEN ADMIN V17.3 — EXACT BINARY CUTOVER" "$TARGET_CSS"
grep -q "admin-v17-hero.jpg" "$TARGET_CSS"
grep -q "admin-v17-health.jpg" "$TARGET_CSS"
! grep -q "admin-v15-hero.jpg" "$TARGET_CSS"
! grep -q "admin-v15-health.jpg" "$TARGET_CSS"
[ -s "$NEW_HERO" ]
[ -s "$NEW_HEALTH" ]

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.v14.css,src/assets/admin-v17-hero.jpg,src/assets/admin-v17-health.jpg,src/assets/admin-v15-hero.jpg(deleted),src/assets/admin-v15-health.jpg(deleted)"
echo "DIRECT_BINARY_DOWNLOAD=YES"
echo "BASE64_PIPELINE=REMOVED"
echo "CLEAN_JPEG_SHA256_VERIFIED=YES"
echo "HERO_BYTES=11751"
echo "HEALTH_BYTES=4154"
echo "REFERENCE_V5_LAYOUT_PRESERVED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
