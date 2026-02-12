#!/bin/bash

#MISE description="本家(upstream)の最新状態を main ブランチに反映し、origin へプッシュする"
#MISE shell="bash -c"
#MISE quiet=true

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

# 現在のブランチを保存
current_branch=$(git rev-parse --abbrev-ref HEAD) || exit 1

log_cyan "Checking out main branch..."
git checkout main

log_cyan "Fetching from upstream..."
git fetch upstream

log_cyan "Resetting main to upstream/main..."
git reset --hard upstream/main

log_cyan "Pushing to origin main..."
git push origin main --force

log_cyan "Checking out ${current_branch}..."
git checkout "${current_branch}"
