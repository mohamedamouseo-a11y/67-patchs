#!/usr/bin/env python3
from pathlib import Path
import hashlib
import re
import sys

ROOT = Path('/67')
JSX = ROOT / 'src/pages/GitHubModule.jsx'
SERVER_GITHUB = ROOT / 'server/github.js'
SERVER_INDEX = ROOT / 'server/index.js'
CSS = ROOT / 'src/pages/GitHubModule.push-progress.css'

EXPECTED = {
    JSX: 'b8c5e6b843e4426077eae5f9d1d578d8d2f34775',
    SERVER_GITHUB: 'ce52b303f284d6a3b9fb75f86c607e77171f95f8',
    SERVER_INDEX: 'ad707bebc140fd2cb18390839ab5c5635248e858',
}

def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

def verify_current():
    for path, expected in EXPECTED.items():
        data = path.read_bytes()
        actual = git_blob_sha(data)
        if actual != expected:
            raise SystemExit(f'PATCH_BASE_MISMATCH:{path}:{actual}:expected:{expected}')

def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'PATCH_CONTEXT_MISMATCH:{label}:count={count}')
    return text.replace(old, new, 1)

def regex_once(text: str, pattern: str, replacement: str, label: str) -> str:
    out, count = re.subn(pattern, lambda _: replacement, text, count=1, flags=re.S)
    if count != 1:
        raise SystemExit(f'PATCH_REGEX_MISMATCH:{label}:count={count}')
    return out

verify_current()

jsx = JSX.read_text()
jsx = replace_once(
    jsx,
    "import './GitHubModule.css';\nimport { createRealtimeTicker, formatElapsedTime } from '../utils/progressTime';",
    "import './GitHubModule.css';\nimport './GitHubModule.push-progress.css';\nimport { createRealtimeTicker, formatElapsedTime } from '../utils/progressTime';",
    'jsx-import',
)
jsx = replace_once(
    jsx,
    "  const [liveProgress, setLiveProgress] = useState(null);\n  const [progressNow, setProgressNow] = useState(Date.now());",
    "  const [liveProgress, setLiveProgress] = useState(null);\n  const [progressNow, setProgressNow] = useState(Date.now());\n  const [lastOperation, setLastOperation] = useState(null);",
    'jsx-state',
)

old_progress = """  const startLiveProgress = useCallback((kind, label) => {
    const startedAt = Date.now();
    setProgressNow(startedAt);
    setLiveProgress({ id: `${kind}-${startedAt}`, kind, label, status: 'running', startedAt, finishedAt: null, message: '' });
  }, []);

  const finishLiveProgress = useCallback((statusValue, message = '') => {
    const finishedAt = Date.now();
    setProgressNow(finishedAt);
    setLiveProgress((current) => current ? { ...current, status: statusValue, finishedAt, message } : current);
  }, []);"""
new_progress = """  const startLiveProgress = useCallback((kind, label, operationId = null) => {
    const startedAt = Date.now();
    setProgressNow(startedAt);
    setLiveProgress({
      id: operationId || `${kind}-${startedAt}`,
      kind,
      label,
      status: 'running',
      startedAt,
      finishedAt: null,
      message: 'بدء العملية…',
      percent: 1,
      stage: 'request',
      logs: [],
      files: [],
    });
  }, []);

  const finishLiveProgress = useCallback((statusValue, message = '') => {
    const finishedAt = Date.now();
    setProgressNow(finishedAt);
    setLiveProgress((current) => current ? { ...current, status: statusValue, finishedAt, message, percent: statusValue === 'success' ? 100 : current.percent } : current);
  }, []);

  const applyServerOperation = useCallback((operation) => {
    if (!operation?.id) return;
    const statusValue = operation.status === 'completed' ? 'success' : operation.status === 'failed' ? 'failed' : 'running';
    const startedAt = Date.parse(operation.startedAt) || Date.now();
    const finishedAt = operation.completedAt ? Date.parse(operation.completedAt) : null;
    setProgressNow(Date.now());
    setLastOperation(operation);
    setLiveProgress((current) => ({
      ...(current || {}),
      id: operation.id,
      kind: 'execute',
      label: current?.label || `${String(operation.action || 'GitHub').toUpperCase()} Execute`,
      status: statusValue,
      startedAt,
      finishedAt,
      percent: Number.isFinite(operation.percent) ? operation.percent : (statusValue === 'success' ? 100 : 1),
      stage: operation.stage || current?.stage || 'running',
      message: operation.message || operation.error || current?.message || '',
      logs: Array.isArray(operation.logs) ? operation.logs : [],
      files: Array.isArray(operation.files) ? operation.files : [],
      fileCount: operation.fileCount ?? operation.files?.length ?? 0,
      commitSha: operation.commitSha || null,
      pushedSha: operation.pushedSha || null,
      repo: operation.repo || null,
      branch: operation.branch || null,
      expectedAction: operation.expectedAction || null,
    }));
  }, []);"""
