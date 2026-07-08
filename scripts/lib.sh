#!/usr/bin/env bash

if [[ -z "${NO_COLOR:-}" && "${TERM:-}" != "dumb" && -t 1 ]]; then
  bold="$(printf '\033[1m')"
  dim="$(printf '\033[2m')"
  reset="$(printf '\033[0m')"
  red="$(printf '\033[31m')"
  green="$(printf '\033[32m')"
  yellow="$(printf '\033[33m')"
  blue="$(printf '\033[34m')"
  cyan="$(printf '\033[36m')"
else
  bold=""
  dim=""
  reset=""
  red=""
  green=""
  yellow=""
  blue=""
  cyan=""
fi

info() {
  printf '  %s\n' "$*"
}

notice() {
  printf '%s\n' "${blue}INFO:${reset} $*"
}

phase() {
  local marker="$1"
  local message="$2"

  printf '\n%s[%s]%s %s\n' "$cyan" "$marker" "$reset" "$message"
}

success() {
  printf '%s\n' "${green}OK:${reset} $*"
}

skip() {
  printf '%s\n' "${dim}SKIP:${reset} $*"
  record_summary skipped_by_choice "$*"
}

skip_unavailable() {
  printf '%s\n' "${yellow}SKIP:${reset} $*"
  record_summary skipped_unavailable "$*"
}

warn() {
  printf '%s\n' "${yellow}WARN:${reset} $*" >&2
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

  printf '\n%s%s (%s)%s\n' "$bold" "$title" "$count" "$reset"
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
  summarize_category skipped "Already installed or unchanged"
  summarize_category skipped_by_choice "Skipped by choice"
  summarize_category skipped_unavailable "Skipped because unavailable"
  summarize_category warnings "Warnings"
  summarize_category dry_run "Planned changes"

  if [[ -z "${DOTFILES_SUMMARY_FILE:-}" || ! -s "$DOTFILES_SUMMARY_FILE" ]]; then
    info "No actions were recorded."
  fi
}

die() {
  printf '%s\n' "${red}ERROR:${reset} $*" >&2
  record_summary warnings "$*"
  exit 1
}

step() {
  if [[ -n "${TOTAL_STEPS:-}" ]]; then
    STEP_COUNT=$(( ${STEP_COUNT:-0} + 1 ))
    printf '\n%sStep %s/%s: %s%s\n' "$bold$blue" "$STEP_COUNT" "$TOTAL_STEPS" "$*" "$reset"
  else
    printf '\n%s==> %s%s\n' "$bold$blue" "$*" "$reset"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

load_homebrew_environment() {
  local brew_path
  local shellenv

  if command_exists brew; then
    return 0
  fi

  for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ ! -x "$brew_path" ]]; then
      continue
    fi

    if shellenv="$("$brew_path" shellenv 2>/dev/null)"; then
      eval "$shellenv"
      if command_exists brew; then
        return 0
      fi
    fi
  done

  return 1
}

summarize_brewfile() {
  local brewfile="$1"
  local counts
  local formulae
  local apps
  local fonts
  local formulae_label
  local apps_label
  local fonts_label

  if [[ ! -f "$brewfile" ]]; then
    warn "Missing Brewfile: $brewfile"
    return 1
  fi

  counts="$(awk '
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    {
      line = $0
      sub(/^[[:space:]]+/, "", line)

      if (line ~ /^brew[[:space:]]*"/) {
        formulae++
      } else if (line ~ /^cask[[:space:]]*"/) {
        item = line
        sub(/^cask[[:space:]]*"/, "", item)
        sub(/".*/, "", item)

        if (item ~ /^font-/) {
          fonts++
        } else {
          apps++
        }
      }
    }
    END {
      printf "%d %d %d\n", formulae + 0, apps + 0, fonts + 0
    }
  ' "$brewfile")"

  read -r formulae apps fonts <<< "$counts"
  formulae_label="command-line tools"
  apps_label="desktop apps"
  fonts_label="font packages"

  if [[ "$formulae" == "1" ]]; then
    formulae_label="command-line tool"
  fi
  if [[ "$apps" == "1" ]]; then
    apps_label="desktop app"
  fi
  if [[ "$fonts" == "1" ]]; then
    fonts_label="font package"
  fi

  info "Found $formulae $formulae_label, $apps $apps_label, and $fonts $fonts_label."
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
    printf '%s[dry-run]%s %q' "$cyan" "$reset" "$1"
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

default_answer() {
  local default="${1:-N}"

  if [[ "$default" =~ ^[Yy]$ ]]; then
    printf 'Y'
  else
    printf 'N'
  fi
}

confirm_prompt() {
  local prompt="$1"
  local default

  default="$(default_answer "${2:-N}")"
  printf '%s [Y/N] default: %s' "$prompt" "$default"
}

answer_is_yes() {
  [[ "$1" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}

answer_is_no() {
  [[ "$1" =~ ^([Nn]|[Nn][Oo])$ ]]
}

confirm() {
  local prompt="$1"
  local default="${2:-N}"
  local answer
  local default_normalized
  local prompt_with_default

  default_normalized="$(default_answer "$default")"
  prompt_with_default="$(confirm_prompt "$prompt" "$default_normalized")"

  if [[ "${YES:-0}" == "1" ]]; then
    info "$prompt_with_default"
    notice "Using YES because --yes was passed."
    return 0
  fi

  if [[ ! -t 0 ]]; then
    info "$prompt_with_default"
    notice "Using default answer: $default_normalized (non-interactive)."
    [[ "$default_normalized" == "Y" ]]
    return
  fi

  while true; do
    read -r -p "$prompt_with_default " answer
    if [[ -z "$answer" ]]; then
      answer="$default_normalized"
    fi

    if answer_is_yes "$answer"; then
      return 0
    fi
    if answer_is_no "$answer"; then
      return 1
    fi

    warn "Please answer Y or N."
  done
}

confirm_manual() {
  local prompt="$1"
  local default="${2:-N}"
  local answer
  local default_normalized
  local prompt_with_default

  default_normalized="$(default_answer "$default")"
  prompt_with_default="$(confirm_prompt "$prompt" "$default_normalized")"

  if [[ ! -t 0 ]]; then
    info "$prompt_with_default"
    notice "Using default answer: $default_normalized (non-interactive)."
    [[ "$default_normalized" == "Y" ]]
    return
  fi

  while true; do
    read -r -p "$prompt_with_default " answer
    if [[ -z "$answer" ]]; then
      answer="$default_normalized"
    fi

    if answer_is_yes "$answer"; then
      return 0
    fi
    if answer_is_no "$answer"; then
      return 1
    fi

    warn "Please answer Y or N."
  done
}

confirm_described() {
  local title="$1"
  local description="$2"
  local prompt="$3"
  local default="${4:-N}"

  printf '  %s%s%s\n' "$bold" "$title" "$reset"
  info "$description"
  confirm "$prompt" "$default"
}

confirm_manual_described() {
  local title="$1"
  local description="$2"
  local prompt="$3"
  local default="${4:-N}"

  printf '  %s%s%s\n' "$bold" "$title" "$reset"
  info "$description"
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
    notice "Backed up $target to $backup"
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
