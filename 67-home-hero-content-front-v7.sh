#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
SEED_LOGO="/tmp/67-logo-full-approved-v6.png"
V6_URL="https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-home-hero-content-front-v6.sh"
V6_LOCAL="/tmp/67-home-hero-content-front-v6-for-v7.sh"
SEED_BACKUP="/tmp/67-home-hero-v7-seed-backup-$(date +%Y%m%d-%H%M%S)/public/assets"

# V7 fixes ONLY the bad size gate from V6. The 946x567 logo already exists locally,
# but V6 incorrectly rejected it because it was efficiently compressed below 100 KB.
if [ ! -f "$SEED_LOGO" ]; then
  echo "ERROR: expected local approved logo missing: $SEED_LOGO" >&2
  exit 70
fi

python3 - "$SEED_LOGO" <<'PY'
from pathlib import Path
import struct, sys
p=Path(sys.argv[1])
b=p.read_bytes()
if len(b) < 5000 or b[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('ERROR: local logo is not a valid PNG')
w,h=struct.unpack('>II', b[16:24])
print(f"Approved local logo: {p} | {w}x{h} | {len(b)} bytes")
if (w,h)!=(946,567):
    raise SystemExit('ERROR: local logo dimensions are not 946x567')
PY

# Seed a fresh backup path so V6 finds this exact 946x567 logo.
mkdir -p "$SEED_BACKUP"
cp -f "$SEED_LOGO" "$SEED_BACKUP/logo-67.png"
touch "$SEED_BACKUP/logo-67.png"

# Fetch the known V6 implementation fresh, then relax ONLY the invalid file-size gate.
rm -f "$V6_LOCAL"
curl -fsSL -H "Cache-Control: no-cache" "${V6_URL}?v7=$(date +%s)" -o "$V6_LOCAL"

# V6 used >100KB as a proxy for correctness. PNG dimensions are the actual invariant.
python3 - "$V6_LOCAL" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text(encoding='utf-8')
s=s.replace('size > 100000', 'size > 5000')
s=s.replace('len(b)<=100000', 'len(b)<=5000')
p.write_text(s, encoding='utf-8')
PY

bash -n "$V6_LOCAL"

# Execute the prepared implementation. V6 itself guards the hero image and navbar CSS hashes.
bash "$V6_LOCAL"

echo "CONTENT_FRONT_V7_APPLIED"
echo "Seed logo used: $SEED_LOGO"
echo "V7 changed no implementation logic except accepting the valid 946x567 compressed PNG."
