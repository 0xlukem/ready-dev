#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

YES=0
DRY_RUN=0
export YES DRY_RUN

usage() {
  cat <<'EOF'
Usage: ./install.sh [--yes] [--dry-run]

Options:
  --yes      Auto-confirm safe setup steps.
  --dry-run  Print planned actions without changing the system.
  --help     Show this help.
EOF
}

while (($#)); do
  case "$1" in
    --yes)
      YES=1
      ;;
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

DOTFILES_SUMMARY_FILE="$(mktemp "${TMPDIR:-/tmp}/dotfiles-install-summary.XXXXXX")"
export DOTFILES_SUMMARY_FILE
INSTALL_FINISHED=0

cleanup_summary() {
  rm -f "$DOTFILES_SUMMARY_FILE"
}

on_install_error() {
  local exit_code=$?
  if [[ "$INSTALL_FINISHED" == "0" ]]; then
    warn "Install failed before completion with exit code $exit_code."
    print_install_summary
  fi
  exit "$exit_code"
}

trap cleanup_summary EXIT
trap on_install_error ERR

ensure_macos

step "System check"
"$DOTFILES_DIR/scripts/check-system.sh"

step "Homebrew"
"$DOTFILES_DIR/scripts/install-homebrew.sh"

if command_exists brew; then
  if confirm_described "Homebrew bundle" "Installs command line tools, desktop apps, fonts, and developer utilities from Brewfile." "Run brew bundle from Brewfile now? [Y/n]" "Y"; then
    run brew bundle --file="$DOTFILES_DIR/Brewfile"
    if [[ "$DRY_RUN" == "0" ]]; then
      record_summary installed "Homebrew bundle from Brewfile"
    fi
  else
    warn "Skipped brew bundle."
    record_summary skipped "Homebrew bundle"
  fi
else
  warn "Homebrew is not available; skipping brew bundle."
  record_summary skipped "Homebrew bundle because Homebrew is unavailable"
fi

step "Oh My Zsh"
"$DOTFILES_DIR/scripts/install-oh-my-zsh.sh"

step "Oh My Zsh plugins and Powerlevel10k"
"$DOTFILES_DIR/scripts/install-zsh-plugins.sh"

step "Dotfile symlinks"
if confirm_described "Dotfile symlinks" "Creates backups for existing files, then links this repo's shell, Git, terminal, and VS Code config." "Create or update dotfile symlinks now? [Y/n]" "Y"; then
  "$DOTFILES_DIR/scripts/setup-symlinks.sh"
else
  warn "Skipped dotfile symlinks."
  record_summary skipped "Dotfile symlinks"
fi

step "Git identity"
"$DOTFILES_DIR/scripts/setup-git-identity.sh"

step "VS Code extensions"
"$DOTFILES_DIR/scripts/install-vscode-extensions.sh"

step "GitHub CLI auth"
"$DOTFILES_DIR/scripts/setup-gh.sh"

step "macOS defaults"
if confirm_described "macOS Finder defaults" "Shows hidden files/path/status bars and avoids .DS_Store files on network drives." "Apply optional macOS Finder defaults now? [y/N]" "N"; then
  "$DOTFILES_DIR/scripts/setup-macos-defaults.sh"
else
  warn "Skipped macOS defaults."
  record_summary skipped "macOS defaults"
fi

step "Docker Desktop"
"$DOTFILES_DIR/scripts/install-docker.sh"

step "OpenAI desktop tools"
if confirm_manual_described "OpenAI desktop tools" "Optionally checks for ChatGPT and Codex, then asks before installing anything missing." "Check and offer ChatGPT/Codex installation now? [y/N]" "N"; then
  "$DOTFILES_DIR/scripts/install-openai-tools.sh"
else
  warn "Skipped OpenAI desktop tools."
  record_summary skipped "OpenAI desktop tools"
fi

print_install_summary
INSTALL_FINISHED=1
success "Install finished."
