#!/usr/bin/env bash
set -euo pipefail

cd /67

CSS="src/pages/ScrapyardsPage.css"
JSX="src/pages/ScrapyardsPage.jsx"

[[ -f "$CSS" ]] || { echo "ERROR: $CSS missing"; exit 1; }
[[ -f "$JSX" ]] || { echo "ERROR: $JSX missing"; exit 1; }

grep -q 'className="sy67-page"' "$JSX" || { echo "ERROR: Batch 08 scrapyards markup not detected"; exit 1; }
grep -q "const scrapyards = \[" "$JSX" || { echo "ERROR: original scrapyards data source marker missing"; exit 1; }
grep -q "const mockParts = \[" "$JSX" || { echo "ERROR: original scrapyard parts marker missing"; exit 1; }

jsx_before="$(sha256sum "$JSX" | awk '{print $1}')"
backup="$(mktemp)"
cp "$CSS" "$backup"

rollback() {
  cp "$backup" "$CSS"
  rm -f "$backup"
  echo "ERROR: SCRAPYARDS_VISUAL_POLISH_V2 failed; CSS restored" >&2
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path
p = Path('src/pages/ScrapyardsPage.css')
s = p.read_text()
marker = '/* SCRAPYARDS_VISUAL_POLISH_V2 */'
if marker not in s:
    s += r'''

/* SCRAPYARDS_VISUAL_POLISH_V2 */
/* Desktop-only refinement based on visual review. No data/JSX changes. */
@media (min-width: 1100px) {
  .sy67-shell {
    width: min(1280px, calc(100% - 64px));
  }

  .sy67-hero {
    padding: 92px 0 82px;
  }

  .sy67-hero-inner {
    grid-template-columns: minmax(0, 1.2fr) 430px;
    gap: clamp(64px, 6vw, 92px);
  }

  .sy67-hero-copy h1 {
    max-width: 760px;
    font-size: clamp(54px, 4.65vw, 68px);
    line-height: 1.02;
    letter-spacing: -1.8px;
  }

  .sy67-hero-copy h1 em {
    display: inline-block;
    white-space: nowrap;
  }

  .sy67-lead {
    max-width: 720px;
    margin-top: 24px;
    font-size: 17px;
    line-height: 1.85;
  }

  .sy67-stats {
    margin-top: 30px;
  }

  .sy67-stats > div {
    min-width: 138px;
    padding-inline: 24px;
  }

  .sy67-stats strong {
    font-size: 32px;
  }

  .sy67-search-panel {
    padding: 30px;
    border-radius: 26px;
  }

  .sy67-results {
    padding: 82px 0 76px;
  }

  .sy67-section-head {
    margin-bottom: 38px;
  }

  .sy67-section-head h2 {
    max-width: 760px;
    font-size: clamp(38px, 3.3vw, 50px);
  }

  .sy67-yards-layout {
    grid-template-columns: 300px minmax(0, 1fr);
    gap: 28px;
  }

  .sy67-network-card {
    top: 96px;
    min-height: 590px;
    padding: 30px;
    border-radius: 24px;
  }

  .sy67-network-rings {
    width: 238px;
    height: 342px;
    margin-top: 34px;
  }

  .sy67-yard-grid {
    gap: 22px;
  }

  .sy67-yard-card {
    min-height: 350px;
    border-radius: 22px;
  }

  .sy67-yard-visual {
    min-height: 190px;
  }

  .sy67-yard-body {
    padding: 22px 24px 20px;
  }

  .sy67-yard-body h3 {
    margin-top: 10px;
    font-size: 21px;
    line-height: 1.35;
  }

  .sy67-yard-body > p {
    margin-top: 9px;
    line-height: 1.75;
  }

  .sy67-card-action {
    min-height: 54px;
    padding-inline: 24px;
  }

  /* With the original project currently having 3 scrapyards, avoid the awkward
     half-empty second row: let the final odd card use the whole content width. */
  .sy67-yard-card:last-child:nth-child(odd) {
    grid-column: 1 / -1;
    display: grid;
    grid-template-columns: minmax(280px, .86fr) minmax(0, 1.14fr);
    grid-template-rows: 1fr auto;
    min-height: 250px;
  }

  .sy67-yard-card:last-child:nth-child(odd) .sy67-yard-visual {
    min-height: 250px;
  }

  .sy67-yard-card:last-child:nth-child(odd) .sy67-yard-body {
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 30px 34px;
  }

  .sy67-yard-card:last-child:nth-child(odd) .sy67-card-action {
    grid-column: 1 / -1;
  }

  .sy67-steps {
    padding: 72px 0 84px;
  }

  .sy67-steps h2 {
    font-size: clamp(36px, 3.5vw, 50px);
  }

  .sy67-steps-grid {
    gap: 18px;
    margin-top: 30px;
  }

  .sy67-steps-grid article {
    min-height: 184px;
    padding: 28px;
  }
}

/* The shared desktop header already handles navigation on this redesigned page.
   Keep BottomNav for tablet/mobile only so it does not float over desktop content. */
@media (min-width: 900px) {
  .sy67-page .bottom-nav {
    display: none !important;
  }
}

@media (max-width: 1099px) and (min-width: 760px) {
  .sy67-shell {
    width: min(940px, calc(100% - 40px));
  }

  .sy67-hero-copy h1 {
    font-size: 50px;
  }

  .sy67-yards-layout {
    grid-template-columns: 250px minmax(0, 1fr);
  }

  .sy67-network-card {
    min-height: 520px;
  }
}
'''
    p.write_text(s)
PY

grep -q 'SCRAPYARDS_VISUAL_POLISH_V2' "$CSS"
grep -q 'grid-column: 1 / -1' "$CSS"
grep -q '.sy67-page .bottom-nav' "$CSS"

jsx_after="$(sha256sum "$JSX" | awk '{print $1}')"
[[ "$jsx_before" == "$jsx_after" ]] || { echo "ERROR: ScrapyardsPage.jsx changed unexpectedly"; exit 1; }

rm -f "$backup"
trap - ERR

echo "SCRAPYARDS_VISUAL_POLISH_V2_APPLIED"
echo "SCRAPYARDS_DESKTOP_LAYOUT_REBALANCED"
echo "SCRAPYARDS_ORIGINAL_DATA_UNCHANGED"
echo "SCRAPYARDS_DESKTOP_BOTTOM_NAV_HIDDEN"
