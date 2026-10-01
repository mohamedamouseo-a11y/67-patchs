import { useEffect, useMemo, useState } from 'react';

export const CART_KEY='_67_cart';
export const RECEIPTS_KEY='_67_order_receipts';

export function toOffer(p){
  return {
    id:String(p.id),
    productId:String(p.id),
    sellerId:p.sellerId,
    storeName:p.storeName,
    storeNameAr:p.storeName,
    isVerified:true,
    rating:0,
    reviewCount:0,
    partName:p.name,
    partNameAr:p.name,
    condition:String(p.condition||'').includes('مستعمل')?'used':'new',
    conditionAr:p.condition||'غير محدد',
    brand:p.brand||'',
    brandAr:p.brand||'',
    price:Number(p.price)||0,
    marketPrice:null,
    currency:'ر.س',
    shippingCost:0,
    shippingDays:2,
    warranty:p.warranty||'حسب سياسة المتجر',
    availability:p.status==='active'&&Number(p.stock)>0,
    stock:Number(p.stock)||0,
    image:p.imageUrl||'',
    description:p.description||'',
    storeCity:'',
    storeCityAr:'',
    category:p.category||'',
    compatibility:p.compatibility||'',
    partNumber:p.partNumber||'',
  };
}

export function useMarketplaceProducts(){
  const [products,setProducts]=useState([]);
  const [loading,setLoading]=useState(true);
  const [error,setError]=useState('');
  const reload=async()=>{
    setLoading(true);setError('');
    try{
      const r=await fetch('/api/marketplace/products',{credentials:'same-origin'});
      const d=await r.json();if(!r.ok)throw new Error(d.error||'تعذر تحميل المنتجات');
      setProducts(Array.isArray(d.products)?d.products:[]);
    }catch(e){setError(e.message||'تعذر تحميل المنتجات')}finally{setLoading(false)}
  };
  useEffect(()=>{reload()},[]);
  const offers=useMemo(()=>products.map(toOffer),[products]);
  return {products,offers,loading,error,reload};
}

export function readCart(){
  try{
    const a=JSON.parse(localStorage.getItem(CART_KEY)||'[]');
    return Array.isArray(a)?a.map(x=>({offerId:String(x.offerId),quantity:Math.max(1,Number(x.quantity)||1)})):[];
  }catch{return []}
}
export function saveCart(lines){localStorage.setItem(CART_KEY,JSON.stringify(lines))}
export function saveOrderReceipts(orders){
  let current=[];try{const x=JSON.parse(localStorage.getItem(RECEIPTS_KEY)||'[]');if(Array.isArray(x))current=x}catch{}
  const next=[...orders.map(o=>({id:o.id,trackingToken:o.trackingToken})),...current].filter((x,i,a)=>a.findIndex(y=>y.id===x.id)===i).slice(0,100);
  localStorage.setItem(RECEIPTS_KEY,JSON.stringify(next));
}
export function readOrderReceipts(){try{const x=JSON.parse(localStorage.getItem(RECEIPTS_KEY)||'[]');return Array.isArray(x)?x:[]}catch{return []}}
