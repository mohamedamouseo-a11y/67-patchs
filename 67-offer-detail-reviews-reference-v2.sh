#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
JSX="$ROOT/src/pages/OfferDetailPage.jsx"
CSS="$ROOT/src/pages/OfferDetailPage.css"
OFFERS="$ROOT/src/data/mockOffers.js"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-offer-detail-reviews-v2-$STAMP"

for f in "$JSX" "$CSS" "$OFFERS"; do
  [ -f "$f" ] || { echo "ERROR: missing required file: $f" >&2; exit 1701; }
done

grep -q "from '../data/mockOffers'" "$JSX" || { echo 'ERROR: original product source import missing' >&2; exit 1702; }
grep -q "activeTab === 'reviews'" "$JSX" || { echo 'ERROR: reviews tab marker missing' >&2; exit 1703; }
grep -q 'od67-rating-summary' "$JSX" || { echo 'ERROR: current rating summary marker missing' >&2; exit 1704; }

mkdir -p "$BACKUP"
cp -a "$JSX" "$BACKUP/OfferDetailPage.jsx"
cp -a "$CSS" "$BACKUP/OfferDetailPage.css"
OFFERS_SHA="$(sha256sum "$OFFERS" | awk '{print $1}')"

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/OfferDetailPage.jsx" "$JSX" || true
  cp -f "$BACKUP/OfferDetailPage.css" "$CSS" || true
  echo 'ERROR: Offer Detail reviews V2 failed; restored target files' >&2
  exit "$code"
}
trap rollback ERR

python3 - "$JSX" "$CSS" <<'PY'
from pathlib import Path
import sys

jsx_path = Path(sys.argv[1])
css_path = Path(sys.argv[2])
s = jsx_path.read_text(encoding='utf-8')

start_marker = "            {activeTab === 'reviews' && ("
end_marker = "\n          </section>"
start = s.find(start_marker)
if start == -1:
    raise SystemExit('ERROR: reviews block start not found')
end = s.find(end_marker, start)
if end == -1:
    raise SystemExit('ERROR: reviews block end not found')

new_reviews = r'''            {activeTab === 'reviews' && (
              <div className="od67-tab-panel od67-reviews-panel">
                <aside className="od67-rating-summary" aria-label={`متوسط التقييم ${offer.rating} من 5`}>
                  <strong>{offer.rating}</strong>
                  <div className="od67-rating-stars" aria-hidden="true">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <Star
                        key={star}
                        size={18}
                        fill={star <= Math.round(offer.rating) ? 'currentColor' : 'none'}
                      />
                    ))}
                  </div>
                  <span>بناءً على {offer.reviewCount} تقييم</span>
                </aside>

                <div className="od67-review-list">
                  <article className="od67-review-card">
                    <div className="od67-review-card-head">
                      <div>
                        <strong>ملخص التقييم</strong>
                        <span>{offer.storeNameAr}</span>
                      </div>
                      <div className="od67-review-card-score">
                        <Star size={16} fill="currentColor" />
                        <b>{offer.rating}</b>
                      </div>
                    </div>
                    <p>
                      متوسط تقييم هذا العرض هو {offer.rating} من 5 بناءً على {offer.reviewCount} تقييم مسجل في بيانات المشروع.
                    </p>
                    <small>{offer.isVerified ? 'متجر موثق' : 'متجر'} · {offer.storeCityAr}</small>
                  </article>

                  <article className="od67-review-card od67-review-card-market">
                    <div className="od67-review-card-head">
                      <div>
                        <strong>حالة السعر</strong>
                        <span>مقارنة ببيانات السوق المسجلة</span>
                      </div>
                      <ShieldCheck size={20} />
                    </div>

                    {offer.marketPrice ? (
                      <p className={offer.price <= offer.marketPrice ? 'is-fair' : 'is-high'}>
                        {offer.price <= offer.marketPrice
                          ? `السعر الحالي ضمن أو أقل من متوسط السوق المسجل (${offer.marketPrice} ${offer.currency}).`
                          : `السعر الحالي أعلى من متوسط السوق المسجل (${offer.marketPrice} ${offer.currency}).`}
                      </p>
                    ) : (
                      <p>لا توجد بيانات مقارنة سعرية مسجلة لهذا العرض.</p>
                    )}

                    {offer.marketPrice && offer.price <= offer.marketPrice && !ratingSubmitted && (
                      <div className="od67-star-rate">
                        <span>قيّم السعر:</span>
                        {[1, 2, 3, 4, 5].map((star) => (
                          <button
                            type="button"
                            key={star}
                            className={fairRating >= star ? 'is-active' : ''}
                            onClick={() => setFairRating(star)}
                            aria-label={`تقييم ${star}`}
                          >
                            <Star size={19} fill={fairRating >= star ? 'currentColor' : 'none'} />
                          </button>
                        ))}
                        {fairRating > 0 && (
                          <button type="button" className="od67-submit-rating" onClick={() => setRatingSubmitted(true)}>
                            إرسال التقييم
                          </button>
                        )}
                      </div>
                    )}

                    {ratingSubmitted && <small className="od67-rating-thanks">شكراً لتقييمك.</small>}
                  </article>
                </div>
              </div>
            )}'''

