#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

YES=0
DRY_RUN=0
FIX=0
export YES DRY_RUN

# shellcheck source=lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

TOTAL_STEPS=6
STEP_COUNT=0

usage() {
  cat <<'EOF'
Usage: ./scripts/doctor.sh [--fix] [--yes] [--dry-run]

Checks the local developer setup. With --fix, offers safe guided fixes.
EOF
}

while (($#)); do
  case "$1" in
    --fix)
      FIX=1
      ;;
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

ensure_macos

missing_count=0

check_command() {
  local command_name="$1"
  local package_name="${2:-$1}"
  local description="$3"

  if command_exists "$command_name"; then
    success "$command_name found at $(command -v "$command_name")"
    return 0
  fi

  warn "$command_name missing. $description"
  missing_count=$((missing_count + 1))

  if [[ "$FIX" == "1" && "$package_name" != "-" ]] && command_exists brew; then
    if confirm_described "$package_name" "$description" "Install $package_name with Homebrew now?" "N"; then
      run brew install "$package_name"
    else
      skip "$package_name installation skipped by choice."
    fi
  fi
}

check_app() {
  local app_name="$1"
  local app_path="$2"
  local cask_name="$3"
  local description="$4"

  if [[ -d "$app_path" ]]; then
    success "$app_name found at $app_path"
    return 0
  fi

  warn "$app_name missing. $description"
  missing_count=$((missing_count + 1))

  if [[ "$FIX" == "1" ]] && command_exists brew; then
    if confirm_described "$app_name" "$description" "Install $app_name with Homebrew Cask now?" "N"; then
      run brew install --cask "$cask_name"
    else
      skip "$app_name installation skipped by choice."
    fi
  fi
}

check_font() {
  local font_name="$1"
  local cask_name="$2"
  local description="$3"
  local font_path

  font_path="$(
    find "$HOME/Library/Fonts" /Library/Fonts -maxdepth 1 \
      \( -name "MesloLGS NF Regular.ttf" \
        -o -name "MesloLGSNerdFont-Regular.ttf" \
        -o -name "MesloLGSNerdFontMono-Regular.ttf" \) \
      -print -quit 2>/dev/null
  )"

  if [[ -n "$font_path" ]]; then
    success "$font_name found at $font_path"
    return 0
  fi

  warn "$font_name missing. $description"
  missing_count=$((missing_count + 1))

  if [[ "$FIX" == "1" ]] && command_exists brew; then
    if confirm_described "$font_name" "$description" "Install $font_name with Homebrew Cask now?" "N"; then
      run brew install --cask "$cask_name"
    else
      skip "$font_name installation skipped by choice."
    fi
  fi
}

check_optional_app() {
  local app_name="$1"
  local app_path="$2"
  local description="$3"

  if [[ -d "$app_path" ]]; then
    success "$app_name found at $app_path"
    return 0
  fi

  info "Optional: $app_name not installed. $description"
}

check_symlink() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    success "Symlink OK: $target"
    return 0
  fi

  warn "Symlink missing or not owned by this repo: $target"
  missing_count=$((missing_count + 1))
}

step "Core tools"
check_command brew - "Homebrew installs developer tools and desktop apps."
check_command git git "Git is required for source control."
check_command gh gh "GitHub CLI is used for optional interactive GitHub authentication."
check_command code - "VS Code command line helper installs extensions."

step "Python and Node tooling"
check_command mise mise "mise manages Python and Node versions per project."
check_command uv uv "uv is a fast Python package and virtual environment tool."
check_command node node "Node.js runs JavaScript tooling."
check_command pnpm pnpm "pnpm is a fast JavaScript package manager."

step "Terminal tools"
check_command tmux tmux "tmux provides persistent terminal sessions; config is left to the user."
check_command zoxide zoxide "zoxide provides smarter cd navigation."
check_command fzf fzf "fzf provides fuzzy finding in terminal workflows."
check_command delta git-delta "git-delta improves Git diff output."

step "Desktop apps"
check_optional_app "Docker Desktop" "/Applications/Docker.app" "Docker Desktop runs local containers and may require macOS permissions or sign-in."
check_app "Ghostty" "/Applications/Ghostty.app" "ghostty" "Ghostty is the GPU-native terminal configured by this repo."
check_app "iTerm2" "/Applications/iTerm.app" "iterm2" "iTerm2 is an alternate terminal with a dynamic profile from this repo."
check_app "Visual Studio Code" "/Applications/Visual Studio Code.app" "visual-studio-code" "VS Code is the editor configured by this repo."

step "Terminal font"
check_font "Meslo LG Nerd Font" "font-meslo-lg-nerd-font" "Required for Powerlevel10k icons in Ghostty and iTerm2."

step "Repo symlinks"
check_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
check_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
check_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

if [[ "$FIX" == "1" ]]; then
  if confirm_described "Dotfile symlinks" "Recreates missing repo-owned symlinks and backs up any existing files before replacing them." "Run setup-symlinks now?" "N"; then
    "$DOTFILES_DIR/scripts/setup-symlinks.sh"
  else
    skip "Dotfile symlink repair skipped by choice."
  fi

  if confirm_described "Oh My Zsh plugins" "Installs missing shell plugins and Powerlevel10k into the Oh My Zsh custom directories used by this repo." "Run install-zsh-plugins now?" "N"; then
    "$DOTFILES_DIR/scripts/install-zsh-plugins.sh"
  else
    skip "Oh My Zsh plugin repair skipped by choice."
  fi
fi

if [[ "$missing_count" == "0" ]]; then
  success "Doctor finished cleanly."
else
  warn "Doctor finished with $missing_count item(s) needing attention."
fi
