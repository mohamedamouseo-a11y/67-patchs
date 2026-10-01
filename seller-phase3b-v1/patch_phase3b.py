from pathlib import Path
import re

root=Path("/67")

def read(p): return (root/p).read_text()
def write(p,s): (root/p).write_text(s)

# TopPartsPage: real marketplace catalog, same UI.
p="src/pages/TopPartsPage.jsx"; s=read(p)
s=s.replace("import { mockOffers } from '../data/mockOffers';","import { useMarketplaceProducts } from '../utils/marketplaceClient';")
anchor="  const [favoriteIds, setFavoriteIds] = useState(() => new Set());"
if "offers: mockOffers" not in s:
    s=s.replace(anchor,anchor+"\n  const { offers: mockOffers, loading, error } = useMarketplaceProducts();",1)
s=s.replace("<p>كل المنتجات المعروضة هنا تأتي من بيانات المنتجات الموجودة أصلًا داخل مشروع 67، مع إعادة تصميم طريقة العرض فقط.</p>","<p>المنتجات المعروضة هنا تأتي مباشرة من متاجر التجار المعتمدين في 67.</p>")
s=s.replace("<p>لا يتم تقسيم المنتجات إلى فئات غير موجودة في مصدر البيانات الأصلي.</p>","<p>الأسعار والمخزون مرتبطة مباشرة ببيانات التاجر الحالية.</p>")
empty="{products.length === 0 ? ("
if "loading ? (" not in s:
    s=s.replace(empty,"{loading ? (\n            <div className=\"tp67-empty\"><Package size={44} /><h3>جاري تحميل المنتجات…</h3></div>\n          ) : error ? (\n            <div className=\"tp67-empty\"><Package size={44} /><h3>تعذر تحميل المنتجات</h3><p>{error}</p></div>\n          ) : products.length === 0 ? (",1)
write(p,s)

# HomeBelowHero: homepage featured products from backend.
p="src/components/HomeBelowHero.jsx"; s=read(p)
s=s.replace("import { useState, useEffect, useRef } from 'react';","import { useState, useEffect, useRef, useMemo } from 'react';")
s=s.replace("import { mockOffers } from '../data/mockOffers';","import { useMarketplaceProducts } from '../utils/marketplaceClient';")
pattern=re.compile(r"const representativeProducts = \['ac', 'transmission', 'body', 'brakes'\][\s\S]*?const homeProducts = \[[\s\S]*?\];\n",re.M)
s=pattern.sub("""const buildHomeProducts = (offers) => {
  const representativeProducts = ['ac', 'transmission', 'body', 'brakes']
    .map((category) => offers.find((product) => getHomeProductCategory(product) === category))
    .filter(Boolean);
  const ids = new Set(representativeProducts.map((product) => product.id));
  return [...representativeProducts, ...offers.filter((product) => !ids.has(product.id))];
};
""",s,1)
anchor="const HomeBelowHero = () => {\n  const navigate = useNavigate();"
if "offers: mockOffers" not in s:
    s=s.replace(anchor,anchor+"\n  const { offers: mockOffers } = useMarketplaceProducts();\n  const homeProducts = useMemo(() => buildHomeProducts(mockOffers), [mockOffers]);",1)
s=s.replace("نفس بيانات المنتجات الموجودة في مشروع 67، مع إعادة تصميم طريقة عرضها فقط.","منتجات حقيقية مضافة من التجار المعتمدين ومتصلة بالمخزون الحالي.")
write(p,s)

# Offer details: resolve actual backend product by id.
p="src/pages/OfferDetailPage.jsx"; s=read(p)
s=s.replace("import { mockOffers } from '../data/mockOffers';","import { useMarketplaceProducts } from '../utils/marketplaceClient';")
anchor="  const navigate = useNavigate();"
if "offers: mockOffers" not in s:
    s=s.replace(anchor,anchor+"\n  const { offers: mockOffers, loading, error } = useMarketplaceProducts();",1)
