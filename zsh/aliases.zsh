alias ll="ls -la"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gb="git branch"
alias gco="git checkout"
alias lg="git log --oneline --graph --decorate --all"
alias cls="clear"
alias reload="source ~/.zshrc"

if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
  alias tree="eza --tree"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

