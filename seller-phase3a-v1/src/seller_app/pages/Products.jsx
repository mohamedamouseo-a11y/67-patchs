import React, { useEffect, useMemo, useState } from 'react';
import { Check, Edit, Eye, Image as ImageIcon, Package, Plus, Search, Trash2, X } from 'lucide-react';

const empty={name:'',partNumber:'',category:'الفرامل',condition:'جديد',brand:'تويوتا',compatibility:'',description:'',warranty:'',price:'',stock:'1',status:'active',imageUrl:''};

export default function Products(){
  const [products,setProducts]=useState([]),[form,setForm]=useState(empty),[editing,setEditing]=useState(null),[open,setOpen]=useState(false);
  const [query,setQuery]=useState(''),[busy,setBusy]=useState(false),[error,setError]=useState(''),[csrf,setCsrf]=useState('');
  const load=async()=>{setError('');const s=await fetch('/api/seller/session').then(r=>r.json());setCsrf(s.csrfToken||'');const r=await fetch('/api/seller/products');const d=await r.json();if(!r.ok)throw new Error(d.error||'تعذر تحميل المنتجات');setProducts(d.products||[])};
  useEffect(()=>{load().catch(e=>setError(e.message))},[]);
  const filtered=useMemo(()=>products.filter(p=>!query||[p.name,p.partNumber,p.brand,p.category].join(' ').toLowerCase().includes(query.toLowerCase())),[products,query]);
  const change=k=>e=>setForm(v=>({...v,[k]:e.target.value}));
  const startAdd=()=>{setEditing(null);setForm(empty);setOpen(true)};
  const startEdit=p=>{setEditing(p.id);setForm({...empty,...p,price:String(p.price),stock:String(p.stock)});setOpen(true)};
  const save=async()=>{
    setBusy(true);setError('');
    try{
      const url=editing?'/api/seller/products/'+encodeURIComponent(editing):'/api/seller/products';
      const r=await fetch(url,{method:editing?'PATCH':'POST',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify({...form,price:Number(form.price),stock:Number(form.stock)})});
      const d=await r.json().catch(()=>({}));if(!r.ok)throw new Error(d.error||'تعذر حفظ المنتج');await load();setOpen(false);
    }catch(e){setError(e.message)}finally{setBusy(false)}
  };
  const remove=async id=>{if(!confirm('حذف المنتج؟'))return;setBusy(true);try{const r=await fetch('/api/seller/products/'+encodeURIComponent(id),{method:'DELETE',headers:{'X-CSRF-Token':csrf}});const d=await r.json().catch(()=>({}));if(!r.ok)throw new Error(d.error||'تعذر الحذف');await load()}catch(e){setError(e.message)}finally{setBusy(false)}};
  const quickStock=async(p,delta)=>{const next=Math.max(0,p.stock+delta);setBusy(true);try{const r=await fetch('/api/seller/products/'+encodeURIComponent(p.id),{method:'PATCH',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify({...p,stock:next,status:next===0?'inactive':p.status})});const d=await r.json().catch(()=>({}));if(!r.ok)throw new Error(d.error||'تعذر تحديث المخزون');await load()}catch(e){setError(e.message)}finally{setBusy(false)}};

  if(open)return <div className="animate-fadeIn" dir="rtl">
    <div className="flex-between mb-lg"><div><h2>{editing?'تعديل المنتج':'إضافة منتج جديد'}</h2><p className="text-secondary-color">المنتج سيُحفظ في Backend 67 ويرتبط بحساب متجرك.</p></div><button className="btn btn-ghost" onClick={()=>setOpen(false)}><X size={18}/> إلغاء</button></div>
    <div className="grid-2">
      <div className="card"><div className="card-body flex-col gap-md">
        <h3>المعلومات الأساسية</h3>
        <label>اسم القطعة<input className="input-field" value={form.name} onChange={change('name')} /></label>
        <div className="grid-2"><label>رقم القطعة<input className="input-field" value={form.partNumber} onChange={change('partNumber')} /></label><label>الحالة<select className="input-field" value={form.condition} onChange={change('condition')}><option>جديد</option><option>مستعمل</option><option>مجدد</option></select></label></div>
        <div className="grid-3"><label>التصنيف<input className="input-field" value={form.category} onChange={change('category')} /></label><label>الماركة<input className="input-field" value={form.brand} onChange={change('brand')} /></label><label>التوافق<input className="input-field" value={form.compatibility} onChange={change('compatibility')} /></label></div>
        <label>الوصف<textarea className="input-field" rows="4" value={form.description} onChange={change('description')} /></label>
        <label>الضمان<input className="input-field" value={form.warranty} onChange={change('warranty')} /></label>
      </div></div>
      <div className="flex-col gap-md">
        <div className="card"><div className="card-body"><h3>السعر والمخزون</h3><div className="grid-2"><label>السعر<input type="number" min="0" step="0.01" className="input-field" value={form.price} onChange={change('price')} /></label><label>الكمية<input type="number" min="0" className="input-field" value={form.stock} onChange={change('stock')} /></label></div><label style={{display:'block',marginTop:14}}>الظهور<select className="input-field" value={form.status} onChange={change('status')}><option value="active">نشط في المتجر</option><option value="inactive">موقوف</option><option value="draft">مسودة</option></select></label></div></div>
        <div className="card"><div className="card-body"><h3>صورة المنتج</h3><label>رابط الصورة HTTPS<input className="input-field" value={form.imageUrl} onChange={change('imageUrl')} placeholder="https://..." /></label><small className="text-muted">رفع الصور الفعلي إلى Object Storage سيتم في مرحلة الوسائط؛ حاليًا نحفظ URL فقط.</small></div></div>
      </div>
    </div>
    {error&&<div style={{marginTop:14,color:'#b91c1c'}}>{error}</div>}
    <div className="flex justify-end gap-sm mt-md"><button className="btn btn-primary" disabled={busy} onClick={save}><Check size={18}/>{busy?'جاري الحفظ…':'حفظ المنتج'}</button></div>
  </div>;

  return <div className="animate-fadeIn" dir="rtl">
    <div className="flex-between mb-lg"><div><h2 className="m-0 mb-xs">إدارة المنتجات والمخزون</h2><p className="text-secondary-color text-sm m-0">البيانات الآن مرتبطة بحساب التاجر في Backend 67.</p></div><button className="btn btn-primary" onClick={startAdd}><Plus size={18}/> إضافة قطعة جديدة</button></div>
    {error&&<div style={{padding:12,background:'#fef2f2',color:'#b91c1c',borderRadius:10,marginBottom:12}}>{error}</div>}
    <div className="card mb-md"><div className="card-body flex items-center gap-md"><div className="search-box" style={{flex:1}}><Search size={18}/><input value={query} onChange={e=>setQuery(e.target.value)} placeholder="ابحث بالاسم، الرقم، الماركة أو التصنيف..." /></div></div></div>
    <div className="card" style={{overflow:'hidden'}}><div style={{overflowX:'auto'}}><table style={{width:'100%',borderCollapse:'collapse',textAlign:'right'}}><thead style={{background:'#F8FAFC'}}><tr><th className="p-md">القطعة</th><th>الحالة</th><th>السعر</th><th>المخزون</th><th>الظهور</th><th>الإجراءات</th></tr></thead><tbody>
      {filtered.map(p=><tr key={p.id} style={{borderTop:'1px solid var(--border-light)'}}><td className="p-md"><div className="flex items-center gap-sm"><div style={{width:50,height:50,borderRadius:9,background:'#E2E8F0',display:'grid',placeItems:'center',overflow:'hidden'}}>{p.imageUrl?<img src={p.imageUrl} alt="" style={{width:'100%',height:'100%',objectFit:'cover'}}/>:<ImageIcon size={22}/>}</div><div><strong>{p.name}</strong><div className="text-xs text-muted"><Package size={12}/> {p.category} · {p.partNumber||'بدون رقم'}</div></div></div></td><td>{p.condition}</td><td><strong>{p.price.toLocaleString()} ر.س</strong></td><td><div className="flex items-center gap-xs"><button disabled={busy||p.stock===0} onClick={()=>quickStock(p,-1)}>-</button><strong>{p.stock}</strong><button disabled={busy} onClick={()=>quickStock(p,1)}>+</button></div></td><td>{p.status==='active'?'نشط':p.status==='draft'?'مسودة':'موقوف'}</td><td><div className="flex gap-xs"><button className="btn-icon" title="معاينة"><Eye size={17}/></button><button className="btn-icon" onClick={()=>startEdit(p)}><Edit size={17}/></button><button className="btn-icon text-danger" onClick={()=>remove(p.id)}><Trash2 size={17}/></button></div></td></tr>)}
      {!filtered.length&&<tr><td colSpan="6" style={{padding:30,textAlign:'center',color:'#64748B'}}>لا توجد منتجات حقيقية لهذا التاجر حتى الآن.</td></tr>}
    </tbody></table></div></div>
  </div>;
}
