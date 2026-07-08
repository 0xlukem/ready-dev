#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

extensions_file="$DOTFILES_DIR/vscode/extensions.txt"

if ! command_exists code; then
  warn "VS Code 'code' command not found. Install VS Code, then run this script again."
  record_summary skipped "VS Code extensions because the code command is unavailable"
  exit 0
fi

if [[ ! -f "$extensions_file" ]]; then
  warn "Missing $extensions_file"
  record_summary skipped "VS Code extensions because extensions.txt is missing"
  exit 0
fi

while IFS= read -r extension || [[ -n "$extension" ]]; do
  if [[ "$extension" =~ ^[[:space:]]*$ || "$extension" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "[dry-run] code --install-extension $extension"
    record_summary dry_run "Install VS Code extension $extension"
    continue
  fi

  if code --install-extension "$extension"; then
    success "Installed VS Code extension: $extension"
    record_summary installed "VS Code extension $extension"
  else
    warn "Failed to install VS Code extension: $extension"
    record_summary skipped "VS Code extension $extension failed"
  fi
done < "$extensions_file"
