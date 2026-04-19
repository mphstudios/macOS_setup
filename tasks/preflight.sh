#!/bin/bash
set -euo pipefail

#MISE description="Check system state and report what setup would do"

source "${MISE_PROJECT_DIR}/lib/output.sh"

printf "macOS %s (%s)\n\n" "$(sw_vers -productVersion)" "$(uname -m)"

# Rosetta 2 (Apple Silicon only)
if [[ "$(uname -m)" == "arm64" ]]; then
  if /usr/bin/pgrep -q oahd 2>/dev/null; then
    printf "  %s Rosetta 2 installed\n" "${STATUS_OK}"
  else
    printf "  %s Rosetta 2 will be installed\n" "${STATUS_INFO}"
  fi
fi

# Xcode CLT
if xcode-select -p &>/dev/null; then
  printf "  %s Xcode CLT installed\n" "${STATUS_OK}"
else
  printf "  %s Xcode CLT will be installed\n" "${STATUS_INFO}"
fi

# Homebrew
if command -v brew &>/dev/null; then
  printf "  %s Homebrew installed (%s)\n" "${STATUS_OK}" "$(brew --prefix)"
else
  printf "  %s Homebrew will be installed\n" "${STATUS_INFO}"
fi

# mise
if command -v mise &>/dev/null; then
  printf "  %s mise installed (%s)\n" "${STATUS_OK}" "$(mise --version)"
else
  printf "  %s mise will be installed\n" "${STATUS_INFO}"
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
    printf "  %s .env exists (all variables set)\n" "${STATUS_OK}"
  else
    printf "  %s .env exists but missing: %s\n" "${STATUS_WARN}" "${missing[*]}"
  fi
else
  printf "  %s .env will be created (interactive prompts)\n" "${STATUS_INFO}"
fi

# SSH keys
if [[ -f "$HOME/.ssh/github_ed25519" ]]; then
  printf "  %s SSH key exists\n" "${STATUS_OK}"
else
  printf "  %s SSH key will be generated\n" "${STATUS_INFO}"
fi

# Dotfiles
if [[ -d "$HOME/Code/dotfiles" ]]; then
  printf "  %s Dotfiles cloned\n" "${STATUS_OK}"
else
  printf "  %s Dotfiles will be cloned\n" "${STATUS_INFO}"
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
BREW_PREFIX="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
resolved=$(mktemp)
trap 'rm -f "$resolved"' EXIT

for plist in "$MISE_PROJECT_DIR/system/LaunchAgents"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  dest="$HOME/Library/LaunchAgents/$name"
  # Resolve placeholders to match what install would produce
  BREW_PREFIX="$BREW_PREFIX" envsubst '${BREW_PREFIX} ${HOME}' < "$plist" > "$resolved"

  if [[ ! -f "$dest" ]]; then
    # destination file does not yet exist, resolved source will be installed
    printf "  %s %s (will install)\n" "${STATUS_INFO}" "$name"
  elif cmp -s "$resolved" "$dest"; then
    # OK - copy at destination is a byte-exact match of the resolved source
    printf "  %s %s (current)\n" "${STATUS_OK}" "$name"
  else
    # copy at destination does not match and will be replaced by resolved source
    printf "  %s %s (will update)\n" "${STATUS_INFO}" "$name"
  fi
done

# Check for stale agents
for plist in "$HOME/Library/LaunchAgents"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  if [[ ! -f "$MISE_PROJECT_DIR/system/LaunchAgents/$name" ]]; then
    printf "  %s %s (stale, will remove)\n" "${STATUS_WARN}" "$name"
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
  printf "  %s %s YAML file(s) in defaults/\n" "${STATUS_OK}" "$yaml_count"
  if command -v macos-defaults &>/dev/null; then
    macos-defaults apply --dry-run "$MISE_PROJECT_DIR/defaults/" 2>&1 | sed 's/^/  /'
  else
    printf "  %s macos-defaults not installed (install via: mise install)\n" "${STATUS_WARN}"
  fi
else
  printf "  %s No YAML files in defaults/ — defaults will not be applied\n" "${STATUS_WARN}"
fi

# Setup overview
printf "\nSetup steps (mise run setup):\n"
printf "  1. Install Homebrew packages   (brewfiles/base, casks, fonts, mas)\n"
printf "  2. Set computer name           (configure:hostname)\n"
printf "  3. Configure git and SSH keys  (configure:git)\n"
printf "  4. Clone and link dotfiles     (configure:dotfiles)\n"
printf "  5. Configure login shells      (configure:shell)\n"
printf "  6. Apply macOS defaults        (configure:defaults)\n"
printf "  7. Sync LaunchAgents           (install:launch-agents)\n"
