#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
CSS="$ROOT/src/pages/AdminDashboard.theme-v1.css"
BACKUP="$(mktemp -d /tmp/67-admin-theme-v1.XXXXXX)"
CSS_EXISTED=0

cd "$ROOT"
test -f "$JSX"
grep -q "AdminDashboard.v45.css" "$JSX"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
if [ -f "$CSS" ]; then
  CSS_EXISTED=1
  cp "$CSS" "$BACKUP/AdminDashboard.theme-v1.css"
fi

restore() {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  if [ "$CSS_EXISTED" = "1" ]; then
    cp "$BACKUP/AdminDashboard.theme-v1.css" "$CSS"
  else
    rm -f "$CSS"
  fi
}
trap restore ERR

python3 - <<'PY'
from pathlib import Path

p = Path('/67/src/pages/AdminDashboard.jsx')
s = p.read_text()

# 1) Icons
old_icons = "UserCheck, AlertCircle, Award, Star, Settings, LogOut, Key, Camera, Link, Github, Loader2, LockKeyhole, CarFront, CalendarDays, ChevronDown, Download"
new_icons = old_icons + ", Sun, Moon"
if "Sun, Moon" not in s:
    if old_icons not in s:
        raise SystemExit("ERROR: lucide icon anchor missing")
    s = s.replace(old_icons, new_icons, 1)

# 2) Theme stylesheet loaded last
theme_import = "import './AdminDashboard.theme-v1.css';"
if theme_import not in s:
    anchor = "import './AdminDashboard.v45.css';"
    if anchor not in s:
        raise SystemExit("ERROR: v45 CSS import missing")
    s = s.replace(anchor, anchor + "\n" + theme_import, 1)

# 3) Shared theme storage helper
if "ADMIN_THEME_STORAGE_KEY" not in s:
    anchor = "\nconst AdminDashboard = () => {"
    helper = r'''
const ADMIN_THEME_STORAGE_KEY = '_67_theme';

const readStoredAdminTheme = () => {
  try {
    const saved = localStorage.getItem(ADMIN_THEME_STORAGE_KEY);
    return saved === 'dark' || saved === 'light' ? saved : 'light';
  } catch {
    return 'light';
  }
};
'''
    if anchor not in s:
        raise SystemExit("ERROR: AdminDashboard component anchor missing")
    s = s.replace(anchor, helper + anchor, 1)

# 4) State + DOM theme binding + cross-tab browser sync
state_anchor = "  const [logoTheme, setLogoTheme] = useState(localStorage.getItem('logoTheme') || 'car_concept');"
if "const [adminTheme, setAdminTheme]" not in s:
    if state_anchor not in s:
        raise SystemExit("ERROR: logoTheme state anchor missing")
    s = s.replace(state_anchor, state_anchor + "\n  const [adminTheme, setAdminTheme] = useState(readStoredAdminTheme);", 1)

if "data-67-admin-theme" not in s:
    effect_anchor = "  const [session, setSession] = useState({ loading: true, authenticated: false, configured: true });"
    effect = r'''
  useEffect(() => {
    try { localStorage.setItem(ADMIN_THEME_STORAGE_KEY, adminTheme); } catch {}
    document.documentElement.setAttribute('data-67-admin-theme', adminTheme);
    document.documentElement.style.colorScheme = adminTheme;

    const syncTheme = (event) => {
      if (event.key !== ADMIN_THEME_STORAGE_KEY) return;
      if (event.newValue === 'dark' || event.newValue === 'light') setAdminTheme(event.newValue);
    };
    window.addEventListener('storage', syncTheme);
    return () => {
      window.removeEventListener('storage', syncTheme);
      document.documentElement.removeAttribute('data-67-admin-theme');
      document.documentElement.style.colorScheme = '';
    };
  }, [adminTheme]);

'''
    if effect_anchor not in s:
        raise SystemExit("ERROR: session state anchor missing")
    s = s.replace(effect_anchor, effect + effect_anchor, 1)

