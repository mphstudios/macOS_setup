# macOS Setup

Setup and configure a macOS machine for daily use and software development.

## Quick Start

Download and decompress the repository archive:

```sh
curl -L -o setup.tar.gz https://github.com/mphstudios/macOS_setup/archive/refs/heads/main.tar.gz
mkdir -p ~/Code/macOS_setup
tar -xvf setup.tar.gz --directory ~/Code/macOS_setup/ --strip-components=1
```

Run the bootstrap:

```sh
cd ~/Code/macOS_setup
./bootstrap.sh
```

The script bootstraps prerequisites (Xcode CLT, Homebrew, mise), prompts for machine-specific values on first run, then hands off to `mise run setup`.

## Architecture

```
bootstrap.sh                Thin bootstrap (~80 lines)
.env                        Machine-specific values (git-ignored)
mise.toml                   Tool versions + task config

brewfiles/                  Declarative package lists
  base, casks, fonts, mas

defaults/                   macOS defaults as YAML (applied by macos-defaults)
  general, dock, finder, safari, screen, apps, updates

system/                     Files installed onto the machine
  bin/                      Scripts → ~/.local/bin/
  LaunchAgents/             Plists → ~/Library/LaunchAgents/
  assets/icons/             Notification icons

lib/output.sh               Shared output functions

tasks/
  setup.sh                  Meta-task: orchestrates full setup with logging
  preflight.sh              Read-only system check (no side effects)
  install/
    xcode.sh                Xcode Command Line Tools
    homebrew.sh             Homebrew package manager
    brew.sh                 Install packages from a brewfile
    launch-agents.sh        LaunchAgent lifecycle management
  configure/
    hostname.sh             Set computer name and hostname
    defaults.sh             macOS system defaults
    defaults-export.sh      Export current defaults for a domain
    dotfiles.sh             Clone and setup dotfiles
    git.sh                  Git config + SSH keys
    shell.sh                Login shells + default shell
```

Tasks are atomic and idempotent — they are safe to re-run at any time.

## Ownership Boundary

| Concern | Owner |
|---------|-------|
| What's installed | this repository (`brewfiles`, `mise.toml`) |
| How tools are configured | [dotfiles repository](https://github.com/mphstudios/dotfiles) |
| System preferences | this repository (`defaults/*.yaml`) |
| Machine identity | this repository (`.env`) |
| LaunchAgents | this repository (`system/LaunchAgents/local.*`) |

## Preflight Check

Inspect the system and see what setup would do — no side effects:

```sh
mise run preflight
```

## Running Individual Tasks

```sh
mise run configure:git          # reconfigure git + SSH keys
mise run configure:defaults     # reapply system defaults
mise run configure:shell        # configure login shells
mise run install:launch-agents  # sync LaunchAgents
mise run install:brew -- brewfiles/base  # install a specific brewfile
mise run configure:dotfiles     # clone/setup dotfiles
```

List all available tasks:

```sh
mise tasks
```

## Brewfiles

| File | Contents |
|------|----------|
| `brewfiles/base` | CLI tools, shells, search utilities |
| `brewfiles/casks` | GUI applications |
| `brewfiles/fonts` | Monospace, programming, and Nerd Fonts |
| `brewfiles/mas` | Mac App Store applications |

To remove packages not listed in the brewfiles:

```sh
brew bundle cleanup --file=brewfiles/base
```

## Defaults

System defaults are managed declaratively via YAML files in `defaults/`, applied by [`macos-defaults`](https://github.com/dsully/macos-defaults).

Export current defaults for a domain:

```sh
mise run configure:defaults-export -- com.apple.dock
```

Preview changes without applying:

```sh
macos-defaults apply --dry-run defaults/
```

## References

- `defaults` [man page](https://ss64.com/mac/defaults.html)
- [SS64](https://ss64.com/mac/syntax-defaults.html)
- [macos-defaults.com](https://macos-defaults.com/)
- [defaults-write.com](https://www.defaults-write.com/)
