#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

dotfiles_target="$HOME/.dotfiles"
repo_real_path="$(cd "$DOTFILES_DIR" && pwd -P)"

if [[ -d "$dotfiles_target" && "$(cd "$dotfiles_target" && pwd -P)" == "$repo_real_path" ]]; then
  success "Repo already available at $dotfiles_target"
  record_summary skipped "Repo already available at $dotfiles_target"
else
  link_file "$DOTFILES_DIR" "$dotfiles_target"
fi

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/iterm2/DynamicProfiles/Default.json" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/Default.json"
link_file "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
