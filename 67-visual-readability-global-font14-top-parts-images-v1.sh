#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
SRC="$ROOT/src"
TOP_CSS="$ROOT/src/pages/TopPartsPage.css"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-font14-images-backup-$STAMP"
CHANGED_LIST="$BACKUP/changed-files.txt"

[ -d "$SRC" ] || { echo "ERROR: missing $SRC" >&2; exit 1101; }
[ -f "$TOP_CSS" ] || { echo "ERROR: missing $TOP_CSS" >&2; exit 1102; }

mkdir -p "$BACKUP/files"
: > "$CHANGED_LIST"

rollback() {
  code=$?
  trap - ERR
  if [ -f "$CHANGED_LIST" ]; then
    while IFS= read -r rel; do
      [ -n "$rel" ] || continue
      if [ -f "$BACKUP/files/$rel" ]; then
        mkdir -p "$(dirname "$ROOT/$rel")"
        cp -f "$BACKUP/files/$rel" "$ROOT/$rel" || true
      fi
    done < "$CHANGED_LIST"
  fi
  echo "ERROR: readability/image-fit patch failed; changed source files restored" >&2
  exit "$code"
}
trap rollback ERR

python3 - "$ROOT" "$BACKUP" "$CHANGED_LIST" <<'PY'
from pathlib import Path
import re, shutil, sys

root = Path(sys.argv[1])
backup = Path(sys.argv[2])
changed_list = Path(sys.argv[3])
src = root / 'src'

# User-facing readability rule: any explicit positive font size below 14px
# in project source is raised to 14px. Zero remains untouched because it is
# sometimes intentionally used for layout/icon techniques.
px_css = re.compile(r'(font-size\s*:\s*)(\d+(?:\.\d+)?)px', re.I)
rem_css = re.compile(r'(font-size\s*:\s*)(\d+(?:\.\d+)?)rem', re.I)
clamp_px = re.compile(r'(font-size\s*:\s*clamp\(\s*)(\d+(?:\.\d+)?)px', re.I)
jsx_px_str = re.compile(r'(fontSize\s*:\s*[\'\"])(\d+(?:\.\d+)?)px([\'\"])')
jsx_num = re.compile(r'(fontSize\s*:\s*)(\d+(?:\.\d+)?)(?=\s*[,}])')

changed = []
counts = {'css_px':0,'css_rem':0,'clamp':0,'jsx_px':0,'jsx_num':0}

# Only source code/styles. Never data/assets/public/dist/node_modules.
for p in sorted(src.rglob('*')):
    if not p.is_file() or p.suffix.lower() not in {'.css', '.jsx', '.js'}:
        continue
    if '/data/' in p.as_posix() or '/assets/' in p.as_posix():
        continue
    original = p.read_text(encoding='utf-8')
    text = original

    if p.suffix.lower() == '.css':
        def repl_clamp(m):
            v=float(m.group(2))
            if 0 < v < 14:
                counts['clamp'] += 1
                return f"{m.group(1)}14px"
            return m.group(0)
        text = clamp_px.sub(repl_clamp, text)

        def repl_px(m):
            v=float(m.group(2))
            if 0 < v < 14:
                counts['css_px'] += 1
                return f"{m.group(1)}14px"
            return m.group(0)
        text = px_css.sub(repl_px, text)

        def repl_rem(m):
            v=float(m.group(2))
            if 0 < v < 0.875:
                counts['css_rem'] += 1
                return f"{m.group(1)}0.875rem"
            return m.group(0)
        text = rem_css.sub(repl_rem, text)

    else:
        def repl_jsx_px(m):
            v=float(m.group(2))
            if 0 < v < 14:
                counts['jsx_px'] += 1
                return f"{m.group(1)}14px{m.group(3)}"
            return m.group(0)
        text = jsx_px_str.sub(repl_jsx_px, text)

        def repl_jsx_num(m):
            v=float(m.group(2))
            if 0 < v < 14:
                counts['jsx_num'] += 1
                return f"{m.group(1)}14"
            return m.group(0)
        text = jsx_num.sub(repl_jsx_num, text)

    if text != original:
        rel = p.relative_to(root)
        dest = backup / 'files' / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(original, encoding='utf-8')
        p.write_text(text, encoding='utf-8')
        changed.append(str(rel))

