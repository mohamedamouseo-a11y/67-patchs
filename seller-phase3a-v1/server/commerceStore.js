import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';

const PRODUCT_STATUSES = new Set(['draft','active','inactive']);
const ORDER_STATUSES = new Set(['new','processing','shipped','delivered','rejected']);

function clean(value, field, max=300, required=true){
  const text=String(value??'').trim();
  if(required&&!text) throw new Error(`${field} is required.`);
  if(text.length>max||/[\u0000-\u001f\u007f]/.test(text)) throw new Error(`${field} is invalid.`);
  return text;
}
function money(value, field){
  const n=Number(value);
  if(!Number.isFinite(n)||n<0||n>10000000) throw new Error(`${field} is invalid.`);
  return Math.round(n*100)/100;
}
function qty(value, field='Stock'){
  const n=Number(value);
  if(!Number.isSafeInteger(n)||n<0||n>1000000) throw new Error(`${field} is invalid.`);
  return n;
}
async function atomicWrite(file,payload){
  const tmp=`${file}.${process.pid}.${Date.now()}.tmp`;
  try{
    await fs.writeFile(tmp,`${JSON.stringify(payload,null,2)}\n`,{mode:0o600,flag:'wx'});
    await fs.rename(tmp,file);
    try{await fs.chmod(file,0o600)}catch{}
  }finally{try{await fs.unlink(tmp)}catch{}}
}