jsx = replace_once(jsx, old_progress, new_progress, 'jsx-progress-state')

execute_review = """  const executeReview = async () => {
    if (!review?.authorization) return;
    const operationId = globalThis.crypto?.randomUUID?.();
    if (!operationId) {
      showNotice('error', 'المتصفح لا يدعم operation UUID الآمن. حدّث المتصفح ثم أعد المحاولة.');
      return;
    }
    startLiveProgress('execute', `${String(review.action || 'GitHub').toUpperCase()} Execute`, operationId);
    setBusy('execute');
    let pollingTimer = null;
    let pollingClosed = false;
    const refreshOperation = async () => {
      if (pollingClosed) return;
      try {
        const data = await api(`/api/developer-hub/github-sync-operation/${operationId}`);
        applyServerOperation(data.operation);
      } catch (error) {
        if (error?.status !== 404) console.warn('GitHub operation progress polling failed:', error?.message || error);
      }
    };
    pollingTimer = window.setInterval(refreshOperation, 650);
    try {
      const data = await api('/api/developer-hub/github-sync-execute', {
        method: 'POST', headers: csrfHeaders,
        body: JSON.stringify({
          action: review.action,
          authorization: review.authorization,
          executionKind: status?.pushMode === 'auto' ? 'auto' : 'review_approved',
          commitMessage,
          operationId,
        }),
      });
      applyServerOperation(data.operation);
      showNotice('success', `تم التنفيذ بنجاح: ${data.operation?.expectedAction || review.expectedAction}`);
      setReview(null); setCommitMessage(''); await loadStatus(); await loadAudit();
    } catch (error) {
      await refreshOperation();
      setLiveProgress((current) => current ? { ...current, status: 'failed', finishedAt: Date.now(), message: error?.message || current.message || 'Execution failed' } : current);
      await handleError(error); setReview(null); await loadStatus();
    } finally {
      pollingClosed = true;
      if (pollingTimer) window.clearInterval(pollingTimer);
      setBusy('');
    }
  };"""
jsx = regex_once(
    jsx,
    r"  const executeReview = async \(\) => \{.*?\n  \};\n\n  const local =",
    execute_review + "\n\n  const local =",
    'jsx-execute-review',
)

jsx = replace_once(
    jsx,
    "      {local.available && <article className=\"sa-card\"><div className=\"sa-card-head\"><div><span className=\"sa-kicker\">LIVE GIT STATE</span>",
    "      {local.available && <article className=\"sa-card\"><div className=\"sa-card-head\"><div><span className=\"sa-kicker\">LIVE GIT STATE</span>",
    'jsx-live-state-anchor',
)
anchor = "\n      <article className=\"sa-card\"><div className=\"sa-card-head\"><div><span className=\"sa-kicker\">GITHUB SECURITY EVENTS</span>"
if jsx.count(anchor) != 1:
    raise SystemExit(f'PATCH_CONTEXT_MISMATCH:jsx-audit-anchor:count={jsx.count(anchor)}')
jsx = jsx.replace(anchor, "\n      <PushHistory events={auditEvents} currentOperation={lastOperation} />\n" + anchor, 1)

