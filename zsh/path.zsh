# Apple Silicon Homebrew
if [[ -d "/opt/homebrew/bin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Intel Homebrew
if [[ -d "/usr/local/bin" ]]; then
  export PATH="/usr/local/bin:$PATH"
fi

export PATH="$HOME/.local/bin:$PATH"
