#!/usr/bin/env bash
set -euo pipefail

SITE=$(grep -RIl 'proxy_pass http://127.0.0.1:4173' /etc/nginx/sites-enabled /etc/nginx/conf.d 2>/dev/null | head -1 || true)
[ -n "$SITE" ] || { echo 'ERROR=NGINX_SITE_NOT_FOUND'; exit 1; }

BACKUP=$(mktemp /tmp/67-nginx-v47.1.XXXXXX)
cat "$SITE" > "$BACKUP"

SITE="$SITE" python3 - <<'PY'
import os,re
from pathlib import Path
p=Path(os.environ['SITE'])
lines=p.read_text().splitlines()
idx=next((i for i,x in enumerate(lines) if 'proxy_pass http://127.0.0.1:4173' in x),None)
if idx is None: raise SystemExit('proxy_pass anchor not found')
# Find enclosing location block end, then replace/add timeout inside it.
start=idx
while start>=0 and '{' not in lines[start]: start-=1
if start<0: raise SystemExit('location block start not found')
depth=0; end=None
for i in range(start,len(lines)):
    depth += lines[i].count('{')-lines[i].count('}')
    if i>start and depth==0:
        end=i; break
if end is None: raise SystemExit('location block end not found')
for i in range(start+1,end):
    if re.search(r'^\s*proxy_read_timeout\b',lines[i]):
        indent=re.match(r'\s*',lines[i]).group(0)
        lines[i]=indent+'proxy_read_timeout 90s;'
        break
else:
    indent=re.match(r'\s*',lines[idx]).group(0)
    lines.insert(idx+1,indent+'proxy_read_timeout 90s;')
p.write_text('\n'.join(lines)+'\n')
PY

if ! nginx -t; then
  cat "$BACKUP" > "$SITE"
  nginx -t
  rm -f "$BACKUP"
  echo 'ERROR=NGINX_TEST_FAILED_ROLLED_BACK'
  exit 1
fi
systemctl reload nginx
rm -f "$BACKUP"

grep -A20 -B5 'proxy_pass http://127.0.0.1:4173' "$SITE" | grep -q 'proxy_read_timeout 90s;'

echo 'PATCH_APPLIED=YES'
echo 'NGINX_READ_TIMEOUT=90s'
echo 'NGINX_TEST=PASS'
echo 'NGINX_RELOAD=PASS'
echo 'PUSH_PERFORMED=NO'
echo 'ERROR=NONE'
