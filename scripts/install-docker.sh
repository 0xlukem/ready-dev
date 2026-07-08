#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

if [[ -d "/Applications/Docker.app" ]]; then
  success "Docker Desktop already installed at /Applications/Docker.app."
  record_summary skipped "Docker Desktop already installed"
  exit 0
fi

if ! command_exists brew; then
  skip_unavailable "Docker Desktop installation skipped because Homebrew is unavailable."
  exit 0
fi

if ! confirm_manual_described "Docker Desktop" "Optional app for projects that need containers, databases, or local services. It may ask for macOS permissions or sign-in after you open it." "Install Docker Desktop now?" "N"; then
  skip "Docker Desktop installation skipped by choice."
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] brew install --cask docker"
  record_summary dry_run "Install Docker Desktop with Homebrew Cask docker"
  exit 0
fi

if brew install --cask docker; then
  success "Docker Desktop installed."
  record_summary installed "Docker Desktop"
else
  warn "Could not install Docker Desktop with Homebrew Cask 'docker'."
fi
