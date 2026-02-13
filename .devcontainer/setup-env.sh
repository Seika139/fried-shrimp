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
      # Fallback: grep
      TOKEN_IN_FILE=$(grep "^OPENCLAW_GATEWAY_TOKEN=" "$ENV_FILE" | cut -d= -f2- || true)
      if [[ -n "$TOKEN_IN_FILE" ]]; then
        if [[ "$TOKEN_IN_FILE" == encrypted:* ]]; then
          echo "Warning: OPENCLAW_GATEWAY_TOKEN is encrypted." >&2
          # We will treat this as empty effectively for our purpose of getting a plain token
          # unless we can decrypt it. If run_dotenvx failed but it's encrypted, we can't use it.
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

# Define path values
OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
OPENCLAW_WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
OPENCLAW_GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
OPENCLAW_BRIDGE_PORT="${OPENCLAW_BRIDGE_PORT:-18790}"
OPENCLAW_GATEWAY_BIND="${OPENCLAW_GATEWAY_BIND:-lan}"
IMAGE_NAME="${OPENCLAW_IMAGE:-openclaw:local}"
OPENCLAW_IMAGE="$IMAGE_NAME"

# Helper to upsert env var to .env (append distinct)
upsert_env_var() {
  local key=$1
  local val=$2
  local file=$3
  
  # Simply append. Docker compose uses the last value if duplicated.
  local last_val
  if [[ -f "$file" ]]; then
    last_val=$(grep "^${key}=" "$file" | tail -n 1 | cut -d= -f2- || true)
  else
    last_val=""
  fi

  if [[ "$last_val" != "$val" ]]; then
    # Check if file ends with newline
    if [[ -f "$file" && -s "$file" ]]; then
        if [[ "$(tail -c 1 "$file")" != "" ]]; then
            echo "" >> "$file"
        fi
    fi
    echo "${key}=${val}" >> "$file"
  fi
}

echo "Updating $ENV_FILE and $DECRYPTED_ENV_FILE..."

# Update .env for host-side interpolation
upsert_env_var "OPENCLAW_GATEWAY_TOKEN" "$OPENCLAW_GATEWAY_TOKEN" "$ENV_FILE"
upsert_env_var "OPENCLAW_CONFIG_DIR" "$OPENCLAW_CONFIG_DIR" "$ENV_FILE"
upsert_env_var "OPENCLAW_WORKSPACE_DIR" "$OPENCLAW_WORKSPACE_DIR" "$ENV_FILE"
upsert_env_var "OPENCLAW_GATEWAY_PORT" "$OPENCLAW_GATEWAY_PORT" "$ENV_FILE"
upsert_env_var "OPENCLAW_BRIDGE_PORT" "$OPENCLAW_BRIDGE_PORT" "$ENV_FILE"
upsert_env_var "OPENCLAW_GATEWAY_BIND" "$OPENCLAW_GATEWAY_BIND" "$ENV_FILE"
upsert_env_var "OPENCLAW_IMAGE" "$OPENCLAW_IMAGE" "$ENV_FILE"

# Make sure other vars exist in .env to prevent warnings
upsert_env_var "OPENCLAW_EXTRA_MOUNTS" "" "$ENV_FILE"
upsert_env_var "OPENCLAW_HOME_VOLUME" "" "$ENV_FILE"
upsert_env_var "OPENCLAW_DOCKER_APT_PACKAGES" "" "$ENV_FILE"
upsert_env_var "CLAUDE_AI_SESSION_KEY" "" "$ENV_FILE"
upsert_env_var "CLAUDE_WEB_SESSION_KEY" "" "$ENV_FILE"
upsert_env_var "CLAUDE_WEB_COOKIE" "" "$ENV_FILE"

# Update .env.decrypted for container environment injection
# We overwrite this file completely to ensure it's clean and up-to-date
echo "# Auto-generated decrypted env vars" > "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_CONFIG_DIR=$OPENCLAW_CONFIG_DIR" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_WORKSPACE_DIR=$OPENCLAW_WORKSPACE_DIR" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_GATEWAY_PORT=$OPENCLAW_GATEWAY_PORT" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_BRIDGE_PORT=$OPENCLAW_BRIDGE_PORT" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_GATEWAY_BIND=$OPENCLAW_GATEWAY_BIND" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_IMAGE=$OPENCLAW_IMAGE" >> "$DECRYPTED_ENV_FILE"
# Add empty vars to .env.decrypted too just in case
echo "OPENCLAW_EXTRA_MOUNTS=" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_HOME_VOLUME=" >> "$DECRYPTED_ENV_FILE"
echo "OPENCLAW_DOCKER_APT_PACKAGES=" >> "$DECRYPTED_ENV_FILE"
echo "CLAUDE_AI_SESSION_KEY=" >> "$DECRYPTED_ENV_FILE"
echo "CLAUDE_WEB_SESSION_KEY=" >> "$DECRYPTED_ENV_FILE"
echo "CLAUDE_WEB_COOKIE=" >> "$DECRYPTED_ENV_FILE"

echo "Environment initialized."