# 5) Theme action
if "handleAdminThemeChange" not in s:
    anchor = r'''  const handleLogoThemeToggle = (newTheme) => {
    localStorage.setItem('logoTheme', newTheme);
    setLogoTheme(newTheme);
    window.dispatchEvent(new Event('storage'));
  };
'''
    action = r'''
  const handleAdminThemeChange = (nextTheme) => {
    const safeTheme = nextTheme === 'dark' ? 'dark' : 'light';
    setAdminTheme(safeTheme);
    try { localStorage.setItem(ADMIN_THEME_STORAGE_KEY, safeTheme); } catch {}
  };

'''
    if anchor not in s:
        raise SystemExit("ERROR: logo theme handler anchor missing")
    s = s.replace(anchor, anchor + action, 1)

# 6) Scope theme to logged-in admin root + explicit main-content class
root_old = '<div className="admin-dashboard admin-exec min-h-screen" style={{ direction: \'rtl\', fontFamily: \'Cairo, sans-serif\', display: \'flex\', backgroundColor: \'transparent\', position: \'relative\' }}>'
root_new = '<div className="admin-dashboard admin-exec min-h-screen" data-admin-theme={adminTheme} style={{ direction: \'rtl\', fontFamily: \'Cairo, sans-serif\', display: \'flex\', backgroundColor: \'var(--admin-page-bg)\', position: \'relative\' }}>'
if "data-admin-theme={adminTheme}" not in s:
    if root_old not in s:
        raise SystemExit("ERROR: admin root anchor missing")
    s = s.replace(root_old, root_new, 1)

main_old = "<div style={{ flex: 1, marginRight: '200px', padding: '0 8px 14px 14px', minHeight: '100vh', overflowY: 'visible' }}>"
main_new = "<div className="admin-main-content" style={{ flex: 1, marginRight: '200px', padding: '0 8px 14px 14px', minHeight: '100vh', overflowY: 'visible' }}>"
if 'className="admin-main-content"' not in s:
    if main_old not in s:
        raise SystemExit("ERROR: admin main content anchor missing")
    s = s.replace(main_old, main_new, 1)

# 7) Sidebar quick switch
if "admin-theme-quick" not in s:
    anchor = '''        {/* Bottom utility — logout only (logo switcher moved to Settings) */}
        <div className="admin-sidebar__footer">
'''
    replacement = '''        {/* Bottom utility */}
        <div className="admin-sidebar__footer">
          <div className="admin-theme-quick" role="group" aria-label="مظهر لوحة الإدارة">
            <button type="button" className={`admin-theme-quick__btn ${adminTheme === 'light' ? 'active' : ''}`} onClick={() => handleAdminThemeChange('light')} aria-pressed={adminTheme === 'light'} title="الوضع الفاتح">
              <Sun size={15} /><span>فاتح</span>
            </button>
            <button type="button" className={`admin-theme-quick__btn ${adminTheme === 'dark' ? 'active' : ''}`} onClick={() => handleAdminThemeChange('dark')} aria-pressed={adminTheme === 'dark'} title="الوضع الداكن">
              <Moon size={15} /><span>داكن</span>
            </button>
          </div>
'''
    if anchor not in s:
        raise SystemExit("ERROR: sidebar footer anchor missing")
    s = s.replace(anchor, replacement, 1)

