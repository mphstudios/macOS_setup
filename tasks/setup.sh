#!/bin/bash
set -euo pipefail

#MISE description="Run full macOS setup"
#MISE depends=["install:xcode", "install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

if [[ ! -f "${MISE_PROJECT_DIR}/.env" ]]; then
  die ".env not found — run 'mise run configure:env' first"
fi

task_labels=(
  "Packages  ›  Homebrew formulae"
  "Packages  ›  Homebrew casks"
  "Packages  ›  Homebrew fonts"
  "Packages  ›  Mac App Store"
  "Configure  ›  hostname"
  "Configure  ›  git"
  "Configure  ›  dotfiles"
  "Configure  ›  shell"
  "Configure  ›  macOS defaults"
  "Services  ›  launch agents"
)

task_commands=(
  "install:brew -- brewfiles/base"
  "install:brew -- brewfiles/casks"
  "install:brew -- brewfiles/fonts"
  "install:mas"
  "configure:hostname"
  "configure:git"
  "configure:dotfiles"
  "configure:shell"
  "configure:defaults"
  "install:launch-agents"
)

all_selected=$(IFS=,; printf '%s' "${task_labels[*]}")

selected=$(gum choose --no-limit \
  --header "Select tasks to run (space to toggle, enter to confirm):" \
  --selected="$all_selected" \
  "${task_labels[@]}")

if [[ -z "$selected" ]]; then
  printf "No tasks selected — exiting.\n"
  exit 0
fi

# Start logging after task selection so gum UI output is not captured in the log
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/macOS_setup"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

printf "\nmacOS setup started at %s\n" "$(date)"
printf "macOS version: %s\n\n" "$(sw_vers -productVersion)"

for i in "${!task_labels[@]}"; do
  if grep -qxF "${task_labels[$i]}" <<< "$selected"; then
    read -ra cmd <<< "${task_commands[$i]}"
    mise run "${cmd[@]}"
  fi
done

printf "\n%s Setup complete.\n" "✔"
printf "  Log saved to %s\n" "$LOG"

# Remind about SSH key if it was just generated
identity_file="$HOME/.ssh/github_ed25519"
if [[ -f "${identity_file}.pub" ]] && ! ssh -T -o ConnectTimeout=5 git@github.com 2>&1 | grep -q "successfully authenticated"; then
  printf "\n  Next step — add your SSH key to GitHub:\n"
  printf "    gh ssh-key add %s --title \"%s\" --type authentication\n" "${identity_file}.pub" "$(scutil --get ComputerName)"
  printf "    ssh -T git@github.com\n"
fi
