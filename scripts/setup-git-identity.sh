#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

identity_file="$HOME/.gitconfig.local"
existing_name="$(git config --global --get user.name 2>/dev/null || true)"
existing_email="$(git config --global --get user.email 2>/dev/null || true)"

if [[ -n "$existing_name" && -n "$existing_email" ]]; then
  success "Git identity already configured: $existing_name <$existing_email>"
  record_summary skipped "Git identity already configured"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] prompt for Git name/email and write $identity_file"
  record_summary dry_run "Configure Git identity in $identity_file"
  exit 0
fi

if [[ ! -t 0 ]]; then
  skip_unavailable "Git identity setup skipped because input is non-interactive."
  exit 0
fi

if ! confirm_manual_described "Git identity" "Git uses this name and email on commits you create. The values are written to ~/.gitconfig.local with private file permissions, not committed to this repo." "Configure Git identity now?" "Y"; then
  skip "Git identity setup skipped by choice."
  exit 0
fi

git_name=""
git_email=""

while [[ -z "$git_name" ]]; do
  read -r -p "Git name: " git_name
done

while [[ -z "$git_email" || "$git_email" != *@* ]]; do
  read -r -p "Git email: " git_email
  if [[ -n "$git_email" && "$git_email" != *@* ]]; then
    warn "Git email should contain @."
  fi
done

umask 077
{
  printf '[user]\n'
  printf '  name = %s\n' "$git_name"
  printf '  email = %s\n' "$git_email"
} > "$identity_file"

success "Git identity written to $identity_file"
record_summary installed "Git identity in $identity_file"