# 8) Full Settings appearance card
if "admin-theme-settings" not in s:
    anchor = '''              {/* Logo switcher (moved from sidebar utility) */}
'''
    block = '''              {/* Unified interface theme */}
              <div className="v44-settings-section admin-theme-settings">
                <div className="v44-settings-aside">
                  <span className="v44-settings-aside__icon">{adminTheme === 'dark' ? <Moon size={20} /> : <Sun size={20} />}</span>
                  <strong>مظهر لوحة الإدارة</strong>
                  <small>اختيارك محفوظ تلقائيًا على هذا المتصفح</small>
                </div>
                <div className="admin-theme-settings__copy">
                  <h4>الوضع الفاتح والداكن</h4>
                  <p>غيّر مظهر لوحة الإدارة فورًا بدون التأثير على بيانات الحساب أو صلاحيات Superadmin.</p>
                </div>
                <div className="admin-theme-settings__options" role="group" aria-label="اختيار مظهر لوحة الإدارة">
                  <button type="button" className={`admin-theme-choice ${adminTheme === 'light' ? 'active' : ''}`} onClick={() => handleAdminThemeChange('light')} aria-pressed={adminTheme === 'light'}>
                    <span className="admin-theme-choice__icon"><Sun size={19} /></span>
                    <span><b>Light</b><small>فاتح وراقي</small></span>
                    <i aria-hidden="true" />
                  </button>
                  <button type="button" className={`admin-theme-choice ${adminTheme === 'dark' ? 'active' : ''}`} onClick={() => handleAdminThemeChange('dark')} aria-pressed={adminTheme === 'dark'}>
                    <span className="admin-theme-choice__icon"><Moon size={19} /></span>
                    <span><b>Dark</b><small>داكن احترافي</small></span>
                    <i aria-hidden="true" />
                  </button>
                </div>
              </div>

'''
    if anchor not in s:
        raise SystemExit("ERROR: settings theme insertion anchor missing")
    s = s.replace(anchor, block + anchor, 1)

# 9) Theme-aware shared inline style objects
replacements = {
"""const inputStyle = {
  padding: '12px 16px',
  borderRadius: '10px',
  border: '1.5px solid #E2E8F0',
  backgroundColor: '#FFFFFF',
  color: '#1E293B',""": """const inputStyle = {
  padding: '12px 16px',
  borderRadius: '10px',
  border: '1.5px solid var(--admin-border)',
  backgroundColor: 'var(--admin-input-bg)',
  color: 'var(--admin-text)',""",
"""const adminInputStyle = {
  padding: '12px 16px',
  borderRadius: '10px',
  border: '1px solid #E2E8F0',
  backgroundColor: '#F8FAFC',
  color: '#1E293B',""": """const adminInputStyle = {
  padding: '12px 16px',
  borderRadius: '10px',
  border: '1px solid var(--admin-border)',
  backgroundColor: 'var(--admin-input-bg)',
  color: 'var(--admin-text)',""",
"""const sidebarMetricStyle = {
  display: 'flex',
  flexDirection: 'column',
  gap: '6px',
  padding: '12px 14px',
  borderRadius: '10px',
  background: '#F8FAFC',
  border: '1px solid #E2E8F0',""": """const sidebarMetricStyle = {
  display: 'flex',
  flexDirection: 'column',
  gap: '6px',
  padding: '12px 14px',
  borderRadius: '10px',
  background: 'var(--admin-surface-soft)',
  border: '1px solid var(--admin-border)',""",
"""const cardStyle = {
  background: '#FFFFFF',
  border: '1px solid #E2E8F0',
  borderRadius: '16px',
  padding: '24px',
  boxShadow: '0 4px 12px rgba(0,0,0,0.01)',""": """const cardStyle = {
  background: 'var(--admin-surface)',
  color: 'var(--admin-text)',
  border: '1px solid var(--admin-border)',
  borderRadius: '16px',
  padding: '24px',
  boxShadow: 'var(--admin-card-shadow)',""",
"""const thStyle = {
  padding: '12px 16px',
  color: '#64748B',
  fontWeight: 'bold',
  fontSize: '0.9rem',
  borderBottom: '2px solid #E2E8F0'""": """const thStyle = {
  padding: '12px 16px',
  color: 'var(--admin-muted)',
  fontWeight: 'bold',
  fontSize: '0.9rem',
  borderBottom: '2px solid var(--admin-border)'""",
"""const tdStyle = {
  padding: '16px',
  fontSize: '0.9rem',
  color: '#334155'""": """const tdStyle = {
  padding: '16px',
  fontSize: '0.9rem',
  color: 'var(--admin-text-soft)'"""
}
for old, new in replacements.items():
    if old in s:
        s = s.replace(old, new, 1)

p.write_text(s)
PY

