#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
JSX="$ROOT/src/pages/WorkshopsPage.jsx"
CSS="$ROOT/src/pages/WorkshopsPage.css"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/tmp/67-workshops-booking-modal-v1-$STAMP"

cd "$ROOT"

for f in "$JSX" "$CSS"; do
  [[ -f "$f" ]] || { echo "ERROR: missing required file: $f" >&2; exit 2301; }
done

grep -q "const workshops = \[" "$JSX" || { echo 'ERROR: original workshops data source missing' >&2; exit 2302; }
grep -q "name: 'مركز العناية الشاملة'" "$JSX" || { echo 'ERROR: original workshop 1 missing' >&2; exit 2303; }
grep -q "name: 'ورشة الخبراء الألمان'" "$JSX" || { echo 'ERROR: original workshop 2 missing' >&2; exit 2304; }
grep -q 'ws67-book-btn' "$JSX" || { echo 'ERROR: workshop booking button marker missing' >&2; exit 2305; }
grep -q 'className="ws67-page"' "$JSX" || { echo 'ERROR: redesigned workshops page marker missing' >&2; exit 2306; }

mkdir -p "$BACKUP"
cp -a "$JSX" "$BACKUP/WorkshopsPage.jsx"
cp -a "$CSS" "$BACKUP/WorkshopsPage.css"

# Protect every source file except the two intended targets.
find "$ROOT/src" -type f ! -path "$JSX" ! -path "$CSS" -print0 | sort -z | xargs -0 sha256sum > "$BACKUP/protected-src.sha256"
for f in "$ROOT/public/assets/hero-car.jpg" "$ROOT/public/assets/logo-67.png"; do
  [[ -f "$f" ]] && sha256sum "$f" >> "$BACKUP/protected-src.sha256"
done

rollback() {
  code=$?
  trap - ERR
  cp -f "$BACKUP/WorkshopsPage.jsx" "$JSX" || true
  cp -f "$BACKUP/WorkshopsPage.css" "$CSS" || true
  echo 'ERROR: WORKSHOPS_BOOKING_MODAL_V1 failed; target files restored' >&2
  exit "$code"
}
trap rollback ERR

python3 - <<'PY'
from pathlib import Path

p = Path('/67/src/pages/WorkshopsPage.jsx')
s = p.read_text(encoding='utf-8')

state_marker = "  const [activeSpecialty, setActiveSpecialty] = useState('all');\n"
state_insert = """  const [activeSpecialty, setActiveSpecialty] = useState('all');
  const [bookingWorkshop, setBookingWorkshop] = useState(null);
  const [bookingDate, setBookingDate] = useState('');
  const [bookingTime, setBookingTime] = useState('');
  const [bookingDraftReady, setBookingDraftReady] = useState(false);

  const openBooking = (shop) => {
    setBookingWorkshop(shop);
    setBookingDate('');
    setBookingTime('');
    setBookingDraftReady(false);
  };

  const closeBooking = () => {
    setBookingWorkshop(null);
    setBookingDate('');
    setBookingTime('');
    setBookingDraftReady(false);
  };

  const confirmBookingDraft = () => {
    if (!bookingWorkshop || !bookingDate || !bookingTime) return;
    setBookingDraftReady(true);
  };
"""

if 'WORKSHOPS_BOOKING_MODAL_V1' not in s:
    if state_marker not in s:
        raise SystemExit('ERROR: workshops state insertion marker not found')
    s = s.replace(state_marker, state_insert, 1)

    old_button = '''                    <button type="button" className="ws67-book-btn">\n                      <CalendarClock size={17} /> حجز موعد\n                    </button>'''
    new_button = '''                    <button type="button" className="ws67-book-btn" onClick={() => openBooking(shop)}>\n                      <CalendarClock size={17} /> حجز موعد\n                    </button>'''
    if old_button not in s:
        raise SystemExit('ERROR: booking button replacement marker not found')
    s = s.replace(old_button, new_button, 1)

    modal = '''\n\n      {/* WORKSHOPS_BOOKING_MODAL_V1 */}
      {bookingWorkshop && (
        <div className="ws67-booking-overlay" role="presentation" onMouseDown={closeBooking}>
          <section
            className="ws67-booking-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="ws67-booking-title"
            onMouseDown={(event) => event.stopPropagation()}
          >
            <button
              type="button"
              className="ws67-booking-close"
              aria-label="إغلاق نافذة الحجز"
              onClick={closeBooking}
            >
              ×
            </button>

            <p className="ws67-booking-kicker">حجز ورشة</p>
            <h2 id="ws67-booking-title">احجز في {bookingWorkshop.name}</h2>
            <p className="ws67-booking-intro">
              اختار اليوم والوقت المناسبين لك. المشروع الحالي لا يحتوي على مواعيد متاحة من API، لذلك لن نعرض أوقاتاً وهمية.
            </p>

            <div className="ws67-booking-fields">
              <label>
                <span>اليوم</span>
                <input
                  type="date"
                  value={bookingDate}
                  onChange={(event) => {
                    setBookingDate(event.target.value);
                    setBookingDraftReady(false);
                  }}
                />
              </label>

              <label>
                <span>الوقت</span>
                <input
                  type="time"
                  value={bookingTime}
                  onChange={(event) => {
                    setBookingTime(event.target.value);
                    setBookingDraftReady(false);
                  }}
                />
              </label>
            </div>

            {bookingDraftReady && (
              <div className="ws67-booking-note" role="status">
                تم اختيار الموعد داخل الشاشة. التأكيد النهائي يحتاج ربط خدمة الحجز الفعلية بالمشروع.
              </div>
            )}

            <button
              type="button"
              className="ws67-booking-confirm"
              disabled={!bookingDate || !bookingTime}
              onClick={confirmBookingDraft}
            >
              تأكيد الحجز
            </button>
          </section>
        </div>
      )}
'''

    target = '''      </main>\n\n      <BottomNav />'''
    if target not in s:
        raise SystemExit('ERROR: booking modal mount marker not found')
    s = s.replace(target, '      </main>' + modal + '\n      <BottomNav />', 1)