export class CommerceStore{
  constructor(dataDir){
    this.root=path.join(dataDir,'commerce');
    this.productsPath=path.join(this.root,'products.json');
    this.ordersPath=path.join(this.root,'orders.json');
    this.queue=Promise.resolve();
  }
  async init(){await fs.mkdir(this.root,{recursive:true,mode:0o700});try{await fs.chmod(this.root,0o700)}catch{}}
  async read(file){await this.init();try{const p=JSON.parse(await fs.readFile(file,'utf8'));return Array.isArray(p)?p:[]}catch(e){if(e?.code==='ENOENT')return[];throw e}}
  async products(){return this.read(this.productsPath)}
  async orders(){return this.read(this.ordersPath)}
  normalizeProduct(input, seller, existing={}){
    const status=PRODUCT_STATUSES.has(input.status)?input.status:(existing.status||'draft');
    const stock=qty(input.stock ?? existing.stock ?? 0);
    return {
      ...existing,
      sellerId:seller.id,
      storeName:seller.storeName,
      name:clean(input.name ?? existing.name,'Product name',180),
      partNumber:clean(input.partNumber ?? existing.partNumber,'Part number',100,false),
      category:clean(input.category ?? existing.category,'Category',120),
      condition:clean(input.condition ?? existing.condition,'Condition',80),
      brand:clean(input.brand ?? existing.brand,'Brand',100),
      compatibility:clean(input.compatibility ?? existing.compatibility,'Compatibility',180,false),
      description:clean(input.description ?? existing.description,'Description',1500,false),
      warranty:clean(input.warranty ?? existing.warranty,'Warranty',180,false),
      price:money(input.price ?? existing.price,'Price'),
      stock,
      status:stock===0?'inactive':status,
      imageUrl:clean(input.imageUrl ?? existing.imageUrl,'Image URL',600,false),
    };
  }
  async createProduct(seller,input){
    const task=this.queue.then(async()=>{
      const rows=await this.products();
      const now=new Date().toISOString();
      const product=this.normalizeProduct(input,seller,{id:`PRD-${crypto.randomUUID()}`,createdAt:now,updatedAt:now});
      product.updatedAt=now;
      rows.unshift(product);await atomicWrite(this.productsPath,rows);return product;
    });this.queue=task.catch(()=>{});return task;
  }
  async updateProduct(seller,id,input){
    const task=this.queue.then(async()=>{
      const rows=await this.products();const i=rows.findIndex(x=>x.id===id&&x.sellerId===seller.id);
      if(i<0) throw new Error('Product not found.');
      rows[i]={...this.normalizeProduct(input,seller,rows[i]),id:rows[i].id,createdAt:rows[i].createdAt,updatedAt:new Date().toISOString()};
      await atomicWrite(this.productsPath,rows);return rows[i];
    });this.queue=task.catch(()=>{});return task;
  }
  async deleteProduct(seller,id){
    const task=this.queue.then(async()=>{
      const rows=await this.products();const i=rows.findIndex(x=>x.id===id&&x.sellerId===seller.id);
      if(i<0) throw new Error('Product not found.');
      const orders=await this.orders();
      if(orders.some(o=>o.items?.some(line=>line.productId===id)&&!['delivered','rejected'].includes(o.status))) throw new Error('Product has an open order and cannot be deleted.');
      rows.splice(i,1);await atomicWrite(this.productsPath,rows);return true;
    });this.queue=task.catch(()=>{});return task;
  }
  async sellerProducts(sellerId){return (await this.products()).filter(x=>x.sellerId===sellerId)}
  async publicProducts(){return (await this.products()).filter(x=>x.status==='active'&&x.stock>0).map(x=>({...x}))}
  async createOrder(input){
    const task=this.queue.then(async()=>{
      const productRows=await this.products();
      const requested=Array.isArray(input.items)?input.items:[];
      if(!requested.length||requested.length>50) throw new Error('Order items are required.');
      const groups=new Map();
      for(const line of requested){
        const product=productRows.find(p=>p.id===String(line.productId||''));
        const quantity=qty(line.quantity,'Quantity');
        if(!product||product.status!=='active'||product.stock<quantity||quantity<1) throw new Error('A product is unavailable or has insufficient stock.');
        if(!groups.has(product.sellerId)) groups.set(product.sellerId,{sellerId:product.sellerId,storeName:product.storeName,items:[]});
        groups.get(product.sellerId).items.push({productId:product.id,name:product.name,price:product.price,quantity});
      }
      const rows=await this.orders();const created=[];const now=new Date().toISOString();
      for(const group of groups.values()){
        const subtotal=group.items.reduce((s,x)=>s+x.price*x.quantity,0);
        const commission=Math.round(subtotal*0.015*100)/100;
        const order={
          id:`ORD-${crypto.randomUUID()}`,sellerId:group.sellerId,storeName:group.storeName,
          customerName:clean(input.customerName,'Customer name',160),customerPhone:clean(input.customerPhone,'Customer phone',40),
          fulfillment:clean(input.fulfillment||'delivery','Fulfillment',40),
          address:clean(input.address||'','Address',500,false),items:group.items,
          subtotal:Math.round(subtotal*100)/100,commission,sellerNet:Math.round((subtotal-commission)*100)/100,
          status:'new',createdAt:now,updatedAt:now,statusHistory:[{status:'new',at:now,actor:'customer'}],
        };
        for(const line of group.items){
          const p=productRows.find(x=>x.id===line.productId);p.stock-=line.quantity;if(p.stock===0)p.status='inactive';p.updatedAt=now;
        }
        rows.unshift(order);created.push(order);
      }
      await atomicWrite(this.productsPath,productRows);await atomicWrite(this.ordersPath,rows);return created;
    });this.queue=task.catch(()=>{});return task;
  }
  async sellerOrders(sellerId){return (await this.orders()).filter(o=>o.sellerId===sellerId)}
  async allOrders(){return this.orders()}
  async updateOrderStatus(seller,id,status){
    if(!ORDER_STATUSES.has(status)) throw new Error('Invalid order status.');
    const allowed={new:new Set(['processing','rejected']),processing:new Set(['shipped','rejected']),shipped:new Set(['delivered']),delivered:new Set(),rejected:new Set()};
    const task=this.queue.then(async()=>{
      const rows=await this.orders();const i=rows.findIndex(o=>o.id===id&&o.sellerId===seller.id);
      if(i<0) throw new Error('Order not found.');
      if(!allowed[rows[i].status]?.has(status)) throw new Error('Invalid order status transition.');
      const now=new Date().toISOString();rows[i]={...rows[i],status,updatedAt:now,statusHistory:[...(rows[i].statusHistory||[]),{status,at:now,actor:'seller'}]};
      await atomicWrite(this.ordersPath,rows);return rows[i];
    });this.queue=task.catch(()=>{});return task;
  }
}
