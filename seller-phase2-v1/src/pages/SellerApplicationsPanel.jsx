import React, { useCallback, useEffect, useState } from 'react';

const labels={pending:'قيد المراجعة',needs_changes:'يحتاج تعديل',approved:'معتمد',rejected:'مرفوض'};
export default function SellerApplicationsPanel({session}){
  const [rows,setRows]=useState([]),[busy,setBusy]=useState(''),[error,setError]=useState('');
  const load=useCallback(()=>fetch('/api/superadmin/seller-applications').then(async r=>{const d=await r.json();if(!r.ok)throw new Error(d.error||'تعذر تحميل طلبات التجار');setRows(d.applications||[])}).catch(e=>setError(e.message)),[]);
  useEffect(()=>{load()},[load]);
  const update=async(id,status)=>{
    const reviewNote=status==='approved'?'':window.prompt('ملاحظة الإدارة (اختياري):','')||'';
    setBusy(id+status);setError('');
    try{const r=await fetch(`/api/superadmin/seller-applications/${encodeURIComponent(id)}/status`,{method:'PATCH',headers:{'Content-Type':'application/json','X-CSRF-Token':session.csrfToken},body:JSON.stringify({status,reviewNote})});const d=await r.json().catch(()=>({}));if(!r.ok)throw new Error(d.error||'تعذر تحديث الطلب');await load()}catch(e){setError(e.message)}finally{setBusy('')}
  };
  return <section style={{background:'var(--admin-surface)',border:'1px solid var(--admin-border)',borderRadius:16,padding:20,marginBottom:24}}>
    <div style={{display:'flex',justifyContent:'space-between',gap:12,alignItems:'center',marginBottom:16}}><div><h3 style={{margin:0}}>طلبات تسجيل التجار الحقيقية</h3><small style={{color:'var(--admin-muted)'}}>Backend seller verification — CR / ID / IBAN</small></div><button onClick={load}>تحديث</button></div>
    {error&&<div style={{color:'#B91C1C',marginBottom:12}}>{error}</div>}
    <div style={{overflowX:'auto'}}><table style={{width:'100%',borderCollapse:'collapse',textAlign:'right'}}><thead><tr><th>المتجر</th><th>المسؤول</th><th>الجوال</th><th>البريد</th><th>الحالة</th><th>المستندات</th><th>الإجراء</th></tr></thead><tbody>
      {rows.map(a=><tr key={a.id} style={{borderTop:'1px solid var(--admin-border)'}}><td style={{padding:12}}><strong>{a.storeName}</strong><div style={{fontSize:12,color:'var(--admin-muted)'}}>{a.commercialRegistration}</div></td><td>{a.responsibleName}</td><td dir="ltr">{a.phone}</td><td>{a.email}</td><td>{labels[a.status]||a.status}</td><td>{['commercialRegistration','identity','ibanProof'].map(k=>a.documents?.[k]?<a key={k} href={`/api/superadmin/seller-applications/${encodeURIComponent(a.id)}/documents/${k}`} target="_blank" rel="noreferrer" style={{marginLeft:8}}>عرض</a>:null)}</td><td style={{display:'flex',gap:6,padding:12,flexWrap:'wrap'}}>{a.status!=='approved'&&<button disabled={busy} onClick={()=>update(a.id,'approved')}>اعتماد</button>}<button disabled={busy} onClick={()=>update(a.id,'needs_changes')}>طلب تعديل</button><button disabled={busy} onClick={()=>update(a.id,'rejected')}>رفض</button></td></tr>)}
      {!rows.length&&<tr><td colSpan="7" style={{padding:20,textAlign:'center',color:'var(--admin-muted)'}}>لا توجد طلبات حقيقية حتى الآن.</td></tr>}
    </tbody></table></div>
  </section>;
}
