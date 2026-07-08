# Enable Powerlevel10k instant prompt when available.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path
[[ -f "$HOME/.dotfiles/zsh/path.zsh" ]] && source "$HOME/.dotfiles/zsh/path.zsh"

# Exports
[[ -f "$HOME/.dotfiles/zsh/exports.zsh" ]] && source "$HOME/.dotfiles/zsh/exports.zsh"

# Local personal config. This file is gitignored and must not contain secrets in commits.
[[ -f "$HOME/.dotfiles/config/personal.sh" ]] && source "$HOME/.dotfiles/config/personal.sh"
[[ -f "$HOME/.dotfiles/config/work.sh" ]] && source "$HOME/.dotfiles/config/work.sh"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

if command -v brew >/dev/null 2>&1; then
  zsh_completions_base="$(brew --prefix zsh-completions 2>/dev/null || true)"
  [[ -d "$zsh_completions_base/share/zsh/site-functions" ]] && fpath=("$zsh_completions_base/share/zsh/site-functions" $fpath)
fi
[[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions/src" ]] && fpath=("${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions/src" $fpath)

plugins=(
  git
  brew
  gh
  npm
  node
  macos
  vscode
  web-search
  colored-man-pages
  z
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

if command -v brew >/dev/null 2>&1; then
  history_substring_base="$(brew --prefix zsh-history-substring-search 2>/dev/null || true)"
  [[ -f "$history_substring_base/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && source "$history_substring_base/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi
[[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

if (( $+functions[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# Aliases
[[ -f "$HOME/.dotfiles/zsh/aliases.zsh" ]] && source "$HOME/.dotfiles/zsh/aliases.zsh"

# Functions
[[ -f "$HOME/.dotfiles/zsh/functions.zsh" ]] && source "$HOME/.dotfiles/zsh/functions.zsh"

# Optional local tools, loaded only when installed.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v brew >/dev/null 2>&1; then
  fzf_base="$(brew --prefix fzf 2>/dev/null || true)"
  [[ -f "$fzf_base/shell/key-bindings.zsh" ]] && source "$fzf_base/shell/key-bindings.zsh"
fi

# Powerlevel10k
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
