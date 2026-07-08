#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

if ! command_exists gh; then
  warn "GitHub CLI is not installed. It should be installed by Brewfile."
  record_summary skipped "GitHub CLI auth because gh is unavailable"
  exit 0
fi

if gh auth status >/dev/null 2>&1; then
  success "GitHub CLI is already authenticated."
  record_summary skipped "GitHub CLI auth already configured"
  exit 0
fi

if ! confirm_manual_described "GitHub CLI auth" "Starts an interactive GitHub login; credentials are stored by gh, never in this repo." "Run GitHub CLI authentication now? [y/N]" "N"; then
  warn "Skipped GitHub CLI authentication."
  record_summary skipped "GitHub CLI authentication"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] gh auth login"
  record_summary dry_run "Run gh auth login"
  exit 0
fi

gh auth login
record_summary installed "GitHub CLI authentication"

if confirm_manual_described "Git credential helper" "Lets Git use your authenticated gh session for GitHub HTTPS operations." "Configure gh as Git credential helper? [y/N]" "N"; then
  gh auth setup-git
  record_summary installed "GitHub CLI Git credential helper"
else
  warn "Skipped gh auth setup-git."
  record_summary skipped "GitHub CLI Git credential helper"
fi
