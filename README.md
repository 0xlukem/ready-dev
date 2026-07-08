# macOS Coding Bootstrap

![macOS](https://img.shields.io/badge/platform-macOS-000000?logo=apple)
![Dev Friendly](https://img.shields.io/badge/dev-friendly-2ea44f)
![Vibecoder Friendly](https://img.shields.io/badge/vibecoder-friendly-ff69b4)
![Beginner Friendly](https://img.shields.io/badge/onboarding-beginner%20friendly-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

One command to prepare a new Mac for coding.

This one-click installer was created to help first-time developers,
vibecoders, and curious builders set up a coding workspace without getting
stuck in hours of YouTube tutorials. It installs the common tools, configures
the terminal and editor, asks before optional steps, and prints a final report
of what was installed, linked, skipped by choice, skipped because unavailable,
or backed up.

If you need help, read this README all the way through first. It is written to
be easy to follow. If you still feel lost, ask your LLM of choice to read
`AGENTS.md` and explain this repo with the extra context it needs.

## Start Here

If this is your first coding setup, start with a preview. It shows what the
installer would do without changing your Mac.

1. Open the **Terminal** app on your Mac. You can find it in
   **Applications > Utilities > Terminal**.
2. Clone this repo:

   ```sh
   git clone https://github.com/0xlukem/ready-dev.git ~/ready-dev
   cd ~/ready-dev
   ```

3. Preview the setup:

   ```sh
   ./install.sh --dry-run
   ```

4. If the preview looks good, run the real install:

   ```sh
   ./install.sh
   ```

If this is the first time you run `git clone` on this Mac, macOS may ask you to
install **Xcode Command Line Tools**. Accept that prompt, wait for it to finish,
and then run the `git clone` command again. After that one-time install, `git`
will work normally.

## What This Does

The installer turns a fresh Mac into a practical coding machine:

- Installs Homebrew, the package manager used to install developer tools.
- Installs Git and GitHub CLI for source control.
- Installs VS Code, Ghostty, iTerm2, and the Meslo LG Nerd Font.
- Installs Node.js, pnpm, Python, mise, and uv for common project work.
- Installs terminal tools like fzf, ripgrep, zoxide, tmux, eza, bat, and
  git-delta.
- Installs Oh My Zsh, Powerlevel10k, and the shell plugins used here.
- Applies this repo's terminal, Git, Ghostty, iTerm2, and VS Code settings.
- Installs the VS Code extensions listed in `vscode/extensions.txt`.
- Optionally offers Docker Desktop.
- Optionally offers ChatGPT and Codex desktop tools.
- Optionally offers a few Finder defaults.

## What It Will Ask

The script does not silently make every decision. Prompts use this format:

```text
Question? [Y/N] default: Y
```

If you press **Enter** without typing `Y` or `N`, the default answer is used.
These are the main prompts:

| Prompt | Recommended answer | Why |
| --- | --- | --- |
| Run Homebrew bundle? | Yes | Installs the core command-line tools, apps, and font. |
| Create dotfile symlinks? | Yes | Applies the terminal, Git, and editor settings from this repo. |
| Configure Git name/email? | Yes | Git needs this information for your commits. |
| Log in to GitHub CLI? | Optional | Useful if you use GitHub from the terminal. |
| Apply macOS Finder defaults? | Optional | Shows helpful Finder details, but it changes personal preferences. |
| Install Docker Desktop? | Optional | Needed for projects that run containers locally. |
| Install OpenAI desktop tools? | Optional | Only needed if you want ChatGPT/Codex desktop apps. |

You can auto-confirm the normal setup steps with:

```sh
./install.sh --yes
```

`--yes` is mainly for repeat installs or users who already reviewed the dry run.
It answers `Y` for safe setup prompts such as Homebrew, the Brewfile install,
Oh My Zsh, and dotfile symlinks. It still does not silently answer personal or
heavier optional prompts such as Git identity, GitHub login, Finder defaults,
Docker Desktop, or OpenAI desktop tools.

## Safety

This repo is designed to be safe to try:

- `./install.sh --dry-run` previews actions without changing your Mac.
- Existing files are moved to timestamped backups before symlinks replace them.
- Your Git name/email is written to `~/.gitconfig.local`, not committed here.
- GitHub, ChatGPT, Codex, and Docker sign-ins are never automated.
- SSH keys, tokens, browser sessions, cookies, `.env` files, and API keys are
  not stored in this repo.
- `./uninstall.sh` removes only symlinks that point to this repo.

## How It Works

`install.sh` is the main entrypoint. It runs the setup in this order:

1. Checks that the machine is macOS.
2. Installs Homebrew if it is missing.
3. Offers to run `brew bundle --file=Brewfile`.
4. Installs Oh My Zsh and shell plugins.
5. Offers to link this repo's dotfiles into the expected macOS locations.
6. Offers to configure Git name/email in `~/.gitconfig.local`.
7. Installs VS Code extensions.
8. Offers GitHub CLI login.
9. Offers Finder defaults, Docker Desktop, and OpenAI desktop tools.
10. Prints an install summary.

## Check The Setup

After install, run the health check:

```sh
./scripts/doctor.sh
```

If something is missing and you want guided fixes:

```sh
./scripts/doctor.sh --fix
```

## Files Linked

When you accept the symlink step, the installer links:

- `zsh/.zshrc` to `~/.zshrc`
- `zsh/.p10k.zsh` to `~/.p10k.zsh`
- `git/.gitconfig` to `~/.gitconfig`
- `git/.gitignore_global` to `~/.gitignore_global`
- `ghostty/config` to `~/.config/ghostty/config`
- `iterm2/DynamicProfiles/Default.json` to `~/Library/Application Support/iTerm2/DynamicProfiles/Default.json`
- `vscode/settings.json` to `~/Library/Application Support/Code/User/settings.json`
- this repo root to `~/.dotfiles`

If a target already exists, it is moved to a timestamped backup first.

## Git Identity

The committed Git config does not include a name or email. During install, the
script can create this local-only file:

```ini
# ~/.gitconfig.local
[user]
  name = Your Name
  email = your.email@example.com
```

`git/.gitconfig` includes that local file automatically.

## Troubleshooting

**`git clone` asks to install Command Line Tools**

Accept the macOS prompt, wait for Command Line Tools to finish installing, and
then run `git clone` again. This usually happens only once on a clean Mac.

**Homebrew asks for your password**

That is normal when Homebrew needs permission to create or update system
folders. The script does not store your password.

**VS Code extensions did not install**

Open VS Code once, then run:

```sh
./scripts/install-vscode-extensions.sh
```

**GitHub login opens a browser**

That is expected. GitHub CLI uses an interactive browser login so this repo does
not handle your credentials.

**Docker asks for permissions or sign-in**

That is expected for Docker Desktop. The installer can install the app, but
Docker setup finishes inside Docker itself.

## Uninstall

Preview what would be removed:

```sh
./uninstall.sh --dry-run
```

Remove repo-owned symlinks only:

```sh
./uninstall.sh
```

This does not uninstall Homebrew packages, apps, credentials, backups, Oh My
Zsh, or real user files.

## For Maintainers

Maintainers are welcome. Open an issue with the change you want to make, and we
can work from there. If something important is missing and you think this setup
needs it, open an issue and we can add it.

Keep the setup intentional and beginner-friendly:

- Keep `Brewfile` focused on broadly useful coding tools.
- Keep `vscode/extensions.txt` limited to extensions that help a default coding
  setup.
- Do not commit full machine exports, private app lists, tokens, company names,
  local paths, SSH keys, API keys, or personal credentials.

## License

MIT. See [LICENSE](LICENSE).
