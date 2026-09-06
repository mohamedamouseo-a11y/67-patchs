#!/usr/bin/env bash
set -euo pipefail

[ "$(git branch --show-current)" = "redesign/store-home-concept-1" ] || { echo "Wrong branch"; exit 1; }

python3 <<'PY'
from pathlib import Path

app=Path('src/App.jsx')
s=app.read_text()
if "import './premium-v3.css';" not in s:
    s=s.replace("import './App.css';", "import './App.css';\nimport './premium-v3.css';")
app.write_text(s)

home=Path('src/pages/Home.jsx')
s=home.read_text()
old='''          <div className="lux-hero__visual" aria-hidden="true">\n            <div className="lux-orbit lux-orbit--1" />\n            <div className="lux-orbit lux-orbit--2" />\n            <div className="lux-stage" />\n            <Car className="lux-car" size={260} strokeWidth={1.05} />\n            <span className="lux-float lux-float--a"><Wrench size={18} /> صيانة</span>\n            <span className="lux-float lux-float--b"><PackageSearch size={18} /> قطع غيار</span>\n          </div>'''
new='''          <div className="lux-hero__visual lux-v3-showcase" aria-hidden="true">\n            <div className="lux-v3-frame">\n              <div className="lux-v3-glow" />\n              <div className="lux-v3-lines lux-v3-lines--a" />\n              <div className="lux-v3-lines lux-v3-lines--b" />\n              <div className="lux-v3-car-shell">\n                <span className="lux-v3-badge">67 SELECT</span>\n                <Car className="lux-v3-car" size={210} strokeWidth={1.15} />\n                <div className="lux-v3-base" />\n              </div>\n              <div className="lux-v3-part lux-v3-part--a">\n                <span><Wrench size={20} /></span>\n                <div><small>خدمة معتمدة</small><strong>ورش وإصلاح</strong></div>\n              </div>\n              <div className="lux-v3-part lux-v3-part--b">\n                <span><PackageSearch size={20} /></span>\n                <div><small>اختيار أدق</small><strong>قطع غيار</strong></div>\n              </div>\n              <div className="lux-v3-signature">PREMIUM AUTOMOTIVE</div>\n            </div>\n          </div>'''
if old not in s: raise SystemExit('Hero block not found')
s=s.replace(old,new,1)
old2='''              <article className="lux-service" key={title}>\n                <span className="lux-service__icon"><Icon size={26} /></span>\n                <h3>{title}</h3>\n                <p>{text}</p>\n                <button aria-label={title}><ArrowLeft size={17} /></button>\n              </article>'''
new2='''              <article className="lux-service lux-v3-service" key={title}>\n                <div className="lux-v3-service__top">\n                  <span className="lux-service__icon"><Icon size={26} /></span>\n                  <span className="lux-v3-service__mark">67</span>\n                </div>\n                <h3>{title}</h3>\n                <p>{text}</p>\n                <button aria-label={title}><ArrowLeft size={17} /></button>\n              </article>'''
if old2 not in s: raise SystemExit('Service block not found')
s=s.replace(old2,new2,1)
home.write_text(s)
PY

