#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE=src/pages/AdminDashboard.v34.1.css
TARGET=src/pages/AdminDashboard.v34.2.css
RAW=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-v34.2-fidelity-overrides.css
cd "$ROOT"
[ -f "$JSX" ] || { echo FAILED_STEP=JSX_MISSING; exit 1; }
[ -f "$SOURCE" ] || { echo FAILED_STEP=V34_1_CSS_MISSING; exit 1; }
grep -q "import './AdminDashboard.v34.1.css';" "$JSX" || { echo FAILED_STEP=V34_1_RUNTIME_NOT_ACTIVE; exit 1; }
cp "$SOURCE" "$TARGET"
curl -fsSL "$RAW" >> "$TARGET"
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
p.write_text(s.replace("import './AdminDashboard.v34.1.css';","import './AdminDashboard.v34.2.css';",1))
PY
npm run build >/tmp/67-v34-2-build.log 2>&1 || { tail -n 120 /tmp/67-v34-2-build.log; exit 1; }
echo PATCH_APPLIED=YES
echo BUILD=PASS
echo RUNTIME_CSS=AdminDashboard.v34.2.css
echo DATA_CHANGED=NO
echo LOGIC_CHANGED=NO
echo BACKEND_CHANGED=NO
echo AUTH_CHANGED=NO
echo SOURCE_PROJECT_PUSHED=NO