live_component = """function LiveProgressTime({ progress, now, onDismiss }) {
  const active = progress.status === 'running';
  const endAt = progress.finishedAt || now;
  const elapsed = formatElapsedTime(Math.max(0, endAt - progress.startedAt));
  const started = new Date(progress.startedAt).toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
  const statusLabel = active ? 'LIVE' : progress.status === 'success' ? 'DONE' : progress.status === 'blocked' ? 'BLOCKED' : 'FAILED';
  const percent = Math.max(0, Math.min(100, Number(progress.percent) || 0));
  return <article className={`sa-live-progress sa-live-progress-${progress.status}`} aria-live="polite">
    <div className="sa-live-progress-main">
      <div className="sa-live-progress-icon"><Clock3 size={20} className={active ? 'sa-live-clock' : ''} /></div>
      <div className="sa-live-progress-copy">
        <div className="sa-live-progress-title"><strong>{progress.label}</strong><span className={`sa-live-state ${progress.status}`}>{statusLabel}</span></div>
        <div className="sa-live-progress-meta"><span>بدأ: {started}</span><span>المرحلة: <b>{progress.stage || '—'}</b></span><span>الوقت: <b className="mono">{elapsed}</b></span>{progress.message && <span>{progress.message}</span>}</div>
      </div>
      <strong className="sa-live-percent mono">{percent}%</strong>
      {!active && <button type="button" className="sa-live-dismiss" onClick={onDismiss} aria-label="إخفاء Progress time">×</button>}
    </div>
    <div className="sa-live-progress-track" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow={percent}><span className={progress.status} style={{ width: `${percent}%` }} /></div>
    {!!progress.logs?.length && <div className="sa-operation-log"><div className="sa-operation-log-head"><strong>Execution Log</strong><span>{progress.logs.length} events</span></div>{progress.logs.slice(-14).map((entry, index) => <div className="sa-operation-log-row" key={`${entry.at}-${entry.stage}-${index}`}><time>{new Date(entry.at).toLocaleTimeString('ar-EG')}</time><code>{entry.stage}</code><span>{entry.message}</span></div>)}</div>}
    {!!progress.files?.length && <div className="sa-operation-files"><div className="sa-operation-log-head"><strong>Files in this operation</strong><span>{progress.fileCount || progress.files.length}</span></div>{progress.files.slice(0, 100).map((file, index) => <div className="sa-operation-file-row" key={`${file.path}-${index}`}><code>{file.status}</code><span>{file.path}</span>{file.originalPath && <small>← {file.originalPath}</small>}</div>)}{progress.files.length > 100 && <small className="sa-more-files">+ {progress.files.length - 100} files</small>}</div>}
    {(progress.commitSha || progress.pushedSha) && <div className="sa-operation-shas"><span>Commit <b className="mono">{progress.commitSha?.slice(0, 12) || '—'}</b></span><span>Remote <b className="mono">{progress.pushedSha?.slice(0, 12) || '—'}</b></span></div>}
  </article>;
}

function PushHistory({ events, currentOperation }) {
  const completed = (events || []).filter((event) => event.action === 'GITHUB_SYNC_EXECUTE' && event.outcome === 'success' && ['push', 'commit_and_push'].includes(event.meta?.expectedAction)).slice(0, 6);
  if (!completed.length && !currentOperation?.files?.length) return null;
  return <article className="sa-card sa-push-history">
    <div className="sa-card-head"><div><span className="sa-kicker">PUSH TRACE</span><h2>آخر الملفات التي وصلت إلى GitHub</h2></div><Github size={24} /></div>
    {!completed.length ? <div className="sa-empty">سيظهر سجل الـPush الدائم هنا بعد أول تنفيذ ناجح.</div> : completed.map((event, index) => <details key={`${event.at}-${index}`} open={index === 0}>
      <summary><span><strong>{event.meta?.expectedAction}</strong><small>{event.meta?.repo} · {event.meta?.branch}</small></span><span className="mono">{event.meta?.commitSha?.slice(0, 12) || event.meta?.pushedSha?.slice(0, 12) || '—'}</span><time>{new Date(event.at).toLocaleString('ar-EG')}</time><StatusPill tone="success">{event.meta?.files || 0} files</StatusPill></summary>
      <div className="sa-push-file-list">{(event.meta?.fileList || []).map((file, fileIndex) => <div key={`${file.path}-${fileIndex}`}><code>{file.status}</code><span>{file.path}</span>{file.originalPath && <small>← {file.originalPath}</small>}</div>)}{event.meta?.filesTruncated && <small className="sa-more-files">السجل يعرض أول {event.meta.fileList?.length || 0} ملف من أصل {event.meta.files}.</small>}</div>
    </details>)}
  </article>;
}"""
jsx = regex_once(
    jsx,
    r"function LiveProgressTime\(\{ progress, now, onDismiss \}\) \{.*?\n\}\n\nfunction ReviewPanel",
    live_component + "\n\nfunction ReviewPanel",
    'jsx-live-component',
)

