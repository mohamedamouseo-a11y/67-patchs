#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
TARGET=server/index.js
TEST_FILE=server/sessionPersistence.integration.test.js
BACKUP=/tmp/67-v22.3-session-$$
FAILED_STEP=init
APPLIED_NOW=NO
HAD_TEST=NO

cd "$ROOT"

fail(){
  local msg="$1"
  if [ "$APPLIED_NOW" = "YES" ] && [ -d "$BACKUP" ]; then
    cp "$BACKUP/index.js" "$TARGET" 2>/dev/null || true
    if [ "$HAD_TEST" = "YES" ]; then
      cp "$BACKUP/sessionPersistence.integration.test.js" "$TEST_FILE" 2>/dev/null || true
    else
      rm -f "$TEST_FILE"
    fi
  fi
  echo "PATCH_APPLIED=NO"
  echo "TESTS=FAIL"
  echo "BUILD=FAIL"
  echo "FAILED_STEP=$FAILED_STEP"
  echo "ERROR=$msg"
  exit 1
}
trap 'fail V22_3_SESSION_PERSISTENCE_FAILED' ERR

FAILED_STEP=detect_runtime_state
if grep -q "SIX SEVEN V22.3 — MULTI SESSION SUPERADMIN" "$TARGET" 2>/dev/null; then
  STATE_ACTION=ALREADY_AT_V22_3
else
  grep -q "await store.patchConfig({ activeSessionHash: sessionHash(payload.sid) });" "$TARGET" || fail UNSUPPORTED_RUNTIME_STATE_LOGIN_ANCHOR
  grep -q "await store.patchConfig({ activeSessionHash: null });" "$TARGET" || fail UNSUPPORTED_RUNTIME_STATE_LOGOUT_ANCHOR
  APPLIED_NOW=YES
  STATE_ACTION=APPLY_V22_3
  mkdir -p "$BACKUP"
  cp "$TARGET" "$BACKUP/index.js"
  if [ -f "$TEST_FILE" ]; then
    HAD_TEST=YES
    cp "$TEST_FILE" "$BACKUP/sessionPersistence.integration.test.js"
  fi

  FAILED_STEP=patch_server_auth
  python3 - <<'PY'
from pathlib import Path
p=Path('/67/server/index.js')
s=p.read_text()

anchor="const sessionHash = (sid) => crypto.createHash('sha256').update(String(sid)).digest('hex');\n"
helper=r'''const sessionHash = (sid) => crypto.createHash('sha256').update(String(sid)).digest('hex');

// SIX SEVEN V22.3 — MULTI SESSION SUPERADMIN
// Multiple signed Superadmin sessions may coexist (e.g. owner browser + QA agent).
// Sessions stay individually revocable and the registry is bounded.
const MAX_ACTIVE_SUPERADMIN_SESSIONS = 12;

function activeSessionHashes(saved = {}) {
  const values = [];
  if (Array.isArray(saved.activeSessionHashes)) values.push(...saved.activeSessionHashes);
  // Backward-compatible migration from the legacy single-session field.
  if (typeof saved.activeSessionHash === 'string' && saved.activeSessionHash) values.push(saved.activeSessionHash);
  const clean = values
    .map((value) => String(value || '').trim().toLowerCase())
    .filter((value) => /^[a-f0-9]{64}$/.test(value));
  return [...new Set(clean)].slice(-MAX_ACTIVE_SUPERADMIN_SESSIONS);
}

function isSessionActive(saved, sid) {
  const candidate = sessionHash(sid);
  return activeSessionHashes(saved).some((hash) => timingSafeEqualString(hash, candidate));
}

async function registerActiveSession(sid) {
  const saved = await store.readConfig();
  const candidate = sessionHash(sid);
  const hashes = activeSessionHashes(saved).filter((hash) => !timingSafeEqualString(hash, candidate));
  hashes.push(candidate);
  await store.patchConfig({
    activeSessionHashes: hashes.slice(-MAX_ACTIVE_SUPERADMIN_SESSIONS),
    activeSessionHash: null,
  });
}

async function revokeActiveSession(sid) {
  const saved = await store.readConfig();
  const candidate = sessionHash(sid);
  const hashes = activeSessionHashes(saved).filter((hash) => !timingSafeEqualString(hash, candidate));
  await store.patchConfig({
    activeSessionHashes: hashes,
    activeSessionHash: null,
  });
}
'''
if 'SIX SEVEN V22.3 — MULTI SESSION SUPERADMIN' not in s:
    if anchor not in s:
        raise SystemExit('SESSION_HASH_ANCHOR_NOT_FOUND')
    s=s.replace(anchor,helper,1)

