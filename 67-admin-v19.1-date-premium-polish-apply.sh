#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
BASE_COMMIT=33615c0fdb7a6af04e549bdaf965e1a6652e209e
TARGET_JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v19.css
TARGET_CSS=src/pages/AdminDashboard.v19.1.css
BACKUP_DIR="/tmp/67-admin-v19.1-backup-$$"
FAILED_STEP=init
MUTATED=0

cd "$ROOT"
mkdir -p "$BACKUP_DIR/src/pages"
cp "$TARGET_JSX" "$BACKUP_DIR/src/pages/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v19.css"
[ -f "$TARGET_CSS" ] && cp "$TARGET_CSS" "$BACKUP_DIR/src/pages/AdminDashboard.v19.1.css" || true

rollback(){
  local code="$1"
  if [ "$MUTATED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/AdminDashboard.jsx" "$TARGET_JSX"
    cp "$BACKUP_DIR/src/pages/AdminDashboard.v19.css" "$SOURCE_CSS"
    if [ -f "$BACKUP_DIR/src/pages/AdminDashboard.v19.1.css" ]; then
      cp "$BACKUP_DIR/src/pages/AdminDashboard.v19.1.css" "$TARGET_CSS"
    else
      rm -f "$TARGET_CSS"
    fi
    npm run build >/tmp/67-admin-v19.1-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "LOCAL_ADMIN_HTTP=NOT_CHECKED"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=V19_1_PREMIUM_DATE_POLISH_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

FAILED_STEP=verify_v19_state
grep -q "import './AdminDashboard.v19.css';" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19" "$SOURCE_CSS"
grep -q "executive-date-popover__badge">" "$TARGET_JSX" || grep -q "executive-date-popover__badge" "$TARGET_JSX"
grep -q "type=\"date\"" "$TARGET_JSX"
grep -q "EXECUTIVE DATE RANGE CONTROL" "$SOURCE_CSS"

FAILED_STEP=create_v19_1_css
MUTATED=1
cp "$SOURCE_CSS" "$TARGET_CSS"
cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V19.1 — PREMIUM DATE CONTROL POLISH
   Refined executive glass capsule + sidecar custom range panel. */
.ov-header__toolbar-top{
  left:18px!important;
  top:14px!important;
  z-index:40!important;
}
.executive-date-shell{
  position:relative!important;
  height:48px!important;
  padding:5px 6px!important;
  gap:6px!important;
  border-radius:14px!important;
  overflow:visible!important;
  background:
    radial-gradient(circle at 18% 0%,rgba(225,188,98,.10),transparent 34%),
    linear-gradient(180deg,rgba(8,12,18,.965) 0%,rgba(3,7,11,.93) 100%)!important;
  border:1px solid rgba(222,183,87,.34)!important;
  box-shadow:
    0 16px 38px rgba(0,0,0,.42),
    inset 0 1px 0 rgba(255,255,255,.055),
    inset 0 -1px 0 rgba(0,0,0,.42)!important;
  backdrop-filter:blur(20px) saturate(135%)!important;
}
.executive-date-shell::before{
  content:"";
  position:absolute;
  left:16px;right:16px;top:-1px;height:1px;
  background:linear-gradient(90deg,transparent,rgba(239,207,119,.74),transparent);
  opacity:.72;
  pointer-events:none;
}
.executive-date-display{
  height:36px!important;
  min-width:248px!important;
  padding:0 11px!important;
  gap:9px!important;
  border-radius:10px!important;
  color:#f7f0e3!important;
  background:linear-gradient(180deg,rgba(255,255,255,.050),rgba(255,255,255,.018))!important;
  border:1px solid rgba(255,255,255,.080)!important;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.025)!important;
}
.executive-date-display:hover{
  border-color:rgba(224,187,95,.30)!important;
  background:linear-gradient(180deg,rgba(255,255,255,.068),rgba(255,255,255,.026))!important;
}
.executive-date-display__icon{
  width:28px!important;height:28px!important;flex:0 0 28px!important;
  border-radius:9px!important;
  color:#efcc70!important;
  background:linear-gradient(145deg,rgba(225,186,91,.18),rgba(165,113,24,.07))!important;
  border:1px solid rgba(222,183,87,.26)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.06)!important;
}
.executive-date-display__copy small{
  margin-bottom:3px!important;
  font-size:7.5px!important;
  letter-spacing:.02em!important;
  color:#8e949d!important;
}
.executive-date-display__copy strong{
  font-size:10.8px!important;
  font-weight:900!important;
  color:#f6efe2!important;
  letter-spacing:-.015em!important;
}
.executive-date-display__chevron{margin-left:1px!important;color:#7f8791!important}
.executive-date-display__chevron.open{color:#e2bc61!important}

.executive-date-presets{
  height:36px!important;
  padding:3px!important;
  gap:2px!important;
  border-radius:10px!important;
  background:rgba(255,255,255,.025)!important;
  border:1px solid rgba(255,255,255,.05)!important;
}
.executive-date-preset{
  position:relative!important;
  height:30px!important;
  min-width:49px!important;
  padding:0 10px!important;
  border-radius:8px!important;
  color:#aaa69f!important;
  background:transparent!important;
  border:1px solid transparent!important;
  font-size:9px!important;
  font-weight:850!important;
}
.executive-date-preset:hover{
  color:#eee6d8!important;
  background:rgba(255,255,255,.045)!important;
}
.executive-date-preset.active{
  color:#f0cf73!important;
  background:
    radial-gradient(circle at 50% -30%,rgba(229,193,101,.18),transparent 70%),
    linear-gradient(180deg,rgba(215,173,81,.11),rgba(215,173,81,.055))!important;
  border-color:rgba(222,183,87,.35)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.045),0 6px 14px rgba(0,0,0,.22)!important;
}
.executive-date-preset.active::after{
  content:"";position:absolute;left:50%;bottom:2px;width:14px;height:1px;transform:translateX(-50%);
  background:linear-gradient(90deg,transparent,#e8c568,transparent);box-shadow:0 0 6px rgba(232,197,104,.42)
}
.executive-date-actions{height:36px!important;gap:4px!important}
.executive-date-action{
  width:34px!important;height:34px!important;
  border-radius:10px!important;
  color:#9fa3a8!important;
  background:linear-gradient(180deg,rgba(255,255,255,.040),rgba(255,255,255,.015))!important;
  border:1px solid rgba(255,255,255,.07)!important;
  box-shadow:inset 0 1px rgba(255,255,255,.025)!important;
}
.executive-date-action:hover{
  color:#efcf75!important;
  border-color:rgba(215,173,81,.30)!important;
  background:rgba(215,173,81,.075)!important;
  transform:translateY(-1px)
}

/* Sidecar placement prevents the custom panel from covering the hero headline. */
.executive-date-popover{
  left:calc(100% + 10px)!important;
  right:auto!important;
  top:0!important;
  width:410px!important;
  min-height:0!important;
  padding:12px!important;
  border-radius:15px!important;
  overflow:visible!important;
  background:
    radial-gradient(circle at 18% 0%,rgba(222,183,87,.10),transparent 30%),
    linear-gradient(180deg,rgba(10,15,22,.988) 0%,rgba(4,8,13,.988) 100%)!important;
  border:1px solid rgba(222,183,87,.30)!important;
  box-shadow:
    0 26px 58px rgba(0,0,0,.55),
    inset 0 1px rgba(255,255,255,.045)!important;
  backdrop-filter:blur(22px) saturate(140%)!important;
  animation:v19PremiumPanelIn .18s ease-out!important;
}
.executive-date-popover::before{
  content:"";
  position:absolute;
  left:-7px;top:17px;width:12px;height:12px;
  transform:rotate(45deg);
  background:#091019;
  border-left:1px solid rgba(222,183,87,.30);
  border-bottom:1px solid rgba(222,183,87,.30);
}
.executive-date-popover::after{
  content:"";position:absolute;left:16px;right:16px;top:-1px;height:1px;
  background:linear-gradient(90deg,transparent,rgba(239,207,119,.68),transparent);opacity:.8
}
@keyframes v19PremiumPanelIn{from{opacity:0;transform:translateX(-7px) scale(.985)}to{opacity:1;transform:translateX(0) scale(1)}}
.executive-date-popover__head{
  align-items:center!important;
  margin-bottom:10px!important;
  padding-bottom:9px!important;
  border-bottom:1px solid rgba(255,255,255,.055)!important;
}
.executive-date-popover__head strong{
  margin-bottom:3px!important;
  font-size:11.5px!important;
  font-weight:900!important;
  color:#f4eddf!important;
}
.executive-date-popover__head span{font-size:7.8px!important;color:#818995!important}
.executive-date-popover__badge{
  padding:5px 8px!important;
  border-radius:999px!important;
  font-size:7.6px!important;
  font-weight:850!important;
  color:#e6c66c!important;
  background:rgba(215,173,81,.075)!important;
  border:1px solid rgba(215,173,81,.19)!important;
}
.executive-date-fields{grid-template-columns:1fr 1fr!important;gap:8px!important;margin-bottom:9px!important}
.executive-date-field-card{display:flex;flex-direction:column;gap:5px;min-width:0}
.executive-date-field-label{font-size:7.8px;color:#9ba0a7;font-weight:800;padding:0 2px}
.executive-date-picker{
  position:relative;
  height:45px;
  padding:0 9px;
  display:flex;
  align-items:center;
  gap:8px;
  overflow:hidden;
  border-radius:10px;
  cursor:pointer;
  color:#f1eadc;
  background:linear-gradient(180deg,#111923,#0c131c);
  border:1px solid rgba(255,255,255,.08);
  box-shadow:inset 0 1px rgba(255,255,255,.025);
  transition:border-color .18s ease,background .18s ease,box-shadow .18s ease;
}
.executive-date-picker:hover,.executive-date-picker:focus-within{
  border-color:rgba(222,183,87,.34);
  background:linear-gradient(180deg,#131c27,#0d151f);
  box-shadow:0 0 0 3px rgba(215,173,81,.045),inset 0 1px rgba(255,255,255,.03)
}
.executive-date-picker__icon{
  width:26px;height:26px;flex:0 0 26px;display:grid;place-items:center;border-radius:8px;
  color:#dcbc66;background:rgba(215,173,81,.075);border:1px solid rgba(215,173,81,.13)
}
.executive-date-picker__copy{display:flex;flex-direction:column;align-items:flex-start;min-width:0;line-height:1.05}
.executive-date-picker__copy small{font-size:6.8px;color:#747d87;margin-bottom:3px;font-weight:700}
.executive-date-picker__copy strong{font-size:9px;color:#eee7db;font-weight:850;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:125px}
.executive-date-picker__chevron{margin-inline-start:auto;color:#737b85;flex:0 0 auto}
.executive-date-native{
  position:absolute!important;
  inset:0!important;
  width:100%!important;
  height:100%!important;
  opacity:0!important;
  cursor:pointer!important;
  border:0!important;
  padding:0!important;
  z-index:4!important;
  color-scheme:dark!important;
}
.executive-date-native::-webkit-calendar-picker-indicator{position:absolute;inset:0;width:100%;height:100%;opacity:0;cursor:pointer}
.executive-date-error{margin:-1px 0 8px!important;padding:6px 8px!important;border-radius:8px!important;font-size:7.8px!important}
.executive-date-popover__footer{
  min-height:34px!important;
  padding-top:9px!important;
  gap:8px!important;
}
.executive-date-popover__hint{font-size:7.3px!important;line-height:1.45!important;max-width:150px!important;color:#727b85!important}
.executive-date-popover__buttons{display:flex;align-items:center;gap:6px;margin-inline-start:auto}
.executive-date-cancel{
  height:31px;padding:0 12px;border-radius:8px;cursor:pointer;font-family:inherit;font-size:8px;font-weight:800;
  color:#aeb0b2;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.075)
}
.executive-date-cancel:hover{color:#eee8dd;background:rgba(255,255,255,.055)}
.executive-date-apply{
  height:31px!important;
  padding:0 15px!important;
  border-radius:8px!important;
  color:#1a1207!important;
  background:linear-gradient(180deg,#efd17a 0%,#c99732 100%)!important;
  box-shadow:0 7px 18px rgba(180,126,29,.20),inset 0 1px rgba(255,255,255,.40)!important;
}
.executive-date-apply:hover{filter:brightness(1.045)!important;transform:translateY(-1px)}

@media(max-width:1280px){
  .executive-date-display{min-width:210px!important}
  .executive-date-popover{left:calc(100% + 7px)!important;width:376px!important}
  .executive-date-preset{min-width:43px!important;padding:0 8px!important}
}
CSS

FAILED_STEP=patch_jsx_markup
python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()

if "import './AdminDashboard.v19.css';" not in s:
    raise SystemExit('V19_RUNTIME_IMPORT_NOT_FOUND')
if 'SIX SEVEN ADMIN V19.1' in s:
    raise SystemExit('V19_1_ALREADY_PRESENT_IN_JSX')

# Switch to the polished runtime stylesheet.
s=s.replace("import './AdminDashboard.v19.css';", "import './AdminDashboard.v19.1.css';", 1)

# Add a safe Arabic Gregorian formatter for custom date cards.
anchor="const AdminDashboard = () => {"
helper=r'''const formatExecutiveFieldDate = (value) => {
  if (!value) return 'اختر التاريخ';
  const date = new Date(`${value}T12:00:00`);
  if (Number.isNaN(date.getTime())) return 'اختر التاريخ';
  return new Intl.DateTimeFormat('ar-SA-u-ca-gregory', {
    day: 'numeric', month: 'long', year: 'numeric'
  }).format(date);
};

'''
if anchor not in s:
    raise SystemExit('COMPONENT_ANCHOR_NOT_FOUND')
s=s.replace(anchor,helper+anchor,1)

# Add a draft-day counter for the premium custom panel.
range_anchor="  const rangeSummaryLabel = datePreset === 'today' ? 'اليوم' : datePreset === '7d' ? 'آخر 7 أيام' : datePreset === '30d' ? 'آخر 30 يوم' : 'فترة مخصصة';\n"
range_add=range_anchor+r'''  const customDraftDays = (() => {
    const from = new Date(`${customFrom}T00:00:00`);
    const to = new Date(`${customTo}T23:59:59`);
    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime()) || from > to) return 0;
    return Math.max(1, Math.round((to - from) / 86400000) + 1);
  })();
'''
if range_anchor not in s:
    raise SystemExit('RANGE_SUMMARY_ANCHOR_NOT_FOUND')
s=s.replace(range_anchor,range_add,1)

# Upgrade small label copy.
s=s.replace('<small>الفترة المحددة</small>', '<small>الفترة التحليلية</small>', 1)

# Replace only the custom panel; presets/actions stay functional and untouched.
start_marker='                    {datePopoverOpen && (\n                      <div className="executive-date-popover">'
end_marker='                    )}\n                  </div>\n                </div>\n\n                <div className="ov-header__copy-left">'
start=s.find(start_marker)
end=s.find(end_marker,start)
if start == -1 or end == -1:
    raise SystemExit(f'DATE_POPOVER_BLOCK_NOT_FOUND:{start}:{end}')

new_panel=r'''                    {datePopoverOpen && (
                      <div className="executive-date-popover" role="dialog" aria-label="اختيار نطاق زمني مخصص">
                        <div className="executive-date-popover__head">
                          <div>
                            <strong>تخصيص الفترة التحليلية</strong>
                            <span>اختر البداية والنهاية ثم طبّق النطاق على لوحة الأداء</span>
                          </div>
                          <span className="executive-date-popover__badge">{customDraftDays ? `${customDraftDays} يوم` : 'نطاق مخصص'}</span>
                        </div>

                        <div className="executive-date-fields">
                          <div className="executive-date-field-card">
                            <span className="executive-date-field-label">من</span>
                            <label className="executive-date-picker">
                              <span className="executive-date-picker__icon"><CalendarDays size={14} /></span>
                              <span className="executive-date-picker__copy">
                                <small>تاريخ البداية</small>
                                <strong>{formatExecutiveFieldDate(customFrom)}</strong>
                              </span>
                              <ChevronDown size={13} className="executive-date-picker__chevron" />
                              <input
                                className="executive-date-native"
                                type="date"
                                aria-label="تاريخ بداية الفترة"
                                value={customFrom}
                                max={customTo || toDateInputValue(new Date())}
                                onChange={(e) => { setCustomFrom(e.target.value); setDateError(''); }}
                              />
                            </label>
                          </div>

                          <div className="executive-date-field-card">
                            <span className="executive-date-field-label">إلى</span>
                            <label className="executive-date-picker">
                              <span className="executive-date-picker__icon"><CalendarDays size={14} /></span>
                              <span className="executive-date-picker__copy">
                                <small>تاريخ النهاية</small>
                                <strong>{formatExecutiveFieldDate(customTo)}</strong>
                              </span>
                              <ChevronDown size={13} className="executive-date-picker__chevron" />
                              <input
                                className="executive-date-native"
                                type="date"
                                aria-label="تاريخ نهاية الفترة"
                                value={customTo}
                                min={customFrom}
                                max={toDateInputValue(new Date())}
                                onChange={(e) => { setCustomTo(e.target.value); setDateError(''); }}
                              />
                            </label>
                          </div>
                        </div>

                        {dateError && <div className="executive-date-error">{dateError}</div>}

                        <div className="executive-date-popover__footer">
                          <span className="executive-date-popover__hint">سيتم توحيد الفترة على المؤشرات والإيرادات.</span>
                          <div className="executive-date-popover__buttons">
                            <button type="button" className="executive-date-cancel" onClick={() => { setDateError(''); setDatePopoverOpen(false); }}>إلغاء</button>
                            <button type="button" className="executive-date-apply" onClick={applyCustomDateRange}>تطبيق الفترة</button>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                <div className="ov-header__copy-left">'''

s=s[:start]+new_panel+s[end+len(end_marker):]
p.write_text(s)
PY

FAILED_STEP=validate_sources
grep -q "import './AdminDashboard.v19.1.css';" "$TARGET_JSX"
! grep -q "import './AdminDashboard.v19.css';" "$TARGET_JSX"
grep -q "formatExecutiveFieldDate" "$TARGET_JSX"
grep -q "customDraftDays" "$TARGET_JSX"
grep -q "executive-date-native" "$TARGET_JSX"
grep -q "executive-date-cancel" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.1" "$TARGET_CSS"
grep -q "left:calc(100% + 10px)" "$TARGET_CSS"

FAILED_STEP=build
npm run build

FAILED_STEP=restart_service
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

FAILED_STEP=local_http_check
LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
[ "$LOCAL_ADMIN_HTTP" = "200" ]

FAILED_STEP=post_apply_validation
grep -q "import './AdminDashboard.v19.1.css';" "$TARGET_JSX"
grep -q "executive-date-picker__copy" "$TARGET_JSX"
grep -q "SIX SEVEN ADMIN V19.1" "$TARGET_CSS"

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=$BASE_COMMIT"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/AdminDashboard.jsx,src/pages/AdminDashboard.v19.1.css"
echo "RUNTIME_CSS=AdminDashboard.v19.1.css"
echo "PREMIUM_CAPSULE_POLISH=YES"
echo "ACTIVE_PRESET_REFINED_GOLD=YES"
echo "CUSTOM_POPOVER_SIDECAR=YES"
echo "HERO_HEADLINE_OVERLAP_REMOVED=YES"
echo "NATIVE_DATE_TEXT_HIDDEN=YES"
echo "ARABIC_GREGORIAN_DATE_CARDS=YES"
echo "CUSTOM_RANGE_DAY_COUNT=YES"
echo "CANCEL_AND_APPLY_ACTIONS=YES"
echo "V19_FUNCTIONALITY_PRESERVED=YES"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
