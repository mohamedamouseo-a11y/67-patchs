#!/usr/bin/env bash
set -euo pipefail

APP=/67/server/index.js
ENV=/etc/67-production.env
TS=$(date +%Y%m%d-%H%M%S)

cp "$APP" "$APP.v47.$TS.bak"
cp "$ENV" "$ENV.v47.$TS.bak"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/server/index.js')
s=p.read_text()
old='requestTimeout: 30_000'
new='requestTimeout: 90_000'
if old in s:
    s=s.replace(old,new,1)
elif new not in s:
    raise SystemExit('requestTimeout anchor not found')
p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path
p=Path('/etc/67-production.env')
lines=p.read_text().splitlines()
out=[]; found=False
for line in lines:
    if line.startswith('UV_THREADPOOL_SIZE='):
        out.append('UV_THREADPOOL_SIZE=8'); found=True
    else:
        out.append(line)
if not found: out.append('UV_THREADPOOL_SIZE=8')
p.write_text('\n'.join(out)+'\n')
PY

SITE=$(grep -RIl 'proxy_pass http://127.0.0.1:4173' /etc/nginx/sites-enabled /etc/nginx/conf.d 2>/dev/null | head -1 || true)
if [ -n "$SITE" ]; then
  cp "$SITE" "$SITE.v47.$TS.bak"
  SITE="$SITE" python3 - <<'PY'
import os,re
from pathlib import Path
p=Path(os.environ['SITE'])
lines=p.read_text().splitlines()
for i,line in enumerate(lines):
    if 'proxy_pass http://127.0.0.1:4173' not in line: continue
    start=i+1; end=min(len(lines),i+16); replaced=False
    for j in range(start,end):
        if re.search(r'\bproxy_read_timeout\b', lines[j]):
            indent=re.match(r'\s*',lines[j]).group(0)
            lines[j]=indent+'proxy_read_timeout 90s;'; replaced=True; break
        if '}' in lines[j]: break
    if not replaced:
        indent=re.match(r'\s*',line).group(0)
        lines.insert(i+1,indent+'proxy_read_timeout 90s;')
    break
p.write_text('\n'.join(lines)+'\n')
PY
  nginx -t || { cp "$SITE.v47.$TS.bak" "$SITE"; nginx -t; exit 1; }
  systemctl reload nginx
fi

systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

CODE=$(curl -skS -o /tmp/v47-login.json -w '%{http_code}' \
  -H 'Origin: https://sixty-seven.net' \
  -H 'Content-Type: application/json' \
  --max-time 20 \
  -d '{"username":"v47-probe","password":"V47-probe-invalid-password"}' \
  https://sixty-seven.net/api/superadmin/login || true)

case "$CODE" in
  401|429) LOGIN_PATH=PASS ;;
  *) LOGIN_PATH=FAIL ;;
esac

echo "PATCH_APPLIED=YES"
echo "REQUEST_TIMEOUT=90000"
echo "UV_THREADPOOL_SIZE=8"
echo "NGINX_SITE=${SITE:-NONE}"
echo "SERVICE=ACTIVE"
echo "LOGIN_PATH=$LOGIN_PATH"
echo "HTTP_CODE=$CODE"
echo "PUSH_PERFORMED=NO"
