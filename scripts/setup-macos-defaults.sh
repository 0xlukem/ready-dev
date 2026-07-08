#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

ensure_macos

run defaults write com.apple.finder AppleShowAllFiles -bool true
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.finder ShowStatusBar -bool true
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "[dry-run] killall Finder"
  record_summary dry_run "Restart Finder"
else
  killall Finder >/dev/null 2>&1 || warn "Finder was not running or could not be restarted."
fi

success "macOS defaults applied."
if [[ "${DRY_RUN:-0}" == "0" ]]; then
  record_summary installed "macOS Finder defaults"
fi