server_index = SERVER_INDEX.read_text()
route_replacement = """    if (method === 'POST' && pathname === '/api/developer-hub/github-sync-execute') {
      const body = await readJson(req);
      try {
        const saved = await store.readConfig();
        const selection = saved.githubSelection;
        const pushMode = ['off', 'review', 'auto'].includes(saved.githubPushMode) ? saved.githubPushMode : 'review';
        const action = String(body.action || '');
        const executionKind = String(body.executionKind || '');
        const operationId = String(body.operationId || '').trim();
        if (operationId && !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(operationId)) throw new HttpError(400, 'Invalid operation id.');
        const auth = verifyExecutionAuthorization(body.authorization, config.sessionSecret);
        if (!timingSafeEqualString(auth.sessionBinding, sessionHash(ctx.superadmin.sid))) throw new HttpError(403, 'Execution authorization belongs to a different Superadmin session.');
        if (auth.pushMode === 'review' && ['push', 'commit_and_push'].includes(auth.expectedAction) && executionKind !== 'review_approved') throw new HttpError(403, 'Review mode requires explicit Superadmin approval.');
        if (auth.pushMode === 'auto' && ['push', 'commit_and_push'].includes(auth.expectedAction) && !['auto', 'review_approved'].includes(executionKind)) throw new HttpError(403, 'Auto mode requires verified auto or explicit approval.');
        const operation = await github.execute({ selection, authorizationPayload: auth, action, pushMode, commitMessage: body.commitMessage, operationId });
        const fileList = (operation.files || []).slice(0, 250).map((file) => ({
          status: file.status,
          path: file.path,
          ...(file.originalPath ? { originalPath: file.originalPath } : {}),
        }));
        await audit(ctx, 'GITHUB_SYNC_EXECUTE', 'success', {
          action,
          expectedAction: operation.expectedAction,
          operationId: operation.id,
          repo: operation.repo,
          branch: operation.branch,
          commitSha: operation.commitSha || null,
          pushedSha: operation.pushedSha || null,
          files: operation.fileCount || fileList.length,
          fileList,
          filesTruncated: (operation.fileCount || 0) > fileList.length,
        });
        return json(res, 200, { operation });
      } catch (error) {
        const failedOperation = body.operationId ? github.getOperation(String(body.operationId)) : null;
        await audit(ctx, 'GITHUB_SYNC_EXECUTE', 'failed', { action: String(body.action || ''), operationId: String(body.operationId || ''), stage: failedOperation?.stage || null, percent: failedOperation?.percent ?? null, reason: redactSecrets(error?.message || 'execution_failed') });
        throw error;
      }
    }

    const operationMatch"""
server_index = regex_once(
    server_index,
    r"    if \(method === 'POST' && pathname === '/api/developer-hub/github-sync-execute'\) \{.*?\n    \}\n\n    const operationMatch",
    route_replacement,
    'server-index-execute-route',
)

