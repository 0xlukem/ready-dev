#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

if command_exists brew; then
  success "Homebrew already installed."
  record_summary skipped "Homebrew already installed at $(command -v brew)"
  exit 0
fi

if ! confirm_described "Homebrew" "Package manager for installing macOS developer tools and desktop apps." "Homebrew is missing. Install it now? [Y/n]" "Y"; then
  warn "Skipped Homebrew installation."
  record_summary skipped "Homebrew installation"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] install Homebrew using the official install script"
  record_summary dry_run "Install Homebrew using the official install script"
  exit 0
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
success "Homebrew installed."
record_summary installed "Homebrew"
