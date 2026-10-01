from pathlib import Path

root = Path("/67")
server = root / "server/index.js"
seller_app = root / "src/seller_app/SellerApp.jsx"
admin = root / "src/pages/AdminDashboard.jsx"

s = server.read_text()

imp = "import { SellerStore, createSellerSession, verifySellerSession } from './sellerStore.js';"
anchor = "import { SecureStore } from './store.js';"
if imp not in s:
    if anchor not in s: raise SystemExit("server import anchor missing")
    s = s.replace(anchor, anchor + "\n" + imp, 1)

anchor = "await store.init();"
insert = """await store.init();

const sellerStore = new SellerStore(config.dataDir);
await sellerStore.init();
const sellerCookieName = config.production ? '__Host-67-seller' : '67-seller';
const SELLER_SESSION_TTL_MS = 7 * 24 * 60 * 60_000;"""
if "const sellerStore = new SellerStore" not in s:
    if anchor not in s: raise SystemExit("sellerStore init anchor missing")
    s = s.replace(anchor, insert, 1)

s = s.replace("async function readJson(req) {", "async function readJson(req, limit = JSON_LIMIT) {", 1)
s = s.replace("if (total > JSON_LIMIT) throw new HttpError(413, 'Request body is too large.');", "if (total > limit) throw new HttpError(413, 'Request body is too large.');", 1)

anchor = "const mutationLimiter = new FixedWindowLimiter({ windowMs: 60_000, limit: 45 });"
extra = anchor + """
const sellerApplyLimiter = new FixedWindowLimiter({ windowMs: 15 * 60_000, limit: 10 });
const sellerLoginLimiter = new FixedWindowLimiter({ windowMs: 15 * 60_000, limit: 12 });"""
if "sellerApplyLimiter" not in s:
    if anchor not in s: raise SystemExit("limiter anchor missing")
    s = s.replace(anchor, extra, 1)

s = s.replace(
"if (config.production && (pathname.startsWith('/api/superadmin/') || pathname.startsWith('/api/developer-hub/')) && !isSecureRequest(req)) {",
"if (config.production && (pathname.startsWith('/api/superadmin/') || pathname.startsWith('/api/developer-hub/') || pathname.startsWith('/api/seller/')) && !isSecureRequest(req)) {",
1)

health = """  if (method === 'GET' && pathname === '/api/health') {
    return json(res, 200, { ok: true, service: '67', adminConfigured: config.configErrors.length === 0 });
  }
"""
seller_api = health + """
  if (method === 'POST' && pathname === '/api/seller/applications') {
    requireMutationOrigin(ctx);
    const rate = sellerApplyLimiter.check(requestIp(req));
    if (!rate.allowed) throw new HttpError(429, 'Too many seller application attempts.');
    try {
      const body = await readJson(req, 10 * 1024 * 1024);
      const created = await sellerStore.createApplication(body);
      await audit(ctx, 'SELLER_APPLICATION_CREATED', 'success', { sellerId: created.application.id, email: created.application.email, storeName: created.application.storeName });
      return json(res, 201, created);
    } catch (error) {
      if (error instanceof HttpError) throw error;
      await audit(ctx, 'SELLER_APPLICATION_CREATED', 'failed', { reason: error?.message || 'application_failed' });
      throw new HttpError(400, error?.message || 'Seller application failed.');
    }
  }

  if (method === 'POST' && pathname === '/api/seller/application-status') {
    requireMutationOrigin(ctx);
    const rate = sellerApplyLimiter.check(requestIp(req));
    if (!rate.allowed) throw new HttpError(429, 'Too many status requests.');
    const body = await readJson(req);
    const application = await sellerStore.verifyTracking(body.id, body.trackingToken);
    if (!application) throw new HttpError(401, 'Invalid application tracking credentials.');
    return json(res, 200, { application });
  }

  if (method === 'POST' && pathname === '/api/seller/login') {
    requireMutationOrigin(ctx);
    const rate = sellerLoginLimiter.check(requestIp(req));
    if (!rate.allowed) throw new HttpError(429, 'Too many seller login attempts.');
    const body = await readJson(req);
    const result = await sellerStore.authenticate(body.email, body.password);
    if (!result.ok) {
      if (result.reason === 'not_approved') return json(res, 403, { error: 'Seller account is not approved yet.', code: 'SELLER_NOT_APPROVED', application: result.application });
      throw new HttpError(401, 'Invalid seller credentials.');
    }
    const { token, payload } = createSellerSession({ sellerId: result.seller.id, email: result.seller.email, secret: config.sessionSecret, ttlMs: SELLER_SESSION_TTL_MS });
    ctx.seller = payload;
    await audit(ctx, 'SELLER_LOGIN', 'success', { sellerId: result.seller.id });
    return json(res, 200, { authenticated: true, seller: result.seller, csrfToken: payload.csrf, expiresAt: new Date(payload.exp).toISOString() }, {
      'Set-Cookie': serializeCookie(sellerCookieName, token, { httpOnly: true, secure: config.production, sameSite: 'strict', path: '/', maxAge: SELLER_SESSION_TTL_MS }),
    });
  }

  if (method === 'GET' && pathname === '/api/seller/session') {
    const token = parseCookie(req.headers.cookie, sellerCookieName);
    const session = verifySellerSession(token, config.sessionSecret);
    if (!session) return json(res, 401, { authenticated: false });
    const seller = await sellerStore.getApplication(session.sellerId);
    if (!seller || seller.status !== 'approved') return json(res, 401, { authenticated: false });
    return json(res, 200, { authenticated: true, seller, csrfToken: session.csrf, expiresAt: new Date(session.exp).toISOString() });
  }

  if (method === 'POST' && pathname === '/api/seller/logout') {
    requireMutationOrigin(ctx);
    return empty(res, 204, { 'Set-Cookie': serializeCookie(sellerCookieName, '', { httpOnly: true, secure: config.production, sameSite: 'strict', path: '/', maxAge: 0 }) });
  }
"""
if "SELLER_APPLICATION_CREATED" not in s:
    if health not in s: raise SystemExit("health route anchor missing")
    s = s.replace(health, seller_api, 1)

