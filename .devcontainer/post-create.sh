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

# --- Tailscale Installation & Daemon ---
if ! command -v tailscale >/dev/null 2>&1; then
  echo "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi

if command -v tailscaled >/dev/null 2>&1; then
  if ! pgrep tailscaled >/dev/null 2>&1; then
    echo "Starting tailscaled..."
    mkdir -p /var/run/tailscale /var/lib/tailscale
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock > /dev/null 2>&1 &
    
    # Wait for the socket to become available
    for i in {1..20}; do
      if [ -S /var/run/tailscale/tailscaled.sock ]; then
        echo "tailscaled is ready."
        break
      fi
      sleep 0.5
    done
  fi
fi

echo "Post-create setup complete."
