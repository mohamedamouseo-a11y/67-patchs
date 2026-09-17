#!/usr/bin/env bash
set -euo pipefail

cd /67

CSS="src/pages/ScrapyardsPage.css"
JSX="src/pages/ScrapyardsPage.jsx"

[[ -f "$CSS" ]] || { echo "ERROR: $CSS missing"; exit 1; }
[[ -f "$JSX" ]] || { echo "ERROR: $JSX missing"; exit 1; }

grep -q 'className="sy67-page"' "$JSX" || { echo "ERROR: redesigned Scrapyards markup not detected"; exit 1; }
grep -q 'className="sy67-watermark"' "$JSX" || { echo "ERROR: Scrapyards watermark marker missing"; exit 1; }
grep -q 'className="sy67-search-panel"' "$JSX" || { echo "ERROR: Scrapyards search-panel marker missing"; exit 1; }

jsx_before="$(sha256sum "$JSX" | awk '{print $1}')"
backup="$(mktemp)"
cp "$CSS" "$backup"

rollback() {
  cp "$backup" "$CSS"
  rm -f "$backup"
  echo "ERROR: SCRAPYARDS_HERO_ALIGNMENT_V3 failed; CSS restored" >&2
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path
p = Path('src/pages/ScrapyardsPage.css')
s = p.read_text(encoding='utf-8')
marker = '/* SCRAPYARDS_HERO_ALIGNMENT_V3 */'
if marker not in s:
    s += r'''

/* SCRAPYARDS_HERO_ALIGNMENT_V3 */
/* Visual-only hero correction from screenshot review. */
.sy67-watermark {
  display: none !important;
}

@media (min-width: 1100px) {
  /* The search panel previously rose into the shared header area.
     Drop it to the same visual breathing room used by the Auctions hero. */
  .sy67-search-panel {
    margin-top: 54px !important;
  }
}

@media (max-width: 1099px) {
  .sy67-search-panel {
    margin-top: 0;
  }
}
'''
    p.write_text(s, encoding='utf-8')
PY

grep -q 'SCRAPYARDS_HERO_ALIGNMENT_V3' "$CSS"
grep -q 'display: none !important' "$CSS"
grep -q 'margin-top: 54px !important' "$CSS"

jsx_after="$(sha256sum "$JSX" | awk '{print $1}')"
[[ "$jsx_before" == "$jsx_after" ]] || { echo "ERROR: ScrapyardsPage.jsx changed unexpectedly"; exit 1; }

rm -f "$backup"
trap - ERR

echo "SCRAPYARDS_HERO_ALIGNMENT_V3_APPLIED"
echo "SCRAPYARDS_BACKGROUND_WATERMARK_REMOVED"
echo "SCRAPYARDS_SEARCH_PANEL_LOWERED"
echo "SCRAPYARDS_DATA_AND_JSX_UNCHANGED"