# Add the explicit Top Parts image-fit correction after the readability sweep.
top = src / 'pages' / 'TopPartsPage.css'
text = top.read_text(encoding='utf-8')
marker = '/* TOP PARTS IMAGE FIT — V1 */'
if marker not in text:
    if str(top.relative_to(root)) not in changed:
        rel = top.relative_to(root)
        dest = backup / 'files' / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(text, encoding='utf-8')
        changed.append(str(rel))
    text += r'''

/* TOP PARTS IMAGE FIT — V1 */
.tp67-card-visual {
  min-height: 270px;
  padding: 14px;
}

.tp67-card-visual img {
  width: 84%;
  height: 84%;
  max-width: 84%;
  max-height: 84%;
  object-fit: contain;
  object-position: center;
  padding: 0;
  margin: auto;
}

@media (max-width: 620px) {
  .tp67-card-visual {
    min-height: 240px;
  }

  .tp67-card-visual img {
    width: 88%;
    height: 88%;
    max-width: 88%;
    max-height: 88%;
  }
}
'''
    top.write_text(text, encoding='utf-8')

# Persist changed-file list after all edits.
changed = sorted(set(changed))
changed_list.write_text('\n'.join(changed) + ('\n' if changed else ''), encoding='utf-8')

print(f"FONT14_CSS_PX_REPLACEMENTS={counts['css_px']}")
print(f"FONT14_CSS_REM_REPLACEMENTS={counts['css_rem']}")
print(f"FONT14_CLAMP_REPLACEMENTS={counts['clamp']}")
print(f"FONT14_JSX_PX_REPLACEMENTS={counts['jsx_px']}")
print(f"FONT14_JSX_NUM_REPLACEMENTS={counts['jsx_num']}")
print(f"SOURCE_FILES_CHANGED={len(changed)}")
PY

# Validate the specific image-fit rule exists.
grep -q 'TOP PARTS IMAGE FIT — V1' "$TOP_CSS"
grep -q 'width: 84%' "$TOP_CSS"
grep -q 'object-fit: contain' "$TOP_CSS"

echo 'TOP_PARTS_IMAGES_FIT_V1_APPLIED'

# Validate no explicit positive CSS px/rem font size below 14 remains
# and no JSX inline fontSize under 14 remains in customer source styles/components.
python3 - "$SRC" <<'PY'
from pathlib import Path
import re, sys
src=Path(sys.argv[1])
issues=[]
css_px=re.compile(r'font-size\s*:\s*(\d+(?:\.\d+)?)px', re.I)
css_rem=re.compile(r'font-size\s*:\s*(\d+(?:\.\d+)?)rem', re.I)
clamp_px=re.compile(r'font-size\s*:\s*clamp\(\s*(\d+(?:\.\d+)?)px', re.I)
jsx_px=re.compile(r'fontSize\s*:\s*[\'\"](\d+(?:\.\d+)?)px[\'\"]')
jsx_num=re.compile(r'fontSize\s*:\s*(\d+(?:\.\d+)?)(?=\s*[,}])')
for p in src.rglob('*'):
    if not p.is_file() or p.suffix.lower() not in {'.css','.jsx','.js'}: continue
    if '/data/' in p.as_posix() or '/assets/' in p.as_posix(): continue
    t=p.read_text(encoding='utf-8')
    for m in clamp_px.finditer(t):
        v=float(m.group(1));
        if 0 < v < 14: issues.append((p, 'clamp-px', v))
    for m in css_px.finditer(t):
        v=float(m.group(1));
        if 0 < v < 14: issues.append((p, 'css-px', v))
    for m in css_rem.finditer(t):
        v=float(m.group(1));
        if 0 < v < .875: issues.append((p, 'css-rem', v))
    for m in jsx_px.finditer(t):
        v=float(m.group(1));
        if 0 < v < 14: issues.append((p, 'jsx-px', v))
    for m in jsx_num.finditer(t):
        v=float(m.group(1));
        if 0 < v < 14: issues.append((p, 'jsx-num', v))
if issues:
    for row in issues[:30]: print('FONT_UNDER_14_REMAINS', *row, file=sys.stderr)
    raise SystemExit(1)
print('GLOBAL_EXPLICIT_FONT_MIN_14_VERIFIED')
PY

echo 'GLOBAL_FONT_MIN_14_V1_APPLIED'
echo 'CHANGED_FILES:'
cat "$CHANGED_LIST"
