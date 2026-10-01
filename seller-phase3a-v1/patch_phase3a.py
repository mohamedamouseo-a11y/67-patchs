from pathlib import Path

root=Path("/67")
server=root/"server/index.js"
admin=root/"src/pages/AdminDashboard.jsx"

s=server.read_text()

imp="import { CommerceStore } from './commerceStore.js';"
anchor="import { SellerStore, createSellerSession, verifySellerSession } from './sellerStore.js';"
if imp not in s:
    if anchor not in s: raise SystemExit("Phase 2 SellerStore import anchor missing")
    s=s.replace(anchor,anchor+"\n"+imp,1)

anchor="await sellerStore.init();"
insert="""await sellerStore.init();

const commerceStore = new CommerceStore(config.dataDir);
await commerceStore.init();"""
if "const commerceStore = new CommerceStore" not in s:
    if anchor not in s: raise SystemExit("commerce init anchor missing")
    s=s.replace(anchor,insert,1)

anchor="const sellerLoginLimiter = new FixedWindowLimiter({ windowMs: 15 * 60_000, limit: 12 });"
extra=anchor+"\nconst sellerCommerceLimiter = new FixedWindowLimiter({ windowMs: 60_000, limit: 90 });\nconst marketplaceOrderLimiter = new FixedWindowLimiter({ windowMs: 15 * 60_000, limit: 20 });"
if "sellerCommerceLimiter" not in s:
    if anchor not in s: raise SystemExit("seller limiter anchor missing")
    s=s.replace(anchor,extra,1)

helper_anchor="function requireMutationOrigin(ctx) {"
helper="""async function authenticateSellerCommerce(ctx) {
  const token = parseCookie(ctx.req.headers.cookie, sellerCookieName);
  const session = verifySellerSession(token, config.sessionSecret);
  if (!session) throw new HttpError(401, 'Seller authentication required.');
  const seller = await sellerStore.getApplication(session.sellerId);
  if (!seller || seller.status !== 'approved') throw new HttpError(403, 'Approved seller account required.');
  ctx.seller = session;
  return { session, seller };
}

function requireSellerCommerceMutation(ctx, session) {
  requireMutationOrigin(ctx);
  if (!csrfMatches(session, ctx.req.headers['x-csrf-token'])) throw new HttpError(403, 'Seller CSRF validation failed.');
  const key = requestIp(ctx.req) + ':' + session.sellerId;
  const rate = sellerCommerceLimiter.check(key);
  if (!rate.allowed) throw new HttpError(429, 'Too many seller commerce requests.');
}

"""
if "authenticateSellerCommerce" not in s:
    if helper_anchor not in s: raise SystemExit("seller auth helper anchor missing")
    s=s.replace(helper_anchor,helper+helper_anchor,1)

