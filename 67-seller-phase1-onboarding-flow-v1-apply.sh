#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/67}"
REGISTER="$ROOT/src/seller_app/pages/Register.jsx"
LOGIN="$ROOT/src/seller_app/pages/Login.jsx"
SELLER_APP="$ROOT/src/seller_app/SellerApp.jsx"
PENDING="$ROOT/src/seller_app/pages/PendingReview.jsx"
BACKUP="$(mktemp -d /tmp/67-seller-phase1.XXXXXX)"
PENDING_EXISTED=0

cd "$ROOT"
test -f "$REGISTER"
test -f "$LOGIN"
test -f "$SELLER_APP"

cp "$REGISTER" "$BACKUP/Register.jsx"
cp "$LOGIN" "$BACKUP/Login.jsx"
cp "$SELLER_APP" "$BACKUP/SellerApp.jsx"
if [ -f "$PENDING" ]; then
  PENDING_EXISTED=1
  cp "$PENDING" "$BACKUP/PendingReview.jsx"
fi

restore() {
  cp "$BACKUP/Register.jsx" "$REGISTER"
  cp "$BACKUP/Login.jsx" "$LOGIN"
  cp "$BACKUP/SellerApp.jsx" "$SELLER_APP"
  if [ "$PENDING_EXISTED" = "1" ]; then
    cp "$BACKUP/PendingReview.jsx" "$PENDING"
  else
    rm -f "$PENDING"
  fi
}
trap restore ERR

python3 - "$REGISTER" <<'PY'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
s = p.read_text()

# Seller registration is commission-first. No mandatory package during onboarding.
s = s.replace("  const [isSubmitted, setIsSubmitted] = useState(false);\n", "")
s = s.replace("  const [selectedPlan, setSelectedPlan] = useState('monthly');\n", "")

old = """  const handleSubmit = (e) => {
    e.preventDefault();
    if (step < 6) {
      setStep(step + 1);
    } else {
      setIsSubmitted(true);
    }
  };"""
new = """  const handleSubmit = (e) => {
    e.preventDefault();
    if (step < 5) {
      setStep(step + 1);
      return;
    }

    try {
      localStorage.setItem('_67_seller_application_status', 'pending');
      localStorage.setItem('_67_seller_application_submitted_at', new Date().toISOString());
    } catch {}
    navigate('/seller/pending');
  };"""
if old not in s:
    raise SystemExit("handleSubmit anchor missing")
s = s.replace(old, new, 1)

# Remove obsolete inline submitted-success view; PendingReview owns this state.
start = s.find("  if (isSubmitted) {")
end = s.find("\n  return (", start)
if start == -1 or end == -1:
    raise SystemExit("submitted-success block anchor missing")
s = s[:start] + s[end:]

# Five onboarding steps: business, responsible person, location, settlement, documents.
s = s.replace("width: `${(step-1)*20}%`", "width: `${(step-1)*25}%`")
icons_old = """            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(1, <Store size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(2, <User size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(3, <MapPin size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(4, <Building size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(5, <CreditCard size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(6, <FileCheck size={20} />)}</div>"""
icons_new = """            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(1, <Store size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(2, <User size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(3, <MapPin size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(4, <CreditCard size={20} />)}</div>
            <div style={{ position: 'relative', zIndex: 1 }}>{renderStepIcon(5, <FileCheck size={20} />)}</div>"""
if icons_old not in s:
    raise SystemExit("step icon anchor missing")
s = s.replace(icons_old, icons_new, 1)

# Add commission-first onboarding notice under title.
title_anchor = """            <h2 className="m-0" style={{ color: 'var(--text-primary)', margin: 0, fontSize: '1.6rem' }}>إنشاء حساب تاجر</h2>"""
title_new = title_anchor + """
            <span style={{ color: '#64748B', fontSize: '0.78rem', fontWeight: 700 }}>ابدأ بالعمولة فقط — لا توجد باقة إلزامية أثناء التسجيل</span>"""
s = s.replace(title_anchor, title_new, 1)

# Remove mandatory plan step completely.
plan_start = s.find("            {step === 5 && (")
docs_start = s.find("            {step === 6 && (", plan_start)
if plan_start == -1 or docs_start == -1:
    raise SystemExit("plan/doc step anchors missing")
s = s[:plan_start] + s[docs_start:].replace("{step === 6 && (", "{step === 5 && (", 1)

# Require proof of IBAN / bank account before optional visual assets.
iban_doc_anchor = """                <div className="input-group">
                  <label style={{ color: 'var(--text-secondary)', display: 'block', marginBottom: '8px', fontSize: '0.85rem' }}>شعار المتجر</label>"""
iban_doc = """                <div className="input-group">
                  <label style={{ color: 'var(--text-secondary)', display: 'block', marginBottom: '8px', fontSize: '0.85rem' }}>شهادة الآيبان / إثبات الحساب البنكي</label>
                  <input type="file" accept=".pdf,image/*" className="input-field" style={{ width: '100%', background: 'white', border: '1px solid var(--border)', borderRadius: '12px', padding: '10px', color: 'var(--text-primary)' }} required />
                  <small style={{ color: '#64748B' }}>يجب أن يظهر اسم صاحب الحساب ورقم IBAN بوضوح للمراجعة.</small>
                </div>

""" + iban_doc_anchor
if iban_doc_anchor not in s:
    raise SystemExit("IBAN document insertion anchor missing")