old_check="if (!saved.activeSessionHash || !timingSafeEqualString(saved.activeSessionHash, sessionHash(session.sid))) throw new HttpError(401, 'Session is no longer active.');"
new_check="if (!isSessionActive(saved, session.sid)) throw new HttpError(401, 'Session is no longer active.');"
if old_check in s:
    s=s.replace(old_check,new_check,1)
elif new_check not in s:
    raise SystemExit('AUTHENTICATE_ACTIVE_SESSION_CHECK_NOT_FOUND')

old_route="if (!saved.activeSessionHash || !timingSafeEqualString(saved.activeSessionHash, sessionHash(session.sid))) return json(res, 401, { authenticated: false, configured: true });"
new_route="if (!isSessionActive(saved, session.sid)) return json(res, 401, { authenticated: false, configured: true });"
if old_route in s:
    s=s.replace(old_route,new_route,1)
elif new_route not in s:
    raise SystemExit('SESSION_ROUTE_ACTIVE_SESSION_CHECK_NOT_FOUND')

old_login="await store.patchConfig({ activeSessionHash: sessionHash(payload.sid) });"
new_login="await registerActiveSession(payload.sid);"
if old_login in s:
    s=s.replace(old_login,new_login,1)
elif new_login not in s:
    raise SystemExit('LOGIN_REGISTRY_WRITE_NOT_FOUND')

old_logout="await store.patchConfig({ activeSessionHash: null });"
new_logout="await revokeActiveSession(ctx.superadmin.sid);"
if old_logout in s:
    s=s.replace(old_logout,new_logout,1)
elif new_logout not in s:
    raise SystemExit('LOGOUT_REGISTRY_WRITE_NOT_FOUND')

p.write_text(s)
PY

  FAILED_STEP=write_regression_test
  cat > "$TEST_FILE" <<'TEST'
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { hashPassword } from './security.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.dirname(here);

function waitForServer(child) {
  return new Promise((resolve, reject) => {
    let output = '';
    const timer = setTimeout(() => reject(new Error(`server start timeout: ${output}`)), 10_000);
    const onData = (chunk) => {
      output += String(chunk);
      const match = output.match(/67 server listening on 127\.0\.0\.1:(\d+)/);
      if (match) {
        clearTimeout(timer);
        child.stdout.off('data', onData);
        resolve(Number(match[1]));
      }
    };
    child.stdout.on('data', onData);
    child.stderr.on('data', (chunk) => { output += String(chunk); });
    child.once('exit', (code) => {
      clearTimeout(timer);
      reject(new Error(`server exited before ready (${code}): ${output}`));
    });
  });
}

async function login(base, headers, username, password) {
  const response = await fetch(`${base}/api/superadmin/login`, {
    method: 'POST',
    headers: { ...headers, 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password }),
  });
  assert.equal(response.status, 200);
  const body = await response.json();
  return { cookie: (response.headers.get('set-cookie') || '').split(';')[0], csrf: body.csrfToken };
}

