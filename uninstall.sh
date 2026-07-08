#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

YES=0
DRY_RUN=0
export YES DRY_RUN

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [--dry-run]

Removes only symlinks that point to this repository. It does not uninstall
Homebrew packages, Oh My Zsh, apps, credentials, or real user files.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

ensure_macos
step "Removing repo-owned symlinks"

remove_repo_symlink "$HOME/.dotfiles" "$DOTFILES_DIR"
remove_repo_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
remove_repo_symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/zsh/.p10k.zsh"
remove_repo_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
remove_repo_symlink "$HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global"
remove_repo_symlink "$HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/config"
remove_repo_symlink "$HOME/Library/Application Support/iTerm2/DynamicProfiles/Default.json" "$DOTFILES_DIR/iterm2/DynamicProfiles/Default.json"
remove_repo_symlink "$HOME/Library/Application Support/Code/User/settings.json" "$DOTFILES_DIR/vscode/settings.json"

cat <<'EOF'

Manual cleanup, if desired:
- Remove ~/.oh-my-zsh manually.
- Remove Homebrew packages with brew uninstall or brew bundle cleanup.
- Remove app credentials from each app directly.
- Remove backups created as *.backup.YYYYMMDD-HHMMSS after reviewing them.
EOF

success "Uninstall finished."
