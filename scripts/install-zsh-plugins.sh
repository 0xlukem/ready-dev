#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  warn "Oh My Zsh is not installed; skipping custom plugins."
  record_summary skipped "Oh My Zsh plugins because Oh My Zsh is unavailable"
  exit 0
fi

if ! command_exists git; then
  warn "git is required to install Oh My Zsh plugins."
  record_summary skipped "Oh My Zsh plugins because git is unavailable"
  exit 0
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
plugins_dir="$ZSH_CUSTOM/plugins"
themes_dir="$ZSH_CUSTOM/themes"

clone_if_missing() {
  local name="$1"
  local url="$2"
  local target="$3"

  if [[ -d "$target" ]]; then
    success "$name already installed."
    record_summary skipped "$name already installed"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "[dry-run] git clone --depth=1 $url $target"
    record_summary dry_run "Install $name into $target"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  git clone --depth=1 "$url" "$target"
  success "$name installed."
  record_summary installed "$name"
}

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] mkdir -p $plugins_dir $themes_dir"
  record_summary dry_run "Create Oh My Zsh plugin/theme directories"
else
  mkdir -p "$plugins_dir" "$themes_dir"
fi

clone_if_missing "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions" \
  "$plugins_dir/zsh-autosuggestions"

clone_if_missing "zsh-completions" \
  "https://github.com/zsh-users/zsh-completions.git" \
  "$plugins_dir/zsh-completions"

clone_if_missing "zsh-history-substring-search" \
  "https://github.com/zsh-users/zsh-history-substring-search.git" \
  "$plugins_dir/zsh-history-substring-search"

clone_if_missing "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$plugins_dir/zsh-syntax-highlighting"

clone_if_missing "powerlevel10k" \
  "https://github.com/romkatv/powerlevel10k.git" \
  "$themes_dir/powerlevel10k"
