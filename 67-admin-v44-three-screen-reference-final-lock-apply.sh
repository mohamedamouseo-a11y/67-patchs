#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
V43="$ROOT/src/pages/AdminDashboard.v43.css"
V44="$ROOT/src/pages/AdminDashboard.v44.css"

cd "$ROOT"

test -f "$JSX"
test -f "$V43"

grep -q "AdminDashboard.v43.css" "$JSX" || grep -q "AdminDashboard.v44.css" "$JSX"

cp "$V43" "$V44"

python3 - <<'PY'
from pathlib import Path
p = Path('/67/src/pages/AdminDashboard.jsx')
s = p.read_text()

s = s.replace("import './AdminDashboard.v43.css';", "import './AdminDashboard.v44.css';")

# Stable screen aliases for the final reference lock.
s = s.replace('v43-reference-screen v43-notifications-screen', 'v43-reference-screen v43-notifications-screen v44-notifications-screen')
s = s.replace('v43-reference-screen v43-github-screen', 'v43-reference-screen v43-github-screen v44-github-screen')
s = s.replace('v43-reference-screen v43-settings-screen', 'v43-reference-screen v43-settings-screen v44-settings-screen')
s = s.replace('className="v43-settings-card"', 'className="v43-settings-card v44-settings-card"')

# Settings reference: preserve every original field/action but add the left-side
# explanatory blocks visible in the approved reference.
logo_open = """<div style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>"""
logo_new = """<div className="v44-settings-section v44-settings-logo" style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <div className="v44-settings-aside"><span className="v44-settings-aside__icon"><Settings size={20} /></span><strong>تخصيص مظهر المنصة</strong><small>يمكنك تغيير نمط الشعار في أي وقت</small></div>"""
if logo_open in s:
    s = s.replace(logo_open, logo_new, 1)
elif 'v44-settings-logo' not in s:
    raise SystemExit('V44 logo settings anchor not found')

profile_open = """<div style={{ display: 'flex', alignItems: 'center', gap: '20px', background: '#F8FAFC', padding: '16px', borderRadius: '14px', border: '1px solid #E2E8F0' }}>"""
profile_new = """<div className="v44-settings-section v44-settings-profile" style={{ display: 'flex', alignItems: 'center', gap: '20px', background: '#F8FAFC', padding: '16px', borderRadius: '14px', border: '1px solid #E2E8F0' }}>
                  <div className="v44-settings-aside"><span className="v44-settings-aside__icon"><Users size={20} /></span><strong>صورتك الشخصية</strong><small>تظهر الصورة في ملفك الشخصي ومعاملاتك</small></div>"""
if profile_open in s:
    s = s.replace(profile_open, profile_new, 1)
elif 'v44-settings-profile' not in s:
    raise SystemExit('V44 profile settings anchor not found')

identity_open = """<div style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>"""
identity_new = """<div className="v44-settings-section v44-settings-identity" style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  <div className="v44-settings-aside"><span className="v44-settings-aside__icon"><ShieldCheck size={20} /></span><strong>حساب محمي وآمن</strong><small>بياناتك الشخصية مشفرة ومحفوظة</small></div>"""
if identity_open in s:
    s = s.replace(identity_open, identity_new, 1)
elif 'v44-settings-identity' not in s:
    raise SystemExit('V44 identity settings anchor not found')

bank_marker = """                {/* Bank Account Settings */}"""
if 'v44-settings-bank' not in s:
    if bank_marker not in s:
        raise SystemExit('V44 bank section anchor not found')
    s = s.replace(bank_marker, """                <section className="v44-settings-bank">
                  <div className="v44-settings-aside"><span className="v44-settings-aside__icon"><CreditCard size={20} /></span><strong>بيانات الحساب البنكي</strong><small>لاستلام أرباح العمولات بنسبة 1%</small></div>

                {/* Bank Account Settings */}""", 1)

    bank_tail = """                  </button>
                </div>

              </form>"""
    bank_tail_new = """                  </button>
                </div>
                </section>

              </form>"""
    if bank_tail not in s:
        raise SystemExit('V44 bank section closing anchor not found')
    s = s.replace(bank_tail, bank_tail_new, 1)

