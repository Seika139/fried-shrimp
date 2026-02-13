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

# Define default values for paths needed by docker-compose
# Since we removed these from .env, we must ensure they are set here.
OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
OPENCLAW_WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
OPENCLAW_GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
OPENCLAW_BRIDGE_PORT="${OPENCLAW_BRIDGE_PORT:-18790}"
OPENCLAW_GATEWAY_BIND="${OPENCLAW_GATEWAY_BIND:-lan}"
IMAGE_NAME="${OPENCLAW_IMAGE:-openclaw:local}"
OPENCLAW_IMAGE="$IMAGE_NAME"

# Write the plain token to a decrypted env file for docker-compose to use
echo "# Auto-generated decrypted env vars" >"$DECRYPTED_ENV_FILE"

if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  echo "OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN" >>"$DECRYPTED_ENV_FILE"
fi

# Write other necessary variables
echo "OPENCLAW_CONFIG_DIR=$OPENCLAW_CONFIG_DIR" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_WORKSPACE_DIR=$OPENCLAW_WORKSPACE_DIR" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_GATEWAY_PORT=$OPENCLAW_GATEWAY_PORT" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_BRIDGE_PORT=$OPENCLAW_BRIDGE_PORT" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_GATEWAY_BIND=$OPENCLAW_GATEWAY_BIND" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_IMAGE=$OPENCLAW_IMAGE" >>"$DECRYPTED_ENV_FILE"

# Also write empty placeholders for optional vars to avoid warning if not set
echo "OPENCLAW_EXTRA_MOUNTS=" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_HOME_VOLUME=" >>"$DECRYPTED_ENV_FILE"
echo "OPENCLAW_DOCKER_APT_PACKAGES=" >>"$DECRYPTED_ENV_FILE"
# These Claude related vars were warning in logs
echo "CLAUDE_AI_SESSION_KEY=" >>"$DECRYPTED_ENV_FILE"
echo "CLAUDE_WEB_SESSION_KEY=" >>"$DECRYPTED_ENV_FILE"
echo "CLAUDE_WEB_COOKIE=" >>"$DECRYPTED_ENV_FILE"

echo "Decrypted variables written to $DECRYPTED_ENV_FILE"
