#!/usr/bin/env bash
set -euo pipefail

# --- User Binaries & PATH ---
mkdir -p ~/.local/bin
if command -v fdfind >/dev/null 2>&1 && [ ! -L ~/.local/bin/fd ]; then
  ln -s $(which fdfind) ~/.local/bin/fd
fi

# --- Essential Tools ---
if ! command -v dotenvx >/dev/null 2>&1; then
  curl -sfS https://dotenvx.sh/install.sh | sh
fi

# --- Mise configuration ---
mise trust -a
mise use -g eza

# --- Tailscale Installation ---
if ! command -v tailscale >/dev/null 2>&1; then
  echo "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "Post-create setup complete."
