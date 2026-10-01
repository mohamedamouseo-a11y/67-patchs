import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import { hashPassword, verifyPasswordHash, timingSafeEqualString } from './security.js';

const ALLOWED_DOCUMENTS = new Set(['commercialRegistration', 'identity', 'ibanProof', 'logo', 'storefront']);
const REQUIRED_DOCUMENTS = ['commercialRegistration', 'identity', 'ibanProof'];
const ALLOWED_MIME = new Set(['application/pdf', 'image/png', 'image/jpeg', 'image/webp']);
const MAX_DOCUMENT_BYTES = 3 * 1024 * 1024;
const SELLER_SESSION_VERSION = 1;

function cleanText(value, field, max = 180, required = true) {
  const text = String(value ?? '').trim();
  if (required && !text) throw new Error(`${field} is required.`);
  if (text.length > max || /[\u0000-\u001f\u007f]/.test(text)) throw new Error(`${field} is invalid.`);
  return text;
}

function normalizeEmail(value) {
  const email = cleanText(value, 'Email', 254).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new Error('Email is invalid.');
  return email;
}

function normalizePhone(value) {
  const phone = String(value ?? '').replace(/[^0-9+]/g, '');
  if (!/^\+?[0-9]{8,15}$/.test(phone)) throw new Error('Phone is invalid.');
  return phone;
}

function normalizeIban(value) {
  const iban = String(value ?? '').replace(/\s+/g, '').toUpperCase();
  if (!/^SA[0-9]{22}$/.test(iban)) throw new Error('Saudi IBAN is invalid.');
  return iban;
}

function safeFileName(kind, mime) {
  const ext = mime === 'application/pdf' ? '.pdf' : mime === 'image/png' ? '.png' : mime === 'image/webp' ? '.webp' : '.jpg';
  return `${kind}${ext}`;
}

function decodeDocument(input, kind) {
  if (!input || typeof input !== 'object') {
    if (REQUIRED_DOCUMENTS.includes(kind)) throw new Error(`${kind} document is required.`);
    return null;
  }
  const mime = String(input.type || '').toLowerCase();
  if (!ALLOWED_MIME.has(mime)) throw new Error(`${kind} document type is not allowed.`);
  const raw = String(input.data || '');
  const match = raw.match(/^data:([^;]+);base64,([A-Za-z0-9+/=]+)$/);
  if (!match || match[1].toLowerCase() !== mime) throw new Error(`${kind} document payload is invalid.`);
  const buffer = Buffer.from(match[2], 'base64');
  if (!buffer.length || buffer.length > MAX_DOCUMENT_BYTES) throw new Error(`${kind} document must be 3MB or less.`);
  return { buffer, mime, originalName: cleanText(input.name || safeFileName(kind, mime), 'Document name', 160) };
}

function publicApplication(app) {
  if (!app) return null;
  const { passwordHash, trackingHash, ...safe } = app;
  return safe;
}

function atomicWriteJson(filePath, payload) {
  return (async () => {
    const tmp = `${filePath}.${process.pid}.${Date.now()}.tmp`;
    try {
      await fs.writeFile(tmp, `${JSON.stringify(payload, null, 2)}\n`, { mode: 0o600, flag: 'wx' });
      await fs.rename(tmp, filePath);
      try { await fs.chmod(filePath, 0o600); } catch {}
    } finally {
      try { await fs.unlink(tmp); } catch {}
    }
  })();
}

function sessionSign(body, secret) {
  return crypto.createHmac('sha256', secret).update('67/seller/session/v1\0').update(body).digest('base64url');
}

export function createSellerSession({ sellerId, email, secret, ttlMs, now = Date.now() }) {
  const payload = {
    v: SELLER_SESSION_VERSION,
    sellerId,
    email,
    sid: crypto.randomBytes(24).toString('base64url'),
    csrf: crypto.randomBytes(24).toString('base64url'),
    iat: now,
    exp: now + ttlMs,
  };
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  return { token: `${body}.${sessionSign(body, secret)}`, payload };
}

export function verifySellerSession(token, secret, now = Date.now()) {
  const raw = String(token || '');
  if (!raw || raw.length > 8192) return null;
  const [body, signature, extra] = raw.split('.');
  if (!body || !signature || extra) return null;
  if (!timingSafeEqualString(signature, sessionSign(body, secret))) return null;
  try {
    const payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
    if (payload?.v !== SELLER_SESSION_VERSION || !payload.sellerId || !payload.email || !payload.sid || !payload.csrf) return null;
    if (!Number.isSafeInteger(payload.iat) || !Number.isSafeInteger(payload.exp) || payload.exp <= now) return null;
    if (payload.exp - payload.iat > 8 * 24 * 60 * 60_000) return null;
    return payload;
  } catch {
    return null;
  }
}

export class SellerStore {
  constructor(dataDir) {
    this.root = path.join(dataDir, 'seller');
    this.dataPath = path.join(this.root, 'applications.json');
    this.documentsRoot = path.join(this.root, 'documents');
    this.queue = Promise.resolve();
  }

  async init() {
    await fs.mkdir(this.root, { recursive: true, mode: 0o700 });
    await fs.mkdir(this.documentsRoot, { recursive: true, mode: 0o700 });
    try { await fs.chmod(this.root, 0o700); } catch {}
    try { await fs.chmod(this.documentsRoot, 0o700); } catch {}
  }

