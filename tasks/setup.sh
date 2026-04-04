#!/bin/bash
set -euo pipefail

#MISE description="Run full macOS setup"

source "${MISE_PROJECT_DIR}/lib/output.sh"

if [[ ! -f "${MISE_PROJECT_DIR}/.env" ]]; then
  die ".env not found — run 'mise run configure:env' first"
fi

# Each entry is "Human label|mise task command"
# Label and command are co-located so adding, removing, or reordering tasks
# requires changing only one line.
tasks=(
  "Services   ›  launch agents|install:launch-agents"
  "Packages   ›  Homebrew formulae|install:brew -- brewfiles/base"
  "Packages   ›  Homebrew casks|install:brew -- brewfiles/casks"
  "Packages   ›  Homebrew fonts|install:brew -- brewfiles/fonts"
  "Packages   ›  Mac App Store|install:mas"
  "Configure  ›  hostname|configure:hostname"
  "Configure  ›  git|configure:git"
  "Configure  ›  dotfiles|configure:dotfiles"
  "Configure  ›  shell|configure:shell"
  "Configure  ›  macOS defaults|configure:defaults"
)

task_labels=()
for task in "${tasks[@]}"; do
  task_labels+=("${task%%|*}")
done

all_selected=$(IFS=,; printf '%s' "${task_labels[*]}")

selected=$(gum choose --no-limit \
  --header "Select tasks to run (space to toggle, enter to confirm):" \
  --selected="$all_selected" \
  "${task_labels[@]}")

if [[ -z "$selected" ]]; then
  printf "No tasks selected — exiting.\n"
  exit 0
fi

# Export XDG base dirs and tool-specific home dirs for this session so that
# tools install to the correct locations before the dotfiles are available.
# Values must stay in sync with local.xdg-basedir.plist and dotfiles repository.
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/Library/Caches}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export CARGO_HOME="${CARGO_HOME:-$HOME/.local/share/cargo}"
export DOCKER_CONFIG="${DOCKER_CONFIG:-$HOME/.config/docker}"
export GNUPGHOME="${GNUPGHOME:-$HOME/.config/gnupg}"
export NPM_CONFIG_CACHE="$NPM_CONFIG_CACHE:-$HOME/.cache/npm}"
export NPM_CONFIG_USERCONFIG="$NPM_CONFIG_USERCONFIG:-$HOME/.config/npm/npmrc}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.local/share/rustup}"

# Preserve colour output through the log redirect: after exec stdout is a pipe
# so [[ -t 1 ]] returns false. FORCE_COLOR tells output.sh to keep colours on.
[[ -t 1 ]] && export FORCE_COLOR=1

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/macOS_setup"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

printf "\nmacOS setup started at %s\n" "$(date)"
printf "macOS version: %s\n\n" "$(sw_vers -productVersion)"

for task in "${tasks[@]}"; do
  label="${task%%|*}"
  cmd="${task#*|}"
  if grep -qxF "$label" <<< "$selected"; then
    read -ra args <<< "$cmd"
    mise run "${args[@]}"
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
