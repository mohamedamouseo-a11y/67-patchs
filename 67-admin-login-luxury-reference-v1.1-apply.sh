#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
export ROOT
JSX="$ROOT/src/pages/AdminDashboard.jsx"
CSS="$ROOT/src/pages/AdminDashboard.login-luxury-v1.1.css"
BACKUP="$(mktemp -d /tmp/67-admin-login-luxury-v1.1.XXXXXX)"
CSS_EXISTED=0

cd "$ROOT"
test -f "$JSX"
test -f "$ROOT/src/assets/admin-v29.4-hero-highres.jpg"
test -f "$ROOT/src/assets/sixty-seven-official-logo.png"

cp "$JSX" "$BACKUP/AdminDashboard.jsx"
if [ -f "$CSS" ]; then CSS_EXISTED=1; cp "$CSS" "$BACKUP/AdminDashboard.login-luxury-v1.1.css"; fi

restore() {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  if [ "$CSS_EXISTED" = "1" ]; then cp "$BACKUP/AdminDashboard.login-luxury-v1.1.css" "$CSS"; else rm -f "$CSS"; fi
}
trap restore ERR

curl -fsSL https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-admin-login-luxury-reference-v1.1.css -o "$CSS"

python3 - <<'PY'
import os
from pathlib import Path

root = Path(os.environ.get('ROOT', '/67'))
p = root / 'src/pages/AdminDashboard.jsx'
s = p.read_text()

login_import = "import './AdminDashboard.login-luxury-v1.1.css';"
if login_import not in s:
    if "import './AdminDashboard.theme-v1.css';" in s:
        anchor = "import './AdminDashboard.theme-v1.css';"
    elif "import './AdminDashboard.v45.css';" in s:
        anchor = "import './AdminDashboard.v45.css';"
    else:
        raise SystemExit("ERROR: admin CSS import anchor missing")
    s = s.replace(anchor, anchor + "\n" + login_import, 1)

start_marker = """  // ==========================================
  // 1. PREMIUM ADMIN LOGIN SCREEN
  // ==========================================
"""
end_marker = """  // ==========================================
  // LOGGED IN SUPER ADMIN DASHBOARD
  // ==========================================
"""
start = s.find(start_marker)
end = s.find(end_marker)
if start < 0:
    # Upgrade from V1 if it was already applied.
    start_marker = """  // ==========================================
  // 1. PREMIUM ADMIN LOGIN SCREEN — LUXURY REFERENCE V1
  // ==========================================
"""
    start = s.find(start_marker)
if start < 0:
    # Idempotent/reapply support.
    start_marker = """  // ==========================================
  // 1. PREMIUM ADMIN LOGIN SCREEN — LUXURY REFERENCE V1.1
  // ==========================================
"""
    start = s.find(start_marker)
if start < 0 or end < 0 or end <= start:
    raise SystemExit("ERROR: admin login markers missing")

