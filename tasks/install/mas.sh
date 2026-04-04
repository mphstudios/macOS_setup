#!/bin/bash
set -euo pipefail

#MISE description="Install Mac App Store applications"
#MISE depends=["install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

# Ensure mas is available before checking authentication
if ! command -v mas &>/dev/null; then
  info "Installing mas..."
  brew install mas
fi

# Verify App Store authentication — `mas signin` was removed in 1.8.0,
# so authentication requires the App Store app.
if ! mas account &>/dev/null; then
  warn "Not signed in to the App Store"
  open -a "App Store"
  if ! gum confirm "Sign in to the App Store, then confirm to continue (Esc to skip)"; then
    warn "Skipping Mac App Store installations"
    exit 0
  fi
  if ! mas account &>/dev/null; then
    warn "Still not signed in — skipping Mac App Store installations"
    exit 0
  fi
fi

ok "App Store signed in as $(mas account)"

brew bundle --file="$MISE_PROJECT_DIR/brewfiles/mas"
brew cleanup
ok "Mac App Store apps"
