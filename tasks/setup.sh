#!/bin/bash
set -euo pipefail

#MISE description="Run full macOS setup"
#MISE depends=["install:xcode", "install:homebrew"]
#MISE confirm="Run full macOS setup? (This will install packages, configure git, dotfiles, shells, defaults, and LaunchAgents)"

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/macOS_setup"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

printf "\nmacOS setup started at %s\n" "$(date)"
printf "macOS version: %s\n" "$(sw_vers -productVersion)"

# Install packages
for brewfile in base casks fonts mas; do
  mise run install:brew -- "brewfiles/$brewfile"
done

# Configure
mise run configure:hostname
mise run configure:git
mise run configure:dotfiles
mise run configure:shell
mise run configure:defaults

# Install services
mise run install:launch-agents

printf "\n✔ Setup complete.\n"
printf "  Log saved to %s\n" "$LOG"

# Remind about SSH key if it was just generated
identity_file="$HOME/.ssh/github_ed25519"
if [[ -f "${identity_file}.pub" ]] && ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  printf "\n  Next step — add your SSH key to GitHub:\n"
  printf "    gh ssh-key add %s --title \"%s\" --type authentication\n" "${identity_file}.pub" "$(scutil --get ComputerName)"
  printf "    ssh -T git@github.com\n"
fi
