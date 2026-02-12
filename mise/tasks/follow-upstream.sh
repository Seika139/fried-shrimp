#!/bin/bash

#MISE description="本家(upstream)の最新状態を main ブランチに反映し、origin へプッシュする"
#MISE shell="bash -c"
#MISE quiet=true

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

current_branch=$(git rev-parse --abbrev-ref HEAD) || exit 1

log_yellow "Checking out main branch..."
git checkout main

log_yellow "Fetching from upstream..."
git fetch upstream

log_yellow "Resetting main to upstream/main..."
git reset --hard upstream/main

log_yellow "Pushing to origin main..."
git push origin main --force

git checkout "${current_branch}"