s=s.replace("    () => mockOffers.find((item) => item.id === offerId) || mockOffers[0],","    () => mockOffers.find((item) => item.id === offerId) || null,")
s=s.replace("    () => mockOffers.filter((item) => item.id !== offer.id).slice(0, 4),\n    [offer.id],","    () => offer ? mockOffers.filter((item) => item.id !== offer.id).slice(0, 4) : [],\n    [mockOffers, offer],")
state_anchor="  const [quantity, setQuantity] = useState(1);"
if "جاري تحميل بيانات القطعة" not in s:
    s=s.replace(state_anchor,state_anchor+"""\n
  if (loading) return <div dir="rtl" style={{minHeight:'60vh',display:'grid',placeItems:'center'}}>جاري تحميل بيانات القطعة…</div>;
  if (error || !offer) return <div dir="rtl" style={{minHeight:'60vh',display:'grid',placeItems:'center'}}><div><h2>القطعة غير متاحة</h2><p>{error || 'قد تكون نفدت من المخزون أو تم إيقافها.'}</p></div></div>;""",1)
s=s.replace(".filter((line) => mockOffers.some((item) => item.id === line.offerId));",".filter((line) => mockOffers.some((item) => item.id === line.offerId));",1)
# Stock cap in quantity.
s=s.replace("onClick={() => setQuantity((value) => value + 1)}","onClick={() => setQuantity((value) => Math.min(offer.stock || 1, value + 1))}")
write(p,s)

# Cart: product truth comes from API; localStorage only contains IDs + qty.
p="src/pages/CartPage.jsx"; s=read(p)
s=s.replace("import { mockOffers } from '../data/mockOffers';","import { readCart, saveCart, useMarketplaceProducts } from '../utils/marketplaceClient';")
# remove local readCart declaration
s=re.sub(r"const CART_KEY = '_67_cart';\n\nconst readCart = \(\) => \{[\s\S]*?\n\};\n","",s,count=1)
anchor="  const navigate = useNavigate();"
if "offers: mockOffers" not in s:
    s=s.replace(anchor,anchor+"\n  const { offers: mockOffers, loading, error } = useMarketplaceProducts();",1)
s=s.replace("    localStorage.setItem(CART_KEY, JSON.stringify(cartLines));","    saveCart(cartLines);")
# Clamp quantity to stock.
s=s.replace("? { ...line, quantity: Math.max(1, line.quantity + delta) }", "? { ...line, quantity: Math.max(1, Math.min(mockOffers.find((o) => o.id === offerId)?.stock || 1, line.quantity + delta)) }")
# Display loading/errors before empty.
marker="      <main className=\"c67-main\">"
if "جاري تحديث السلة" not in s:
    s=s.replace(marker,marker+"\n        {loading && <div style={{padding:24,textAlign:'center'}}>جاري تحديث السلة من المخزون…</div>}\n        {error && <div style={{padding:14,textAlign:'center',color:'#b91c1c'}}>{error}</div>}",1)
write(p,s)

# Checkout: real catalog + real order creation, no local fake orders, Tabby/Tamara deferred.
p="src/pages/CheckoutPage.jsx"; s=read(p)
s=s.replace("import { mockOffers } from '../data/mockOffers';","import { readCart, saveCart, saveOrderReceipts, useMarketplaceProducts } from '../utils/marketplaceClient';")
s=re.sub(r"const CART_KEY = '_67_cart';\nconst ORDERS_KEY = '_67_orders';\n\nconst ORIGINAL_ORDERS = \[[\s\S]*?\n\];\n\n","",s,count=1)
s=re.sub(r"const readCart = \(\) => \{[\s\S]*?\n\};\n\n","",s,count=1)
s=s.replace("  { id: 'tabby', label: 'tabby', note: 'تابي · قسمها على 4' },\n  { id: 'tamara', label: 'tamara', note: 'تمارا · قسمها على 3 أو 4' },\n","")
anchor="  const navigate = useNavigate();"
if "offers: mockOffers" not in s:
    s=s.replace(anchor,anchor+"\n  const { offers: mockOffers, loading: catalogLoading, error: catalogError, reload: reloadCatalog } = useMarketplaceProducts();",1)
