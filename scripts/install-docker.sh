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
  warn "Homebrew is required to install Docker Desktop automatically."
  record_summary skipped "Docker Desktop installation because Homebrew is unavailable"
  exit 0
fi

if ! confirm_manual_described "Docker Desktop" "Optional app for running containers locally; it may ask for macOS permissions or sign-in after opening." "Install Docker Desktop now? [y/N]" "N"; then
  warn "Skipped Docker Desktop installation."
  record_summary skipped "Docker Desktop"
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
  record_summary skipped "Docker Desktop installation failed"
fi
