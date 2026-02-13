#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
DECRYPTED_ENV_FILE="$ROOT_DIR/.devcontainer/.env.decrypted"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to run dotenvx
run_dotenvx() {
  if command_exists dotenvx; then
    dotenvx "$@"
  elif command_exists npx; then
    npx -y dotenvx "$@"
  else
    return 1
  fi
}

# Generate token if not present
if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  # Try to read from .env using dotenvx first (handles encryption)
  if [[ -f "$ENV_FILE" ]]; then
    # Attempt to get the value using dotenvx
    # capture stdout, mute stderr to avoid noise if key is missing or not encrypted properly
    TOKEN_FROM_DOTENVX=$(run_dotenvx get OPENCLAW_GATEWAY_TOKEN 2>/dev/null || true)

    if [[ -n "$TOKEN_FROM_DOTENVX" ]]; then
      OPENCLAW_GATEWAY_TOKEN="$TOKEN_FROM_DOTENVX"
    else
      # Fallback: Try straight check to file if dotenvx failed or returned empty (maybe plain text?)
      TOKEN_IN_FILE=$(grep "^OPENCLAW_GATEWAY_TOKEN=" "$ENV_FILE" | cut -d= -f2- || true)
      if [[ -n "$TOKEN_IN_FILE" ]]; then
        # Check if it looks encrypted
        if [[ "$TOKEN_IN_FILE" == encrypted:* ]]; then
          echo "Warning: OPENCLAW_GATEWAY_TOKEN is encrypted but could not be decrypted." >&2
          echo "Ensure DOTENV_PRIVATE_KEY is set or .env.keys exists, and dotenvx is installed." >&2
        else
          OPENCLAW_GATEWAY_TOKEN="$TOKEN_IN_FILE"
        fi
      fi
    fi
  fi

  # If still empty, generate a new one
  if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
    echo "Generating new OPENCLAW_GATEWAY_TOKEN..." >&2
    if command -v openssl >/dev/null 2>&1; then
      OPENCLAW_GATEWAY_TOKEN="$(openssl rand -hex 32)"
    else
      OPENCLAW_GATEWAY_TOKEN="$(
        python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
      )"
    fi
  fi
fi

# Write the plain token to a decrypted env file for docker-compose to use
echo "# Auto-generated decrypted env vars" >"$DECRYPTED_ENV_FILE"

if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  echo "OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN" >>"$DECRYPTED_ENV_FILE"
fi

echo "Decrypted variables written to $DECRYPTED_ENV_FILE"