p.write_text(s, encoding='utf-8')
PY

cat >> "$CSS" <<'CSS'

/* WORKSHOPS_BOOKING_MODAL_V1 */
.ws67-booking-overlay {
  position: fixed;
  inset: 0;
  z-index: 5000;
  display: grid;
  place-items: center;
  padding: 24px;
  background: rgba(10, 11, 9, .56);
  backdrop-filter: blur(2px);
  -webkit-backdrop-filter: blur(2px);
}

.ws67-booking-modal {
  position: relative;
  width: min(560px, 100%);
  padding: 34px 34px 32px;
  border: 1px solid #e9e3d7;
  border-radius: 24px;
  background: #fff;
  color: #171713;
  box-shadow: 0 30px 80px rgba(0, 0, 0, .20);
  direction: rtl;
}

.ws67-booking-close {
  position: absolute;
  top: 20px;
  left: 20px;
  width: 42px;
  height: 42px;
  border: 0;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: #f4f1e8;
  color: #171713;
  cursor: pointer;
  font-size: 25px;
  line-height: 1;
  font-weight: 500;
}

.ws67-booking-kicker {
  margin: 0 0 12px;
  color: var(--ws67-gold-deep);
  font-size: 14px;
  font-weight: 900;
}

.ws67-booking-modal h2 {
  max-width: calc(100% - 56px);
  margin: 0;
  color: #171713;
  font-size: clamp(28px, 3vw, 36px);
  line-height: 1.3;
}

.ws67-booking-intro {
  margin: 12px 0 24px;
  color: #817b70;
  font-size: 14px;
  line-height: 1.8;
}

.ws67-booking-fields {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.ws67-booking-fields label {
  display: grid;
  gap: 8px;
}

.ws67-booking-fields label > span {
  color: #918b80;
  font-size: 14px;
  font-weight: 700;
}

.ws67-booking-fields input {
  width: 100%;
  min-height: 56px;
  padding: 0 14px;
  border: 1px solid #e5dfd3;
  border-radius: 12px;
  outline: none;
  background: #fbfaf6;
  color: #171713;
  font-size: 15px;
}

.ws67-booking-fields input:focus {
  border-color: var(--ws67-gold);
  box-shadow: 0 0 0 3px rgba(214, 174, 40, .10);
}

.ws67-booking-note {
  margin-top: 14px;
  padding: 12px 14px;
  border: 1px solid #eadca7;
  border-radius: 10px;
  background: #fff9e7;
  color: #695b2a;
  font-size: 14px;
  line-height: 1.7;
}

.ws67-booking-confirm {
  width: 100%;
  min-height: 58px;
  margin-top: 18px;
  border: 0;
  border-radius: 12px;
  background: #171814;
  color: #fff;
  cursor: pointer;
  font-size: 16px;
  font-weight: 900;
}

.ws67-booking-confirm:disabled {
  cursor: not-allowed;
  opacity: .42;
}

@media (max-width: 620px) {
  .ws67-booking-overlay {
    padding: 14px;
  }

  .ws67-booking-modal {
    padding: 28px 20px 22px;
    border-radius: 20px;
  }

  .ws67-booking-fields {
    grid-template-columns: 1fr;
  }

  .ws67-booking-modal h2 {
    padding-left: 42px;
    max-width: none;
    font-size: 27px;
  }
}
CSS

# Validate exact original workshop records remain untouched and only user-entered date/time were added.
grep -q "{ id: 1, name: 'مركز العناية الشاملة', rating: 4.7, reviews: 124, distance: '3 كم', specialized: 'ميكانيكا عامة', price: '\$\$' }" "$JSX"
grep -q "{ id: 2, name: 'ورشة الخبراء الألمان', rating: 4.9, reviews: 89, distance: '5 كم', specialized: 'سيارات ألمانية', price: '\$\$\$' }" "$JSX"
grep -q 'WORKSHOPS_BOOKING_MODAL_V1' "$JSX"
grep -q 'type="date"' "$JSX"
grep -q 'type="time"' "$JSX"
grep -q 'المشروع الحالي لا يحتوي على مواعيد متاحة من API' "$JSX"
grep -q 'WORKSHOPS_BOOKING_MODAL_V1' "$CSS"

# Ensure no fake reference workshop names or fake slot values were introduced.
for forbidden in 'Prime Auto' 'Volt Garage' 'Cool Drive Center' 'Stop+ Workshop' '5:30 م' '7:00 م'; do
  if grep -Fq "$forbidden" "$JSX"; then
    echo "ERROR: invented booking/reference value detected: $forbidden" >&2
    false
  fi
done

sha256sum -c "$BACKUP/protected-src.sha256" >/dev/null || { echo 'ERROR: protected source file changed unexpectedly' >&2; false; }

trap - ERR
rm -rf "$BACKUP"

echo 'WORKSHOPS_BOOKING_MODAL_V1_APPLIED'
echo 'BOOKING_MODAL_USES_SELECTED_ORIGINAL_WORKSHOP'
echo 'BOOKING_DATE_TIME_START_EMPTY'
echo 'NO_FAKE_BOOKING_SLOTS_OR_API_ADDED'
echo 'ORIGINAL_WORKSHOP_DATA_PRESERVED'
echo 'OTHER_SOURCE_FILES_UNCHANGED'
echo 'CHANGED_FILES:'
echo '  src/pages/WorkshopsPage.jsx'
echo '  src/pages/WorkshopsPage.css'
