#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  success "Oh My Zsh already installed."
  record_summary skipped "Oh My Zsh already installed"
  exit 0
fi

if ! command_exists curl; then
  warn "curl is required to install Oh My Zsh."
  record_summary skipped "Oh My Zsh installation because curl is unavailable"
  exit 0
fi

if ! confirm_described "Oh My Zsh" "Zsh framework that provides plugins, themes, completions, and shell defaults." "Oh My Zsh is missing. Install it unattended now? [Y/n]" "Y"; then
  warn "Skipped Oh My Zsh installation."
  record_summary skipped "Oh My Zsh installation"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] install Oh My Zsh unattended without changing the default shell"
  record_summary dry_run "Install Oh My Zsh unattended without changing the default shell"
  exit 0
fi

RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  "" --unattended

success "Oh My Zsh installed."
record_summary installed "Oh My Zsh"