route_anchor="  if (method === 'GET' && pathname === '/api/superadmin/session') {"
routes="""  if (method === 'GET' && pathname === '/api/marketplace/products') {
    return json(res, 200, { products: await commerceStore.publicProducts() });
  }

  if (method === 'POST' && pathname === '/api/marketplace/orders') {
    requireMutationOrigin(ctx);
    const rate = marketplaceOrderLimiter.check(requestIp(req));
    if (!rate.allowed) throw new HttpError(429, 'Too many order attempts.');
    try {
      const body = await readJson(req);
      const orders = await commerceStore.createOrder(body);
      await audit(ctx, 'MARKETPLACE_ORDER_CREATED', 'success', { orders: orders.length, customerPhone: String(body.customerPhone || '').slice(-4) });
      return json(res, 201, { orders });
    } catch (error) {
      if (error instanceof HttpError) throw error;
      throw new HttpError(400, error?.message || 'Order creation failed.');
    }
  }

  if (pathname === '/api/seller/products' && method === 'GET') {
    const { seller } = await authenticateSellerCommerce(ctx);
    return json(res, 200, { products: await commerceStore.sellerProducts(seller.id) });
  }

  if (pathname === '/api/seller/products' && method === 'POST') {
    const { session, seller } = await authenticateSellerCommerce(ctx);
    requireSellerCommerceMutation(ctx, session);
    const body = await readJson(req);
    try {
      const product = await commerceStore.createProduct(seller, body);
      await audit(ctx, 'SELLER_PRODUCT_CREATED', 'success', { sellerId: seller.id, productId: product.id });
      return json(res, 201, { product });
    } catch (error) { throw new HttpError(400, error?.message || 'Product creation failed.'); }
  }

  const sellerProductMatch = pathname.match(/^\/api\/seller\/products\/([^/]+)$/);
  if (sellerProductMatch && method === 'PATCH') {
    const { session, seller } = await authenticateSellerCommerce(ctx);
    requireSellerCommerceMutation(ctx, session);
    const body = await readJson(req);
    try {
      const product = await commerceStore.updateProduct(seller, decodeURIComponent(sellerProductMatch[1]), body);
      await audit(ctx, 'SELLER_PRODUCT_UPDATED', 'success', { sellerId: seller.id, productId: product.id, stock: product.stock, status: product.status });
      return json(res, 200, { product });
    } catch (error) { throw new HttpError(400, error?.message || 'Product update failed.'); }
  }

  if (sellerProductMatch && method === 'DELETE') {
    const { session, seller } = await authenticateSellerCommerce(ctx);
    requireSellerCommerceMutation(ctx, session);
    try {
      await commerceStore.deleteProduct(seller, decodeURIComponent(sellerProductMatch[1]));
      await audit(ctx, 'SELLER_PRODUCT_DELETED', 'success', { sellerId: seller.id, productId: decodeURIComponent(sellerProductMatch[1]) });
      return empty(res, 204);
    } catch (error) { throw new HttpError(400, error?.message || 'Product deletion failed.'); }
  }

  if (pathname === '/api/seller/orders' && method === 'GET') {
    const { seller } = await authenticateSellerCommerce(ctx);
    return json(res, 200, { orders: await commerceStore.sellerOrders(seller.id) });
  }

  const sellerOrderStatusMatch = pathname.match(/^\/api\/seller\/orders\/([^/]+)\/status$/);
  if (sellerOrderStatusMatch && method === 'PATCH') {
    const { session, seller } = await authenticateSellerCommerce(ctx);
    requireSellerCommerceMutation(ctx, session);
    const body = await readJson(req);
    try {
      const order = await commerceStore.updateOrderStatus(seller, decodeURIComponent(sellerOrderStatusMatch[1]), String(body.status || ''));
      await audit(ctx, 'SELLER_ORDER_STATUS_UPDATED', 'success', { sellerId: seller.id, orderId: order.id, status: order.status });
      return json(res, 200, { order });
    } catch (error) { throw new HttpError(400, error?.message || 'Order status update failed.'); }
  }

""" + route_anchor
if "SELLER_PRODUCT_CREATED" not in s:
    if route_anchor not in s: raise SystemExit("commerce route anchor missing")
    s=s.replace(route_anchor,routes,1)

super_anchor="""    if (method === 'GET' && pathname === '/api/superadmin/seller-applications') {"""
super_insert="""    if (method === 'GET' && pathname === '/api/superadmin/commerce-orders') {
      return json(res, 200, { orders: await commerceStore.allOrders() });
    }

    if (method === 'GET' && pathname === '/api/superadmin/commerce-products') {
      return json(res, 200, { products: await commerceStore.products() });
    }

""" + super_anchor
if "/api/superadmin/commerce-orders" not in s:
    if super_anchor not in s: raise SystemExit("superadmin commerce anchor missing")
    s=s.replace(super_anchor,super_insert,1)

server.write_text(s)

a=admin.read_text()
if "import CommerceOrdersPanel" not in a:
    anchor="import SellerApplicationsPanel from './SellerApplicationsPanel';"
    if anchor not in a: raise SystemExit("Phase 2 admin panel import missing")
    a=a.replace(anchor,anchor+"\nimport CommerceOrdersPanel from './CommerceOrdersPanel';",1)

tx_anchor="""        {activeTab === 'transactions' && (
          <div className="animate-fadeIn ref-batch-panel ref-batch-transactions" data-v42-reference-screen="payments-transactions" style={cardStyle}>"""
tx_new=tx_anchor+"\n            <CommerceOrdersPanel />"
if "<CommerceOrdersPanel />" not in a:
    if tx_anchor not in a: raise SystemExit("transactions tab anchor missing")
    a=a.replace(tx_anchor,tx_new,1)

admin.write_text(a)
