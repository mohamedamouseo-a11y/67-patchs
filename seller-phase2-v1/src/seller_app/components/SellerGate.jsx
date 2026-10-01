import React, { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';

export default function SellerGate({children}){
  const [state,setState]=useState('loading');
  useEffect(()=>{
    fetch('/api/seller/session',{credentials:'same-origin'})
      .then(r=>r.json().then(data=>({ok:r.ok,data})))
      .then(({ok,data})=>setState(ok&&data.authenticated&&data.seller?.status==='approved'?'ok':'no'))
      .catch(()=>setState('no'));
  },[]);
  if(state==='loading') return <div dir="rtl" style={{minHeight:'60vh',display:'grid',placeItems:'center',color:'#64748B'}}>جاري التحقق من حساب التاجر…</div>;
  if(state!=='ok') return <Navigate to="/seller/login" replace />;
  return children;
}
