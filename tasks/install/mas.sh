#!/bin/bash
set -euo pipefail

#MISE description="Install Mac App Store applications"

source "${MISE_PROJECT_DIR}/lib/output.sh"

command -v brew &>/dev/null || die "Homebrew is required — run 'mise run install:homebrew'"

# Ensure mas is available before checking authentication
if ! command -v mas &>/dev/null; then
  spin "Installing mas..." brew install mas
  ok "mas installed"
fi

# Verify App Store authentication — `mas signin` was removed in 1.8.0,
# so authentication requires the App Store app.
apple_id=$(mas account 2>/dev/null) || apple_id=""
if [[ -z "$apple_id" ]]; then
  warn "Not signed in to the App Store"
  open -a "App Store"
  if ! gum confirm "Sign in to the App Store, then confirm to continue (Esc to skip)"; then
    warn "Skipping Mac App Store installations"
    exit 0
  fi
  apple_id=$(mas account 2>/dev/null) || apple_id=""
  if [[ -z "$apple_id" ]]; then
    warn "Still not signed in — skipping Mac App Store installations"
    exit 0
  fi
fi

ok "App Store signed in as $apple_id"

if ! gum spin --spinner dot --show-output --title "Installing Mac App Store apps..." -- \
    brew bundle --file="$MISE_PROJECT_DIR/brewfiles/mas"; then
  warn "Some App Store apps failed to install — re-run with 'mise run install:mas' for details"
fi
brew cleanup
ok "Mac App Store apps"
