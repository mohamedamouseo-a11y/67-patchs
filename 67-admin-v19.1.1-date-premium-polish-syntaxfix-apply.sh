#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=33615c0fdb7a6af04e549bdaf965e1a6652e209e
SOURCE_COMMIT=0b9c6e50d34033f6db2b30a090649fd8e44a614e
INNER=/tmp/67-admin-v19.1-premium-inner.sh
FAILED_STEP=init

cd "$ROOT"

FAILED_STEP=verify_current_v19_state
grep -q "import './AdminDashboard.v19.css';" src/pages/AdminDashboard.jsx
grep -q "SIX SEVEN ADMIN V19" src/pages/AdminDashboard.v19.css

FAILED_STEP=download_v19_1_source
rm -f "$INNER"
curl -fsSL \
  "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${SOURCE_COMMIT}/67-admin-v19.1-date-premium-polish-apply.sh" \
  -o "$INNER"

FAILED_STEP=repair_known_shell_quote_bug
python3 - <<'PY'
from pathlib import Path
p = Path('/tmp/67-admin-v19.1-premium-inner.sh')
s = p.read_text()
bad = 'grep -q "executive-date-popover__badge">" "$TARGET_JSX" || grep -q "executive-date-popover__badge" "$TARGET_JSX"'
good = 'grep -q "executive-date-popover__badge" "$TARGET_JSX"'
if bad not in s:
    raise SystemExit('KNOWN_BAD_GREP_LINE_NOT_FOUND')
s = s.replace(bad, good, 1)
p.write_text(s)
PY

FAILED_STEP=syntax_check_repaired_installer
bash -n "$INNER"
chmod +x "$INNER"

echo "V19_1_1_WRAPPER=READY"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "SHELL_SYNTAX_FIX=PASS"
echo "SOURCE_COMMIT=$SOURCE_COMMIT"

FAILED_STEP=execute_repaired_v19_1
exec bash "$INNER"
