#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=18e98d63a2b1776b9ff1e311227f3a74a826dabe
TARGET_JSX=src/pages/AdminDashboard.jsx
TARGET_CSS=src/pages/AdminDashboard.v14.css
OLD_HERO=src/assets/admin-v15-hero.jpg
OLD_HEALTH=src/assets/admin-v15-health.jpg
NEW_HERO=src/assets/admin-v17-hero.jpg
NEW_HEALTH=src/assets/admin-v17-health.jpg
BACKUP_DIR="/tmp/67-admin-v17.2-backup-$$"
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
    npm run build >/tmp/67-admin-v17.2-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V17_2_EXACT_ASSETS_FAILED_EXIT_${code}"
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
curl -fsSL "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/91f80aeafc370175134bdc4316fee690b0d95e14/assets/v17-clean/admin-v17-hero.jpg" -o /tmp/67-v17.2-hero.jpg
curl -fsSL "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/0150cb188060afbb15e13e1317557874578d2a26/assets/v17-exact/admin-v17-health.jpg.b64" -o /tmp/67-v17.2-health.b64

FAILED_STEP=decode_and_verify_exact_assets
python3 - <<'PY'
from pathlib import Path
import base64,hashlib
hero=Path('/tmp/67-v17.2-hero.jpg').read_bytes()
if len(hero)!=11751: raise SystemExit(f'HERO_JPEG_SIZE_MISMATCH:{len(hero)}:11751')
if hashlib.sha256(hero).hexdigest()!='9f0d19b07bb0af0494b5768c7d43a21cb4565f3c05b096c3b665fcecc5d4da65': raise SystemExit('HERO_SHA256_MISMATCH')
raw=''.join(Path('/tmp/67-v17.2-health.b64').read_text().split())
if len(raw)!=5540: raise SystemExit(f'HEALTH_BASE64_LENGTH_MISMATCH:{len(raw)}:5540')
health=base64.b64decode(raw,validate=True)
if len(health)!=4154: raise SystemExit(f'HEALTH_JPEG_SIZE_MISMATCH:{len(health)}:4154')
if hashlib.sha256(health).hexdigest()!='f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db': raise SystemExit('HEALTH_SHA256_MISMATCH')
if not (hero.startswith(b'\xff\xd8\xff') and hero.endswith(b'\xff\xd9')): raise SystemExit('HERO_JPEG_MAGIC_INVALID')
if not (health.startswith(b'\xff\xd8\xff') and health.endswith(b'\xff\xd9')): raise SystemExit('HEALTH_JPEG_MAGIC_INVALID')
Path('/tmp/67-v17.2-health.jpg').write_bytes(health)
print('HERO_JPEG_BYTES=11751')
print('HERO_SHA256=9f0d19b07bb0af0494b5768c7d43a21cb4565f3c05b096c3b665fcecc5d4da65')
print('HEALTH_JPEG_BYTES=4154')
print('HEALTH_SHA256=f2c167f8c9f9b54508dc00aad9f956321627361d70ed53a2a37866ad5b35c9db')
PY
file /tmp/67-v17.2-hero.jpg | grep -qi 'JPEG image data'
file /tmp/67-v17.2-health.jpg | grep -qi 'JPEG image data'

FAILED_STEP=cutover_assets
MUTATED=1
cp /tmp/67-v17.2-hero.jpg "$NEW_HERO"
cp /tmp/67-v17.2-health.jpg "$NEW_HEALTH"
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.v14.css')
s=p.read_text()
if 'SIX SEVEN ADMIN V17.2 — EXACT ASSET CUTOVER' in s: raise SystemExit('V17_2_ALREADY_PRESENT')
if 'admin-v15-hero.jpg' not in s or 'admin-v15-health.jpg' not in s: raise SystemExit('V15_ASSET_REFERENCES_NOT_FOUND')
s=s.replace('admin-v15-hero.jpg','admin-v17-hero.jpg').replace('admin-v15-health.jpg','admin-v17-health.jpg')
s += r'''

/* SIX SEVEN ADMIN V17.2 — EXACT ASSET CUTOVER */
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
grep -q "SIX SEVEN ADMIN V17.2 — EXACT ASSET CUTOVER" "$TARGET_CSS"
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
echo "HERO_BINARY_EXACT=YES"
echo "HEALTH_PAYLOAD_EXACT=YES"
echo "CLEAN_JPEG_SHA256_VERIFIED=YES"
echo "HERO_BYTES=11751"
echo "HEALTH_BYTES=4154"
echo "REFERENCE_V5_LAYOUT_PRESERVED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
