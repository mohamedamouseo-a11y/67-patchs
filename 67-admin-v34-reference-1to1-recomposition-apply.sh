#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
JSX=src/pages/AdminDashboard.jsx
SOURCE_CSS=src/pages/AdminDashboard.v33.css
TARGET_CSS=src/pages/AdminDashboard.v34.css
BACKUP=/tmp/67-v34-$$
MARKER='SIX SEVEN ADMIN V34 — REFERENCE 1TO1 RECOMPOSITION'

cd "$ROOT"
[ -f "$JSX" ] || { echo 'FAILED_STEP=JSX_MISSING'; exit 1; }
[ -f "$SOURCE_CSS" ] || { echo 'FAILED_STEP=V33_CSS_MISSING'; exit 1; }
grep -q "import './AdminDashboard.v33.css';" "$JSX" || { echo 'FAILED_STEP=V33_RUNTIME_NOT_ACTIVE'; exit 1; }

mkdir -p "$BACKUP"
cp "$JSX" "$BACKUP/AdminDashboard.jsx"
cp "$SOURCE_CSS" "$BACKUP/AdminDashboard.v33.css"
cp "$SOURCE_CSS" "$TARGET_CSS"

python3 - <<'PY'
from pathlib import Path
p=Path('/67/src/pages/AdminDashboard.jsx')
s=p.read_text()
old="import './AdminDashboard.v33.css';"
new="import './AdminDashboard.v34.css';"
if old not in s:
    raise SystemExit('V33_IMPORT_NOT_FOUND')
p.write_text(s.replace(old,new,1))
PY

cat >> "$TARGET_CSS" <<'CSS'

/* SIX SEVEN ADMIN V34 — REFERENCE 1TO1 RECOMPOSITION
   Visual target: the approved luxury automotive executive dashboard reference.
   CSS-only recomposition. No data, business logic, auth, routing or API changes.
*/

:root{
  --v34-bg:#f7f2e8;
  --v34-paper:#fffdf8;
  --v34-paper-2:#fbf5e9;
  --v34-ink:#07101a;
  --v34-ink-2:#0d1722;
  --v34-ink-3:#13202d;
  --v34-gold:#d7a72f;
  --v34-gold-deep:#9d6d10;
  --v34-line:rgba(174,119,15,.26);
  --v34-green:#12ad78;
  --v34-cyan:#29c7bd;
  --v34-red:#d72027;
  --v34-shadow:0 10px 26px rgba(81,55,10,.07);
  --v34-radius:14px;
}