  async readAll() {
    await this.init();
    try {
      const raw = await fs.readFile(this.dataPath, 'utf8');
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch (error) {
      if (error?.code === 'ENOENT') return [];
      throw error;
    }
  }

  async writeAll(rows) {
    await this.init();
    await atomicWriteJson(this.dataPath, rows);
  }

  async createApplication(input) {
    const task = this.queue.then(async () => {
      const email = normalizeEmail(input.email);
      const phone = normalizePhone(input.phone);
      const password = String(input.password || '');
      if (password.length < 14 || password.length > 256) throw new Error('Password must be between 14 and 256 characters.');
      const rows = await this.readAll();
      if (rows.some((row) => row.email === email && row.status !== 'rejected')) throw new Error('A seller application already exists for this email.');

      const id = `SEL-${crypto.randomUUID()}`;
      const documentsInput = input.documents && typeof input.documents === 'object' ? input.documents : {};
      const decoded = {};
      for (const kind of ALLOWED_DOCUMENTS) {
        const doc = decodeDocument(documentsInput[kind], kind);
        if (doc) decoded[kind] = doc;
      }

      const documentDir = path.join(this.documentsRoot, id);
      await fs.mkdir(documentDir, { recursive: true, mode: 0o700 });
      const documents = {};
      try {
        for (const [kind, doc] of Object.entries(decoded)) {
          const fileName = safeFileName(kind, doc.mime);
          const filePath = path.join(documentDir, fileName);
          await fs.writeFile(filePath, doc.buffer, { mode: 0o600, flag: 'wx' });
          documents[kind] = { fileName, mime: doc.mime, originalName: doc.originalName, size: doc.buffer.length };
        }
      } catch (error) {
        await fs.rm(documentDir, { recursive: true, force: true });
        throw error;
      }

      const trackingToken = crypto.randomBytes(32).toString('base64url');
      const trackingHash = crypto.createHash('sha256').update(trackingToken).digest('hex');
      const passwordHash = await hashPassword(password);
      const now = new Date().toISOString();
      const application = {
        id,
        storeName: cleanText(input.storeName, 'Store name', 160),
        activityType: cleanText(input.activityType, 'Activity type', 80),
        commercialRegistration: cleanText(input.commercialRegistration, 'Commercial registration', 80),
        taxNumber: cleanText(input.taxNumber, 'Tax number', 80, false),
        foundedYear: cleanText(input.foundedYear, 'Founded year', 4, false),
        responsibleName: cleanText(input.responsibleName, 'Responsible name', 160),
        phone,
        email,
        passwordHash,
        city: cleanText(input.city, 'City', 120),
        district: cleanText(input.district, 'District', 120),
        address: cleanText(input.address, 'Address', 300),
        bankName: cleanText(input.bankName, 'Bank name', 120),
        accountHolder: cleanText(input.accountHolder, 'Account holder', 160),
        iban: normalizeIban(input.iban),
        documents,
        status: 'pending',
        reviewNote: '',
        createdAt: now,
        updatedAt: now,
        approvedAt: null,
        rejectedAt: null,
        trackingHash,
      };
      rows.unshift(application);
      await this.writeAll(rows);
      return { application: publicApplication(application), trackingToken };
    });
    this.queue = task.catch(() => {});
    return task;
  }

  async listApplications() {
    return (await this.readAll()).map(publicApplication);
  }

  async getApplication(id) {
    const row = (await this.readAll()).find((item) => item.id === id);
    return publicApplication(row);
  }

  async getInternalByEmail(email) {
    const normalized = normalizeEmail(email);
    return (await this.readAll()).find((item) => item.email === normalized) || null;
  }

  async verifyTracking(id, token) {
    const row = (await this.readAll()).find((item) => item.id === String(id || ''));
    if (!row || !token) return null;
    const hash = crypto.createHash('sha256').update(String(token)).digest('hex');
    return timingSafeEqualString(hash, row.trackingHash) ? publicApplication(row) : null;
  }

  async authenticate(email, password) {
    const row = await this.getInternalByEmail(email);
    if (!row) return { ok: false, reason: 'invalid_credentials' };
    const passwordOk = await verifyPasswordHash(password, row.passwordHash);
    if (!passwordOk) return { ok: false, reason: 'invalid_credentials' };
    if (row.status !== 'approved') return { ok: false, reason: 'not_approved', application: publicApplication(row) };
    return { ok: true, seller: publicApplication(row) };
  }

  async setStatus(id, status, reviewNote = '') {
    if (!['pending', 'needs_changes', 'approved', 'rejected'].includes(status)) throw new Error('Invalid seller status.');
    const task = this.queue.then(async () => {
      const rows = await this.readAll();
      const index = rows.findIndex((item) => item.id === id);
      if (index < 0) throw new Error('Seller application not found.');
      const now = new Date().toISOString();
      rows[index] = {
        ...rows[index],
        status,
        reviewNote: cleanText(reviewNote, 'Review note', 800, false),
        updatedAt: now,
        approvedAt: status === 'approved' ? now : rows[index].approvedAt,
        rejectedAt: status === 'rejected' ? now : rows[index].rejectedAt,
      };
      await this.writeAll(rows);
      return publicApplication(rows[index]);
    });
    this.queue = task.catch(() => {});
    return task;
  }

  async readDocument(id, kind) {
    if (!ALLOWED_DOCUMENTS.has(kind)) return null;
    const row = (await this.readAll()).find((item) => item.id === id);
    const meta = row?.documents?.[kind];
    if (!row || !meta) return null;
    const filePath = path.join(this.documentsRoot, row.id, path.basename(meta.fileName));
    const buffer = await fs.readFile(filePath);
    return { buffer, meta };
  }
}
