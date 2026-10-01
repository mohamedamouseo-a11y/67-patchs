import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, ArrowRight, Building, CreditCard, FileCheck, MapPin, Store, User } from 'lucide-react';

const emptyForm = {
  storeName:'', activityType:'', commercialRegistration:'', taxNumber:'', foundedYear:'',
  responsibleName:'', phone:'', email:'', password:'', confirmPassword:'',
  city:'', district:'', address:'',
  bankName:'', accountHolder:'', iban:'',
};

const fileToDataUrl = (file) => new Promise((resolve, reject) => {
  if (!file) return resolve(null);
  if (file.size > 3 * 1024 * 1024) return reject(new Error('حجم كل مستند يجب ألا يتجاوز 3MB'));
  const reader = new FileReader();
  reader.onload = () => resolve({ name: file.name, type: file.type, data: reader.result });
  reader.onerror = () => reject(new Error('تعذر قراءة المستند'));
  reader.readAsDataURL(file);
});

export default function Register() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [form, setForm] = useState(emptyForm);
  const [files, setFiles] = useState({});
  const [accepted, setAccepted] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const update = (key) => (e) => setForm((v) => ({ ...v, [key]: e.target.value }));
  const setFile = (key) => (e) => setFiles((v) => ({ ...v, [key]: e.target.files?.[0] || null }));

  const submit = async (e) => {
    e.preventDefault();
    setError('');
    if (step < 5) {
      if (step === 2 && form.password !== form.confirmPassword) return setError('كلمتا المرور غير متطابقتين');
      setStep((v) => v + 1);
      return;
    }
    if (!accepted) return setError('يجب الموافقة على إقرار التسجيل ونظام العمولة');
    setBusy(true);
    try {
      const documents = {};
      for (const kind of ['commercialRegistration','identity','ibanProof','logo','storefront']) {
        if (files[kind]) documents[kind] = await fileToDataUrl(files[kind]);
      }
      const res = await fetch('/api/seller/applications', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({ ...form, documents }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || 'تعذر إرسال طلب التسجيل');
      localStorage.setItem('_67_seller_application_id', data.application.id);
      localStorage.setItem('_67_seller_application_tracking', data.trackingToken);
      localStorage.setItem('_67_seller_application_status', data.application.status);
      navigate('/seller/pending');
    } catch (err) {
      setError(err.message || 'حدث خطأ غير متوقع');
    } finally {
      setBusy(false);
    }
  };

  const input = (label, key, type='text', extra={}) => (
    <label style={{display:'grid',gap:7,color:'#334155',fontWeight:700,fontSize:14}}>
      <span>{label}</span>
      <input value={form[key]} onChange={update(key)} type={type} required={extra.required !== false} dir={extra.dir} minLength={extra.minLength}
        style={{height:48,border:'1px solid #CBD5E1',borderRadius:12,padding:'0 14px',fontSize:15,background:'#fff'}} />
    </label>
  );

  const file = (label, key, required=true) => (
    <label style={{display:'grid',gap:7,color:'#334155',fontWeight:700,fontSize:14}}>
      <span>{label}</span>
      <input type="file" accept=".pdf,image/png,image/jpeg,image/webp" required={required} onChange={setFile(key)}
        style={{border:'1px solid #CBD5E1',borderRadius:12,padding:12,background:'#fff'}} />
      <small style={{color:'#64748B',fontWeight:500}}>PDF أو صورة — حد أقصى 3MB</small>
    </label>
  );

  return (
    <div className="seller-app-root" dir="rtl" style={{minHeight:'100vh',padding:'32px 18px',background:'linear-gradient(145deg,#F8FAFC,#FFF9E8)'}}>
      <div style={{maxWidth:760,margin:'0 auto',background:'rgba(255,255,255,.96)',border:'1px solid rgba(212,175,55,.25)',borderRadius:24,padding:28,boxShadow:'0 24px 70px rgba(15,23,42,.09)'}}>
        <header style={{display:'flex',justifyContent:'space-between',gap:16,alignItems:'center',marginBottom:22}}>
          <div>
            <div style={{fontSize:12,color:'#B8962C',fontWeight:900,letterSpacing:1.3}}>67 SELLER ONBOARDING</div>
            <h1 style={{margin:'6px 0',color:'#0F172A'}}>إنشاء حساب تاجر</h1>
            <p style={{margin:0,color:'#64748B'}}>ابدأ على نظام العمولة. لا توجد باقة مدفوعة إلزامية أثناء التسجيل.</p>
          </div>
          <button type="button" onClick={()=> step > 1 ? setStep(step-1) : navigate('/seller/login')} style={{border:'1px solid #E2E8F0',background:'#fff',borderRadius:10,padding:10,cursor:'pointer'}}><ArrowRight size={20}/></button>
        </header>

        <div style={{display:'grid',gridTemplateColumns:'repeat(5,1fr)',gap:8,marginBottom:28}}>
          {[Store,User,MapPin,CreditCard,FileCheck].map((Icon,i)=><div key={i} style={{height:6,borderRadius:99,background:i+1<=step?'#D4AF37':'#E2E8F0'}} title={String(i+1)} />)}
        </div>

        <form onSubmit={submit} style={{display:'grid',gap:16}}>
          {step===1 && <>
            <h3 style={{margin:0}}>بيانات النشاط التجاري</h3>
            {input('اسم المتجر / التشليح','storeName')}
            <label style={{display:'grid',gap:7,fontWeight:700,color:'#334155'}}><span>نوع النشاط</span><select value={form.activityType} onChange={update('activityType')} required style={{height:48,border:'1px solid #CBD5E1',borderRadius:12,padding:'0 14px',background:'#fff'}}>
              <option value="">اختر نوع النشاط</option><option value="parts_store">متجر قطع غيار</option><option value="scrapyard">تشليح</option><option value="agency">وكالة</option><option value="distributor">موزع معتمد</option><option value="services">خدمات سيارات</option>
            </select></label>
            <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fit,minmax(220px,1fr))',gap:14}}>
              {input('رقم السجل التجاري','commercialRegistration')}
              {input('الرقم الضريبي (اختياري)','taxNumber','text',{required:false})}
              {input('سنة التأسيس (اختياري)','foundedYear','number',{required:false})}
            </div>
          </>}
          {step===2 && <>
            <h3 style={{margin:0}}>بيانات المسؤول والدخول</h3>
            {input('اسم المسؤول','responsibleName')}
            <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fit,minmax(220px,1fr))',gap:14}}>
              {input('رقم الجوال','phone','tel',{dir:'ltr'})}
              {input('البريد الإلكتروني','email','email',{dir:'ltr'})}
            </div>
            <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fit,minmax(220px,1fr))',gap:14}}>
              {input('كلمة المرور — 14 حرفًا على الأقل','password','password',{minLength:14})}
              {input('تأكيد كلمة المرور','confirmPassword','password',{minLength:14})}
            </div>
          </>}
          {step===3 && <>
            <h3 style={{margin:0}}>الموقع</h3>
            <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fit,minmax(220px,1fr))',gap:14}}>{input('المدينة','city')}{input('الحي','district')}</div>
            {input('العنوان التفصيلي','address')}
          </>}
          {step===4 && <>
            <h3 style={{margin:0}}>بيانات التسوية البنكية</h3>
            {input('اسم البنك','bankName')}
            {input('اسم صاحب الحساب','accountHolder')}
            {input('رقم الآيبان السعودي','iban','text',{dir:'ltr'})}
          </>}
          {step===5 && <>
            <h3 style={{margin:0}}>المستندات والمراجعة</h3>
            {file('السجل التجاري','commercialRegistration',true)}
            {file('هوية المسؤول','identity',true)}
            {file('شهادة الآيبان / إثبات الحساب البنكي','ibanProof',true)}
            {file('شعار المتجر (اختياري)','logo',false)}
            {file('صورة واجهة المتجر (اختياري)','storefront',false)}
            <label style={{display:'flex',gap:10,alignItems:'flex-start',padding:14,borderRadius:12,background:'#FFF9E8',border:'1px solid rgba(212,175,55,.35)',color:'#475569',lineHeight:1.7}}>
              <input type="checkbox" checked={accepted} onChange={(e)=>setAccepted(e.target.checked)} style={{marginTop:5,accentColor:'#D4AF37'}} />
              <span>أقر بصحة البيانات والمستندات، وأفهم أن الحساب يبدأ بنظام العمولة على البيع الناجح بعد اعتماد إدارة 67، وأن الباقات الإضافية اختيارية لاحقًا.</span>
            </label>
          </>}

          {error && <div style={{padding:12,borderRadius:10,background:'#FEF2F2',color:'#B91C1C',fontWeight:700}}>{error}</div>}
          <button type="submit" disabled={busy} style={{height:50,border:0,borderRadius:12,background:'linear-gradient(135deg,#D4AF37,#B8962C)',color:'#111',fontWeight:900,cursor:'pointer',opacity:busy?.65:1,display:'flex',alignItems:'center',justifyContent:'center',gap:8}}>
            {busy?'جاري الإرسال…':step===5?'إرسال للمراجعة':'التالي'} {step<5 && <ArrowLeft size={18}/>}
          </button>
        </form>
      </div>
    </div>
  );
}