new_block = r'''  // ==========================================
  // 1. PREMIUM ADMIN LOGIN SCREEN — LUXURY REFERENCE V1.1
  // ==========================================
  if (!isLoggedIn) {
    return (
      <div className="admin-login-luxury-v1">
        <section className="admin-login-luxury-v1__form-side" aria-label="تسجيل دخول المشرف">
          <div className="admin-login-luxury-v1__panel">
            <button type="button" className="admin-login-luxury-v1__back" onClick={() => navigate('/')}>
              <ArrowRight size={17} /><span>العودة إلى الرئيسية</span>
            </button>

            <header className="admin-login-luxury-v1__header">
              <h1>تسجيل دخول المشرف</h1>
              <p>الرجاء إدخال بيانات المسؤول للوصول إلى لوحة الأداء الرقابية، بشكل آمن.</p>
            </header>

            {loginError && <div className="admin-login-luxury-v1__alert admin-login-luxury-v1__alert--error">{loginError}</div>}
            {!session.configured && (
              <div className="admin-login-luxury-v1__alert admin-login-luxury-v1__alert--blocked">
                بوابة Superadmin مقفولة Fail-Closed لأن إعدادات الأمان على السيرفر غير مكتملة.
              </div>
            )}

            <form className="admin-login-luxury-v1__form" onSubmit={handleLoginSubmit}>
              <div className="admin-login-luxury-v1__field">
                <label htmlFor="admin-login-username">اسم مستخدم <b>Superadmin</b></label>
                <div className="admin-login-luxury-v1__input-wrap">
                  <Users className="admin-login-luxury-v1__input-icon admin-login-luxury-v1__input-icon--left" size={20} aria-hidden="true" />
                  <input id="admin-login-username" type="text" autoComplete="username" placeholder="اسم المستخدم" value={usernameInput} onChange={(e) => setUsernameInput(e.target.value)} required disabled={!session.configured || loginBusy} />
                </div>
              </div>

              <div className="admin-login-luxury-v1__field">
                <label htmlFor="admin-login-password">كلمة المرور</label>
                <div className="admin-login-luxury-v1__input-wrap admin-login-luxury-v1__input-wrap--password">
                  <Eye className="admin-login-luxury-v1__input-icon admin-login-luxury-v1__input-icon--right" size={19} aria-hidden="true" />
                  <LockKeyhole className="admin-login-luxury-v1__input-icon admin-login-luxury-v1__input-icon--left admin-login-luxury-v1__input-icon--gold" size={18} aria-hidden="true" />
                  <input id="admin-login-password" type="password" autoComplete="current-password" placeholder="••••••••••••" value={passwordInput} onChange={(e) => setPasswordInput(e.target.value)} required disabled={!session.configured || loginBusy} />
                </div>
              </div>

              <div className="admin-login-luxury-v1__server-note">
                <span>المصادقة تتم على السيرفر، لا نحتفظ بكلمة مرور أو كود افتراضي داخل الواجهة.</span>
                <span className="admin-login-luxury-v1__server-check" aria-hidden="true"><ShieldCheck size={14} /></span>
              </div>

              <button type="submit" className="admin-login-luxury-v1__submit" disabled={!session.configured || loginBusy}>
                {loginBusy ? <Loader2 className="spin" size={19} /> : <Key size={19} />}
                <span>{loginBusy ? 'جاري التحقق…' : 'دخول آمن'}</span>
                {!loginBusy && <ArrowRight size={18} className="admin-login-luxury-v1__submit-arrow" />}
              </button>
            </form>

            <div className="admin-login-luxury-v1__security">
              <ShieldCheck size={27} />
              <div>
                <strong>بياناتك محمية ومشفرة باستخدام أعلى معايير الأمان</strong>
                <small>نحرص على خصوصيتك وسلامة بياناتك دائمًا.</small>
              </div>
            </div>
          </div>

          <div className="admin-login-luxury-v1__footer-mark" aria-hidden="true">
            <span>SIX SEVEN</span><i /><small>معًا نبني مستقبل أكثر ازدهارًا</small>
          </div>
        </section>

        <section className="admin-login-luxury-v1__hero" style={{ '--admin-login-hero': `url(${heroHighResV295})` }} aria-label="Six Seven executive identity">
          <div className="admin-login-luxury-v1__hero-arc admin-login-luxury-v1__hero-arc--one" aria-hidden="true" />
          <div className="admin-login-luxury-v1__hero-arc admin-login-luxury-v1__hero-arc--two" aria-hidden="true" />

          <div className="admin-login-luxury-v1__hero-kicker">
            <span>إدارة أذكى</span><strong>قرارات أعظم</strong><i />
          </div>

          <div className="admin-login-luxury-v1__hero-content">
            <img src={officialLogo} alt="Six Seven" className="admin-login-luxury-v1__hero-logo" />
            <h2>منصة <span>الإدارة والتحكم</span></h2>
            <p>اللوحة الرقابية العليا لمشرفي منصة 67. تتيح لك الرقابة الكاملة على عمليات البيع، التوثيق، والتواصل الفوري في المجتمع.</p>
            <div className="admin-login-luxury-v1__hero-divider" />
            <div className="admin-login-luxury-v1__hero-values"><span>أمان</span><i /><span>كفاءة</span><i /><span>تحكم أكبر</span></div>
          </div>

          <div className="admin-login-luxury-v1__hero-engraving" aria-hidden="true">
            <span>PEOPLE</span><span>MARKETS</span><span>COMMUNITY</span><strong>A BRIGHTER<br />TOMORROW</strong>
          </div>
        </section>
      </div>
    );
  }

'''

s = s[:start] + new_block + s[end:]
p.write_text(s)
PY

grep -q "AdminDashboard.login-luxury-v1.1.css" "$JSX"
grep -q "admin-login-luxury-v1__hero" "$JSX"
grep -q "admin-login-luxury-v1__panel" "$JSX"
grep -q "heroHighResV295" "$JSX"
grep -q "admin-login-luxury-v1__hero-content" "$CSS"

npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-ADMIN-LOGIN-LUXURY-REFERENCE-V1.1"
echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "REFERENCE_LOCK=YES"
echo "DESKTOP_REFERENCE=1672x941"
echo "RESPONSIVE=YES"
echo "AUTH_LOGIC_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "THEME_SYSTEM_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
