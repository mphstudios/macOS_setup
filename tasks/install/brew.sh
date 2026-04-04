#!/bin/bash
set -euo pipefail

#MISE description="Install packages from a Homebrew brewfile"

#USAGE arg "<brewfile>" help="Path to a brewfile (relative to project root)"
#USAGE flag "-v --verbose" help="Show live brew bundle output instead of a spinner"

source "${MISE_PROJECT_DIR}/lib/output.sh"

command -v brew &>/dev/null || die "Homebrew is required — run 'mise run install:homebrew'"

brewfile="${usage_brewfile}"

if [[ -z "$brewfile" ]]; then
  die "brewfile is a required argument"
fi

# Resolve relative paths against project root
if [[ "$brewfile" != /* ]]; then
  brewfile="$MISE_PROJECT_DIR/$brewfile"
fi

if [[ ! -f "$brewfile" ]]; then
  die "brewfile not found: $brewfile"
fi

# Ensure node/npm install properly via Homebrew
unset -v NODE_PATH

if [[ "${usage_verbose:-false}" == "true" ]]; then
  info "Installing packages from $(basename "$brewfile")..."
  brew bundle --file="$brewfile" --verbose
else
  spin "Installing packages from $(basename "$brewfile")..." \
    brew bundle --file="$brewfile"
fi
brew cleanup
ok "$(basename "$brewfile")"
