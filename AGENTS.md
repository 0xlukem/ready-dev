# Agent Instructions

This repo is a beginner-friendly macOS coding bootstrapper.

Its purpose is to help first-time developers, vibecoders, and curious builders
set up a coding workspace without getting stuck in hours of tutorials. When a
user asks about this repo, explain things simply, guide them safely, and avoid
assuming they already understand Terminal, Git, Homebrew, shells, dotfiles, or
developer tooling.

## How To Help Users

When helping someone with this repo:

- Read `README.md` first.
- Explain what the repo does before explaining how to install it.
- Use plain language. Avoid jargon unless you define it immediately.
- Explain every command before asking the user to run it.
- Prefer `./install.sh --dry-run` before any real installation.
- Do not run or recommend `./install.sh` for a real install without explicit
  user confirmation.
- Do not ask for passwords, tokens, SSH keys, API keys, browser cookies, or
  private credentials.
- If something fails, ask for the exact command output and explain the error in
  beginner-friendly language.
- Do not suggest deleting files unless the user clearly understands what will
  be removed.
- When the user is confused, slow down and explain the next safest step.

Good first response for a new user:

```text
This repo prepares a Mac for coding. It installs common developer tools,
configures your terminal and editor, asks before optional steps, and prints a
summary at the end. The safest first command is ./install.sh --dry-run because
it previews changes without modifying your Mac.
```

## Safe Install Flow

Guide beginners through this order:

1. Open Terminal.
2. Clone the repo.
3. Enter the repo folder.
4. Run the dry run.
5. Review what would happen.
6. Run the real install only after they confirm.
7. Run the doctor check after install.

Commands:

```sh
git clone https://github.com/0xlukem/ready-dev.git ~/ready-dev
cd ~/ready-dev
./install.sh --dry-run
./install.sh
./scripts/doctor.sh
```

If this is the first time the user runs `git clone` on a clean Mac, macOS may
ask them to install Xcode Command Line Tools. Explain that this is normal: they
should accept the prompt, wait for it to finish, and then run the same
`git clone` command again. After that one-time install, `git` should work
normally.

## What The Installer Does

`install.sh` is the main entrypoint. It runs setup in this order:

1. Checks that the computer is a Mac.
2. Installs Homebrew if it is missing.
3. Offers to install tools and apps from `Brewfile`.
4. Installs Oh My Zsh and shell plugins.
5. Offers to link this repo's dotfiles into macOS locations.
6. Offers to configure Git name/email locally.
7. Installs VS Code extensions.
8. Offers GitHub CLI login.
9. Offers optional Finder defaults.
10. Offers optional Docker Desktop.
11. Offers optional ChatGPT and Codex desktop tools.
12. Prints a final install summary.

When explaining this to beginners, say:

```text
The script is not one silent black box. It checks your Mac, installs common
tools, asks before optional choices, backs up existing config files before
linking new ones, and reports what happened at the end.
```

## Simple Explanation Of Each Installed Tool

Use these explanations when users ask "what is this?" or "do I need this?"

### Core Tools

- **Homebrew**: The Mac package manager. It installs developer tools and apps
  from the terminal.
- **Git**: Tracks changes in code and lets projects use version control.
- **GitHub CLI (`gh`)**: Lets users connect to GitHub from the terminal.
- **Zsh**: The default modern Mac shell. It is the program users type commands
  into.
- **curl**: Downloads data from URLs. Many developer tools use it.
- **jq**: Reads and formats JSON, a common data format used by APIs and config
  files.

### Terminal Quality-Of-Life Tools

- **fzf**: Fuzzy finder. It helps users search through files, commands, and
  lists quickly.
- **ripgrep (`rg`)**: Fast search inside files. Useful for finding text in a
  project.
- **fd**: Fast file finder. Simpler than the built-in `find` command.
- **bat**: Like `cat`, but easier to read because it adds colors and line
  numbers.
- **eza**: A nicer `ls` replacement for listing files.
- **zoxide**: Smarter `cd`. It learns folders the user visits often.
- **tmux**: Keeps terminal sessions organized and running.
- **git-delta (`delta`)**: Makes Git diffs easier to read.

### Runtime And Project Tools

- **Node.js**: Runs JavaScript outside the browser. Needed for many web apps and
  frontend tools.
- **pnpm**: Installs JavaScript packages. Similar purpose to npm, usually faster
  and more disk-efficient.
- **Python**: General-purpose programming language used in scripting, data,
  automation, AI, and backend work.
- **mise**: Manages tool versions per project, such as Node or Python versions.
- **uv**: Fast Python package and virtual environment tool.

### Desktop Apps And Font

- **Ghostty**: A modern terminal app.
- **iTerm2**: Another popular Mac terminal app. This repo includes an iTerm2
  dynamic profile.
- **Visual Studio Code**: The main code editor installed by this setup.
- **JetBrains Mono Nerd Font**: A developer-friendly font with icons used by
  terminal prompts and themes.

### Shell Setup

- **Oh My Zsh**: A framework that makes Zsh easier to customize.
- **Powerlevel10k**: A fast, useful terminal prompt theme.
- **zsh-autosuggestions**: Suggests commands based on history while typing.
- **zsh-completions**: Adds more command autocompletion.
- **zsh-history-substring-search**: Makes it easier to search previous commands.
- **zsh-syntax-highlighting**: Colors valid and invalid commands as the user
  types.