cat > "$CSS" <<'CSS'
/* ============================================================
   SIX SEVEN — ADMIN THEME V1
   Scope: logged-in Admin only.
   Persistence: localStorage key _67_theme.
   No auth/backend/business-data changes.
   ============================================================ */

body .admin-exec[data-admin-theme="light"]{
  --admin-page-bg:#f7f2e8;
  --admin-surface:#fffdf8;
  --admin-surface-soft:#fbf6ec;
  --admin-surface-raised:#ffffff;
  --admin-input-bg:#fffdf9;
  --admin-text:#07111a;
  --admin-text-soft:#334155;
  --admin-muted:#64748b;
  --admin-border:rgba(169,116,20,.22);
  --admin-border-strong:rgba(169,116,20,.34);
  --admin-gold:#d7a126;
  --admin-gold-soft:#f0c65d;
  --admin-card-shadow:0 8px 24px rgba(75,51,8,.07);
  --admin-hover:rgba(215,161,38,.07);
}

body .admin-exec[data-admin-theme="dark"]{
  --admin-page-bg:#071019;
  --admin-surface:#0d1823;
  --admin-surface-soft:#111e2a;
  --admin-surface-raised:#152433;
  --admin-input-bg:#0a151f;
  --admin-text:#f6f1e7;
  --admin-text-soft:#d0dae5;
  --admin-muted:#91a0b1;
  --admin-border:rgba(222,174,45,.18);
  --admin-border-strong:rgba(232,190,78,.34);
  --admin-gold:#d9ae43;
  --admin-gold-soft:#f0ce72;
  --admin-card-shadow:0 16px 38px rgba(0,0,0,.28);
  --admin-hover:rgba(222,174,45,.08);
}

html[data-67-admin-theme="light"],
html[data-67-admin-theme="light"] body,
html[data-67-admin-theme="light"] #root{background:#f7f2e8!important}
html[data-67-admin-theme="dark"],
html[data-67-admin-theme="dark"] body,
html[data-67-admin-theme="dark"] #root{background:#071019!important}

body .admin-exec,
body .admin-exec .admin-main-content,
body .admin-exec .v38-kpi,
body .admin-exec .v38-health,
body .admin-exec .v38-revenue,
body .admin-exec .v38-live,
body .admin-exec .v38-current,
body .admin-exec .v38-ledger,
body .admin-exec .ref-batch-panel,
body .admin-exec .v43-settings-card,
body .admin-exec .v44-settings-section,
body .admin-exec input,
body .admin-exec select,
body .admin-exec textarea{
  transition:background-color .22s ease,border-color .22s ease,color .22s ease,box-shadow .22s ease;
}

body .admin-exec .admin-main-content{
  background:var(--admin-page-bg)!important;
  color:var(--admin-text)!important;
}