p.write_text(s)
PY

cat >> "$V44" <<'CSS'

/* ============================================================
   V44 — THREE SCREEN REFERENCE FINAL LOCK
   Manual visual review correction on top of V43.
   References: user-provided screen structure + approved generated visual targets.
   No fake rows, no data changes, no business-logic changes.
   ============================================================ */

/* ---------- NOTIFICATIONS: reference proportions ---------- */
.v44-notifications-screen{
  position:relative;
  padding:30px 24px 42px !important;
  border-top:2px solid rgba(12,27,38,.10) !important;
}
.v44-notifications-screen::after{
  content:"";
  position:absolute;
  left:0;
  bottom:0;
  width:46%;
  height:240px;
  pointer-events:none;
  opacity:.5;
  background:repeating-radial-gradient(ellipse at 10% 110%,transparent 0 32px,rgba(206,166,46,.07) 33px 34px,transparent 35px 48px);
}
.v44-notifications-screen>div:first-child{
  min-height:66px;
  align-items:flex-start !important;
  padding-bottom:14px;
}
.v44-notifications-screen>div:first-child h3{
  position:relative;
  padding-bottom:22px;
  font-size:20px !important;
}
.v44-notifications-screen>div:first-child h3::after{
  content:"مراقبة فورية لجميع الأحداث في المنصة";
  position:absolute;
  right:28px;
  bottom:0;
  color:#77879a;
  font-size:11px;
  font-weight:600;
  white-space:nowrap;
}
.v44-notifications-screen>div:first-child button{
  min-width:150px;
  min-height:48px;
  justify-content:center;
  font-size:14px !important;
}
.v44-notifications-screen>div:nth-child(2){gap:12px !important}
.v44-notifications-screen>div:nth-child(2)>div{
  min-height:90px;
  padding:22px 70px !important;
  border-radius:16px !important;
}
.v44-notifications-screen>div:nth-child(2)>div::before{right:24px;width:12px;height:12px}
.v44-notifications-screen>div:nth-child(2)>div::after{left:28px;font-size:28px}
.v44-notifications-screen>div:nth-child(2)>div>div span{font-size:17px !important;line-height:1.55}
.v44-notifications-screen>div:nth-child(2)>div>span{font-size:13px !important}

/* ---------- GITHUB: keep V43 composition, lock reference viewport ---------- */
.v44-github-screen .v43-screen-hero{height:182px;min-height:182px;margin-bottom:14px}
.v44-github-screen .sa-shell-embedded{padding:24px 24px 30px}
.v44-github-screen .sa-module-heading{min-height:90px}
.v44-github-screen .sa-grid.three{gap:18px}
.v44-github-screen .sa-metric{min-height:122px}
.v44-github-screen .sa-content-stack>.sa-card{min-height:196px}
.v44-github-screen .sa-content-stack>.sa-grid.two{min-height:330px;align-items:stretch}
.v44-github-screen .sa-content-stack>.sa-grid.two>.sa-card{min-height:330px}
.v44-github-screen .sa-security-grid{row-gap:12px}

/* ---------- SETTINGS: explicit reference information architecture ---------- */
.v44-settings-screen .v43-screen-hero{height:176px;min-height:176px}
.v44-settings-card{padding:20px 18px 24px !important}
.v44-settings-card>h3{font-size:21px !important;min-height:50px;margin-bottom:14px !important}
.v44-settings-card form{gap:14px !important}

