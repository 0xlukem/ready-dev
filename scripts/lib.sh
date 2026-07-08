#!/usr/bin/env bash

info() {
  printf '  %s\n' "$*"
}

success() {
  printf 'OK: %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
  record_summary warnings "$*"
}

record_summary() {
  local category="$1"
  local message="$2"

  if [[ -n "${DOTFILES_SUMMARY_FILE:-}" ]]; then
    printf '%s\t%s\n' "$category" "$message" >> "$DOTFILES_SUMMARY_FILE"
  fi
}

summarize_category() {
  local category="$1"
  local title="$2"
  local count

  if [[ -z "${DOTFILES_SUMMARY_FILE:-}" || ! -f "$DOTFILES_SUMMARY_FILE" ]]; then
    return 0
  fi

  count="$(awk -F '\t' -v cat="$category" '$1 == cat { count++ } END { print count + 0 }' "$DOTFILES_SUMMARY_FILE")"
  if [[ "$count" == "0" ]]; then
    return 0
  fi

  printf '\n%s (%s)\n' "$title" "$count"
  awk -F '\t' -v cat="$category" '$1 == cat { print "- " $2 }' "$DOTFILES_SUMMARY_FILE"
}

print_install_summary() {
  step "Install summary"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "Dry-run mode: no system changes were applied."
  fi

  summarize_category installed "Installed or updated"
  summarize_category linked "Linked"
  summarize_category backups "Backed up"
  summarize_category skipped "Skipped"
  summarize_category warnings "Warnings"
  summarize_category dry_run "Planned in dry-run"

  if [[ -z "${DOTFILES_SUMMARY_FILE:-}" || ! -s "$DOTFILES_SUMMARY_FILE" ]]; then
    info "No actions were recorded."
  fi
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  record_summary warnings "$*"
  exit 1
}

step() {
  printf '\n==> %s\n' "$*"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    die "This installer supports macOS only."
  fi
}

timestamp() {
  date +%Y%m%d-%H%M%S
}

run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    local dry_run_command
    printf -v dry_run_command '%q' "$1"
    printf '[dry-run] %q' "$1"
    shift
    local arg
    for arg in "$@"; do
      printf ' %q' "$arg"
      dry_run_command+=" $(printf '%q' "$arg")"
    done
    printf '\n'
    record_summary dry_run "$dry_run_command"
    return 0
  fi

  "$@"
}

confirm() {
  local prompt="$1"
  local default="${2:-N}"
  local answer

  if [[ "${YES:-0}" == "1" ]]; then
    info "$prompt yes (--yes)"
    return 0
  fi

  if [[ ! -t 0 ]]; then
    info "$prompt ${default} (non-interactive)"
    [[ "$default" =~ ^[Yy]$ ]]
    return
  fi

  read -r -p "$prompt " answer
  if [[ -z "$answer" ]]; then
    answer="$default"
  fi
  [[ "$answer" =~ ^[Yy]$ ]]
}

confirm_manual() {
  local prompt="$1"
  local default="${2:-N}"
  local answer

  if [[ ! -t 0 ]]; then
    info "$prompt ${default} (non-interactive)"
    [[ "$default" =~ ^[Yy]$ ]]
    return
  fi

  read -r -p "$prompt " answer
  if [[ -z "$answer" ]]; then
    answer="$default"
  fi
  [[ "$answer" =~ ^[Yy]$ ]]
}

confirm_described() {
  local title="$1"
  local description="$2"
  local prompt="$3"
  local default="${4:-N}"

  info "$title: $description"
  confirm "$prompt" "$default"
}

confirm_manual_described() {
  local title="$1"
  local description="$2"
  local prompt="$3"
  local default="${4:-N}"

  info "$title: $description"
  confirm_manual "$prompt" "$default"
}

backup_target() {
  local target="$1"
  printf '%s.backup.%s' "$target" "$(timestamp)"
}

link_file() {
  local source="$1"
  local target="$2"
  local parent
  local backup

  if [[ ! -e "$source" ]]; then
    die "Missing source file: $source"
  fi

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    success "Symlink already correct: $target"
    record_summary skipped "Symlink already correct: $target"
    return 0
  fi

  parent="$(dirname "$target")"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "[dry-run] mkdir -p $parent"
    if [[ -e "$target" || -L "$target" ]]; then
      backup="$(backup_target "$target")"
      info "[dry-run] mv $target $backup"
      record_summary dry_run "Back up $target to $backup"
    fi
    info "[dry-run] ln -s $source $target"
    record_summary dry_run "Link $target -> $source"
    return 0
  fi

  mkdir -p "$parent"
  if [[ -e "$target" || -L "$target" ]]; then
    backup="$(backup_target "$target")"
    mv "$target" "$backup"
    warn "Backed up $target to $backup"
    record_summary backups "$target -> $backup"
  fi
  ln -s "$source" "$target"
  success "Linked $target"
  record_summary linked "$target -> $source"
}

remove_repo_symlink() {
  local target="$1"
  local source="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      info "[dry-run] rm $target"
    else
      rm "$target"
      success "Removed $target"
    fi
    return 0
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    warn "Skipped $target; it is not a symlink to this repo."
  else
    info "Not present: $target"
  fi
}