/* ===== PAGE / MAIN CANVAS ===== */
body .admin-exec{
  background:
    radial-gradient(circle at 12% 0%,rgba(220,174,61,.08),transparent 18%),
    linear-gradient(180deg,#fff 0%,#fbf8f1 42%,var(--v34-bg) 100%)!important;
  color:var(--v34-ink)!important;
}
body .admin-exec>div[style*="marginRight"]{
  margin-right:258px!important;
  padding:12px 14px 18px!important;
  overflow:visible!important;
}
body .admin-exec .animate-fadeIn{gap:8px!important}

/* ===== SIDEBAR — REFERENCE PROPORTIONS ===== */
body .admin-exec .admin-sidebar{
  width:244px!important;
  min-width:244px!important;
  padding:10px 10px 12px!important;
  gap:4px!important;
  background:
    radial-gradient(circle at 50% 7%,rgba(213,168,45,.09),transparent 24%),
    linear-gradient(180deg,#071019 0%,#08111a 54%,#04090e 100%)!important;
  border-left:1px solid rgba(215,167,47,.31)!important;
  box-shadow:-12px 0 28px rgba(0,0,0,.18)!important;
}
body .admin-exec .admin-sidebar::after{
  content:"";
  position:absolute;
  inset:0;
  pointer-events:none;
  background:linear-gradient(115deg,transparent 0 77%,rgba(214,170,55,.07) 77.3% 77.6%,transparent 78%);
  opacity:.8;
}
body .admin-exec .admin-sidebar__brand{
  min-height:118px!important;
  padding:7px 10px 11px!important;
  border:1px solid rgba(215,167,47,.30)!important;
  border-radius:14px!important;
  background:linear-gradient(180deg,rgba(215,167,47,.08),rgba(255,255,255,.015))!important;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.018),0 9px 20px rgba(0,0,0,.15)!important;
}
body .admin-exec .admin-sidebar__official-logo{width:122px!important;max-height:60px!important;margin:0 auto 2px!important}
body .admin-exec .admin-sidebar__brand-text h2{font-size:13px!important;color:#f1d374!important;letter-spacing:.1px!important}
body .admin-exec .admin-sidebar__brand-text span{font-size:8.5px!important;color:#8f958f!important}
body .admin-exec .back-btn{width:27px!important;height:27px!important;padding:0!important;display:grid!important;place-items:center!important;border-radius:9px!important;color:#e0ba55!important;border-color:rgba(215,167,47,.26)!important;background:rgba(255,255,255,.025)!important}
body .admin-exec .admin-sidebar__group-label{margin:9px 8px 3px!important;font-size:7.5px!important;letter-spacing:1.05px!important;color:#9f7620!important}
body .admin-exec .admin-sidebar-button{
  min-height:38px!important;
  padding:7px 10px!important;
  border-radius:9px!important;
  font-size:10px!important;
  color:#e7e7e2!important;
  background:rgba(255,255,255,.012)!important;
  border:1px solid rgba(215,167,47,.16)!important;
}
body .admin-exec .admin-sidebar-button .sb-ico{color:#b68a2a!important}
body .admin-exec .admin-sidebar-button.active{
  color:#fff4cb!important;
  background:linear-gradient(90deg,rgba(197,139,25,.34),rgba(214,168,49,.12))!important;
  border-color:rgba(231,190,81,.58)!important;
  box-shadow:inset 3px 0 0 #e0b548,0 0 14px rgba(207,153,31,.22)!important;
}
body .admin-exec .admin-sidebar__footer{
  position:relative!important;
  margin-top:auto!important;
  padding-top:142px!important;
}
body .admin-exec .admin-sidebar__footer::before{
  content:"♛\A تميّز في كل خطوة\A معًا نحو مستقبل أكثر تميزًا";
  white-space:pre-line;
  position:absolute;
  left:0;right:0;top:5px;
  height:126px;
  padding:14px 12px 10px;
  border-radius:12px;
  color:#efd276;
  font-size:9px;
  line-height:1.65;
  text-align:center;
  font-weight:800;
  background:
    linear-gradient(180deg,rgba(6,11,16,.16),rgba(5,9,14,.92)),
    url('../assets/admin-v29.4-hero-highres.jpg') center 63%/cover no-repeat;
  border:1px solid rgba(215,167,47,.25);
  box-shadow:inset 0 0 26px rgba(0,0,0,.38);
}
body .admin-exec .admin-sidebar__identity{
  min-height:54px!important;
  margin:0 0 5px!important;
  padding:8px 10px!important;
  border-radius:11px!important;
  background:#0b141e!important;
  border:1px solid rgba(215,167,47,.18)!important;
}
body .admin-exec .admin-sidebar__identity-avatar{width:34px!important;height:34px!important;background:linear-gradient(145deg,#ffe59b,#be8720)!important;color:#111!important;font-size:10px!important;font-weight:900!important}
body .admin-exec .admin-sidebar__identity-info strong{font-size:9px!important;color:#fff!important}
body .admin-exec .admin-sidebar__identity-info small{font-size:7px!important;color:#9aa0a5!important}
body .admin-exec .admin-sidebar-button--logout{background:#0c1218!important;border-color:rgba(215,167,47,.13)!important;color:#ddd!important}

/* ===== HERO — SAME CINEMATIC COMPOSITION ===== */
body .admin-exec .ov-header{
  height:174px!important;
  min-height:174px!important;
  border-radius:14px!important;
  border:1px solid rgba(218,169,48,.34)!important;
  box-shadow:0 12px 27px rgba(0,0,0,.18)!important;
  background:#05090d!important;
}
body .admin-exec .ov-header::after{
  background:
    linear-gradient(90deg,rgba(2,6,9,.84) 0%,rgba(2,6,9,.36) 21%,rgba(2,6,9,.03) 47%,rgba(2,6,9,.22) 69%,rgba(2,6,9,.86) 100%),
    radial-gradient(circle at 73% 59%,rgba(240,189,65,.16),transparent 27%),
    linear-gradient(180deg,rgba(0,0,0,.04),transparent 59%,rgba(0,0,0,.34))!important;
}
body .admin-exec .ov-header__motif{
  background-image:var(--hero-v295-image)!important;
  background-size:cover!important;
  background-position:center 55%!important;
  filter:saturate(1.08) contrast(1.04) brightness(.95)!important;
}
body .admin-exec .ov-header__copy-left{
  position:absolute!important;
  left:18px!important;
  right:auto!important;
  top:18px!important;
  width:37%!important;
  z-index:8!important;
  text-align:left!important;
  direction:rtl!important;
}
body .admin-exec .ov-header__copy-left::before{
  content:"مرحبا بك مجددًا   •   Super Admin";
  display:block;
  margin-bottom:14px;
  font-size:8px;
  font-weight:800;
  color:#f4d67f;
  letter-spacing:.1px;
}
body .admin-exec .ov-header__copy-left .ov-header__eyebrow{display:none!important}
body .admin-exec .ov-header__copy-left h1{
  max-width:430px!important;
  margin:0 0 4px!important;
  font-size:23px!important;
  line-height:1.2!important;
  font-weight:900!important;
  color:#fff2c6!important;
  text-shadow:0 3px 16px rgba(0,0,0,.75)!important;
}
body .admin-exec .ov-header__copy-left h1 span{color:#f5db88!important}
body .admin-exec .ov-header__copy-left p{max-width:360px!important;font-size:8.5px!important;line-height:1.5!important;color:#e6e7e5!important}
body .admin-exec .ov-header__copy-right{
  position:absolute!important;
  right:26px!important;
  left:auto!important;
  top:26px!important;
  z-index:8!important;
  width:220px!important;
  text-align:right!important;
  direction:rtl!important;
  color:#fff!important;
}
body .admin-exec .ov-header__copy-right>span{display:block!important;font-size:13px!important;font-weight:800!important;color:#fff4d4!important}
body .admin-exec .ov-header__copy-right>strong{display:block!important;margin:1px 0 4px!important;font-size:17px!important;line-height:1.15!important;color:#f1d36d!important}
body .admin-exec .ov-header__copy-right>small{font-size:6.8px!important;letter-spacing:1.5px!important;color:#d9cba7!important}
body .admin-exec .ov-header__toolbar-top{
  position:absolute!important;
  left:18px!important;
  right:18px!important;
  bottom:9px!important;
  top:auto!important;
  z-index:12!important;
}
body .admin-exec .executive-date-shell{
  width:min(735px,72%)!important;
  height:36px!important;
  padding:3px!important;
  display:flex!important;
  align-items:center!important;
  gap:4px!important;
  border-radius:9px!important;
  background:rgba(3,8,13,.90)!important;
  border:1px solid rgba(221,177,62,.28)!important;
  box-shadow:0 7px 17px rgba(0,0,0,.24)!important;
  backdrop-filter:blur(9px)!important;
}
body .admin-exec .executive-date-display{height:28px!important;min-height:28px!important;border-radius:6px!important;background:rgba(255,255,255,.02)!important;border-color:rgba(215,167,47,.22)!important}
body .admin-exec .executive-date-display__copy small{font-size:5.5px!important}
body .admin-exec .executive-date-display__copy strong{font-size:7.5px!important}
body .admin-exec .executive-date-presets{height:28px!important;gap:2px!important}
body .admin-exec .executive-date-preset{height:28px!important;min-height:28px!important;padding:0 10px!important;font-size:7px!important;border-radius:6px!important}
body .admin-exec .executive-date-preset.active{background:rgba(205,154,38,.23)!important;color:#f3d372!important;border-color:rgba(222,180,69,.45)!important}
body .admin-exec .executive-date-actions{height:28px!important;gap:2px!important}
body .admin-exec .executive-date-action{width:28px!important;height:28px!important;border-radius:6px!important;color:#c9b36d!important}

/* ===== KPI STRIP ===== */
body .admin-exec .kpi-grid{grid-template-columns:repeat(4,minmax(0,1fr))!important;gap:7px!important}
body .admin-exec .kpi-card{
  height:86px!important;
  min-height:86px!important;
  padding:9px 11px 8px!important;
  border-radius:11px!important;
  background:linear-gradient(180deg,#fffefa 0%,#fbf6eb 100%)!important;
  border:1px solid rgba(195,137,19,.24)!important;
  box-shadow:0 7px 17px rgba(87,57,9,.05)!important;
}
body .admin-exec .kpi-card__label{font-size:8px!important;color:#706d66!important}
body .admin-exec .kpi-card__icon{width:29px!important;height:29px!important;border-radius:8px!important;background:#fff8e9!important;color:#b77e0f!important}
body .admin-exec .kpi-card__icon svg{width:14px!important;height:14px!important}
body .admin-exec .kpi-card__value{font-size:21px!important;letter-spacing:-.02em!important}
body .admin-exec .kpi-card__value small{font-size:7px!important}
body .admin-exec .kpi-card__note{padding-left:0!important;font-size:7px!important;min-height:13px!important}
body .admin-exec .kpi-card::after{
  left:15px!important;bottom:9px!important;width:86px!important;height:18px!important;opacity:.85!important;
  clip-path:none!important;
  background:none!important;
  border-top:1.5px solid #2ab9aa!important;
  border-radius:50%!important;
  transform:skewX(-12deg) rotate(-2deg)!important;
}
body .admin-exec .kpi-card:nth-child(2)::after{border-color:#45c5ab!important;transform:skewX(10deg) rotate(2deg)!important}
body .admin-exec .kpi-card:nth-child(3)::after{border-color:#e0a641!important;transform:skewX(-8deg) rotate(1deg)!important}
body .admin-exec .kpi-card:nth-child(4)::after{border-color:#5ca6e8!important;transform:skewX(8deg) rotate(-3deg)!important}

/* ===== SYSTEM HEALTH — DARK SINGLE STRIP ===== */
body .admin-exec .syshealth{
  height:96px!important;
  min-height:96px!important;
  border-radius:12px!important;
  background:linear-gradient(101deg,#071019 0%,#0c1721 58%,#091019 100%)!important;
  border-color:rgba(218,170,49,.20)!important;
}
body .admin-exec .syshealth__layout{grid-template-columns:18% 57% 25%!important;gap:7px!important;padding:8px 10px!important}
body .admin-exec .syshealth__zone-left{padding-right:8px!important}
body .admin-exec .syshealth__title{font-size:9.2px!important}
body .admin-exec .syshealth__title small{font-size:6.5px!important}
body .admin-exec .syshealth__status{font-size:6.7px!important}
body .admin-exec .syshealth__status-text{font-size:6.3px!important}
body .admin-exec .syshealth__grid{gap:5px!important}
body .admin-exec .syshealth__metric{height:78px!important;min-height:78px!important;padding:8px!important;border-radius:9px!important;background:linear-gradient(180deg,#10202e,#0d1823)!important}
body .admin-exec .syshealth__metric label{font-size:6.6px!important}
body .admin-exec .syshealth__metric strong{font-size:15px!important}
body .admin-exec .syshealth__metric small{font-size:5.7px!important}
body .admin-exec .syshealth__zone-right{background-position:center 58%!important;box-shadow:inset 35px 0 34px rgba(5,9,14,.42)!important}
body .admin-exec .syshealth__zone-right::after{
  content:"أداء مستقر\A لرحلة أكثر سلاسة\A STABLE TODAY — SMOOTHER TOMORROW";
  white-space:pre-line;
  position:absolute;
  right:10px;top:12px;
  width:118px;
  text-align:right;
  color:#eed276;
  font-size:8px;
  font-weight:800;
  line-height:1.42;
  text-shadow:0 2px 8px rgba(0,0,0,.8);
}

/* ===== REVENUE — FULL WIDTH REFERENCE COMPOSITION ===== */
body .admin-exec .admin-command-grid{
  grid-template-columns:1fr 1fr!important;
  grid-template-areas:"revenue revenue" "live ops"!important;
  gap:8px!important;
  align-items:stretch!important;
}
body .admin-exec .adm-chart-card{
  grid-area:revenue!important;
  height:278px!important;
  min-height:278px!important;
  max-height:278px!important;
  padding:9px 10px 10px!important;
  border-radius:12px!important;
  background:linear-gradient(180deg,#fffefb,#fbf6ed)!important;
  border:1px solid rgba(185,127,16,.25)!important;
  box-shadow:var(--v34-shadow)!important;
}
body .admin-exec .adm-chart-card__head{height:31px!important;min-height:31px!important;margin:0 0 5px!important}
body .admin-exec .rev-title-icon{width:29px!important;height:29px!important;border-radius:8px!important}
body .admin-exec .rev-title-copy h3{font-size:11px!important;color:#13181d!important}
body .admin-exec .rev-title-copy small{font-size:6.3px!important;color:#88837a!important}
body .admin-exec .rev-period-pill{height:20px!important;padding:0 7px!important;font-size:6px!important}
body .admin-exec .rev-stats{height:45px!important;margin:0 0 6px!important;gap:5px!important;grid-template-columns:repeat(4,minmax(0,1fr))!important}
body .admin-exec .rev-stat{height:45px!important;min-height:45px!important;padding:5px 7px!important;border-radius:7px!important;background:#fffdf8!important}
body .admin-exec .rev-stat small{font-size:5.8px!important}
body .admin-exec .rev-stat strong{font-size:11px!important}
body .admin-exec .rev-stat span{font-size:5.4px!important}
body .admin-exec .rev-visual-grid{height:181px!important;min-height:181px!important;max-height:181px!important;grid-template-columns:minmax(0,1fr) 232px!important;gap:8px!important}
body .admin-exec .adex-chart{height:181px!important;min-height:181px!important;border-radius:10px!important;background:#fffdfa!important;border:1px solid rgba(182,126,18,.13)!important}
body .admin-exec .adex-chart::before{content:"الإيرادات (ر.س)"!important;top:8px!important;right:10px!important;font-size:6px!important;color:#8e877e!important}
body .admin-exec .rev-total{
  height:181px!important;
  max-width:232px!important;
  border-radius:10px!important;
  background:linear-gradient(145deg,#0a1520,#0c1924)!important;
  border:1px solid rgba(215,167,47,.22)!important;
  display:flex!important;
  flex-direction:column!important;
  justify-content:center!important;
  align-items:center!important;
  gap:5px!important;
}
body .admin-exec .rev-total::before{content:"توزيع الإيرادات";font-size:9px;font-weight:900;color:#fff;align-self:stretch;text-align:right;padding:0 12px}
body .admin-exec .rev-total__ring{width:98px!important;height:98px!important;min-width:98px!important;min-height:98px!important}
body .admin-exec .rev-total__ring-core strong{font-size:12px!important;color:#fff!important}
body .admin-exec .rev-total__ring-core small{font-size:6px!important}
body .admin-exec .rev-total__copy{width:100%!important;display:grid!important;grid-template-columns:auto 1fr auto!important;align-items:center!important;gap:4px!important;padding:0 10px!important}
body .admin-exec .rev-total__copy>span{display:none!important}
body .admin-exec .rev-total__copy>strong{font-size:8px!important;color:#efd16e!important}
body .admin-exec .rev-total__copy>small{font-size:5.5px!important;color:#8f98a3!important}
body .admin-exec .rev-total__copy>em{font-size:6.5px!important}

/* ===== OPERATIONS — SAME TWO-COLUMN RHYTHM ===== */
body .admin-exec .live-card,
body .admin-exec .ops-card{
  height:242px!important;
  min-height:242px!important;
  max-height:242px!important;
  border-radius:12px!important;
  box-shadow:var(--v34-shadow)!important;
}
body .admin-exec .live-card{
  grid-area:live!important;
  padding:9px 10px!important;
  background:linear-gradient(180deg,#08131d,#0a1621)!important;
  border:1px solid rgba(215,167,47,.19)!important;
}
body .admin-exec .live-card__head{height:27px!important;min-height:27px!important;margin:0 0 5px!important;border-bottom:1px solid rgba(215,167,47,.15)!important}
body .admin-exec .live-card__head h3{font-size:10px!important;color:#fff!important}
body .admin-exec .live-card__badge{height:20px!important;font-size:7px!important;background:rgba(210,161,43,.13)!important;color:#e3bd5c!important}
body .admin-exec .live-card__list{gap:4px!important}
body .admin-exec .live-item{height:34px!important;min-height:34px!important;max-height:34px!important;padding:4px 6px!important;border-radius:8px!important;background:#101e2a!important;border:1px solid rgba(255,255,255,.055)!important}
body .admin-exec .live-item__ico{width:23px!important;height:23px!important;min-width:23px!important}
body .admin-exec .live-item__body p{font-size:7.4px!important;color:#fff!important}
body .admin-exec .live-item__body small,body .admin-exec .live-item .when{font-size:5.4px!important;color:#8694a0!important}
body .admin-exec .live-activity-summary{height:48px!important;min-height:48px!important;max-height:48px!important;margin-top:5px!important;background:#101b25!important;border-color:rgba(215,167,47,.16)!important}
body .admin-exec .live-card__footer{height:42px!important;min-height:42px!important;max-height:42px!important;margin-top:5px!important}
body .admin-exec .live-cta{height:21px!important;min-height:21px!important;background:rgba(202,153,38,.12)!important;border-color:rgba(215,167,47,.27)!important;color:#e6c568!important}

body .admin-exec .ops-card{
  grid-area:ops!important;
  padding:9px 10px!important;
  background:linear-gradient(180deg,#fffefb,#fbf5e9)!important;
  border:1px solid rgba(190,132,22,.24)!important;
}
body .admin-exec .ops-card__head{height:28px!important;min-height:28px!important;margin:0 0 5px!important}
body .admin-exec .ops-card__title-group h3{font-size:10px!important;color:#171b20!important}
body .admin-exec .ops-card__title-group small{font-size:5.7px!important;color:#8d877e!important}
body .admin-exec .ops-card__command-badge{height:19px!important;font-size:5.8px!important;background:#fff4da!important;color:#93650d!important}
body .admin-exec .ops-summary-row{height:39px!important;min-height:39px!important;max-height:39px!important;gap:4px!important}
body .admin-exec .ops-summary-tile{height:39px!important;min-height:39px!important;max-height:39px!important;border-radius:7px!important;background:#fff9ef!important}
body .admin-exec .ops-summary-tile--ok{background:#edf9f5!important;border-color:rgba(19,170,119,.22)!important}
body .admin-exec .ops-summary-tile strong{font-size:11px!important}
body .admin-exec .ops-tiles{height:104px!important;min-height:104px!important;max-height:104px!important;grid-template-rows:repeat(3,32px)!important;gap:4px!important}
body .admin-exec .ops-tile{height:32px!important;min-height:32px!important;max-height:32px!important;padding:3px 5px!important;border-radius:8px!important;background:#fffdf9!important}
body .admin-exec .ops-card>.ops-tile{height:32px!important;min-height:32px!important;max-height:32px!important}
body .admin-exec .ops-good-strip{height:22px!important;min-height:22px!important;max-height:22px!important;border-radius:7px!important;background:#e9f8f3!important;color:#07845b!important}

/* ===== FINANCIAL LEDGER — REFERENCE FOOTER TABLE ===== */
body .admin-exec .tx-card{
  margin-top:0!important;
  border-radius:12px!important;
  overflow:hidden!important;
  background:#fffdf8!important;
  border:1px solid rgba(188,130,19,.25)!important;
  box-shadow:var(--v34-shadow)!important;
}
body .admin-exec .tx-card__head{
  min-height:54px!important;
  padding:8px 11px!important;
  background:linear-gradient(95deg,#0b1721 0%,#0e1b26 65%,#111d26 100%)!important;
  border-bottom:1px solid rgba(215,167,47,.16)!important;
}
body .admin-exec .tx-card__title-icon{width:30px!important;height:30px!important;border-radius:8px!important;background:rgba(215,167,47,.13)!important;color:#d8ad40!important}
body .admin-exec .tx-card__title-group h3{font-size:10px!important;color:#fff!important}
body .admin-exec .tx-card__title-group small{font-size:5.7px!important;color:#8f9aa5!important}
body .admin-exec .tx-card__count-badge{height:20px!important;font-size:6px!important;background:rgba(215,167,47,.12)!important;color:#e0bb59!important}
body .admin-exec .tx-card__head-actions input{height:28px!important;border-radius:7px!important;background:#f5f6f7!important;border-color:#d6d9dc!important;font-size:6.5px!important}
body .admin-exec .tx-card__head-actions button{height:28px!important;border-radius:7px!important;font-size:6.3px!important}
body .admin-exec .tx-ledger-summary{grid-template-columns:repeat(3,minmax(0,1fr))!important;gap:6px!important;padding:8px 10px 7px!important;background:#fffdf8!important}
body .admin-exec .tx-ledger-summary__item{height:46px!important;min-height:46px!important;padding:7px 10px!important;border-radius:8px!important;background:#fffefb!important;border:1px solid rgba(189,133,25,.15)!important}
body .admin-exec .tx-ledger-summary__item strong{font-size:14px!important}
body .admin-exec .tx-ledger-summary__item small{font-size:6px!important}
body .admin-exec .tx-card__table-wrap{padding:0 10px 10px!important;background:#fffdf8!important}
body .admin-exec .tx-card table{border-collapse:separate!important;border-spacing:0!important;width:100%!important;border:1px solid rgba(185,127,16,.12)!important;border-radius:8px!important;overflow:hidden!important}
body .admin-exec .tx-card thead th{height:25px!important;padding:5px 7px!important;font-size:5.8px!important;font-weight:800!important;color:#6f6a62!important;background:#f7edda!important;border-bottom:1px solid rgba(190,132,22,.15)!important}
body .admin-exec .tx-card tbody td{height:28px!important;padding:5px 7px!important;font-size:6.2px!important;color:#34373a!important;background:#fff!important;border-bottom:1px solid #f0ece5!important}
body .admin-exec .tx-card tbody tr:nth-child(even) td{background:#fffcf6!important}
body .admin-exec .tx-amount{background:#fff1c9!important;color:#93630a!important;border-color:#ecd18b!important}
body .admin-exec .tx-status{border-radius:99px!important}

/* ===== CUSTOM DATE PANEL ===== */
body .admin-exec .executive-date-flow-slot{margin-top:0!important}
body .admin-exec .executive-date-popover--flow{border-radius:12px!important;background:#fffdf8!important;border-color:rgba(190,132,22,.25)!important;box-shadow:0 14px 34px rgba(65,44,8,.12)!important}

/* ===== RESPONSIVE LOCKS ===== */
@media (max-width:1500px){
  body .admin-exec>div[style*="marginRight"]{margin-right:238px!important;padding:10px 11px 16px!important}
  body .admin-exec .admin-sidebar{width:224px!important;min-width:224px!important}
  body .admin-exec .admin-sidebar__footer{padding-top:132px!important}
  body .admin-exec .admin-sidebar__footer::before{height:117px!important}
  body .admin-exec .ov-header{height:166px!important;min-height:166px!important}
  body .admin-exec .adm-chart-card{height:270px!important;min-height:270px!important;max-height:270px!important}
  body .admin-exec .rev-visual-grid,body .admin-exec .adex-chart,body .admin-exec .rev-total{height:173px!important;min-height:173px!important;max-height:173px!important}
  body .admin-exec .live-card,body .admin-exec .ops-card{height:232px!important;min-height:232px!important;max-height:232px!important}
}

@media (max-width:1100px){
  body .admin-exec>div[style*="marginRight"]{margin-right:0!important;padding:9px!important}
  body .admin-exec .admin-sidebar{display:none!important}
  body .admin-exec .kpi-grid{grid-template-columns:repeat(2,minmax(0,1fr))!important}
  body .admin-exec .admin-command-grid{grid-template-columns:1fr!important;grid-template-areas:"revenue" "live" "ops"!important}
  body .admin-exec .adm-chart-card,body .admin-exec .live-card,body .admin-exec .ops-card{height:auto!important;min-height:unset!important;max-height:none!important}
  body .admin-exec .rev-visual-grid{grid-template-columns:1fr!important;height:auto!important;max-height:none!important}
  body .admin-exec .rev-total{max-width:none!important;width:100%!important}
}
CSS

grep -q "$MARKER" "$TARGET_CSS" || {
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=CSS_MARKER_MISSING'
  exit 1
}

npm run build >/tmp/67-v34-build.log 2>&1 || {
  tail -n 180 /tmp/67-v34-build.log || true
  cp "$BACKUP/AdminDashboard.jsx" "$JSX"
  rm -f "$TARGET_CSS"
  echo 'FAILED_STEP=BUILD_FAILED'
  exit 1
}

echo '=================================================='
echo 'PROJECT=67 ADMIN DASHBOARD'
echo 'VERSION=V34'
echo 'ELEMENT=FULL DASHBOARD REFERENCE 1TO1 RECOMPOSITION'
echo 'BASE_VERSION=V33'
echo 'TARGET_VERSION=V34'
echo '=================================================='
echo 'PATCH_APPLIED=YES'
echo 'BUILD=PASS'
echo 'RUNTIME_CSS=AdminDashboard.v34.css'
echo 'REFERENCE_MODE=1TO1'
echo 'JSX_STRUCTURE_CHANGED=NO'
echo 'DATA_CHANGED=NO'
echo 'LOGIC_CHANGED=NO'
echo 'BACKEND_CHANGED=NO'
echo 'AUTH_CHANGED=NO'
echo 'SOURCE_PROJECT_PUSHED=NO'
