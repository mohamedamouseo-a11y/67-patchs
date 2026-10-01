from pathlib import Path

p=Path("/67/server/index.js")
s=p.read_text()

anchor="""  if (method === 'POST' && pathname === '/api/marketplace/orders') {
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
"""
insert=anchor+"""
  if (method === 'POST' && pathname === '/api/marketplace/order-status') {
    requireMutationOrigin(ctx);
    const rate = marketplaceOrderLimiter.check(requestIp(req));
    if (!rate.allowed) throw new HttpError(429, 'Too many order status attempts.');
    const body = await readJson(req);
    const receipts = Array.isArray(body.receipts) ? body.receipts : [];
    if (!receipts.length || receipts.length > 100) throw new HttpError(400, 'Valid order receipts are required.');
    const orders = await commerceStore.customerOrders(receipts);
    return json(res, 200, { orders });
  }
"""
if "/api/marketplace/order-status" not in s:
    if anchor not in s: raise SystemExit("Phase 3A marketplace order route anchor missing")
    s=s.replace(anchor,insert,1)

p.write_text(s)