cat > src/premium-v3.css <<'CSS'
:root{--v3-cream:#fbf5e9;--v3-ivory:#fffdf8;--v3-gold:#c69a3a;--v3-gold-dark:#9f7422;--v3-charcoal:#211f1c;--v3-green:#1e3a29}
.lux-header__inner{min-height:70px}
.lux-hero__grid{min-height:395px;padding-top:42px;padding-bottom:82px;gap:42px}
.lux-hero__copy h1{max-width:620px;font-size:clamp(44px,5vw,64px)}
.lux-hero__copy p{max-width:530px}.lux-primary{min-width:136px}
.lux-v3-showcase{min-height:300px}
.lux-v3-frame{width:min(100%,500px);min-height:300px;position:relative;border:1px solid rgba(198,154,58,.24);border-radius:34px;overflow:hidden;background:radial-gradient(circle at 50% 38%,rgba(198,154,58,.12),transparent 34%),linear-gradient(145deg,rgba(255,255,255,.92),rgba(248,239,222,.82));box-shadow:0 28px 60px rgba(91,70,32,.10),inset 0 1px 0 rgba(255,255,255,.9)}
.lux-v3-frame:before{content:"";position:absolute;inset:14px;border:1px solid rgba(198,154,58,.12);border-radius:25px;pointer-events:none}
.lux-v3-glow{position:absolute;width:260px;height:260px;border-radius:50%;left:50%;top:44%;transform:translate(-50%,-50%);background:radial-gradient(circle,rgba(198,154,58,.16) 0 32%,rgba(198,154,58,.03) 33% 53%,transparent 54%);box-shadow:0 0 0 1px rgba(198,154,58,.13)}
.lux-v3-lines{position:absolute;width:190px;height:1px;background:linear-gradient(90deg,transparent,rgba(198,154,58,.45),transparent)}
.lux-v3-lines--a{right:-15px;top:68px;transform:rotate(-18deg)}.lux-v3-lines--b{left:-20px;bottom:58px;transform:rotate(15deg)}
.lux-v3-car-shell{position:absolute;inset:55px 70px 52px;display:grid;place-items:center;z-index:2}
.lux-v3-badge{position:absolute;top:-18px;right:0;padding:6px 10px;border-radius:999px;background:var(--v3-charcoal);color:#f4d991;font-size:9px;font-weight:900;letter-spacing:1.2px}
.lux-v3-car{width:min(100%,290px);height:auto;color:#45423d;filter:drop-shadow(0 18px 14px rgba(54,46,36,.14))}
.lux-v3-base{position:absolute;width:84%;height:42px;bottom:6px;border-radius:50%;transform:perspective(420px) rotateX(67deg);background:linear-gradient(#fff,#e9dcc5);box-shadow:0 19px 26px rgba(85,64,29,.12);z-index:-1}
.lux-v3-part{position:absolute;z-index:4;min-width:142px;padding:10px 12px;border-radius:15px;display:flex;align-items:center;gap:9px;background:rgba(255,255,255,.94);border:1px solid #e9dfcf;box-shadow:0 14px 28px rgba(69,57,38,.09)}
.lux-v3-part>span{width:37px;height:37px;border-radius:11px;display:grid;place-items:center;background:#fbf3e3;color:var(--v3-gold-dark)}
.lux-v3-part>div{display:grid;gap:1px}.lux-v3-part small{color:#9a9389;font-size:8px}.lux-v3-part strong{color:#3f3b35;font-size:10px;font-weight:900}
.lux-v3-part--a{right:20px;bottom:24px}.lux-v3-part--b{left:22px;top:33px}.lux-v3-signature{position:absolute;left:25px;bottom:24px;color:rgba(159,116,34,.55);font-size:8px;font-weight:900;letter-spacing:1.8px}
.lux-finder{padding:15px;border-radius:21px;box-shadow:0 22px 54px rgba(57,48,34,.11)}
.lux-field{min-height:72px;background:linear-gradient(#fff,#fffdf9)}
.lux-search-btn{min-width:122px;background:linear-gradient(180deg,#d1a447,#b98627);box-shadow:0 12px 24px rgba(165,116,24,.17)}
.lux-stats{padding-top:16px}.lux-stat{min-height:82px;padding:14px 16px;border-radius:15px}.lux-stat__icon{width:40px;height:40px}.lux-stat strong{font-size:18px}
.lux-services{padding-top:40px}.lux-v3-service{min-height:205px;overflow:hidden;background:radial-gradient(circle at 0 100%,rgba(198,154,58,.10),transparent 34%),linear-gradient(180deg,#fff,#fffdf9)}
.lux-v3-service:after{content:"";position:absolute;width:92px;height:92px;left:-40px;bottom:-46px;border-radius:50%;border:1px solid rgba(198,154,58,.14)}
.lux-v3-service__top{display:flex;align-items:center;justify-content:space-between}.lux-v3-service__mark{color:rgba(159,116,34,.28);font-size:13px;font-weight:900;letter-spacing:.7px}.lux-v3-service h3{margin-top:24px;font-size:16px}.lux-v3-service p{max-width:170px;font-size:10px}
.lux-offer__card{min-height:160px;border-radius:20px;background:radial-gradient(circle at 12% 50%,rgba(198,154,58,.15),transparent 24%),linear-gradient(100deg,#fff9ee,#f6ecda 58%,#fffaf2);box-shadow:inset 0 1px 0 rgba(255,255,255,.8)}
.lux-offer__badge{min-width:86px;min-height:86px;border-radius:50%;justify-content:center;align-content:center;background:rgba(255,255,255,.72);border:1px solid rgba(198,154,58,.22)}
.lux-footer{background:var(--v3-green)!important}.lux-footer a,.lux-footer button{transition:opacity .2s ease,transform .2s ease}.lux-footer a:hover,.lux-footer button:hover{opacity:.88;transform:translateY(-1px)}
@media(max-width:820px){.lux-hero__grid{padding-top:36px;gap:24px}.lux-v3-frame{min-height:275px}.lux-v3-car-shell{inset:48px 55px 48px}}
@media(max-width:600px){.lux-hero__grid{padding-top:30px;padding-bottom:72px}.lux-v3-showcase{min-height:235px}.lux-v3-frame{min-height:230px;border-radius:24px}.lux-v3-car-shell{inset:42px 45px 38px}.lux-v3-car{width:235px}.lux-v3-part{min-width:auto;padding:8px 9px}.lux-v3-part>span{width:32px;height:32px}.lux-v3-part--a{right:12px;bottom:14px}.lux-v3-part--b{left:12px;top:22px}.lux-v3-signature{display:none}.lux-stat{min-height:76px;padding:11px}.lux-v3-service{min-height:180px}}
CSS

echo "V3 patch applied"
