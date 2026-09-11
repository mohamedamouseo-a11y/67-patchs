#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

const OAUTH_KEYS = process.env.GDRIVE_OAUTH_KEYS || '/home/openhands/.openhands/gdrive/gcp-oauth.keys.json';
const TOKEN_FILE = process.env.GDRIVE_CREDENTIALS || '/home/openhands/.openhands/gdrive/.gdrive-server-credentials.json';

function die(message, extra = {}) {
  console.error(JSON.stringify({ ok: false, error: message, ...extra }));
  process.exit(1);
}

async function readJson(file) {
  try { return JSON.parse(await fs.readFile(file, 'utf8')); }
  catch (error) { die('JSON_READ_FAILED', { file, detail: error?.message || String(error) }); }
}

function deepFind(obj, key) {
  if (!obj || typeof obj !== 'object') return undefined;
  if (Object.prototype.hasOwnProperty.call(obj, key) && obj[key]) return obj[key];
  for (const value of Object.values(obj)) {
    const found = deepFind(value, key);
    if (found) return found;
  }
  return undefined;
}

function escapeDriveQuery(value) {
  return String(value).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

async function refreshAccessToken(clientId, clientSecret, refreshToken) {
  const body = new URLSearchParams({
    client_id: clientId,
    client_secret: clientSecret,
    refresh_token: refreshToken,
    grant_type: 'refresh_token',
  });
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok || !payload.access_token) {
    die('OAUTH_REFRESH_FAILED', { status: response.status, detail: payload.error || payload.error_description || 'unknown' });
  }
  return payload.access_token;
}

async function getAccessToken() {
  const keys = await readJson(OAUTH_KEYS);
  const credentials = await readJson(TOKEN_FILE);
  const clientId = deepFind(keys, 'client_id') || deepFind(credentials, 'client_id');
  const clientSecret = deepFind(keys, 'client_secret') || deepFind(credentials, 'client_secret');
  const refreshToken = deepFind(credentials, 'refresh_token');
  const accessToken = deepFind(credentials, 'access_token');
  const expiry = Number(deepFind(credentials, 'expiry_date') || 0);

  if (refreshToken && clientId && clientSecret) {
    return await refreshAccessToken(clientId, clientSecret, refreshToken);
  }
  if (accessToken && (!expiry || expiry > Date.now() + 60_000)) return accessToken;
  die('NO_USABLE_OAUTH_TOKEN');
}

async function driveFetch(url, token, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(options.headers || {}),
    },
  });
  const text = await response.text();
  let payload;
  try { payload = text ? JSON.parse(text) : {}; } catch { payload = { raw: text }; }
  if (!response.ok) {
    const reason = payload?.error?.message || payload?.error_description || payload?.raw || `HTTP_${response.status}`;
    const code = payload?.error?.errors?.[0]?.reason || payload?.error || 'DRIVE_API_ERROR';
    throw new Error(`${response.status}:${code}:${reason}`);
  }
  return payload;
}

async function findExactRootFile(name, token) {
  const q = `name='${escapeDriveQuery(name)}' and trashed=false and 'root' in parents`;
  const params = new URLSearchParams({ q, fields: 'files(id,name,webViewLink,parents,mimeType,size,modifiedTime)', pageSize: '10' });
  const payload = await driveFetch(`https://www.googleapis.com/drive/v3/files?${params}`, token);
  return Array.isArray(payload.files) ? payload.files.find((f) => f.name === name) || null : null;
}

async function uploadPng(filePath, token) {
  const stat = await fs.stat(filePath).catch(() => null);
  if (!stat?.isFile()) throw new Error(`FILE_NOT_FOUND:${filePath}`);
  const name = path.basename(filePath);

  const existing = await findExactRootFile(name, token);
  if (existing) return { ...existing, reused: true };

  const bytes = await fs.readFile(filePath);
  const boundary = `67_${crypto.randomBytes(18).toString('hex')}`;
  const metadata = Buffer.from(
    `--${boundary}\r\n` +
    `Content-Type: application/json; charset=UTF-8\r\n\r\n` +
    `${JSON.stringify({ name })}\r\n` +
    `--${boundary}\r\n` +
    `Content-Type: image/png\r\n\r\n`
  );
  const closing = Buffer.from(`\r\n--${boundary}--\r\n`);
  const body = Buffer.concat([metadata, bytes, closing]);

  const params = new URLSearchParams({
    uploadType: 'multipart',
    fields: 'id,name,webViewLink,parents,mimeType,size,modifiedTime',
  });
  return await driveFetch(`https://www.googleapis.com/upload/drive/v3/files?${params}`, token, {
    method: 'POST',
    headers: { 'Content-Type': `multipart/related; boundary=${boundary}`, 'Content-Length': String(body.length) },
    body,
  });
}

const inputs = process.argv.slice(2);
if (!inputs.length) die('NO_INPUT_FILES');
if (inputs.some((item) => path.extname(item).toLowerCase() !== '.png')) die('ONLY_PNG_SUPPORTED');

const token = await getAccessToken();
const results = [];
for (const [index, filePath] of inputs.entries()) {
  try {
    const uploaded = await uploadPng(path.resolve(filePath), token);
    const verified = await findExactRootFile(uploaded.name, token);
    if (!verified?.id) throw new Error('POST_UPLOAD_VERIFY_FAILED');
    const item = {
      index: index + 1,
      name: verified.name,
      id: verified.id,
      webViewLink: verified.webViewLink || `https://drive.google.com/file/d/${verified.id}/view`,
      parent: Array.isArray(verified.parents) ? verified.parents[0] || null : null,
      reused: Boolean(uploaded.reused),
    };
    results.push(item);
    console.log(`DRIVE_FILE_${String(index + 1).padStart(2, '0')}_NAME=${item.name}`);
    console.log(`DRIVE_FILE_${String(index + 1).padStart(2, '0')}_ID=${item.id}`);
    console.log(`DRIVE_FILE_${String(index + 1).padStart(2, '0')}_LINK=${item.webViewLink}`);
  } catch (error) {
    die('UPLOAD_OR_VERIFY_FAILED', { file: filePath, detail: error?.message || String(error), uploaded_count: results.length });
  }
}
console.log(`DRIVE_UPLOAD=OK`);
console.log(`DRIVE_UPLOAD_COUNT=${results.length}`);
console.log(`DRIVE_DESTINATION=MY_DRIVE_ROOT`);