s=s.replace("  const sellerCommission = subtotal * 0.015;","  const sellerCommission = subtotal * 0.01;")
# replace persistOrder + handleCompleteOrder block
start=s.find("  const persistOrder = () => {")
end=s.find("\n\n  if (!items.length && step !== 3)",start)
if start<0 or end<0: raise SystemExit("Checkout persistOrder block not found")
new="""  const handleCompleteOrder = async () => {
    if (!items.length || (!isPickup && !shippingMethod) || !isAddressComplete || (remainingTotal > 0 && !paymentMethod)) return;
    setIsProcessing(true);
    try {
      const payload = {
        customerName: address.name || 'عميل 67',
        customerPhone: address.phone,
        fulfillment: fulfillmentMethod,
        address: isPickup ? 'استلام من الفرع' : [address.city,address.district,address.street,address.building].filter(Boolean).join(' - '),
        items: items.map(({offer,quantity}) => ({ productId: offer.id, quantity })),
      };
      const response = await fetch('/api/marketplace/orders', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify(payload),
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.error || 'تعذر إنشاء الطلب');
      const orders = Array.isArray(data.orders) ? data.orders : [];
      saveOrderReceipts(orders);
      saveCart([]);
      await reloadCatalog();
      const order = orders[0] || null;
      setCompletedOrder(order ? {
        ...order,
        total: Number((total).toFixed(2)),
        fulfillmentMethod,
      } : null);
      setStep(3);
    } catch (error) {
      window.alert(error.message || 'تعذر إتمام الطلب');
    } finally {
      setIsProcessing(false);
    }
  };"""
s=s[:start]+new+s[end:]
# loading condition
s=s.replace("  if (!items.length && step !== 3) {","  if (catalogLoading && step !== 3) return <div className=\"co67-page\" dir=\"rtl\"><main className=\"co67-empty\"><Package size={46}/><h1>جاري التحقق من الأسعار والمخزون…</h1></main></div>;\n  if (catalogError && step !== 3) return <div className=\"co67-page\" dir=\"rtl\"><main className=\"co67-empty\"><Package size={46}/><h1>تعذر تحميل المنتجات</h1><p>{catalogError}</p></main></div>;\n\n  if (!items.length && step !== 3) {")
# success total and ID compatible
s=s.replace("{completedOrder.total.toFixed(2)} ر.س","{Number(completedOrder.total || total).toFixed(2)} ر.س")
write(p,s)

# MyOrders: use secure receipts to read same backend orders.
p="src/pages/MyOrdersPage.jsx"; s=read(p)
s=s.replace("import './MyOrdersPage.css';","import { readOrderReceipts } from '../utils/marketplaceClient';\nimport './MyOrdersPage.css';")
# remove INITIAL_ORDERS block
s=re.sub(r"const INITIAL_ORDERS = \[[\s\S]*?\n\];\n\n","",s,count=1)
old="""  useEffect(() => {
    const saved = localStorage.getItem('_67_orders');
    if (saved) {
      try {
        setOrders(JSON.parse(saved));
      } catch {
        localStorage.setItem('_67_orders', JSON.stringify(INITIAL_ORDERS));
        setOrders(INITIAL_ORDERS);
      }
    } else {
      localStorage.setItem('_67_orders', JSON.stringify(INITIAL_ORDERS));
      setOrders(INITIAL_ORDERS);
    }
  }, []);"""
new="""  useEffect(() => {
    const receipts = readOrderReceipts();
    if (!receipts.length) { setOrders([]); return; }
    fetch('/api/marketplace/order-status', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({receipts}),
    }).then(async (response) => {
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.error || 'تعذر تحميل الطلبات');
      setOrders((data.orders || []).map((order) => ({
        ...order,
        itemName:(order.items || []).map((item) => item.name).join(' + '),
        date:String(order.createdAt || '').slice(0,10),
        total:Number(order.subtotal || 0),
      })));
    }).catch(() => setOrders([]));
  }, []);"""
if old not in s: raise SystemExit("MyOrders useEffect anchor missing")
s=s.replace(old,new,1)
# Customer cannot mark delivered; seller controls lifecycle in current phase.
start=s.find("  const confirmDelivery = (order) => {")
end=s.find("\n\n  return (",start)
if start>=0 and end>=0: s=s[:start]+s[end:]
s=s.replace("""                      {order.status === 'shipped' && (
                        <button type="button" className="b01o-confirm" onClick={() => confirmDelivery(order)}>
                          <CheckCircle size={15} />
                          تأكيد الاستلام
                        </button>
                      )}
""","")
write(p,s)
