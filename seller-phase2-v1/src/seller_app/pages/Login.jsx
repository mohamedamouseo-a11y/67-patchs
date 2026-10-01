import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Logo67 from '../../components/Logo67';
import { ArrowRight, LogIn, Mail, Lock } from 'lucide-react';

export default function Login() {
  const navigate = useNavigate();
  const [email,setEmail] = useState('');
  const [password,setPassword] = useState('');
  const [busy,setBusy] = useState(false);
  const [error,setError] = useState('');

  const submit = async (e) => {
    e.preventDefault();
    setBusy(true); setError('');
    try {
      const res = await fetch('/api/seller/login', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({email,password}),
      });
      const data = await res.json().catch(()=>({}));
      if (res.ok) {
        localStorage.setItem('_67_seller_application_status','approved');
        navigate('/seller/dashboard');
        return;
      }
      if (data.code === 'SELLER_NOT_APPROVED' && data.application) {
        localStorage.setItem('_67_seller_application_id',data.application.id);
        localStorage.setItem('_67_seller_application_status',data.application.status);
        navigate('/seller/pending');
        return;
      }
      throw new Error(data.error || 'بيانات الدخول غير صحيحة');
    } catch (err) {
      setError(err.message || 'تعذر تسجيل الدخول');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="seller-app-root" dir="rtl" style={{minHeight:'100vh',display:'grid',gridTemplateColumns:'1.05fr .95fr',background:'linear-gradient(145deg,#F8FAFC,#FFF9E8)'}}>
      <section className="hide-on-mobile" style={{display:'grid',placeItems:'center',padding:40,borderLeft:'1px solid #E2E8F0'}}>
        <div style={{textAlign:'center',maxWidth:430}}>
          <Logo67 size={135} color="#D4AF37"/>
          <h2 style={{fontSize:36,color:'#0F172A',margin:'24px 0 10px'}}>بوابة أعمال 67</h2>
          <p style={{color:'#64748B',lineHeight:1.8,fontSize:17}}>الدخول متاح فقط للتجار الذين اعتمدتهم إدارة 67. الطلبات قيد المراجعة ستظهر حالتها بدل فتح لوحة الأعمال.</p>
        </div>
      </section>
      <section style={{display:'grid',placeItems:'center',padding:28,background:'rgba(255,255,255,.82)'}}>
        <div style={{width:'min(430px,100%)'}}>
          <button onClick={()=>navigate('/store')} type="button" style={{border:'1px solid #E2E8F0',background:'#fff',borderRadius:10,padding:10,cursor:'pointer',marginBottom:28}}><ArrowRight size={20}/></button>
          <h1 style={{color:'#0F172A',fontSize:34,margin:'0 0 8px'}}>دخول التاجر</h1>
          <p style={{color:'#64748B',margin:'0 0 28px'}}>استخدم بيانات الحساب التي قدمتها أثناء التسجيل.</p>
          <form onSubmit={submit} style={{display:'grid',gap:18}}>
            <label style={{display:'grid',gap:7,color:'#334155',fontWeight:700}}><span>البريد الإلكتروني</span><div style={{position:'relative'}}><Mail size={19} style={{position:'absolute',right:14,top:15,color:'#94A3B8'}}/><input value={email} onChange={e=>setEmail(e.target.value)} type="email" required dir="ltr" style={{width:'100%',height:50,border:'1px solid #CBD5E1',borderRadius:12,padding:'0 44px 0 14px'}}/></div></label>
            <label style={{display:'grid',gap:7,color:'#334155',fontWeight:700}}><span>كلمة المرور</span><div style={{position:'relative'}}><Lock size={19} style={{position:'absolute',right:14,top:15,color:'#94A3B8'}}/><input value={password} onChange={e=>setPassword(e.target.value)} type="password" required style={{width:'100%',height:50,border:'1px solid #CBD5E1',borderRadius:12,padding:'0 44px 0 14px'}}/></div></label>
            {error && <div style={{padding:12,borderRadius:10,background:'#FEF2F2',color:'#B91C1C',fontWeight:700}}>{error}</div>}
            <button disabled={busy} style={{height:52,border:0,borderRadius:12,background:'linear-gradient(135deg,#D4AF37,#B8962C)',color:'#111',fontWeight:900,cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center',gap:8}}>{busy?'جاري التحقق…':<><LogIn size={20}/> دخول لوحة الأعمال</>}</button>
          </form>
          <div style={{marginTop:24,paddingTop:20,borderTop:'1px solid #E2E8F0',textAlign:'center',color:'#64748B'}}>تاجر جديد؟ <button onClick={()=>navigate('/seller/register')} style={{border:0,background:'transparent',color:'#B8962C',fontWeight:900,cursor:'pointer'}}>سجل نشاطك بدون اشتراك إلزامي</button></div>
        </div>
      </section>
      <style>{'@media(max-width:900px){.hide-on-mobile{display:none!important}.seller-app-root{grid-template-columns:1fr!important}}'}</style>
    </div>
  );
}