/* Sidebar theme switch */
body .admin-exec .admin-theme-quick{
  display:grid;
  grid-template-columns:1fr 1fr;
  gap:5px;
  margin:0 0 6px;
  padding:4px;
  border:1px solid rgba(216,185,85,.17);
  border-radius:11px;
  background:rgba(255,255,255,.025);
}
body .admin-exec .admin-theme-quick__btn{
  min-height:31px;
  border:1px solid transparent;
  border-radius:8px;
  background:transparent;
  color:#8f9aa5;
  cursor:pointer;
  display:flex;
  align-items:center;
  justify-content:center;
  gap:5px;
  font:inherit;
  font-size:12px;
  font-weight:800;
}
body .admin-exec .admin-theme-quick__btn:hover{color:#f0d171;background:rgba(255,255,255,.035)}
body .admin-exec .admin-theme-quick__btn.active{
  color:#10151a;
  border-color:#e4c15c;
  background:linear-gradient(135deg,#f0d276,#bd8c25);
  box-shadow:0 5px 16px rgba(215,161,38,.18);
}

/* Settings appearance card */
body .admin-exec .admin-theme-settings{
  display:grid!important;
  grid-template-columns:210px minmax(0,1fr) minmax(280px,420px)!important;
  gap:22px!important;
  align-items:center!important;
  min-height:116px!important;
  padding:14px 18px!important;
  background:linear-gradient(100deg,var(--admin-surface-raised),var(--admin-surface-soft))!important;
  border:1px solid var(--admin-border)!important;
  box-shadow:var(--admin-card-shadow)!important;
  direction:ltr!important;
}
body .admin-exec .admin-theme-settings>.v44-settings-aside{
  grid-column:1!important;
  position:static!important;
  width:auto!important;
  direction:rtl!important;
  text-align:right!important;
}
body .admin-exec .admin-theme-settings__copy{
  grid-column:2;
  direction:rtl;
  text-align:right;
}
body .admin-exec .admin-theme-settings__copy h4{margin:0 0 5px;color:var(--admin-text);font-size:15px}
body .admin-exec .admin-theme-settings__copy p{margin:0;color:var(--admin-muted);font-size:12px;line-height:1.7}
body .admin-exec .admin-theme-settings__options{
  grid-column:3;
  display:grid;
  grid-template-columns:1fr 1fr;
  gap:8px;
  direction:ltr;
}
body .admin-exec .admin-theme-choice{
  min-height:68px;
  border:1px solid var(--admin-border);
  border-radius:12px;
  background:var(--admin-surface);
  color:var(--admin-text);
  cursor:pointer;
  display:grid;
  grid-template-columns:36px 1fr 10px;
  gap:9px;
  align-items:center;
  padding:9px 11px;
  text-align:left;
  font:inherit;
  box-shadow:none;
}
body .admin-exec .admin-theme-choice:hover{border-color:var(--admin-border-strong);background:var(--admin-hover)}
body .admin-exec .admin-theme-choice.active{
  border-color:var(--admin-gold)!important;
  box-shadow:inset 0 0 0 1px rgba(215,161,38,.16),0 8px 22px rgba(0,0,0,.08);
}
body .admin-exec .admin-theme-choice__icon{
  width:36px;height:36px;border-radius:10px;display:grid;place-items:center;
  color:var(--admin-gold-soft);background:rgba(215,161,38,.10);border:1px solid rgba(215,161,38,.16);
}
body .admin-exec .admin-theme-choice>span:nth-child(2){display:flex;flex-direction:column;gap:1px}
body .admin-exec .admin-theme-choice b{font-size:12px;color:var(--admin-text)}
body .admin-exec .admin-theme-choice small{font-size:10px;color:var(--admin-muted)}
body .admin-exec .admin-theme-choice i{
  width:8px;height:8px;border-radius:50%;background:transparent;border:1px solid var(--admin-muted);
}
body .admin-exec .admin-theme-choice.active i{background:var(--admin-gold);border-color:var(--admin-gold);box-shadow:0 0 0 3px rgba(215,161,38,.12)}

/* Shared cards, forms and tables */
body .admin-exec[data-admin-theme="dark"] .ref-batch-panel,
body .admin-exec[data-admin-theme="dark"] .v43-settings-card,
body .admin-exec[data-admin-theme="dark"] .v44-settings-section{
  background:linear-gradient(145deg,var(--admin-surface),var(--admin-surface-soft))!important;
  color:var(--admin-text)!important;
  border-color:var(--admin-border)!important;
  box-shadow:var(--admin-card-shadow)!important;
}
body .admin-exec[data-admin-theme="dark"] .v44-settings-section h4,
body .admin-exec[data-admin-theme="dark"] .v44-settings-section>div:not(.v44-settings-aside),
body .admin-exec[data-admin-theme="dark"] .ref-batch-panel h3{
  color:var(--admin-text)!important;
}
body .admin-exec[data-admin-theme="dark"] .v44-settings-section p,
body .admin-exec[data-admin-theme="dark"] .v44-settings-section small{
  color:var(--admin-muted)!important;
}
body .admin-exec[data-admin-theme="dark"] table{color:var(--admin-text)!important}
body .admin-exec[data-admin-theme="dark"] table tr{border-color:var(--admin-border)!important}
body .admin-exec[data-admin-theme="dark"] table th{color:var(--admin-muted)!important;border-color:var(--admin-border)!important}
body .admin-exec[data-admin-theme="dark"] table td{color:var(--admin-text-soft)!important;border-color:var(--admin-border)!important}
body .admin-exec[data-admin-theme="dark"] input,
body .admin-exec[data-admin-theme="dark"] select,
body .admin-exec[data-admin-theme="dark"] textarea{
  background:var(--admin-input-bg)!important;
  color:var(--admin-text)!important;
  border-color:var(--admin-border)!important;
}
body .admin-exec[data-admin-theme="dark"] input::placeholder,
body .admin-exec[data-admin-theme="dark"] textarea::placeholder{color:#718096!important}

/* Overview executive surface */
body .admin-exec[data-admin-theme="dark"]{
  --v38-bg:#071019;
  --v38-paper:#0d1823;
  --v38-paper2:#111e2a;
  --v38-ink:#f6f1e7;
  --v38-ink2:#d4dce5;
  --v38-line:rgba(222,174,45,.18);
  --v38-shadow:0 16px 38px rgba(0,0,0,.24);
}
body .admin-exec[data-admin-theme="dark"] .v38-kpi,
body .admin-exec[data-admin-theme="dark"] .v38-health,
body .admin-exec[data-admin-theme="dark"] .v38-revenue,
body .admin-exec[data-admin-theme="dark"] .v38-live,
body .admin-exec[data-admin-theme="dark"] .v38-current,
body .admin-exec[data-admin-theme="dark"] .v38-ledger{
  background:linear-gradient(145deg,#0d1823,#101d29)!important;
  border-color:var(--admin-border)!important;
  color:var(--admin-text)!important;
  box-shadow:var(--admin-card-shadow)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-kpi__value,
body .admin-exec[data-admin-theme="dark"] .v38-section-title,
body .admin-exec[data-admin-theme="dark"] .v38-ops-head,
body .admin-exec[data-admin-theme="dark"] .v38-ledger-title,
body .admin-exec[data-admin-theme="dark"] .v38-health-metric__head,
body .admin-exec[data-admin-theme="dark"] .v38-current-summary{
  color:var(--admin-text)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-kpi small,
body .admin-exec[data-admin-theme="dark"] .v38-period,
body .admin-exec[data-admin-theme="dark"] .v38-live-row__time,
body .admin-exec[data-admin-theme="dark"] .v38-donut-legend,
body .admin-exec[data-admin-theme="dark"] .v38-ledger-table th{
  color:var(--admin-muted)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-health-metric,
body .admin-exec[data-admin-theme="dark"] .v38-rev-stat,
body .admin-exec[data-admin-theme="dark"] .v38-live-row,
body .admin-exec[data-admin-theme="dark"] .v38-current-table,
body .admin-exec[data-admin-theme="dark"] .v38-ledger-table-wrap{
  background:#0a151f!important;
  border-color:var(--admin-border)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-ledger-table th{
  background:#09131d!important;
  border-color:var(--admin-border)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-ledger-table td{
  background:transparent!important;
  color:var(--admin-text-soft)!important;
  border-color:var(--admin-border)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-datebar,
body .admin-exec[data-admin-theme="dark"] .v38-date-popover{
  background:rgba(8,17,26,.96)!important;
  border-color:rgba(222,174,45,.28)!important;
  color:var(--admin-text)!important;
}
body .admin-exec[data-admin-theme="dark"] .v38-date-field input{background:#07111b!important;color:var(--admin-text)!important}
body .admin-exec[data-admin-theme="dark"] .recharts-cartesian-grid line{stroke:rgba(145,160,177,.12)!important}
body .admin-exec[data-admin-theme="dark"] .recharts-cartesian-axis-tick-value{fill:#8999aa!important}

/* Non-overview tabs with inline legacy light colors */
body .admin-exec[data-admin-theme="dark"] .v43-notifications-screen{
  background:linear-gradient(145deg,var(--admin-surface),var(--admin-surface-soft))!important;
  border-color:var(--admin-border)!important;
  color:var(--admin-text)!important;
}
body .admin-exec[data-admin-theme="dark"] .v43-notifications-screen>div:last-child>div{
  border-color:var(--admin-border)!important;
  color:var(--admin-text)!important;
}
body .admin-exec[data-admin-theme="dark"] .v43-notifications-screen button{
  border-color:var(--admin-border)!important;
  color:var(--admin-muted)!important;
}

/* GitHub Developer Hub follows the admin theme */
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded{
  --sa-bg:#f8f3e8;
  --sa-panel:#fffdf8;
  --sa-panel2:#fbf5e9;
  --sa-line:rgba(169,116,20,.22);
  --sa-text:#0b1721;
  --sa-muted:#64748b;
  --sa-gold:#b88618;
  --sa-green:#168765;
  --sa-red:#c24156;
  --sa-blue:#2d6fb7;
  color:var(--sa-text)!important;
  background:linear-gradient(145deg,#fffdf8,#f8f2e5)!important;
  border-color:var(--sa-line)!important;
  box-shadow:0 14px 34px rgba(75,51,8,.08)!important;
}
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded .sa-card,
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded .sa-metric{
  background:linear-gradient(150deg,#ffffff,#fbf5e9)!important;
  border-color:var(--sa-line)!important;
  color:var(--sa-text)!important;
}
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded input,
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded select,
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded .sa-stats>div,
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded .sa-review-summary>div,
body .admin-exec[data-admin-theme="light"] .sa-shell-embedded .sa-actions button{
  background:#fffaf0!important;
  color:var(--sa-text)!important;
  border-color:var(--sa-line)!important;
}
body .admin-exec[data-admin-theme="dark"] .sa-shell-embedded{
  --sa-bg:#07111f;
  --sa-panel:#0d1928;
  --sa-panel2:#111f31;
  --sa-line:#22344b;
  --sa-text:#edf4ff;
  --sa-muted:#8ea0b5;
  --sa-gold:#d8b955;
}

/* Keep hero/sidebar cinematic identity stable in both themes */
body .admin-exec .v38-hero,
body .admin-exec .v43-screen-hero,
body .admin-exec .admin-sidebar{
  color:#fff!important;
}

/* Focus accessibility */
body .admin-exec .admin-theme-quick__btn:focus-visible,
body .admin-exec .admin-theme-choice:focus-visible{
  outline:2px solid var(--admin-gold-soft);
  outline-offset:2px;
}

@media (max-width:1200px){
  body .admin-exec .admin-theme-settings{grid-template-columns:180px minmax(0,1fr)!important}
  body .admin-exec .admin-theme-settings__copy{grid-column:2}
  body .admin-exec .admin-theme-settings__options{grid-column:2}
}
@media (max-width:760px){
  body .admin-exec .admin-theme-settings{display:flex!important;flex-direction:column!important;align-items:stretch!important;direction:rtl!important}
  body .admin-exec .admin-theme-settings__options{grid-template-columns:1fr 1fr;width:100%}
}
CSS

# Verification
grep -q "AdminDashboard.theme-v1.css" "$JSX"
grep -q "ADMIN_THEME_STORAGE_KEY = '_67_theme'" "$JSX"
grep -q "data-admin-theme={adminTheme}" "$JSX"
grep -q "admin-theme-quick" "$JSX"
grep -q "admin-theme-settings" "$JSX"
grep -q "data-admin-theme=\"dark\"" "$CSS"
grep -q "sa-shell-embedded" "$CSS"

npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH_APPLIED=YES"
echo "BUILD=PASS"
echo "THEME=ADMIN_V1"
echo "LIGHT_MODE=YES"
echo "DARK_MODE=YES"
echo "TOGGLE_SIDEBAR=YES"
echo "TOGGLE_SETTINGS=YES"
echo "PERSISTENCE=BROWSER_LOCALSTORAGE"
echo "STORAGE_KEY=_67_theme"
echo "GITHUB_MODULE_THEMED=YES"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "BUSINESS_DATA_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
