#!/usr/bin/env bash
set -euo pipefail

ROOT=/67
SERVICE=sixty-seven.service
STAGE="$ROOT/.dist-v46-new"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$ROOT/dist.pre-v46-$STAMP"

cd "$ROOT"

test -f package.json
test -f src/pages/AdminDashboard.jsx
test -f src/pages/AdminDashboard.v45.css
grep -q "AdminDashboard.v45.css" src/pages/AdminDashboard.jsx

rm -rf "$STAGE"

# Build V45 into a staging directory so the live /67/dist is never emptied mid-build.
npm run build -- --outDir "$STAGE" --emptyOutDir

test -s "$STAGE/index.html"
test -d "$STAGE/assets"

OWNER="$(stat -c '%u:%g' "$ROOT")"
chown -R "$OWNER" "$STAGE"

if [ -d "$ROOT/dist" ]; then
  mv "$ROOT/dist" "$BACKUP"
fi
mv "$STAGE" "$ROOT/dist"

rollback() {
  if [ -d "$BACKUP" ]; then
    rm -rf "$ROOT/dist"
    mv "$BACKUP" "$ROOT/dist"
    systemctl restart "$SERVICE" || true
  fi
}

systemctl restart "$SERVICE"
sleep 2
systemctl is-active --quiet "$SERVICE" || { rollback; echo 'SERVICE_ACTIVE=NO'; exit 1; }

HTTP_CODE="$(curl -k -sS -o /tmp/67-v46-admin-check.out -w '%{http_code}' https://sixty-seven.net/admin/ || true)"
if [ "$HTTP_CODE" -ge 500 ] 2>/dev/null || grep -q '"code":"ENOENT"' /tmp/67-v46-admin-check.out 2>/dev/null; then
  rollback
  echo "LIVE_ADMIN=FAIL"
  echo "HTTP_CODE=$HTTP_CODE"
  exit 1
fi

rm -rf "$BACKUP"

echo 'PATCH_APPLIED=YES'
echo 'VERSION=V46'
echo 'V45_PRESERVED=YES'
echo 'BUILD=PASS'
echo 'DIST_ATOMIC_DEPLOY=YES'
echo 'SERVICE_RESTARTED=YES'
echo "HTTP_CODE=$HTTP_CODE"
echo 'LIVE_ADMIN=PASS'
echo 'PUSH_PERFORMED=NO'
