#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

install_cask_if_missing() {
  local app_name="$1"
  local app_path="$2"
  local cask_name="$3"
  local prompt="$4"
  local description="$5"

  if [[ -d "$app_path" ]]; then
    success "$app_name already installed at $app_path."
    record_summary skipped "$app_name already installed at $app_path"
    return 0
  fi

  if ! command_exists brew; then
    skip_unavailable "$app_name installation skipped because Homebrew is unavailable."
    return 0
  fi

  if ! confirm_described "$app_name" "$description" "$prompt" "N"; then
    skip "$app_name installation skipped by choice."
    return 0
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "[dry-run] brew install --cask $cask_name"
    record_summary dry_run "Install $app_name with Homebrew Cask $cask_name"
    return 0
  fi

  if brew install --cask "$cask_name"; then
    success "$app_name installed."
    record_summary installed "$app_name"
  else
    warn "Could not install $app_name with Homebrew Cask '$cask_name'."
  fi
}

install_cask_if_missing \
  "ChatGPT" \
  "/Applications/ChatGPT.app" \
  "chatgpt" \
  "Install ChatGPT desktop app with Homebrew Cask now?" \
  "Optional OpenAI desktop app. Installation uses Homebrew Cask; sign-in happens later inside the app and this repo never writes credentials."

if command_exists codex; then
  success "Codex CLI already installed at $(command -v codex)."
  record_summary skipped "Codex CLI already installed at $(command -v codex)"
else
  install_cask_if_missing \
    "Codex" \
    "/Applications/Codex.app" \
    "codex" \
    "Install Codex with Homebrew Cask now?" \
    "Optional OpenAI coding agent CLI/app. Installation uses Homebrew Cask; sign-in happens later inside Codex and this repo never writes credentials."
fi

info "No OpenAI credentials were written. Sign in interactively from ChatGPT or Codex when you first open them."