s = s[:start] + new_reviews + s[end:]

for marker in [
    'od67-review-list',
    'od67-review-card',
    'od67-rating-stars',
    'offer.reviewCount',
    'offer.marketPrice',
    'offer.storeNameAr',
]:
    if marker not in s:
        raise SystemExit(f'ERROR: final JSX marker missing: {marker}')

# Explicit guard: the reference contains written reviews, but the original source does not.
for forbidden in ['محمد س.', 'عبدالله ن.', 'التغليف ممتاز', 'البائع رد بسرعة']:
    if forbidden in s:
        raise SystemExit(f'ERROR: invented written review content detected: {forbidden}')

jsx_path.write_text(s, encoding='utf-8')

css = css_path.read_text(encoding='utf-8')
marker = '/* OFFER DETAIL REVIEWS — REFERENCE MATCH V2 */'
if marker in css:
    css = css[:css.index(marker)].rstrip() + '\n'

css += r'''

/* OFFER DETAIL REVIEWS — REFERENCE MATCH V2 */
.od67-reviews-panel {
  display: grid !important;
  grid-template-columns: 260px minmax(0, 1fr) !important;
  gap: 18px !important;
  align-items: stretch !important;
  direction: rtl;
}

.od67-rating-summary {
  min-height: 256px !important;
  padding: 28px 24px !important;
  display: flex !important;
  flex-direction: column !important;
  align-items: center !important;
  justify-content: center !important;
  gap: 13px !important;
  border: 1px solid var(--od67-line) !important;
  border-radius: 18px !important;
  background: #fff !important;
  text-align: center !important;
}

.od67-rating-summary > strong {
  color: #11120f !important;
  font-family: Arial, sans-serif;
  font-size: 48px !important;
  line-height: 1 !important;
  font-weight: 800 !important;
}

.od67-rating-stars {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 3px;
  direction: ltr;
  color: var(--od67-gold);
}

.od67-rating-summary > span {
  color: #9a958a !important;
  font-size: 14px !important;
}

.od67-review-list {
  min-width: 0;
  display: grid;
  gap: 12px;
}

.od67-review-card {
  min-height: 122px;
  padding: 20px 22px;
  display: grid;
  align-content: center;
  gap: 10px;
  border: 1px solid var(--od67-line);
  border-radius: 18px;
  background: #fff;
}

.od67-review-card-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
}

.od67-review-card-head > div:first-child {
  min-width: 0;
  display: grid;
  gap: 4px;
}

.od67-review-card-head strong {
  color: #171814;
  font-size: 15px;
  font-weight: 900;
}

.od67-review-card-head span {
  color: #9d988e;
  font-size: 14px;
}

.od67-review-card-score {
  flex: 0 0 auto;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--od67-gold);
  direction: ltr;
}

.od67-review-card-score b {
  color: #5f5b52;
  font-family: Arial, sans-serif;
  font-size: 14px;
}

.od67-review-card > p {
  margin: 0;
  color: #878278;
  font-size: 14px;
  line-height: 1.8;
}

.od67-review-card > small {
  color: #aaa499;
  font-size: 14px;
}

.od67-review-card-market .od67-review-card-head > svg {
  flex: 0 0 auto;
  color: var(--od67-gold-deep);
}

.od67-review-card-market p.is-fair { color: #4f765c; }
.od67-review-card-market p.is-high { color: #9b5d52; }

.od67-review-card .od67-star-rate {
  margin-top: 2px;
}

.od67-rating-thanks {
  color: #4f765c !important;
  font-weight: 800;
}

@media (max-width: 820px) {
  .od67-reviews-panel {
    grid-template-columns: 1fr !important;
  }

  .od67-rating-summary {
    min-height: 190px !important;
  }
}
'''

css_path.write_text(css, encoding='utf-8')
PY

# Preserve the original product data source byte-for-byte.
[ "$OFFERS_SHA" = "$(sha256sum "$OFFERS" | awk '{print $1}')" ] || { echo 'ERROR: mockOffers.js changed unexpectedly' >&2; false; }

# Validate only source-derived review content is used.
grep -q 'od67-review-list' "$JSX"
grep -q 'offer.reviewCount' "$JSX"
grep -q 'offer.rating' "$JSX"
grep -q 'offer.storeNameAr' "$JSX"
grep -q 'offer.storeCityAr' "$JSX"
grep -q 'offer.marketPrice' "$JSX"
grep -q 'OFFER DETAIL REVIEWS — REFERENCE MATCH V2' "$CSS"

trap - ERR

echo 'OFFER_DETAIL_REVIEWS_REFERENCE_V2_READY'
echo 'REVIEWS_LAYOUT_MATCHED_WITHOUT_INVENTED_WRITTEN_REVIEWS'
echo 'ORIGINAL_REVIEW_SUMMARY_DATA_PRESERVED'
echo 'OFFER_DETAIL_REVIEWS_REFERENCE_V2_APPLIED'
echo 'CHANGED_FILES:'
echo '  src/pages/OfferDetailPage.jsx'
echo '  src/pages/OfferDetailPage.css'