super_anchor = """    if (method === 'POST' && pathname === '/api/superadmin/logout') {"""
admin_api = """    if (method === 'GET' && pathname === '/api/superadmin/seller-applications') {
      return json(res, 200, { applications: await sellerStore.listApplications() });
    }

    const sellerStatusMatch = pathname.match(/^\/api\/superadmin\/seller-applications\/([^/]+)\/status$/);
    if (method === 'PATCH' && sellerStatusMatch) {
      const body = await readJson(req);
      try {
        const application = await sellerStore.setStatus(decodeURIComponent(sellerStatusMatch[1]), String(body.status || ''), String(body.reviewNote || ''));
        await audit(ctx, 'SELLER_APPLICATION_REVIEWED', 'success', { sellerId: application.id, status: application.status });
        return json(res, 200, { application });
      } catch (error) {
        throw new HttpError(400, error?.message || 'Seller review failed.');
      }
    }

    const sellerDocumentMatch = pathname.match(/^\/api\/superadmin\/seller-applications\/([^/]+)\/documents\/([A-Za-z]+)$/);
    if (method === 'GET' && sellerDocumentMatch) {
      const document = await sellerStore.readDocument(decodeURIComponent(sellerDocumentMatch[1]), sellerDocumentMatch[2]);
      if (!document) throw new HttpError(404, 'Seller document not found.');
      res.statusCode = 200;
      res.setHeader('Content-Type', document.meta.mime);
      res.setHeader('Content-Length', document.buffer.length);
      res.setHeader('Cache-Control', 'no-store');
      res.setHeader('Content-Disposition', "inline; filename*=UTF-8''" + encodeURIComponent(document.meta.originalName || document.meta.fileName));
      return res.end(document.buffer);
    }

""" + super_anchor
if "seller-applications')" not in s:
    if super_anchor not in s: raise SystemExit("superadmin seller route anchor missing")
    s = s.replace(super_anchor, admin_api, 1)

server.write_text(s)

sa = seller_app.read_text()
if "import PendingReview" not in sa:
    sa = sa.replace("import Register from './pages/Register';", "import Register from './pages/Register';\nimport PendingReview from './pages/PendingReview';", 1)
if "import SellerGate" not in sa:
    sa = sa.replace("import EngineerAssistant from '../components/EngineerAssistant';", "import EngineerAssistant from '../components/EngineerAssistant';\nimport SellerGate from './components/SellerGate';", 1)
if '<Route path="/seller/pending"' not in sa:
    sa = sa.replace('<Route path="/seller/register" element={<Register />} />', '<Route path="/seller/register" element={<Register />} />\n        <Route path="/seller/pending" element={<PendingReview />} />', 1)
sa = sa.replace('<Route path="/seller/dashboard/*" element={<Dashboard />} />', '<Route path="/seller/dashboard/*" element={<SellerGate><Dashboard /></SellerGate>} />', 1)
seller_app.write_text(sa)

ad = admin.read_text()
if "import SellerApplicationsPanel" not in ad:
    ad = ad.replace("import GitHubModule from './GitHubModule';", "import GitHubModule from './GitHubModule';\nimport SellerApplicationsPanel from './SellerApplicationsPanel';", 1)

users_anchor = """        {activeTab === 'users' && (
          <div className="animate-fadeIn ref-batch-users" data-v42-reference-screen="users-sellers" style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
            
            {/* Sellers */}"""
users_new = """        {activeTab === 'users' && (
          <div className="animate-fadeIn ref-batch-users" data-v42-reference-screen="users-sellers" style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
            
            <SellerApplicationsPanel session={session} />

            {/* Sellers */}"""
if "<SellerApplicationsPanel session={session} />" not in ad:
    if users_anchor not in ad: raise SystemExit("admin users panel anchor missing")
    ad = ad.replace(users_anchor, users_new, 1)
admin.write_text(ad)
