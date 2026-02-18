#!/bin/bash

#MISE description="ゲートウェイを起動する"
#MISE shell="bash -c"
#MISE quiet=true
#MISE depends=["dotenvx"]

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "${SCRIPT_DIR}/../common.sh"

dotenvx run -- pnpm gateway:dev
