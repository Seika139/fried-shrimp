#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
# We will generate a docker-compose override file that contains the decrypted variables
# This ensures they override the base docker-compose.yml 'environment' section
GEN_COMPOSE_FILE="$ROOT_DIR/.devcontainer/docker-compose.gen.yml"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}


# Generate token if not present
if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  # Try to read from .env
  if [[ -f "$ENV_FILE" ]]; then
    TOKEN_IN_FILE=$(grep "^OPENCLAW_GATEWAY_TOKEN=" "$ENV_FILE" | cut -d= -f2- || true)
    if [[ -n "$TOKEN_IN_FILE" ]]; then
      OPENCLAW_GATEWAY_TOKEN="$TOKEN_IN_FILE"
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

# Detect host UID to sync permissions
HOST_UID=$(id -u)
# If host is root, run container as root to avoid permission issues.
# Otherwise, use the 'node' user defined in docker-compose.dev.yml.
if [[ "$HOST_UID" == "0" ]]; then
  CONTAINER_USER="root"
else
  # On local PCs, VS Code handles UID mapping for the 'node' user automatically
  # when no explicit user is provided in the generated override.
  CONTAINER_USER=""
fi

# Define path values
OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
OPENCLAW_WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
OPENCLAW_GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
OPENCLAW_BRIDGE_PORT="${OPENCLAW_BRIDGE_PORT:-18790}"
OPENCLAW_GATEWAY_BIND="${OPENCLAW_GATEWAY_BIND:-lan}"
IMAGE_NAME="${OPENCLAW_IMAGE:-ghcr.io/seika139/fried-shrimp:feature-devcontainer}"
OPENCLAW_IMAGE="$IMAGE_NAME"

# Generate the Docker Compose overrides
# We inject the values directly into the 'environment' section.
# This overrides the ${OPENCLAW_GATEWAY_TOKEN} interpolation in the base file
# which would otherwise pick up the encrypted string from .env.
echo "Generating $GEN_COMPOSE_FILE..."

GEN_USER_LINE=""
if [[ -n "$CONTAINER_USER" ]]; then
  GEN_USER_LINE="user: \"$CONTAINER_USER\""
fi

cat > "$GEN_COMPOSE_FILE" <<EOF
services:
  openclaw-gateway:
    image: "$OPENCLAW_IMAGE"
    $GEN_USER_LINE
    environment:
      # Injected decrypted values
      OPENCLAW_GATEWAY_TOKEN: "$OPENCLAW_GATEWAY_TOKEN"
      OPENCLAW_CONFIG_DIR: "$OPENCLAW_CONFIG_DIR"
      OPENCLAW_WORKSPACE_DIR: "$OPENCLAW_WORKSPACE_DIR"
      OPENCLAW_GATEWAY_PORT: "$OPENCLAW_GATEWAY_PORT"
      OPENCLAW_BRIDGE_PORT: "$OPENCLAW_BRIDGE_PORT"
      OPENCLAW_GATEWAY_BIND: "$OPENCLAW_GATEWAY_BIND"
      OPENCLAW_IMAGE: "$OPENCLAW_IMAGE"
      # Empty defaults for optionals
      OPENCLAW_EXTRA_MOUNTS: ""
      OPENCLAW_HOME_VOLUME: ""
      OPENCLAW_DOCKER_APT_PACKAGES: ""
      CLAUDE_AI_SESSION_KEY: ""
      CLAUDE_WEB_SESSION_KEY: ""
      CLAUDE_WEB_COOKIE: ""

  openclaw-cli:
    image: "$OPENCLAW_IMAGE"
    $GEN_USER_LINE
    environment:
      OPENCLAW_GATEWAY_TOKEN: "$OPENCLAW_GATEWAY_TOKEN"
      CLAUDE_AI_SESSION_KEY: ""
      CLAUDE_WEB_SESSION_KEY: ""
      CLAUDE_WEB_COOKIE: ""

EOF

echo "Generated compose overrides with environment variables from .env."
