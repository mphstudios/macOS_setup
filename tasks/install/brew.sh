#!/bin/bash
set -euo pipefail

#MISE description="Install packages from a Homebrew brewfile"
#MISE depends=["install:homebrew"]

#USAGE arg "<brewfile>" help="Path to a brewfile (relative to project root)"
#USAGE flag "-q --quiet" help="Suppress brew bundle output"
#USAGE flag "-v --verbose" help="Show detailed brew bundle output"

source "${MISE_PROJECT_DIR}/lib/output.sh"

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

bundle_flags=()
if [[ "${usage_quiet:-false}" == "true" ]]; then
  bundle_flags+=(--quiet)
elif [[ "${usage_verbose:-false}" == "true" ]]; then
  bundle_flags+=(--verbose)
fi

# Use a spinner in default/quiet mode; show live output in verbose mode
if [[ "${usage_verbose:-false}" == "true" ]]; then
  info "Installing packages from $(basename "$brewfile")..."
  brew bundle --file="$brewfile" "${bundle_flags[@]}"
else
  spin "Installing packages from $(basename "$brewfile")..." \
    brew bundle --file="$brewfile" "${bundle_flags[@]}"
fi
brew cleanup
ok "$(basename "$brewfile")"
