#!/bin/bash

#MISE description="dotenvxで必要な .env.keys の存在を保証する"
#MISE shell="bash -c"
#MISE quiet=true
#MISE hide=true

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

# dotenvx がインストールされているかチェック
if ! command -v dotenvx >/dev/null 2>&1; then
  log_red "dotenvx is not installed"
  exit 1
fi

# .env.keys が存在するかチェック
if [ ! -f ".env.keys" ]; then
  log_red ".env.keys is not found"
  exit 1
fi

# .env が存在するかチェック
if [ ! -f ".env" ]; then
  log_red ".env is not found"
  exit 1
fi

# .env ファイル内に暗号化されていないシークレットがないかチェック
# コメント行と空行、および、DOTENV_PUBLIC_KEY の行、'encrypted:'を含む行以外に、何らかの文字があればエラーとする
if grep -vE '(^#|^$|encrypted:|DOTENV_PUBLIC_KEY)' .env | grep -q '.'; then
  log_red "Error: Unencrypted secrets found in .env file." >&2
  log_red "Please run 'mise run encrypt' to encrypt them." >&2
  exit 1
fi
