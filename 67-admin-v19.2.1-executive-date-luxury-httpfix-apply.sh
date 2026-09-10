#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=e1e92b9918ca1e2daf38e21c3fff846947a8afa2
SOURCE_COMMIT=eaa03ab66a58cdf2fbc72e87ac85ab2fb8f4a36f
INNER=/tmp/67-admin-v19.2-luxury-inner.sh
FAILED_STEP=init

cd "$ROOT"

FAILED_STEP=verify_current_v19_1_state
grep -q "import './AdminDashboard.v19.1.css';" src/pages/AdminDashboard.jsx
grep -q "SIX SEVEN ADMIN V19.1" src/pages/AdminDashboard.v19.1.css

FAILED_STEP=download_v19_2_source
rm -f "$INNER"
curl -fsSL \
  "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${SOURCE_COMMIT}/67-admin-v19.2-executive-date-luxury-polish-apply.sh" \
  -o "$INNER"

FAILED_STEP=repair_http_readiness_check
python3 - <<'PY'
from pathlib import Path
p = Path('/tmp/67-admin-v19.2-luxury-inner.sh')
s = p.read_text()
old = '''FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 1
[ "$(systemctl is-active sixty-seven.service)" = "active" ]

FAILED_STEP=http_check
HTTP_CODE="$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/ || true)"
[ "$HTTP_CODE" = "200" ]
'''
new = '''FAILED_STEP=restart_service
systemctl restart sixty-seven.service

FAILED_STEP=wait_for_service
for i in $(seq 1 20); do
  if [ "$(systemctl is-active sixty-seven.service 2>/dev/null || true)" = "active" ]; then
    break
  fi
  sleep 1
done
[ "$(systemctl is-active sixty-seven.service 2>/dev/null || true)" = "active" ]

FAILED_STEP=http_check
HTTP_CODE="000"
HTTP_URL=""
for i in $(seq 1 20); do
  for url in http://127.0.0.1:4173/admin/ http://127.0.0.1:4173/admin; do
    code="$(curl --max-time 3 -sS -o /dev/null -w '%{http_code}' "$url" || true)"
    if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]; then
      HTTP_CODE="$code"
      HTTP_URL="$url"
      break 2
    fi
  done
  sleep 1
done
if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "301" ] && [ "$HTTP_CODE" != "302" ]; then
  echo "HTTP_READY=NO"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  journalctl -u sixty-seven.service -n 20 --no-pager 2>/dev/null || true
  false
fi
'''
if old not in s:
    raise SystemExit('HTTP_BLOCK_NOT_FOUND')
s = s.replace(old, new, 1)
s = s.replace('echo "LOCAL_ADMIN_HTTP=$HTTP_CODE"', 'echo "LOCAL_ADMIN_HTTP=$HTTP_CODE"\necho "LOCAL_ADMIN_URL=$HTTP_URL"', 1)
p.write_text(s)
PY

FAILED_STEP=syntax_check_repaired_installer
bash -n "$INNER"
chmod +x "$INNER"

echo "V19_2_1_WRAPPER=READY"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "HTTP_READINESS_RETRY=ENABLED"
echo "SOURCE_COMMIT=$SOURCE_COMMIT"

FAILED_STEP=execute_repaired_v19_2
exec bash "$INNER"
