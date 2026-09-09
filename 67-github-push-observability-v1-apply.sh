#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=/67
PATCHER_URL=https://raw.githubusercontent.com/mohamedamouseo-a11y/67-patchs/main/67-github-push-observability-v1-apply.py
BACKUP_DIR="/tmp/67-github-observability-backup-$$"
PATCHED=0
mkdir -p "$BACKUP_DIR/src/pages" "$BACKUP_DIR/server"

cd "$ROOT"

cp src/pages/GitHubModule.jsx "$BACKUP_DIR/src/pages/GitHubModule.jsx"
cp server/index.js "$BACKUP_DIR/server/index.js"
cp server/github.js "$BACKUP_DIR/server/github.js"
if [ -f src/pages/GitHubModule.push-progress.css ]; then
  cp src/pages/GitHubModule.push-progress.css "$BACKUP_DIR/src/pages/GitHubModule.push-progress.css"
  HAD_PROGRESS_CSS=1
else
  HAD_PROGRESS_CSS=0
fi

rollback() {
  local code="$1"
  if [ "$PATCHED" = "1" ]; then
    cp "$BACKUP_DIR/src/pages/GitHubModule.jsx" src/pages/GitHubModule.jsx
    cp "$BACKUP_DIR/server/index.js" server/index.js
    cp "$BACKUP_DIR/server/github.js" server/github.js
    if [ "$HAD_PROGRESS_CSS" = "1" ]; then
      cp "$BACKUP_DIR/src/pages/GitHubModule.push-progress.css" src/pages/GitHubModule.push-progress.css
    else
      rm -f src/pages/GitHubModule.push-progress.css
    fi
    npm run build >/tmp/67-github-observability-rollback-build.log 2>&1 || true
    systemctl restart sixty-seven.service >/dev/null 2>&1 || true
  fi
  echo "PATCH_APPLIED=NO"
  echo "BUILD=FAILED_OR_NOT_RUN"
  echo "SERVICE_STATUS=$(systemctl is-active sixty-seven.service 2>/dev/null || true)"
  echo "FILES_CHANGED=NONE_AFTER_ROLLBACK"
  echo "ERROR=APPLY_OR_VALIDATION_FAILED_EXIT_${code}"
  exit "$code"
}
trap 'rollback $?' ERR

curl -fsSL "$PATCHER_URL" -o /tmp/67-github-push-observability-v1-apply.py
python3 /tmp/67-github-push-observability-v1-apply.py
PATCHED=1

node --check server/github.js
node --check server/index.js
npm run build
systemctl restart sixty-seven.service
sleep 2
systemctl is-active --quiet sixty-seven.service

LOCAL_ADMIN_HTTP=$(curl -sS -H 'Accept: text/html' -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/admin/)
if [ "$LOCAL_ADMIN_HTTP" != "200" ]; then
  echo "Unexpected local admin HTTP: $LOCAL_ADMIN_HTTP" >&2
  false
fi

grep -q "GitHubModule.push-progress.css" src/pages/GitHubModule.jsx
grep -q "operationId" src/pages/GitHubModule.jsx
grep -q "verifyPublishedHead" server/github.js
grep -q "fileList" server/index.js

echo "PATCH_APPLIED=YES"
echo "BASE_COMMIT=368a4a811704a7fdbfba721dd4febc3326a2d353"
echo "REAL_PROGRESS=YES"
echo "SERVER_STAGE_POLLING=YES"
echo "PUSH_FILE_TRACE=YES"
echo "PERSISTENT_AUDIT_FILE_LIST=YES"
echo "REMOTE_SHA_VERIFICATION=YES"
echo "BUILD=PASS"
echo "SERVICE_STATUS=active"
echo "LOCAL_ADMIN_HTTP=200"
echo "FILES_CHANGED=src/pages/GitHubModule.jsx,src/pages/GitHubModule.push-progress.css,server/index.js,server/github.js"
echo "ERROR=NONE"

rm -rf "$BACKUP_DIR"
trap - ERR
