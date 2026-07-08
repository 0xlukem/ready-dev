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
  --yes      Auto-confirm safe setup prompts; manual optional prompts still ask.
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

TOTAL_STEPS=12
STEP_COUNT=0

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
load_homebrew_environment || true

step "System check"
"$DOTFILES_DIR/scripts/check-system.sh"

step "Homebrew"
"$DOTFILES_DIR/scripts/install-homebrew.sh"
load_homebrew_environment || true

if command_exists brew; then
  if confirm_described "Homebrew bundle" "Installs the shared tool list from Brewfile: command-line tools, desktop apps, and the coding font. This is the main setup step after Homebrew exists." "Run brew bundle from Brewfile now?" "Y"; then
    phase "1/3" "Preparing Homebrew bundle"
    summarize_brewfile "$DOTFILES_DIR/Brewfile"

    phase "2/3" "Installing tools, apps, and fonts"
    info "This can take several minutes on a clean Mac."
    info "Homebrew may look quiet while fetching metadata or downloading apps."
    info "Keep this Terminal window open."
    run brew bundle --file="$DOTFILES_DIR/Brewfile"

    phase "3/3" "Recording Homebrew bundle result"
    if [[ "$DRY_RUN" == "0" ]]; then
      record_summary installed "Homebrew bundle from Brewfile"
    fi
    success "Homebrew bundle finished."
  else
    skip "Homebrew bundle skipped by choice."
  fi
else
  skip_unavailable "Homebrew bundle skipped because Homebrew is unavailable."
fi

step "Oh My Zsh"
"$DOTFILES_DIR/scripts/install-oh-my-zsh.sh"

step "Oh My Zsh plugins and Powerlevel10k"
"$DOTFILES_DIR/scripts/install-zsh-plugins.sh"

step "Dotfile symlinks"
if confirm_described "Dotfile symlinks" "Backs up existing config files, then points your shell, Git, Ghostty, iTerm2, VS Code, and ~/.dotfiles paths at this repo. Skip this if you only want tools installed and no config changes." "Create or update dotfile symlinks now?" "Y"; then
  "$DOTFILES_DIR/scripts/setup-symlinks.sh"
else
  skip "Dotfile symlinks skipped by choice."
fi

step "Git identity"
"$DOTFILES_DIR/scripts/setup-git-identity.sh"

step "VS Code extensions"
"$DOTFILES_DIR/scripts/install-vscode-extensions.sh"

step "GitHub CLI auth"
"$DOTFILES_DIR/scripts/setup-gh.sh"

step "macOS defaults"
if confirm_manual_described "macOS Finder defaults" "Optional Finder preferences: show hidden files, path bar, and status bar, and avoid .DS_Store files on network drives. Skip this if you prefer to keep Finder exactly as it is." "Apply optional macOS Finder defaults now?" "N"; then
  "$DOTFILES_DIR/scripts/setup-macos-defaults.sh"
else
  skip "macOS Finder defaults skipped by choice."
fi

step "Docker Desktop"
"$DOTFILES_DIR/scripts/install-docker.sh"

step "OpenAI desktop tools"
if confirm_manual_described "OpenAI desktop tools" "Optional check for ChatGPT and Codex desktop tools. If anything is missing, the installer asks again before installing it. No OpenAI credentials are handled here." "Check and offer ChatGPT/Codex installation now?" "N"; then
  "$DOTFILES_DIR/scripts/install-openai-tools.sh"
else
  skip "OpenAI desktop tools skipped by choice."
fi

print_install_summary
INSTALL_FINISHED=1
success "Install finished."