.v44-settings-section,
.v44-settings-bank{
  position:relative !important;
  overflow:hidden;
  border:1px solid #dbe3e9 !important;
  border-radius:14px !important;
  background:linear-gradient(90deg,#fff 0%,#fff 78%,#fffdf7 100%) !important;
  box-shadow:0 3px 11px rgba(15,23,42,.025) !important;
  padding-left:255px !important;
}
.v44-settings-section{min-height:124px;padding-top:18px !important;padding-bottom:18px !important}
.v44-settings-profile{min-height:132px}
.v44-settings-identity{min-height:124px}

.v44-settings-aside{
  position:absolute;
  left:18px;
  top:16px;
  bottom:16px;
  width:210px;
  display:flex;
  flex-direction:column;
  justify-content:center;
  align-items:flex-start;
  gap:4px;
  direction:rtl;
  text-align:right;
  color:#14243a;
  pointer-events:none;
}
.v44-settings-aside__icon{
  width:46px;
  height:46px;
  display:grid;
  place-items:center;
  border-radius:11px;
  border:1px solid #efdfad;
  background:#fff8e8;
  color:#b8870f;
  margin-bottom:5px;
}
.v44-settings-aside strong{font-size:14px;font-weight:900;color:#172943}
.v44-settings-aside small{font-size:11px;line-height:1.55;color:#75859a;max-width:190px}

/* V43 icon-only pseudo blocks are replaced by the real V44 descriptor blocks. */
.v44-settings-logo::before,
.v44-settings-identity::before{display:none !important;content:none !important}

.v44-settings-logo h4,.v44-settings-logo p,.v44-settings-logo>div:not(.v44-settings-aside){margin-right:0}
.v44-settings-logo .theme-select-btn{min-width:144px;min-height:42px}

.v44-settings-profile>div:not(.v44-settings-aside){position:relative;z-index:1}
.v44-settings-profile>div:nth-of-type(2){flex:1}
.v44-settings-profile img{width:76px !important;height:76px !important;background:#fff8e8}

.v44-settings-identity>div:not(.v44-settings-aside){position:relative;z-index:1}
.v44-settings-identity{justify-content:center}

.v44-settings-bank{
  min-height:260px;
  padding:18px 20px 18px 275px !important;
}
.v44-settings-bank>.v44-settings-aside{left:18px;top:18px;bottom:18px;width:220px}
.v44-settings-bank>h4{
  margin:0 0 14px !important;
  padding:0 0 12px !important;
  border:0 !important;
  border-bottom:1px solid #edf0f3 !important;
  border-radius:0 !important;
  background:transparent !important;
  color:#17243a !important;
}
.v44-settings-bank>div:not(.v44-settings-aside){
  border:0 !important;
  background:transparent !important;
  padding:0 !important;
}
.v44-settings-bank>div:nth-last-child(2){margin-top:14px !important}
.v44-settings-bank>div:last-child{margin-top:18px !important;justify-content:flex-start !important}
.v44-settings-bank button[type="submit"]{min-width:260px;min-height:50px}
.v44-settings-bank input{min-height:46px}

@media (max-width:1200px){
  .v44-settings-section,.v44-settings-bank{padding-left:220px !important}
  .v44-settings-aside{width:175px}
}
CSS

# Guards
[ "$(grep -c "AdminDashboard.v44.css" "$JSX")" -eq 1 ]
grep -q "v44-notifications-screen" "$JSX"
grep -q "v44-github-screen" "$JSX"
grep -q "v44-settings-screen" "$JSX"
grep -q "v44-settings-logo" "$JSX"
grep -q "v44-settings-profile" "$JSX"
grep -q "v44-settings-identity" "$JSX"
grep -q "v44-settings-bank" "$JSX"

npm run build

echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "RUNTIME_CSS=AdminDashboard.v44.css"
echo "VISUAL_STRATEGY=THREE_SCREEN_REFERENCE_FINAL_LOCK"
echo "NOTIFICATIONS_REFERENCE_PROPORTIONS_REFINED=YES"
echo "GITHUB_REFERENCE_VIEWPORT_REFINED=YES"
echo "SETTINGS_REFERENCE_INFORMATION_ARCHITECTURE=YES"
echo "FAKE_ROWS_ADDED=NO"
echo "DATA_CHANGED=NO"
echo "LOGIC_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