server_github = SERVER_GITHUB.read_text()
execute_service = r"""  updateOperation(operation, percent, stage, message, extra = {}) {
    const at = new Date().toISOString();
    operation.percent = Math.max(0, Math.min(100, Math.trunc(percent)));
    operation.stage = stage;
    operation.message = message;
    operation.updatedAt = at;
    operation.logs = [...(operation.logs || []), { at, stage, message }].slice(-80);
    Object.assign(operation, extra);
    if (Array.isArray(extra.files)) operation.fileCount = extra.files.length;
    return operation;
  }

  async filesInRange(gitRoot, fromSha, toSha) {
    if (!fromSha || !toSha || fromSha === toSha) return [];
    const { stdout } = await this.git(['diff', '--name-status', '-z', '--find-renames=50%', `${fromSha}..${toSha}`], { cwd: gitRoot, timeout: 60_000 });
    return parseNameStatus(stdout);
  }

  async verifyPublishedHead(state, expectedSha) {
    const { stdout } = await this.git(['ls-remote', state.binding.selected.repoUrl, `refs/heads/${state.binding.branch}`], { network: true, timeout: 90_000, cwd: state.gitRoot });
    const actual = String(stdout || '').trim().split(/\s+/)[0] || '';
    if (actual !== expectedSha) throw new Error('GitHub remote verification failed after push.');
    return actual;
  }

  async execute({ selection, authorizationPayload, action, pushMode, commitMessage, operationId: requestedOperationId }) {
    const operationId = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(String(requestedOperationId || '')) ? String(requestedOperationId) : cryptoRandomId();
    if (this.operations.has(operationId)) throw new Error('Operation id is already in use.');
    const operation = {
      id: operationId,
      action,
      expectedAction: authorizationPayload.expectedAction,
      status: 'running',
      percent: 1,
      stage: 'starting',
      message: 'Execution accepted by server.',
      startedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      repo: selection?.repo || null,
      branch: selection?.branch || null,
      files: [],
      fileCount: 0,
      logs: [],
      commitSha: null,
      pushedSha: null,
    };
    this.operations.set(operationId, operation);
    this.updateOperation(operation, 3, 'accepted', 'Server accepted the approved execution.');
    try {
      this.updateOperation(operation, 8, 'refresh_state', 'Refreshing local and remote Git state.');
      const state = await this.rawState(selection, { fetch: action !== 'cleanup' });
      operation.repo = state.binding.selected.fullName;
      operation.branch = state.binding.branch;
      this.updateOperation(operation, 16, 'verify_review', 'Verifying signed review fingerprint against current state.');
      const currentFingerprint = this.stateFingerprint(state, action);
      if (currentFingerprint !== authorizationPayload.fingerprint) throw new Error('Project or remote state changed. Review the operation again.');
      if (authorizationPayload.repo !== state.binding.selected.fullName.toLowerCase() || authorizationPayload.branch !== state.binding.branch || authorizationPayload.action !== action) throw new Error('Repository/branch/action changed. Review again.');
      if (authorizationPayload.pushMode !== pushMode) throw new Error('Push mode changed. Review again.');

      this.updateOperation(operation, 25, 'security_scan', 'Re-running path, secret and outgoing-history security checks.');
      const { blockers, safeFiles } = await this.scanChanges(state.files, state.gitRoot);
      if (!state.manifestComplete) blockers.push({ path: '*', reason: 'more than 250 working-tree changes require manual review' });
      if (['push','commit_and_push'].includes(authorizationPayload.expectedAction)) blockers.push(...await this.scanOutgoingHistory(state));
      if (authorizationPayload.expectedAction === 'fast_forward_pull') blockers.push(...await this.scanIncomingHistory(state));
      if (blockers.length) throw new Error('Security blockers appeared after review. Review again.');
      if (safeFiles.length !== authorizationPayload.fileCount) throw new Error('Project files changed. Review again.');

      const expectedAction = this.expectedAction(action, state);
      operation.expectedAction = expectedAction;
      if (expectedAction !== authorizationPayload.expectedAction) throw new Error('Required Git action changed. Review again.');
      this.updateOperation(operation, 36, 'action_locked', `Execution action locked: ${expectedAction}.`);

      if (expectedAction === 'fast_forward_pull') {
        const incomingFiles = await this.filesInRange(state.gitRoot, state.head, state.remoteSha);
        this.updateOperation(operation, 48, 'pull_prepare', `Prepared ${incomingFiles.length} incoming file changes.`, { files: incomingFiles });
        if (state.mode === 'managed-workspace') await this.applyManagedPullToDeployment(state);
        else {
          await this.assertSafeLocalGitConfig(state.gitRoot);
          await this.git(['merge', '--ff-only', state.remoteSha], { timeout: 120_000, cwd: state.gitRoot });
        }
        this.updateOperation(operation, 92, 'pull_verify', 'Verifying fast-forward result.');
        const pulledHead = (await this.git(['rev-parse', 'HEAD'], { cwd: state.gitRoot })).stdout.trim();
        if (pulledHead !== state.remoteSha) throw new Error('Fast-forward verification failed.');
      } else if (expectedAction === 'commit_and_push') {
        if (pushMode === 'off') throw new Error('GitHub push mode is Off.');
        const paths = [...new Set(safeFiles.flatMap((entry) => [entry.path, entry.originalPath].filter(Boolean)))];
        if (!paths.length) throw new Error('No safe files were approved for commit.');
        this.updateOperation(operation, 44, 'stage_files', `Staging ${paths.length} approved paths.`, { files: safeFiles });
        await this.assertSafeLocalGitConfig(state.gitRoot);
        await this.git(['add', '--all', '--', ...paths], { timeout: 120_000, cwd: state.gitRoot });
        this.updateOperation(operation, 56, 'verify_index', 'Verifying staged content matches the signed review manifest.');
        await this.assertIndexMatchesManifest(state.contentManifest, state.gitRoot);
        const message = String(commitMessage || '').trim().replace(/[\r\n]+/g, ' ').slice(0, 120) || `Verified 67 update — ${new Date().toISOString().slice(0, 16).replace('T', ' ')}`;
        this.updateOperation(operation, 64, 'commit', 'Creating verified Git commit.');
        await this.git(['commit', '-m', message], { timeout: 120_000, cwd: state.gitRoot });
        const commitSha = (await this.git(['rev-parse', 'HEAD'], { cwd: state.gitRoot })).stdout.trim();
        const parentSha = (await this.git(['rev-parse', `${commitSha}^`], { cwd: state.gitRoot })).stdout.trim();
        if (parentSha !== state.head) throw new Error('Commit parent changed during execution; push was blocked.');
        const pushedFiles = await this.filesInRange(state.gitRoot, state.remoteSha, commitSha);
        this.updateOperation(operation, 72, 'commit_ready', `Commit ${commitSha.slice(0, 12)} contains ${pushedFiles.length} files to publish.`, { commitSha, files: pushedFiles });
        await this.assertSafeLocalGitConfig(state.gitRoot);
        this.updateOperation(operation, 79, 'push', `Publishing commit to ${state.binding.selected.fullName}/${state.binding.branch}.`);
        await this.git(['push', state.binding.selected.repoUrl, `${commitSha}:refs/heads/${state.binding.branch}`], { network: true, timeout: 180_000, cwd: state.gitRoot });
        this.updateOperation(operation, 92, 'verify_remote', 'Verifying published branch SHA directly from GitHub.');
        const publishedSha = await this.verifyPublishedHead(state, commitSha);
        await this.git(['update-ref', `refs/remotes/origin/${state.binding.branch}`, commitSha], { cwd: state.gitRoot });
        operation.pushedSha = publishedSha;
      } else if (expectedAction === 'push') {
        if (pushMode === 'off') throw new Error('GitHub push mode is Off.');
        const pushedFiles = await this.filesInRange(state.gitRoot, state.remoteSha, state.head);
        this.updateOperation(operation, 48, 'push_prepare', `Prepared ${pushedFiles.length} committed file changes for GitHub.`, { files: pushedFiles, commitSha: state.head });
        await this.assertSafeLocalGitConfig(state.gitRoot);
        this.updateOperation(operation, 72, 'push', `Publishing ${state.head.slice(0, 12)} to ${state.binding.selected.fullName}/${state.binding.branch}.`);
        await this.git(['push', state.binding.selected.repoUrl, `${state.head}:refs/heads/${state.binding.branch}`], { network: true, timeout: 180_000, cwd: state.gitRoot });
        this.updateOperation(operation, 92, 'verify_remote', 'Verifying published branch SHA directly from GitHub.');
        const publishedSha = await this.verifyPublishedHead(state, state.head);
        await this.git(['update-ref', `refs/remotes/origin/${state.binding.branch}`, state.head], { cwd: state.gitRoot });
        operation.pushedSha = publishedSha;
      } else if (expectedAction === 'safe_maintenance') {
        this.updateOperation(operation, 48, 'maintenance_fetch', 'Pruning remote refs safely.');
        await this.assertSafeLocalGitConfig(state.gitRoot);
        await this.git(['fetch', '--prune', '--no-tags', state.binding.selected.repoUrl, '+refs/heads/*:refs/remotes/origin/*'], { network: true, timeout: 120_000, cwd: state.gitRoot });
        this.updateOperation(operation, 82, 'maintenance_gc', 'Running Git garbage collection.');
        await this.git(['gc', '--auto'], { timeout: 120_000, cwd: state.gitRoot });
      }
      operation.status = 'completed';
      operation.completedAt = new Date().toISOString();
      this.updateOperation(operation, 100, 'completed', 'Operation completed and verified.', { pushedSha: operation.pushedSha || null });
      operation.result = { expectedAction, commitSha: operation.commitSha || null, pushedSha: operation.pushedSha || null, files: operation.files };
      return operation;
    } catch (error) {
      operation.status = 'failed';
      operation.completedAt = new Date().toISOString();
      operation.error = cleanError(error);
      this.updateOperation(operation, operation.percent || 1, 'failed', operation.error);
      throw error;
    } finally {
      this.pruneOperations();
    }
  }"""
