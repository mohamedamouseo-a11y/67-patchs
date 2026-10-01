import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CheckCircle2, Clock3, RefreshCcw, XCircle } from 'lucide-react';

const copy = {
  pending:['طلبك قيد المراجعة','استلمت إدارة 67 بياناتك ومستنداتك. سيتم فتح لوحة التاجر بعد التحقق.','#D4AF37',Clock3],
  needs_changes:['نحتاج تعديل بعض البيانات','راجع ملاحظات الإدارة ثم حدّث بياناتك في المرحلة التالية.','#D97706',RefreshCcw],
  approved:['تم اعتماد حساب التاجر','الحساب Verified / Active ويمكنك الآن تسجيل الدخول.','#16A34A',CheckCircle2],
  rejected:['تعذر اعتماد الطلب','راجع ملاحظة الإدارة ثم تواصل مع فريق 67 عند الحاجة.','#DC2626',XCircle],
};

export default function PendingReview(){
  const navigate=useNavigate();
  const [status,setStatus]=useState(localStorage.getItem('_67_seller_application_status')||'pending');
  const [note,setNote]=useState('');
  useEffect(()=>{
    const id=localStorage.getItem('_67_seller_application_id');
    const trackingToken=localStorage.getItem('_67_seller_application_tracking');
    if(!id||!trackingToken) return;
    fetch('/api/seller/application-status',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({id,trackingToken})})
      .then(async r=>({ok:r.ok,data:await r.json().catch(()=>({}))}))
      .then(({ok,data})=>{if(ok&&data.application){setStatus(data.application.status);setNote(data.application.reviewNote||'');localStorage.setItem('_67_seller_application_status',data.application.status);}})
      .catch(()=>{});
  },[]);
  const [title,description,tone,Icon]=copy[status]||copy.pending;
  return <div className="seller-app-root" dir="rtl" style={{minHeight:'100vh',display:'grid',placeItems:'center',padding:24,background:'linear-gradient(145deg,#F8FAFC,#FFF9E8)'}}>
    <section style={{width:'min(680px,100%)',background:'#fff',border:'1px solid rgba(212,175,55,.25)',borderRadius:26,padding:32,boxShadow:'0 24px 70px rgba(15,23,42,.1)'}}>
      <div style={{width:68,height:68,borderRadius:20,display:'grid',placeItems:'center',background:`${tone}18`,color:tone,marginBottom:18}}><Icon size={34}/></div>
      <h1 style={{margin:'0 0 10px',color:'#0F172A'}}>{title}</h1>
      <p style={{color:'#64748B',lineHeight:1.8}}>{description}</p>
      {note&&<div style={{margin:'18px 0',padding:14,borderRadius:12,background:'#F8FAFC',border:'1px solid #E2E8F0'}}><strong>ملاحظة الإدارة:</strong><div style={{marginTop:6,color:'#475569'}}>{note}</div></div>}
      <div style={{padding:14,borderRadius:12,background:'#FFF9E8',border:'1px solid rgba(212,175,55,.25)',color:'#475569'}}>الحساب يبدأ بنظام العمولة على البيع الناجح. الباقات الإضافية اختيارية لاحقًا.</div>
      <div style={{display:'flex',gap:10,marginTop:22,flexWrap:'wrap'}}>
        {status==='approved'&&<button onClick={()=>navigate('/seller/login')} style={{border:0,borderRadius:12,padding:'12px 18px',background:'linear-gradient(135deg,#D4AF37,#B8962C)',fontWeight:900,cursor:'pointer'}}>تسجيل الدخول</button>}
        {status==='needs_changes'&&<button onClick={()=>navigate('/seller/register')} style={{border:0,borderRadius:12,padding:'12px 18px',background:'linear-gradient(135deg,#D4AF37,#B8962C)',fontWeight:900,cursor:'pointer'}}>تعديل الطلب</button>}
        <button onClick={()=>navigate('/store')} style={{border:'1px solid #CBD5E1',borderRadius:12,padding:'12px 18px',background:'#fff',fontWeight:800,cursor:'pointer'}}>العودة للمتجر</button>
      </div>
    </section>
  </div>;
}
