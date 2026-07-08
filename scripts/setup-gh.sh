#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

if ! command_exists gh; then
  skip_unavailable "GitHub CLI authentication skipped because gh is unavailable."
  exit 0
fi

if gh auth status >/dev/null 2>&1; then
  success "GitHub CLI is already authenticated."
  record_summary skipped "GitHub CLI auth already configured"
  exit 0
fi

if ! confirm_manual_described "GitHub CLI auth" "Starts the official interactive GitHub login flow. Credentials are stored by GitHub CLI, never by this repo." "Run GitHub CLI authentication now?" "N"; then
  skip "GitHub CLI authentication skipped by choice."
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] gh auth login"
  record_summary dry_run "Run gh auth login"
  exit 0
fi

gh auth login
record_summary installed "GitHub CLI authentication"

if confirm_manual_described "Git credential helper" "Lets Git reuse your authenticated gh session for GitHub HTTPS clone, pull, and push operations." "Configure gh as Git credential helper?" "N"; then
  gh auth setup-git
  record_summary installed "GitHub CLI Git credential helper"
else
  skip "GitHub CLI Git credential helper skipped by choice."
fi
