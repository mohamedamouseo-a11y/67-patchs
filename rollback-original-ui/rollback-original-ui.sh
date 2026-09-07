#!/usr/bin/env bash
set -euo pipefail

APP=/67/QARIX
LIVE=/67/dist
OLD_LIVE=/67/dist-backup-20260903-132349
BASE=46c25c4
BRANCH=redesign/store-home-concept-1
STAMP=$(date +%Y%m%d-%H%M%S)

cd "$APP"
CURRENT=$(git branch --show-current)
[ "$CURRENT" = "$BRANCH" ] || { echo "STOP: branch=$CURRENT"; exit 1; }
[ -d "$OLD_LIVE" ] || { echo "STOP: old live backup missing: $OLD_LIVE"; exit 1; }
git cat-file -e "$BASE^{commit}"

# Safety backup of current production
cp -a "$LIVE" "/67/dist-before-original-rollback-$STAMP"

# Restore this redesign branch to the pre-redesign source baseline only.
while IFS= read -r -d '' path; do
  if git cat-file -e "$BASE:$path" 2>/dev/null; then
    git restore --source="$BASE" -- "$path"
  else
    rm -rf -- "$path"
    git rm -f --ignore-unmatch -- "$path" >/dev/null 2>&1 || true
  fi
done < <(git diff --name-only -z "$BASE"..HEAD)

git add -A
if ! git diff --cached --quiet; then
  git commit -m "rollback: restore original UI before redesign"
fi

# Restore exact old production build (do NOT deploy QARIX/dist over it).
mkdir -p "$LIVE"
find "$LIVE" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -a "$OLD_LIVE"/. "$LIVE"/

systemctl restart sixty-seven.service
systemctl is-active --quiet sixty-seven.service

echo "ROLLBACK_OK"
echo "branch=$(git branch --show-current)"
echo "commit=$(git rev-parse --short HEAD)"
echo "live_backup=$OLD_LIVE"
echo "safety_backup=/67/dist-before-original-rollback-$STAMP"