test('owner and QA superadmin sessions coexist; logout revokes only the current session', async (t) => {
  const dataDir = await fs.mkdtemp(path.join(os.tmpdir(), '67-multisession-'));
  t.after(() => fs.rm(dataDir, { recursive: true, force: true }));
  const username = 'root-admin';
  const password = 'Production-Admin-Password-67!';
  const passwordHash = await hashPassword(password);
  const child = spawn(process.execPath, ['server/index.js'], {
    cwd: root,
    env: {
      ...process.env,
      NODE_ENV: 'production',
      PORT: '0',
      SERVER_HOST: '127.0.0.1',
      TRUST_PROXY: '1',
      SUPERADMIN_USERNAME: username,
      SUPERADMIN_PASSWORD_HASH: passwordHash,
      SUPERADMIN_SESSION_SECRET: 'session-secret-'.repeat(4),
      SUPERADMIN_ENCRYPTION_KEY: Buffer.alloc(32, 3).toString('base64'),
      SUPERADMIN_ALLOWED_ORIGIN: 'https://67.test',
      DATA_DIR: dataDir,
      GIT_REPOSITORY_ROOT: root,
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  t.after(() => { if (!child.killed) child.kill('SIGTERM'); });

  const port = await waitForServer(child);
  const base = `http://127.0.0.1:${port}`;
  const headers = { Origin: 'https://67.test', 'X-Forwarded-Proto': 'https' };

  const owner = await login(base, headers, username, password);
  let response = await fetch(`${base}/api/superadmin/session`, { headers: { ...headers, Cookie: owner.cookie } });
  assert.equal(response.status, 200);

  const qa = await login(base, headers, username, password);

  // The second login must NOT invalidate the already-open owner browser session.
  response = await fetch(`${base}/api/superadmin/session`, { headers: { ...headers, Cookie: owner.cookie } });
  assert.equal(response.status, 200);
  assert.equal((await response.json()).authenticated, true);

  response = await fetch(`${base}/api/superadmin/session`, { headers: { ...headers, Cookie: qa.cookie } });
  assert.equal(response.status, 200);
  assert.equal((await response.json()).authenticated, true);

  // Logging out owner revokes owner only; QA remains authenticated.
  response = await fetch(`${base}/api/superadmin/logout`, {
    method: 'POST',
    headers: { ...headers, Cookie: owner.cookie, 'X-CSRF-Token': owner.csrf },
  });
  assert.equal(response.status, 204);

  response = await fetch(`${base}/api/superadmin/session`, { headers: { ...headers, Cookie: owner.cookie } });
  assert.equal(response.status, 401);

  response = await fetch(`${base}/api/superadmin/session`, { headers: { ...headers, Cookie: qa.cookie } });
  assert.equal(response.status, 200);
  assert.equal((await response.json()).authenticated, true);
});
TEST

  grep -q "SIX SEVEN V22.3 — MULTI SESSION SUPERADMIN" "$TARGET"
  grep -q "registerActiveSession(payload.sid)" "$TARGET"
  grep -q "revokeActiveSession(ctx.superadmin.sid)" "$TARGET"
fi

FAILED_STEP=tests
npm test >/tmp/67-v22.3-tests.log 2>&1 || {
  tail -n 160 /tmp/67-v22.3-tests.log || true
  fail TESTS_FAILED
}

FAILED_STEP=build
npm run build >/tmp/67-v22.3-build.log 2>&1 || {
  tail -n 120 /tmp/67-v22.3-build.log || true
  fail BUILD_FAILED
}

trap - ERR
rm -rf "$BACKUP"
echo "PATCH_APPLIED=YES"
echo "TESTS=PASS"
echo "BUILD=PASS"
echo "STATE_ACTION=$STATE_ACTION"
echo "BASE_VERSION=V22.2"
echo "TARGET_VERSION=V22.3"
echo "ELEMENT=SUPERADMIN_SESSION_PERSISTENCE"
echo "ROOT_CAUSE=SINGLE_ACTIVE_SESSION_INVALIDATED_BY_AGENT_LOGIN"
echo "MULTI_SESSION_ENABLED=YES"
echo "MAX_ACTIVE_SESSIONS=12"
echo "LEGACY_SESSION_MIGRATION=YES"
echo "LOGOUT_REVOKES_CURRENT_SESSION_ONLY=YES"
echo "COOKIE_SECURITY_CHANGED=NO"
echo "SESSION_TTL_CHANGED=NO"
echo "UI_CHANGED=NO"
echo "DATA_MODEL_CHANGED=SESSION_REGISTRY_ONLY"
echo "BACKEND_CHANGED=YES"
echo "AUTH_CHANGED=YES"
echo "SERVICE_RESTART_REQUIRED=YES"
echo "SOURCE_PROJECT_PUSHED=NO"
echo "FAILED_STEP=NONE"
echo "ERROR=NONE"
