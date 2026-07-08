#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

ensure_macos

info "macOS detected: $(sw_vers -productVersion 2>/dev/null || uname -r)"
info "Architecture: $(uname -m)"

for cmd in zsh git curl; do
  if command_exists "$cmd"; then
    success "$cmd found at $(command -v "$cmd")"
  else
    warn "$cmd not found; Brewfile or installer may add it."
  fi
done

if command_exists brew; then
  success "Homebrew found at $(command -v brew)"
else
  warn "Homebrew not found."
fi

