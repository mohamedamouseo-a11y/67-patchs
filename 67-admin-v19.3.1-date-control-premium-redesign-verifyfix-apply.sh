#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
SOURCE_COMMIT=e8db81006ef46f4af46d9b6769faefcb05952387
INNER=/tmp/67-admin-v19.3-premium-inner.sh
FAILED_STEP=init

cd "$ROOT"

FAILED_STEP=verify_current_v19_2_3_state
grep -q "import './AdminDashboard.v19.2.3.css';" src/pages/AdminDashboard.jsx
grep -q "SIX SEVEN ADMIN V19.2.3" src/pages/AdminDashboard.v19.2.3.css

FAILED_STEP=download_v19_3_source
rm -f "$INNER"
curl -fsSL \
  "https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/${SOURCE_COMMIT}/67-admin-v19.3-date-control-premium-redesign-apply.sh" \
  -o "$INNER"

FAILED_STEP=repair_false_css_verification
python3 - <<'PY'
from pathlib import Path
p = Path('/tmp/67-admin-v19.3-premium-inner.sh')
s = p.read_text()
bad = 'grep -q "background:linear-gradient(180deg,#fffaf0" "$TARGET_CSS"'
good = 'grep -q "linear-gradient(180deg,#fffaf0" "$TARGET_CSS"'
if bad not in s:
    raise SystemExit('KNOWN_BAD_CSS_VERIFY_NOT_FOUND')
s = s.replace(bad, good, 1)

# Make any future failure self-diagnosing instead of returning a generic rollback only.
s = s.replace('BACKUP=/tmp/67-v19.3-$$\n', 'BACKUP=/tmp/67-v19.3-$$\nFAILED_STEP=init\n', 1)
s = s.replace('rollback(){\n', 'rollback(){\n  local code=$?\n  echo "FAILED_STEP=$FAILED_STEP"\n', 1)
s = s.replace('echo "ERROR=V19_3_DATE_CONTROL_PREMIUM_REDESIGN_FAILED"', 'echo "ERROR=V19_3_DATE_CONTROL_PREMIUM_REDESIGN_FAILED_EXIT_${code}"', 1)

# Add step markers around the operations that can fail.
s = s.replace('grep -q "import \'./AdminDashboard.v19.2.3.css\';" "$TARGET_JSX"', 'FAILED_STEP=verify_runtime_import\ngrep -q "import \'./AdminDashboard.v19.2.3.css\';" "$TARGET_JSX"', 1)
s = s.replace('cp "$SOURCE_CSS" "$TARGET_CSS"\ncat >> "$TARGET_CSS"', 'FAILED_STEP=create_v19_3_css\ncp "$SOURCE_CSS" "$TARGET_CSS"\ncat >> "$TARGET_CSS"', 1)
s = s.replace("python3 - <<'PY'\nfrom pathlib import Path\np=Path('/67/src/pages/AdminDashboard.jsx')", "FAILED_STEP=patch_jsx\npython3 - <<'PY'\nfrom pathlib import Path\np=Path('/67/src/pages/AdminDashboard.jsx')", 1)
s = s.replace('grep -q "import \'./AdminDashboard.v19.3.css\';" "$TARGET_JSX"', 'FAILED_STEP=verify_v19_3_edits\ngrep -q "import \'./AdminDashboard.v19.3.css\';" "$TARGET_JSX"', 1)
s = s.replace('npm run build >/tmp/67-v19.3-build.log 2>&1', 'FAILED_STEP=build\nif ! npm run build >/tmp/67-v19.3-build.log 2>&1; then\n  tail -n 80 /tmp/67-v19.3-build.log || true\n  false\nfi', 1)
s = s.replace('trap - ERR\nrm -rf "$BACKUP"', 'FAILED_STEP=complete\ntrap - ERR\nrm -rf "$BACKUP"', 1)

p.write_text(s)
PY

FAILED_STEP=syntax_check_repaired_installer
bash -n "$INNER"
chmod +x "$INNER"

echo "V19_3_1_WRAPPER=READY"
echo "SOURCE_COMMIT=$SOURCE_COMMIT"
echo "FALSE_CSS_VERIFICATION_FIXED=YES"
echo "FAILURE_DIAGNOSTICS=ENABLED"
echo "CURRENT_RUNTIME=V19.2.3"

FAILED_STEP=execute_repaired_v19_3
exec bash "$INNER"
