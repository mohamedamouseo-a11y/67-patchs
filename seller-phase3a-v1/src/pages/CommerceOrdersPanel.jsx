import React,{useEffect,useState} from 'react';

const labels={new:'جديد',processing:'قيد التجهيز',shipped:'تم الشحن',delivered:'تم التسليم',rejected:'مرفوض'};
export default function CommerceOrdersPanel(){
  const [rows,setRows]=useState([]),[error,setError]=useState('');
  const load=()=>fetch('/api/superadmin/commerce-orders').then(async r=>{const d=await r.json();if(!r.ok)throw new Error(d.error||'تعذر تحميل الطلبات');setRows(d.orders||[])}).catch(e=>setError(e.message));
  useEffect(()=>{load()},[]);
  return <section style={{background:'var(--admin-surface)',border:'1px solid var(--admin-border)',borderRadius:16,padding:20,marginBottom:24}}>
    <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:12,marginBottom:14}}><div><h3 style={{margin:0}}>طلبات التجارة الحقيقية</h3><small style={{color:'var(--admin-muted)'}}>نفس الطلب الذي يراه التاجر من Backend 67</small></div><button onClick={load}>تحديث</button></div>
    {error&&<div style={{color:'#b91c1c',marginBottom:10}}>{error}</div>}
    <div style={{overflowX:'auto'}}><table style={{width:'100%',borderCollapse:'collapse',textAlign:'right'}}><thead><tr><th>الطلب</th><th>التاجر</th><th>العميل</th><th>المنتجات</th><th>القيمة</th><th>العمولة</th><th>الحالة</th></tr></thead><tbody>
      {rows.map(o=><tr key={o.id} style={{borderTop:'1px solid var(--admin-border)'}}><td style={{padding:12,fontFamily:'monospace'}}>{o.id}</td><td>{o.storeName}</td><td>{o.customerName}<div dir="ltr" style={{fontSize:12,color:'var(--admin-muted)'}}>{o.customerPhone}</div></td><td>{(o.items||[]).map(x=><div key={x.productId}>{x.name} × {x.quantity}</div>)}</td><td>{o.subtotal?.toLocaleString()} ر.س</td><td>{o.commission?.toLocaleString()} ر.س</td><td>{labels[o.status]||o.status}</td></tr>)}
      {!rows.length&&<tr><td colSpan="7" style={{padding:22,textAlign:'center',color:'var(--admin-muted)'}}>لا توجد طلبات Commerce حقيقية حتى الآن.</td></tr>}
    </tbody></table></div>
  </section>;
}