### VS Code Extensions

- **ESLint**: Shows JavaScript/TypeScript code issues in VS Code.
- **Prettier**: Formats code consistently.
- **GitLens**: Adds helpful Git history and blame information.
- **GitHub Actions**: Helps view and edit GitHub Actions workflow files.
- **GitHub Pull Requests**: Lets users work with GitHub pull requests in VS
  Code.
- **Playwright**: Helps test websites and web apps in real browsers.
- **Python**: Adds Python language support.
- **debugpy**: Enables Python debugging.
- **Pylance**: Improves Python autocomplete and type checking.
- **Python Environments**: Helps manage Python environments in VS Code.
- **Tailwind CSS IntelliSense**: Autocomplete and hints for Tailwind CSS.
- **Live Server / LiveServer**: Opens simple HTML/CSS/JS pages in a local
  browser preview.
- **TypeScript Next**: Uses a newer TypeScript version in VS Code.
- **OpenAI ChatGPT**: Adds ChatGPT support inside VS Code.
- **Material Icon Theme**: Makes file icons easier to scan.
- **CSS Peek**: Helps jump between HTML classes and CSS definitions.
- **Error Lens**: Shows errors inline so beginners can see issues faster.

### Optional Tools

- **Docker Desktop**: Runs containers locally. Useful for projects that need
  databases, services, or production-like environments. It can ask for macOS
  permissions or sign-in after installation.
- **ChatGPT desktop app**: Optional OpenAI desktop app. The repo never handles
  OpenAI credentials.
- **Codex desktop app/CLI**: Optional OpenAI coding agent. The repo never
  handles OpenAI credentials.
- **macOS Finder defaults**: Optional Finder preferences, such as showing hidden
  files and path/status bars.

## What Gets Linked

If the user accepts dotfile symlinks, this repo links:

- `zsh/.zshrc` to `~/.zshrc`
- `zsh/.p10k.zsh` to `~/.p10k.zsh`
- `git/.gitconfig` to `~/.gitconfig`
- `git/.gitignore_global` to `~/.gitignore_global`
- `ghostty/config` to `~/.config/ghostty/config`
- `iterm2/DynamicProfiles/Default.json` to
  `~/Library/Application Support/iTerm2/DynamicProfiles/Default.json`
- `vscode/settings.json` to
  `~/Library/Application Support/Code/User/settings.json`
- the repo root to `~/.dotfiles`

Explain symlinks simply:

```text
A symlink is a shortcut. Instead of copying config files into many places, the
installer points your Mac to the files inside this repo. That makes the setup
easier to update later.
```

If a target file already exists, the installer moves it to a timestamped backup
before creating the symlink.

## Safety Rules To Explain

Use these points when a user asks if the repo is safe:

- The dry run previews actions without changing the Mac.
- Existing config files are backed up before being replaced by symlinks.
- Git name/email is stored in `~/.gitconfig.local`, not committed here.
- GitHub login is handled by GitHub CLI, not this repo.
- Docker, ChatGPT, and Codex sign-ins happen inside those apps, not in this
  repo.
- SSH keys, tokens, browser sessions, cookies, `.env` files, and API keys should
  never be committed or pasted into chat.
- `./uninstall.sh` removes only symlinks that point to this repo. It does not
  uninstall apps, credentials, Homebrew packages, backups, or real user files.

## How To Answer Common Questions

### "What does this repo do?"

Answer:

```text
It prepares a Mac for coding. It installs common tools, configures the terminal
and VS Code, asks before optional tools like Docker, and gives you a summary at
the end.
```

### "Is it safe to run?"

Answer:

```text
Start with ./install.sh --dry-run. That shows what would happen without making
changes. The real install backs up existing config files before linking new
ones, and it does not store passwords or API keys.
```

### "Do I need Docker?"

Answer:

```text
Not always. Docker is useful when a project needs containers, databases, or
services running locally. If you are just starting, you can skip it and install
it later.
```

### "What should I answer when it asks questions?"

Answer:

```text
For a normal first setup, say yes to Homebrew bundle, dotfile symlinks, and Git
identity. GitHub login, Finder defaults, Docker, ChatGPT, and Codex are optional.
```

### "What if something fails?"

Answer:

```text
Copy the exact command and output. Do not delete files yet. We can read the
error, explain what happened, and choose the safest next step.
```

## Maintenance Guidance

When changing this repo:

- Keep the setup beginner-friendly.
- Do not add niche tools unless they clearly help the default setup.
- Do not commit full machine exports, private app lists, company names, local
  paths, credentials, SSH keys, API keys, or `.env` files.
- Keep `Brewfile` intentional and public-safe.
- Keep `vscode/extensions.txt` limited to broadly useful coding extensions.
- Prefer small, clear scripts over hidden magic.

Verification:

- If changing shell scripts, run:

  ```sh
  bash -n install.sh uninstall.sh scripts/*.sh
  ```

- If changing JSON files, run:

  ```sh
  jq empty <file>
  ```

- If changing install behavior, run:

  ```sh
  ./install.sh --dry-run
  ./uninstall.sh --dry-run
  ```

- If changing docs only, read the edited section and confirm it matches the
  actual installer behavior.