s = s.replace(iban_doc_anchor, iban_doc, 1)

# Add review/commission agreement at final step.
docs_close = """                <div className="input-group">
                  <label style={{ color: 'var(--text-secondary)', display: 'block', marginBottom: '8px', fontSize: '0.85rem' }}>صورة واجهة المتجر</label>
                  <input type="file" className="input-field" style={{ width: '100%', background: 'white', border: '1px solid var(--border)', borderRadius: '12px', padding: '10px', color: 'var(--text-primary)' }} required />
                </div>"""
docs_close_new = docs_close + """

                <label style={{ display: 'flex', gap: '10px', alignItems: 'flex-start', padding: '14px', borderRadius: '12px', background: '#FFF9E8', border: '1px solid rgba(212,175,55,.35)', color: '#475569', lineHeight: 1.7, fontSize: '0.86rem' }}>
                  <input type="checkbox" required style={{ marginTop: '5px', accentColor: '#D4AF37' }} />
                  <span>أقر بصحة البيانات والمستندات، وأفهم أن الحساب يبدأ بنظام العمولة على عمليات البيع الناجحة بعد موافقة إدارة 67. الباقات الإضافية اختيارية ويمكن الاشتراك بها لاحقًا من حساب التاجر.</span>
                </label>"""
if docs_close not in s:
    raise SystemExit("final agreement anchor missing")
s = s.replace(docs_close, docs_close_new, 1)

# Final button now submits after step five.
s = s.replace("{step === 6 ? 'تقديم الطلب' : 'التالي'}", "{step === 5 ? 'إرسال للمراجعة' : 'التالي'}")
s = s.replace("{step !== 6 && <ArrowLeft size={18} />}", "{step !== 5 && <ArrowLeft size={18} />}")

p.write_text(s)
PY

cat > "$PENDING" <<'JSX'
import React from 'react';
import { useNavigate } from 'react-router-dom';
import { CheckCircle2, Clock3, FileCheck2, LogIn, RefreshCcw, ShieldCheck, Store } from 'lucide-react';
import Logo67 from '../../components/Logo67';

const STATUS_COPY = {
  pending: {
    title: 'طلبك قيد المراجعة',
    description: 'استلمت إدارة 67 بيانات النشاط والمستندات. سيتم فتح لوحة التاجر بعد التحقق من السجل والهوية وبيانات IBAN.',
    tone: '#D4AF37',
    icon: Clock3,
  },
  needs_changes: {
    title: 'نحتاج تعديل بعض البيانات',
    description: 'هناك ملاحظة على طلب التاجر. ارجع إلى طلب التسجيل وحدّث البيانات أو المستندات المطلوبة ثم أعد الإرسال.',
    tone: '#D97706',
    icon: RefreshCcw,
  },
  approved: {
    title: 'تم اعتماد حساب التاجر',
    description: 'الحساب Verified / Active ويمكنك الآن تسجيل الدخول والوصول إلى لوحة أعمال 67.',
    tone: '#16A34A',
    icon: CheckCircle2,
  },
};

