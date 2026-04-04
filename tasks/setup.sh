#!/bin/bash
set -euo pipefail

#MISE description="Run full macOS setup"
#MISE depends=["install:xcode", "install:homebrew"]

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/macOS_setup"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

printf "\nmacOS setup started at %s\n" "$(date)"
printf "macOS version: %s\n\n" "$(sw_vers -productVersion)"

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
  "install:brew -- brewfiles/mas"
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

for i in "${!task_labels[@]}"; do
  if grep -qxF "${task_labels[$i]}" <<< "$selected"; then
    mise run ${task_commands[$i]}
  fi
done

printf "\n✔ Setup complete.\n"
printf "  Log saved to %s\n" "$LOG"

# Remind about SSH key if it was just generated
identity_file="$HOME/.ssh/github_ed25519"
if [[ -f "${identity_file}.pub" ]] && ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  printf "\n  Next step — add your SSH key to GitHub:\n"
  printf "    gh ssh-key add %s --title \"%s\" --type authentication\n" "${identity_file}.pub" "$(scutil --get ComputerName)"
  printf "    ssh -T git@github.com\n"
fi