server_github = regex_once(
    server_github,
    r"  async execute\(\{ selection, authorizationPayload, action, pushMode, commitMessage \}\) \{.*?\n  \}\n\n  getOperation\(id\)",
    execute_service + "\n\n  getOperation(id)",
    'server-github-execute',
)

css = r"""/* GitHub Push Observability V1 — truthful server-stage progress */
.sa-live-progress{border:1px solid #2a405d;border-radius:16px;background:linear-gradient(145deg,#0b1726,#0f2033);padding:16px;box-shadow:0 16px 40px rgba(0,0,0,.16);overflow:hidden}
.sa-live-progress-success{border-color:rgba(52,211,153,.38)}.sa-live-progress-failed,.sa-live-progress-blocked{border-color:rgba(251,113,133,.45)}
.sa-live-progress-main{display:flex;align-items:center;gap:12px}.sa-live-progress-icon{width:42px;height:42px;display:grid;place-items:center;border-radius:12px;background:#142942;color:#d7b660;flex:0 0 auto}.sa-live-progress-copy{min-width:0;flex:1}
.sa-live-progress-title{display:flex;align-items:center;gap:9px;flex-wrap:wrap}.sa-live-progress-title>strong{font-size:15px}.sa-live-state{font-size:10px;font-weight:900;letter-spacing:1px;padding:4px 7px;border-radius:999px;border:1px solid #3a4b61;color:#9fb0c3}.sa-live-state.running{color:#a9d3f7;border-color:#2f5c7f;background:#10273a}.sa-live-state.success{color:#9bf7d5;border-color:#2a624f;background:#103229}.sa-live-state.failed,.sa-live-state.blocked{color:#ffadba;border-color:#6d3440;background:#32171d}
.sa-live-progress-meta{display:flex;gap:12px;flex-wrap:wrap;margin-top:6px;color:#8ea0b5;font-size:11px;direction:rtl}.sa-live-progress-meta b{color:#dce8f7}.sa-live-percent{font-size:22px;color:#d7b660;min-width:64px;text-align:center;font-variant-numeric:tabular-nums}.sa-live-dismiss{width:32px;height:32px;border:1px solid #2b3d55;background:#111f31;color:#9cadc0;border-radius:9px;cursor:pointer;font-size:20px}
.sa-live-progress-track{height:10px;margin-top:13px;border-radius:999px;background:#07111d;border:1px solid #1f3349;overflow:hidden}.sa-live-progress-track>span{display:block;height:100%;min-width:2px;border-radius:999px;background:linear-gradient(90deg,#b89237,#e1c56e);transition:width .28s ease;animation:none!important;transform:none!important}.sa-live-progress-track>span.success{background:linear-gradient(90deg,#159b6a,#42d7a1)}.sa-live-progress-track>span.failed,.sa-live-progress-track>span.blocked{background:linear-gradient(90deg,#b43e51,#f16a7b)}
.sa-operation-log,.sa-operation-files{margin-top:14px;border:1px solid #20344b;border-radius:11px;overflow:auto;background:#08131f;max-height:320px;overscroll-behavior:contain}.sa-operation-log-head{display:flex;justify-content:space-between;gap:10px;align-items:center;padding:9px 11px;background:#101e2e;border-bottom:1px solid #20344b}.sa-operation-log-head strong{font-size:12px;color:#e7eef8}.sa-operation-log-head span{font-size:10px;color:#8ea0b5}
.sa-operation-log-row{display:grid;grid-template-columns:92px 125px 1fr;gap:10px;padding:7px 11px;border-bottom:1px solid #15263a;font-size:11px}.sa-operation-log-row time{color:#6f849d;font-family:ui-monospace,SFMono-Regular,Menlo,monospace}.sa-operation-log-row code{color:#d7b660;background:#171d1e;border:1px solid #3f3d2b;padding:2px 6px;border-radius:5px;direction:ltr;text-align:left}.sa-operation-log-row span{color:#b7c6d7;line-height:1.5}
.sa-operation-file-row,.sa-push-file-list>div{display:grid;grid-template-columns:52px minmax(0,1fr) auto;gap:10px;padding:7px 11px;border-bottom:1px solid #15263a;font-size:11px}.sa-operation-file-row code,.sa-push-file-list code{color:#efd37a;font-weight:900;min-width:32px;text-align:center;border:1px solid #3b4939;background:#142019;border-radius:5px;padding:2px 5px}.sa-operation-file-row span,.sa-push-file-list span{color:#c3d0df;word-break:break-all;direction:ltr;text-align:left}.sa-operation-file-row small,.sa-push-file-list small{color:#6f849d;word-break:break-all}.sa-more-files{display:block;padding:9px 11px;color:#8ea0b5!important}.sa-operation-shas{display:flex;gap:18px;flex-wrap:wrap;padding-top:11px;color:#8ea0b5;font-size:11px}.sa-operation-shas b{color:#d9e4f2}
.sa-push-history{border-color:#33455d!important}.sa-push-history details{border:1px solid #20344b;border-radius:11px;background:#091522;margin-top:9px;overflow:hidden}.sa-push-history summary{display:grid;grid-template-columns:16px minmax(180px,1.4fr) 120px 190px auto;gap:12px;align-items:center;padding:11px 12px;cursor:pointer;list-style:none;background:#0d1b2b}.sa-push-history summary::-webkit-details-marker{display:none}.sa-push-history summary:before{content:'▸';color:#7f93aa;transition:transform .15s}.sa-push-history details[open] summary:before{transform:rotate(90deg)}.sa-push-history summary>span:first-of-type{display:flex;flex-direction:column;min-width:0}.sa-push-history summary strong{font-size:12px}.sa-push-history summary small,.sa-push-history summary time{font-size:10px;color:#8ea0b5}.sa-push-history summary>.mono{color:#d8c27a;font-size:11px}.sa-push-file-list{border-top:1px solid #20344b;max-height:310px;overflow:auto}.sa-push-history details:first-of-type summary{box-shadow:inset -3px 0 #34d399}
@media(max-width:900px){.sa-operation-log-row{grid-template-columns:72px 100px 1fr}.sa-push-history summary{grid-template-columns:16px 1fr auto}.sa-push-history summary time{display:none}}
@media(max-width:620px){.sa-live-progress-main{align-items:flex-start;flex-wrap:wrap}.sa-live-percent{font-size:18px;min-width:auto;margin-inline-start:auto}.sa-operation-log-row{grid-template-columns:1fr;gap:4px}.sa-operation-file-row,.sa-push-file-list>div{grid-template-columns:42px 1fr}.sa-operation-file-row small,.sa-push-file-list small{grid-column:2}}
"""

# Write only after every transformation succeeded in memory.
JSX.write_text(jsx)
SERVER_INDEX.write_text(server_index)
SERVER_GITHUB.write_text(server_github)
CSS.write_text(css)

print('PATCH_TRANSFORM=PASS')
print('BASE_COMMIT=368a4a811704a7fdbfba721dd4febc3326a2d353')
print('FILES_CHANGED=src/pages/GitHubModule.jsx,src/pages/GitHubModule.push-progress.css,server/index.js,server/github.js')