export default function PendingReview() {
  const navigate = useNavigate();
  let status = 'pending';
  try {
    status = localStorage.getItem('_67_seller_application_status') || 'pending';
  } catch {}
  const view = STATUS_COPY[status] || STATUS_COPY.pending;
  const StatusIcon = view.icon;

  return (
    <div className="seller-app-root" dir="rtl" style={{ minHeight: '100vh', display: 'grid', placeItems: 'center', padding: '24px', background: 'linear-gradient(145deg, rgba(248,250,252,.96), rgba(255,250,235,.95))' }}>
      <section style={{ width: 'min(720px, 100%)', background: 'rgba(255,255,255,.94)', border: '1px solid rgba(212,175,55,.24)', borderRadius: '28px', boxShadow: '0 28px 80px rgba(15,23,42,.10)', padding: '34px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', gap: '20px', alignItems: 'center', marginBottom: '28px' }}>
          <div>
            <span style={{ color: '#B8962C', fontWeight: 900, letterSpacing: '1.4px', fontSize: '0.76rem' }}>67 SELLER ONBOARDING</span>
            <h1 style={{ margin: '8px 0 6px', color: '#0F172A', fontSize: '2rem' }}>{view.title}</h1>
            <p style={{ margin: 0, color: '#64748B', lineHeight: 1.8 }}>{view.description}</p>
          </div>
          <Logo67 size={82} />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(160px,1fr))', gap: '12px', marginBottom: '24px' }}>
          {[
            [FileCheck2, 'البيانات', 'تم الاستلام'],
            [ShieldCheck, 'التحقق', status === 'approved' ? 'مكتمل' : 'قيد المراجعة'],
            [Store, 'البيع', status === 'approved' ? 'متاح الآن' : 'بعد الاعتماد'],
          ].map(([Icon, label, value]) => (
            <article key={label} style={{ padding: '18px', border: '1px solid #E2E8F0', borderRadius: '16px', background: '#F8FAFC' }}>
              <Icon size={21} color={view.tone} />
              <small style={{ display: 'block', color: '#94A3B8', margin: '9px 0 3px' }}>{label}</small>
              <strong style={{ color: '#0F172A' }}>{value}</strong>
            </article>
          ))}
        </div>

        <div style={{ padding: '16px 18px', borderRadius: '14px', background: '#FFF9E8', border: '1px solid rgba(212,175,55,.25)', color: '#475569', lineHeight: 1.7, marginBottom: '22px' }}>
          يبدأ التاجر على <strong>نظام العمولة على البيع الناجح</strong>. لا توجد باقة مدفوعة مطلوبة لفتح الحساب أو بدء البيع، ويمكن إضافة باقات اختيارية لاحقًا من داخل الحساب.
        </div>

        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          {status === 'approved' ? (
            <button type="button" onClick={() => navigate('/seller/login')} style={{ border: 0, borderRadius: '12px', padding: '13px 18px', background: 'linear-gradient(135deg,#D4AF37,#B8962C)', color: '#111', fontWeight: 900, cursor: 'pointer', display: 'flex', gap: '8px', alignItems: 'center' }}><LogIn size={18} />تسجيل الدخول</button>
          ) : status === 'needs_changes' ? (
            <button type="button" onClick={() => navigate('/seller/register')} style={{ border: 0, borderRadius: '12px', padding: '13px 18px', background: 'linear-gradient(135deg,#D4AF37,#B8962C)', color: '#111', fontWeight: 900, cursor: 'pointer' }}>تعديل الطلب</button>
          ) : (
            <button type="button" onClick={() => navigate('/seller/login')} style={{ border: '1px solid #CBD5E1', borderRadius: '12px', padding: '13px 18px', background: '#fff', color: '#334155', fontWeight: 800, cursor: 'pointer' }}>العودة لبوابة التاجر</button>
          )}
          <button type="button" onClick={() => navigate('/store')} style={{ border: 0, borderRadius: '12px', padding: '13px 18px', background: 'transparent', color: '#64748B', fontWeight: 800, cursor: 'pointer' }}>العودة للمتجر</button>
        </div>
      </section>
    </div>
  );
}
JSX

python3 - "$SELLER_APP" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text()
imp="import PendingReview from './pages/PendingReview';"
if imp not in s:
    anchor="import Register from './pages/Register';"
    if anchor not in s: raise SystemExit("SellerApp import anchor missing")
    s=s.replace(anchor, anchor+"\n"+imp, 1)
route='        <Route path="/seller/pending" element={<PendingReview />} />'
if route not in s:
    anchor='        <Route path="/seller/register" element={<Register />} />'
    if anchor not in s: raise SystemExit("SellerApp route anchor missing")
    s=s.replace(anchor, anchor+"\n"+route, 1)
p.write_text(s)
PY

python3 - "$LOGIN" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text()
old="""  const handleLogin = (e) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      navigate('/seller/dashboard');
    }, 1500);
  };"""
new="""  const handleLogin = (e) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      let applicationStatus = '';
      try { applicationStatus = localStorage.getItem('_67_seller_application_status') || ''; } catch {}
      if (applicationStatus === 'pending' || applicationStatus === 'needs_changes') {
        navigate('/seller/pending');
        return;
      }
      navigate('/seller/dashboard');
    }, 700);
  };"""
if old not in s: raise SystemExit("Login handler anchor missing")
s=s.replace(old,new,1)

copy_anchor="""              أدخل بيانات حسابك للوصول إلى لوحة تحكم المتجر."""
s=s.replace(copy_anchor, """              الدخول مخصص للتجار المعتمدين. إذا كان طلبك ما زال تحت المراجعة سنعرض لك حالته بدل فتح لوحة الأعمال.""", 1)

join_anchor="""              سجل نشاطك الآن"""
s=s.replace(join_anchor, """سجل نشاطك بدون اشتراك إلزامي""", 1)

p.write_text(s)
PY

grep -q "/seller/pending" "$SELLER_APP"
grep -q "ابدأ بالعمولة فقط" "$REGISTER"
grep -q "شهادة الآيبان" "$REGISTER"
grep -q "نظام العمولة على البيع الناجح" "$PENDING"
grep -q "_67_seller_application_status" "$LOGIN"

npm run build

trap - ERR
rm -rf "$BACKUP"

echo "PATCH=67-SELLER-PHASE1-ONBOARDING-FLOW-V1"
echo "BUILD=PASS"
echo "SELLER_STEPS=5"
echo "MANDATORY_PLAN_REMOVED=YES"
echo "PENDING_REVIEW_ROUTE=YES"
echo "IBAN_PROOF_REQUIRED=YES"
echo "SELLER_BACKEND_CHANGED=NO"
echo "ADMIN_SECURITY_CHANGED=NO"
echo "DEVELOPER_HUB_CHANGED=NO"
echo "READY_FOR_REVIEW=YES"
echo "ERROR=NONE"
