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

# brew bundle failures (unavailable formulae, network errors) are non-fatal:
# a missing font or cask should not abort hostname, dotfiles, and defaults steps.
# --show-output surfaces brew's error output only on failure.
name=$(basename "$brewfile")
if [[ "${usage_verbose:-false}" == "true" ]]; then
  info "Installing packages from $name..."
  brew bundle --file="$brewfile" --verbose || warn "Some packages from $name failed to install — review output above"
else
  if ! gum spin --spinner dot --show-output --title "Installing packages from $name..." -- \
      brew bundle --file="$brewfile"; then
    warn "Some packages from $name failed to install — re-run with --verbose for details"
  fi
fi
brew cleanup
ok "$name"
