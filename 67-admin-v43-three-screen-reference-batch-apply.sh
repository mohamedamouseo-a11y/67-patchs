#!/usr/bin/env bash
set -euo pipefail

ROOT="/67"
JSX="$ROOT/src/pages/AdminDashboard.jsx"
V42="$ROOT/src/pages/AdminDashboard.v42.css"
V43="$ROOT/src/pages/AdminDashboard.v43.css"

cd "$ROOT"

test -f "$JSX"
test -f "$V42"

grep -q "AdminDashboard.v42.css" "$JSX" || grep -q "AdminDashboard.v43.css" "$JSX"

cp "$V42" "$V43"

python3 - <<'PY'
from pathlib import Path
p = Path('/67/src/pages/AdminDashboard.jsx')
s = p.read_text()

# Runtime stylesheet switch, idempotent.
s = s.replace("import './AdminDashboard.v42.css';", "import './AdminDashboard.v43.css';")

# Notifications: visual-only wrapper marker.
old = '''{activeTab === 'notifications' && (\n          <div className="animate-fadeIn" style={cardStyle}>'''
new = '''{activeTab === 'notifications' && (\n          <div className="animate-fadeIn v43-reference-screen v43-notifications-screen" style={cardStyle}>'''
if old in s:
    s = s.replace(old, new, 1)
elif 'v43-notifications-screen' not in s:
    raise SystemExit('V43 notifications anchor not found')

hero = '''\n            <section className="v43-screen-hero" style={{ '--v43-hero': `url(${heroHighResV295})` }} aria-label="Six Seven executive identity">\n              <div className="v43-screen-hero__left">\n                <span className="v43-screen-hero__welcome">مرحبًا بك مجددًا · Super Admin</span>\n                <h1>قيادة اليوم .. <b>لمستقبل أكثر تميزًا</b></h1>\n                <p>منصة متكاملة لإدارة الأعمال والتشغيل والعمليات بثقة واحترافية</p>\n              </div>\n              <div className="v43-screen-hero__right">\n                <span>سرعة أكبر</span>\n                <strong>فرص أوسع</strong>\n                <small>DRIVE A BRIGHTER TOMORROW</small>\n              </div>\n            </section>'''

# GitHub screen: preserve GitHubModule behavior; add only the approved visual shell/hero.
old = '''{activeTab === 'github' && (\n          <div className="animate-fadeIn">\n            <GitHubModule session={session} onSessionExpired={loadSession} />\n          </div>\n        )}'''
new = '''{activeTab === 'github' && (\n          <div className="animate-fadeIn v43-reference-screen v43-github-screen">''' + hero + '''\n            <GitHubModule session={session} onSessionExpired={loadSession} />\n          </div>\n        )}'''
if old in s:
    s = s.replace(old, new, 1)
elif 'v43-github-screen' not in s:
    raise SystemExit('V43 GitHub anchor not found')

# Settings: same data and submit flow; add approved hero and styling hooks only.
old = '''{activeTab === 'settings' && (\n          <div className="animate-fadeIn" style={{ display: 'flex', flexDirection: 'column', gap: '25px' }}>\n            <div style={cardStyle}>'''
new = '''{activeTab === 'settings' && (\n          <div className="animate-fadeIn v43-reference-screen v43-settings-screen" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>''' + hero + '''\n            <div className="v43-settings-card" style={cardStyle}>'''
if old in s:
    s = s.replace(old, new, 1)
elif 'v43-settings-screen' not in s:
    raise SystemExit('V43 settings anchor not found')

p.write_text(s)
PY

cat >> "$V43" <<'CSS'

/* ============================================================
   V43 — THREE SCREEN REFERENCE BATCH
   Screens: Live Notifications / GitHub Module / Account Settings
   Visual authority: approved Six Seven navy + gold + ivory language.
   No data, business logic, backend, auth, or action changes.
   ============================================================ */

.v43-reference-screen{
  --v43-navy:#061522;
  --v43-navy-2:#0a1b2b;
  --v43-gold:#d7ad2d;
  --v43-gold-soft:#f0cf6a;
  --v43-ivory:#fffdf7;
  --v43-ink:#10213a;
  --v43-muted:#6d7c91;
  --v43-line:#d9e0e8;
  direction:rtl;
}

