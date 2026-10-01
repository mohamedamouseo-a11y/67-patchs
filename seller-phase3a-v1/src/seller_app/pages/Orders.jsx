import React, { useEffect, useMemo, useState } from 'react';
import { CheckCircle, Clock, Search, Truck, XCircle } from 'lucide-react';

const tabs=[['new','جديدة'],['processing','قيد التجهيز'],['shipped','تم الشحن'],['delivered','مكتملة'],['rejected','مرفوضة']];
const statusText={new:'طلب جديد',processing:'قيد التجهيز',shipped:'تم الشحن',delivered:'تم التسليم',rejected:'مرفوض'};

export default function Orders(){
  const [orders,setOrders]=useState([]),[tab,setTab]=useState('new'),[q,setQ]=useState(''),[csrf,setCsrf]=useState(''),[error,setError]=useState(''),[busy,setBusy]=useState('');
  const load=async()=>{const s=await fetch('/api/seller/session').then(r=>r.json());setCsrf(s.csrfToken||'');const r=await fetch('/api/seller/orders');const d=await r.json();if(!r.ok)throw new Error(d.error||'تعذر تحميل الطلبات');setOrders(d.orders||[])};
  useEffect(()=>{load().catch(e=>setError(e.message))},[]);
  const shown=useMemo(()=>orders.filter(o=>o.status===tab&&(!q||[o.id,o.customerName,o.customerPhone,...(o.items||[]).map(i=>i.name)].join(' ').toLowerCase().includes(q.toLowerCase()))),[orders,tab,q]);
  const change=async(id,status)=>{setBusy(id+status);setError('');try{const r=await fetch('/api/seller/orders/'+encodeURIComponent(id)+'/status',{method:'PATCH',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify({status})});const d=await r.json().catch(()=>({}));if(!r.ok)throw new Error(d.error||'تعذر تحديث الطلب');await load();setTab(status)}catch(e){setError(e.message)}finally{setBusy('')}};
  return <div className="animate-fadeIn" dir="rtl">
    <div className="flex-between mb-lg"><div><h2>طلبات الشراء</h2><p className="text-secondary-color">كل طلب هنا مرتبط بمنتجاتك ومخزونك في Backend 67.</p></div></div>
    {error&&<div style={{padding:12,background:'#fef2f2',color:'#b91c1c',borderRadius:10,marginBottom:12}}>{error}</div>}
    <div className="card mb-md"><div className="card-body"><div className="flex gap-sm" style={{flexWrap:'wrap'}}>{tabs.map(([id,label])=><button key={id} className={`btn ${tab===id?'btn-primary':'btn-ghost'}`} onClick={()=>setTab(id)}>{label} ({orders.filter(o=>o.status===id).length})</button>)}</div><div className="search-box mt-md"><Search size={18}/><input value={q} onChange={e=>setQ(e.target.value)} placeholder="ابحث برقم الطلب أو العميل أو القطعة..." /></div></div></div>
    <div className="flex-col gap-md">{shown.map(o=><div className="card" key={o.id}><div className="card-body">
      <div className="flex-between"><div><strong style={{fontFamily:'monospace'}}>{o.id}</strong><div className="text-sm text-muted">{new Date(o.createdAt).toLocaleString('ar-SA')}</div></div><span className="badge">{statusText[o.status]}</span></div>
      <div className="grid-3 mt-md"><div><small>العميل</small><strong style={{display:'block'}}>{o.customerName}</strong><span dir="ltr">{o.customerPhone}</span></div><div><small>المنتجات</small>{(o.items||[]).map(x=><div key={x.productId}><strong>{x.name}</strong> × {x.quantity}</div>)}</div><div><small>الإجمالي قبل الضريبة والشحن</small><strong style={{display:'block'}}>{o.subtotal.toLocaleString()} ر.س</strong><small>عمولة 67: {o.commission.toLocaleString()} ر.س · صافي التاجر: {o.sellerNet.toLocaleString()} ر.س</small></div></div>
      <div className="flex gap-sm mt-md" style={{flexWrap:'wrap'}}>
        {o.status==='new'&&<><button disabled={busy} className="btn btn-primary" onClick={()=>change(o.id,'processing')}><Clock size={16}/> قبول وتجهيز</button><button disabled={busy} className="btn btn-ghost text-danger" onClick={()=>change(o.id,'rejected')}><XCircle size={16}/> رفض</button></>}
        {o.status==='processing'&&<><button disabled={busy} className="btn btn-primary" onClick={()=>change(o.id,'shipped')}><Truck size={16}/> تم الشحن</button><button disabled={busy} className="btn btn-ghost text-danger" onClick={()=>change(o.id,'rejected')}><XCircle size={16}/> رفض</button></>}
        {o.status==='shipped'&&<button disabled={busy} className="btn btn-primary" onClick={()=>change(o.id,'delivered')}><CheckCircle size={16}/> تم التسليم</button>}
      </div>
    </div></div>)}
    {!shown.length&&<div className="card"><div className="card-body" style={{textAlign:'center',padding:36,color:'#64748B'}}>لا توجد طلبات في هذه الحالة.</div></div>}
    </div>
  </div>;
}
