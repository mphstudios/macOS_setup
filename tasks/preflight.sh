#!/bin/bash
set -euo pipefail

#MISE description="Check system state and report what setup would do"

source "${MISE_PROJECT_DIR}/lib/output.sh"

printf "macOS %s (%s)\n\n" "$(sw_vers -productVersion)" "$(uname -m)"

# Rosetta 2 (Apple Silicon only)
if [[ "$(uname -m)" == "arm64" ]]; then
  if /usr/bin/pgrep -q oahd 2>/dev/null; then
    printf "  ${STATUS_OK} Rosetta 2 installed\n"
  else
    printf "  ${STATUS_INFO} Rosetta 2 will be installed\n"
  fi
fi

# Xcode CLT
if xcode-select -p &>/dev/null; then
  printf "  ${STATUS_OK} Xcode CLT installed\n"
else
  printf "  ${STATUS_INFO} Xcode CLT will be installed\n"
fi

# Homebrew
if command -v brew &>/dev/null; then
  printf "  ${STATUS_OK} Homebrew installed (%s)\n" "$(brew --prefix)"
else
  printf "  ${STATUS_INFO} Homebrew will be installed\n"
fi

# mise
if command -v mise &>/dev/null; then
  printf "  ${STATUS_OK} mise installed (%s)\n" "$(mise --version)"
else
  printf "  ${STATUS_INFO} mise will be installed\n"
fi

# .env
if [[ -f "$MISE_PROJECT_DIR/.env" ]]; then
  missing=()
  while IFS='=' read -r key _; do
    [[ -z "$key" || "$key" = \#* ]] && continue
    if ! grep -q "^${key}=" "$MISE_PROJECT_DIR/.env"; then
      missing+=("$key")
    fi
  done < "$MISE_PROJECT_DIR/.env.example"
  if [[ ${#missing[@]} -eq 0 ]]; then
    printf "  ${STATUS_OK} .env exists (all variables set)\n"
  else
    printf "  ${STATUS_WARN} .env exists but missing: %s\n" "${missing[*]}"
  fi
else
  printf "  ${STATUS_INFO} .env will be created (interactive prompts)\n"
fi

# SSH keys
if [[ -f "$HOME/.ssh/github_ed25519" ]]; then
  printf "  ${STATUS_OK} SSH key exists\n"
else
  printf "  ${STATUS_INFO} SSH key will be generated\n"
fi

# Dotfiles
if [[ -d "$HOME/Code/dotfiles" ]]; then
  printf "  ${STATUS_OK} Dotfiles cloned\n"
else
  printf "  ${STATUS_INFO} Dotfiles will be cloned\n"
fi

# Homebrew bundles
printf "\nHomebrew bundles:\n"
for brewfile in base casks fonts mas; do
  path="$MISE_PROJECT_DIR/brewfiles/$brewfile"
  if [[ -f "$path" ]]; then
    count=$(grep -cE "^(brew|cask|mas|tap) " "$path" 2>/dev/null || echo 0)
    printf "  %-8s %s packages\n" "$brewfile" "$count"
  fi
done

# LaunchAgents
printf "\nLaunchAgents:\n"
for plist in "$MISE_PROJECT_DIR/LaunchAgents"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  if [[ -f "$HOME/Library/LaunchAgents/$name" ]]; then
    if diff -q "$plist" "$HOME/Library/LaunchAgents/$name" &>/dev/null; then
      printf "  ${STATUS_OK} %s (current)\n" "$name"
    else
      printf "  ${STATUS_INFO} %s (will update)\n" "$name"
    fi
  else
    printf "  ${STATUS_INFO} %s (will install)\n" "$name"
  fi
done

# Check for stale agents
for plist in "$HOME/Library/LaunchAgents"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  if [[ ! -f "$MISE_PROJECT_DIR/LaunchAgents/$name" ]]; then
    printf "  ${STATUS_WARN} %s (stale, will remove)\n" "$name"
  fi
done

# Defaults data
printf "\nDefaults:\n"
yaml_count=0
for yaml in "$MISE_PROJECT_DIR/defaults"/*.yaml; do
  [[ -f "$yaml" ]] || continue
  yaml_count=$((yaml_count + 1))
done
if [[ $yaml_count -gt 0 ]]; then
  printf "  ${STATUS_OK} %s YAML file(s) in defaults/\n" "$yaml_count"
  if command -v macos-defaults &>/dev/null; then
    macos-defaults apply --dry-run "$MISE_PROJECT_DIR/defaults/" 2>&1 | sed 's/^/  /'
  else
    printf "  ${STATUS_WARN} macos-defaults not installed (install via: brew install dsully/tap/macos-defaults)\n"
  fi
else
  printf "  ${STATUS_WARN} No YAML files in defaults/ — defaults will not be applied\n"
fi

# Setup overview
printf "\nSetup steps (mise run setup):\n"
printf "  1. Install Homebrew packages   (brewfiles/base, casks, fonts, mas)\n"
printf "  2. Configure git and SSH keys  (configure:git)\n"
printf "  3. Clone and link dotfiles     (configure:dotfiles)\n"
printf "  4. Configure login shells      (configure:shell)\n"
printf "  5. Apply macOS defaults        (configure:defaults)\n"
printf "  6. Sync LaunchAgents           (install:launch-agents)\n"