.v43-screen-hero{
  position:relative;
  height:176px;
  min-height:176px;
  overflow:hidden;
  border-radius:0 0 14px 14px;
  border:1px solid rgba(213,173,45,.42);
  background-image:
    linear-gradient(90deg,rgba(5,12,18,.12) 0%,rgba(5,12,18,.30) 42%,rgba(5,12,18,.68) 100%),
    var(--v43-hero);
  background-size:cover;
  background-position:center 48%;
  box-shadow:0 8px 28px rgba(6,21,34,.16);
  color:#fff;
}
.v43-screen-hero::after{
  content:"";
  position:absolute;
  inset:auto 0 0;
  height:3px;
  background:linear-gradient(90deg,transparent 0 18%,#be1018 38% 66%,transparent 86%);
  opacity:.88;
}
.v43-screen-hero__left{
  position:absolute;
  left:28px;
  top:24px;
  width:52%;
  direction:rtl;
  text-align:left;
  text-shadow:0 2px 8px rgba(0,0,0,.72);
}
.v43-screen-hero__welcome{display:block;font-size:10px;color:#f8e5a3;margin-bottom:8px;font-weight:800}
.v43-screen-hero__left h1{margin:0;font-size:25px;line-height:1.25;font-weight:900;color:#fff0b2}
.v43-screen-hero__left h1 b{color:#fff;font-weight:900}
.v43-screen-hero__left p{margin:7px 0 0;font-size:10px;color:#f7f4ed;opacity:.95}
.v43-screen-hero__right{
  position:absolute;
  right:34px;
  top:40px;
  display:flex;
  flex-direction:column;
  align-items:flex-start;
  text-align:right;
  text-shadow:0 2px 7px rgba(0,0,0,.8)
}
.v43-screen-hero__right span,.v43-screen-hero__right strong{font-size:18px;line-height:1.15;color:#fff;font-weight:900}
.v43-screen-hero__right strong{color:#f6d14d;margin-top:5px}
.v43-screen-hero__right small{margin-top:15px;font-size:7px;letter-spacing:1.4px;color:#eee}

/* ---------- LIVE NOTIFICATIONS ---------- */
.v43-notifications-screen{
  min-height:calc(100vh - 16px);
  margin:0 !important;
  padding:28px 24px 40px !important;
  background:
    radial-gradient(circle at 8% 92%,rgba(211,171,45,.075),transparent 28%),
    linear-gradient(180deg,#fff 0%,#fffdf8 100%) !important;
  border-color:#dfe5eb !important;
  border-radius:0 0 18px 18px !important;
  box-shadow:0 8px 22px rgba(15,23,42,.045) !important;
}
.v43-notifications-screen>div:first-child{
  min-height:54px;
  margin-bottom:20px !important;
  padding-bottom:12px;
  border-bottom:1px solid #edf0f3;
}
.v43-notifications-screen>div:first-child h3{
  color:#111f35;
  font-size:20px !important;
  font-weight:900 !important;
}
.v43-notifications-screen>div:first-child h3 svg{color:#e6b90d !important;filter:drop-shadow(0 0 7px rgba(230,185,13,.22))}
.v43-notifications-screen>div:first-child button{
  background:#0a1723 !important;
  color:#e4bd42 !important;
  border:1px solid rgba(215,173,45,.5) !important;
  border-radius:11px !important;
  min-height:40px;
  padding:8px 16px !important;
  box-shadow:0 5px 16px rgba(6,21,34,.12);
  font-weight:800;
}
.v43-notifications-screen>div:nth-child(2){gap:10px !important}
.v43-notifications-screen>div:nth-child(2)>div{
  position:relative;
  min-height:74px;
  padding:18px 58px !important;
  border:1px solid #d9e0e6 !important;
  border-radius:15px !important;
  background:linear-gradient(90deg,rgba(249,244,224,.58),rgba(255,253,246,.94)) !important;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.6),0 4px 12px rgba(15,23,42,.035);
}
.v43-notifications-screen>div:nth-child(2)>div::before{
  content:"";
  position:absolute;
  right:22px;
  top:50%;
  width:11px;
  height:11px;
  border-radius:50%;
  background:#25bf8a;
  transform:translateY(-50%);
  box-shadow:0 0 0 4px rgba(37,191,138,.08);
}
.v43-notifications-screen>div:nth-child(2)>div::after{
  content:"◷";
  position:absolute;
  left:22px;
  top:50%;
  transform:translateY(-52%);
  color:#c89508;
  font-size:25px;
  line-height:1;
}
.v43-notifications-screen>div:nth-child(2)>div>div span{font-size:16px !important;color:#11233d;font-weight:900 !important}
.v43-notifications-screen>div:nth-child(2)>div>span{font-size:13px !important;color:#66788d !important;margin-left:20px}

/* ---------- GITHUB MODULE ---------- */
.v43-github-screen{padding-top:0;background:#06131f;min-height:100vh}
.v43-github-screen .v43-screen-hero{margin-bottom:14px}
.v43-github-screen .sa-shell-embedded{
  border-radius:16px;
  padding:24px;
  background:
    radial-gradient(circle at 88% 0%,rgba(23,67,91,.20),transparent 28%),
    linear-gradient(160deg,#071724 0%,#06131f 100%);
  border:1px solid #244057;
  box-shadow:0 16px 42px rgba(0,0,0,.2);
}
.v43-github-screen .sa-content-stack{gap:16px}
.v43-github-screen .sa-module-heading{min-height:76px;padding:0 2px 4px}
.v43-github-screen .sa-module-heading .sa-kicker{color:#f2c94c;letter-spacing:1.7px;font-size:10px}
.v43-github-screen .sa-module-heading h2{color:#e9bd3f;font-size:25px;margin:3px 0}
.v43-github-screen .sa-module-heading p{color:#9bb0c3;font-size:12px}
.v43-github-screen .sa-icon-btn{border-color:#29465e;background:#0b1e2f;color:#d9e7f5}
.v43-github-screen .sa-grid{gap:16px}
.v43-github-screen .sa-grid.three{grid-template-columns:repeat(3,minmax(0,1fr))}
.v43-github-screen .sa-metric{
  min-height:116px;
  border-radius:15px;
  padding:18px;
  background:linear-gradient(145deg,#0a1d2d,#071623);
  border:1px solid #28455c;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.012);
}
.v43-github-screen .sa-metric-icon{background:#0d2a40;color:#f1c746;border:1px solid rgba(215,173,45,.12)}
.v43-github-screen .sa-metric>span{color:#9bb0c4}
.v43-github-screen .sa-metric>strong{color:#f6f9fd;font-size:20px}
.v43-github-screen .sa-metric>small{color:#9db0c2}
.v43-github-screen .sa-card{
  border-radius:15px;
  padding:20px;
  background:linear-gradient(150deg,#091b2b,#071522);
  border:1px solid #29465d;
}
.v43-github-screen .sa-card-head h2{color:#d8ac31}
.v43-github-screen .sa-security-grid{gap:10px}
.v43-github-screen .sa-security-badge.bad{
  color:#ff98a9;
  border-color:#a63f51;
  background:linear-gradient(180deg,#37151f,#27121a);
  padding:8px 12px;
}
.v43-github-screen .sa-security-badge.ok{padding:8px 12px}
.v43-github-screen .sa-grid.two{grid-template-columns:1fr 1fr}
.v43-github-screen .sa-token-form input,.v43-github-screen .sa-shell-embedded input,.v43-github-screen .sa-shell-embedded select{
  background:#071521;
  border-color:#31506a;
  min-height:44px;
}
.v43-github-screen .sa-primary{
  min-height:48px;
  background:linear-gradient(135deg,#e0bf55,#b78d1c);
  border-color:#efd06a;
  color:#09111c;
  font-weight:900;
  box-shadow:0 0 0 1px rgba(255,222,110,.14),0 9px 20px rgba(178,135,23,.12);
}

/* ---------- SETTINGS ---------- */
.v43-settings-screen{padding-top:0;min-height:100vh;background:#fffaf1}
.v43-settings-screen .v43-screen-hero{margin-bottom:0}
.v43-settings-card{
  margin:0 !important;
  border-radius:18px !important;
  padding:22px 20px 24px !important;
  background:linear-gradient(180deg,#fff 0%,#fffdf8 100%) !important;
  border:1px solid #dce3e9 !important;
  box-shadow:0 10px 26px rgba(15,23,42,.055) !important;
}
.v43-settings-card>h3{
  min-height:46px;
  margin:0 0 14px !important;
  color:#111f35;
  font-size:20px !important;
  border-bottom:1px solid #e8ecef !important;
}
.v43-settings-card>h3 svg{color:#d8aa18 !important}
.v43-settings-card form{gap:14px !important}
.v43-settings-card form>div:not(:last-child){border-color:#dae2e8 !important}
.v43-settings-card form>div:nth-child(1),
.v43-settings-card form>div:nth-child(2),
.v43-settings-card form>div:nth-child(3){
  position:relative;
  min-height:108px;
  border-radius:14px !important;
  padding:18px 20px !important;
  background:linear-gradient(90deg,#fff,#fbfdff) !important;
  border:1px solid #dbe3e9 !important;
  box-shadow:0 3px 10px rgba(15,23,42,.025);
}
.v43-settings-card form>div:nth-child(1)::before,
.v43-settings-card form>div:nth-child(3)::before{
  position:absolute;
  left:18px;
  top:50%;
  transform:translateY(-50%);
  width:48px;
  height:48px;
  border-radius:12px;
  display:grid;
  place-items:center;
  background:#fff8e6;
  border:1px solid #f0dfad;
  color:#bb8b07;
  font-size:23px;
}
.v43-settings-card form>div:nth-child(1)::before{content:"▣"}
.v43-settings-card form>div:nth-child(3)::before{content:"◇"}
.v43-settings-card .theme-select-btn{
  border:1px solid #e2d2a0 !important;
  background:#fffaf0 !important;
  color:#1a2637 !important;
  border-radius:9px !important;
  min-width:124px;
  font-weight:800;
}
.v43-settings-card .theme-select-btn.active{
  color:#fff !important;
  border-color:#d4aa27 !important;
  background:linear-gradient(135deg,#d8ad2d,#b98a10) !important;
  box-shadow:0 7px 16px rgba(187,139,15,.16);
}
.v43-settings-card form>div:nth-child(2) img{width:74px !important;height:74px !important;border-color:#e4bb19 !important}
.v43-settings-card form>div:nth-child(2)>div:first-child>div{background:#e5b900 !important}
.v43-settings-card form>div:nth-child(4){display:none !important}
.v43-settings-card form>h4{
  margin:0 !important;
  padding:17px 20px 7px;
  border:1px solid #dbe3e9;
  border-bottom:0;
  border-radius:14px 14px 0 0;
  background:#fff;
  color:#17243a !important;
}
.v43-settings-card form>h4+div{
  padding:10px 20px 6px;
  border-left:1px solid #dbe3e9;
  border-right:1px solid #dbe3e9;
  background:#fff;
}
.v43-settings-card form>h4+div+div{
  padding:6px 20px 12px;
  border-left:1px solid #dbe3e9;
  border-right:1px solid #dbe3e9;
  background:#fff;
}
.v43-settings-card form>h4+div+div+div{
  margin-top:0 !important;
  padding:4px 20px 18px;
  border:1px solid #dbe3e9;
  border-top:0;
  border-radius:0 0 14px 14px;
  background:#fff;
  justify-content:flex-start !important;
}
.v43-settings-card input{
  min-height:44px;
  background:#f8fafc !important;
  border-color:#d4dde6 !important;
  border-radius:9px !important;
  color:#27364b !important;
}
.v43-settings-card button[type="submit"]{
  min-height:48px;
  padding:11px 28px !important;
  background:linear-gradient(135deg,#ddb431,#b8870f) !important;
  color:#fff !important;
  border-radius:10px !important;
  box-shadow:0 8px 18px rgba(185,135,15,.18) !important;
}

@media (max-width:1200px){
  .v43-screen-hero__left{width:58%}
  .v43-github-screen .sa-grid.three{grid-template-columns:repeat(3,minmax(0,1fr))}
}
CSS

# Guards
[ "$(grep -c "AdminDashboard.v43.css" "$JSX")" -eq 1 ]
grep -q "v43-notifications-screen" "$JSX"
grep -q "v43-github-screen" "$JSX"
grep -q "v43-settings-screen" "$JSX"
grep -q "v43-screen-hero" "$JSX"

echo "PATCH_APPLIED=YES"
echo "RUNTIME_CSS=AdminDashboard.v43.css"
echo "VISUAL_STRATEGY=THREE_SCREEN_REFERENCE_BATCH"
echo "SCREENS=NOTIFICATIONS,GITHUB,SETTINGS"
echo "DATA_CHANGED=NO"
echo "LOGIC_CHANGED=NO"
echo "BACKEND_CHANGED=NO"
echo "AUTH_CHANGED=NO"
echo "SOURCE_PROJECT_PUSHED=NO"
