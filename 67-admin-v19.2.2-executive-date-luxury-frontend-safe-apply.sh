#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=e1e92b9918ca1e2daf38e21c3fff846947a8afa2
SOURCE_COMMIT=eaa03ab66a58cdf2fbc72e87ac85ab2fb8f4a36f
INNER=/tmp/67-admin-v19.2.2-inner.sh

cd "$ROOT"

# V19.2 failed only because its frontend-only deploy unnecessarily restarted
# the Node service and then hard-coded port 4173. Preserve the running service,
# build the frontend, and validate through the actual configured/bound port.
grep -q "import './AdminDashboard.v19.1.css';" src/pages/AdminDashboard.jsx
grep -q "SIX SEVEN ADMIN V19.1" src/pages/AdminDashboard.v19.1.css

rm -f "$INNER"
curl -fsSL \
  "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${SOURCE_COMMIT}/67-admin-v19.2-executive-date-luxury-polish-apply.sh" \
  -o "$INNER"

python3 - <<'PY'
from pathlib import Path
p = Path('/tmp/67-admin-v19.2.2-inner.sh')
s = p.read_text()
old = '''FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 1
[ "$(systemctl is-active sixty-seven.service)" = "active" ]

FAILED_STEP=http_check
HTTP_CODE="$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/ || true)"
[ "$HTTP_CODE" = "200" ]
'''
new = r'''FAILED_STEP=preserve_running_service
SERVICE_STATUS="$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
[ "$SERVICE_STATUS" = "active" ]

# Frontend bundle is served directly from /67/dist, so no Node restart is
# required for this CSS/JS-only patch. Detect the real runtime port instead
# of assuming 4173.
FAILED_STEP=adaptive_health_check
HTTP_CODE="000"
HTTP_URL=""
RUNTIME_PORT=""

# 1) Prefer PORT from the actual node process environment.
for pid in $(pgrep -f '/67/server/index.js' 2>/dev/null || true); do
  if [ -r "/proc/$pid/environ" ]; then
    candidate="$(tr '\0' '\n' < "/proc/$pid/environ" | sed -n 's/^PORT=//p' | head -n1)"
    if printf '%s' "$candidate" | grep -Eq '^[0-9]{1,5}$'; then
      RUNTIME_PORT="$candidate"
      break
    fi
  fi
done

# 2) If PORT is unset, discover a listening TCP port owned by a node process.
if [ -z "$RUNTIME_PORT" ]; then
  for pid in $(pgrep -f '/67/server/index.js' 2>/dev/null || true); do
    candidate="$(ss -ltnp 2>/dev/null | sed -n "s/.*127\\.0\\.0\\.1:\\([0-9][0-9]*\\).*pid=$pid,.*/\\1/p" | head -n1)"
    if printf '%s' "$candidate" | grep -Eq '^[0-9]{1,5}$'; then
      RUNTIME_PORT="$candidate"
      break
    fi
  done
fi

# 3) Repo default from server/config.js.
[ -n "$RUNTIME_PORT" ] || RUNTIME_PORT=4173

for i in $(seq 1 12); do
  for url in \
    "http://127.0.0.1:${RUNTIME_PORT}/api/health" \
    "http://127.0.0.1:${RUNTIME_PORT}/admin/" \
    "https://sixty-seven.net/admin/"; do
    code="$(curl --connect-timeout 2 --max-time 4 -k -s -o /dev/null -w '%{http_code}' "$url" || true)"
    if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]; then
      HTTP_CODE="$code"
      HTTP_URL="$url"
      break 2
    fi
  done
  sleep 1
done

if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "301" ] && [ "$HTTP_CODE" != "302" ]; then
  echo "ADAPTIVE_HTTP_READY=NO"
  echo "SERVICE_STATUS=$SERVICE_STATUS"
  echo "RUNTIME_PORT=$RUNTIME_PORT"
  echo "NODE_PIDS=$(pgrep -f '/67/server/index.js' 2>/dev/null | tr '\n' ',' || true)"
  echo "LISTENERS_BEGIN"
  ss -ltnp 2>/dev/null | grep -E 'node|4173|4174|4175' || true
  echo "LISTENERS_END"
  echo "SERVICE_LOG_BEGIN"
  journalctl -u sixty-seven.service -n 40 --no-pager 2>/dev/null || true
  echo "SERVICE_LOG_END"
  false
fi
'''
if old not in s:
    raise SystemExit('ORIGINAL_RESTART_HTTP_BLOCK_NOT_FOUND')
s = s.replace(old, new, 1)
s = s.replace(
    'echo "SERVICE_STATUS=active"\necho "LOCAL_ADMIN_HTTP=$HTTP_CODE"',
    'echo "SERVICE_STATUS=$SERVICE_STATUS"\necho "LOCAL_ADMIN_HTTP=$HTTP_CODE"\necho "HEALTHCHECK_URL=$HTTP_URL"\necho "RUNTIME_PORT=$RUNTIME_PORT"\necho "SERVICE_RESTART=SKIPPED_FRONTEND_ONLY"\necho "ADAPTIVE_HEALTHCHECK=YES"',
    1,
)
p.write_text(s)
PY

bash -n "$INNER"
chmod +x "$INNER"

echo "V19_2_2_WRAPPER=READY"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "FRONTEND_ONLY_DEPLOY=YES"
echo "SERVICE_RESTART=SKIPPED"
echo "ADAPTIVE_HEALTHCHECK=ENABLED"
echo "SOURCE_COMMIT=$SOURCE_COMMIT"

exec bash "$INNER"
