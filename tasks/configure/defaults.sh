#!/bin/bash
set -euo pipefail

#MISE description="Write macOS system defaults"

source "${MISE_PROJECT_DIR}/lib/output.sh"

command -v macos-defaults &>/dev/null || die "macos-defaults is required — run 'mise install'"
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
sudo -v

info "Applying system defaults (macOS $(sw_vers -productVersion))..."
macos-defaults apply "$MISE_PROJECT_DIR/defaults/"
ok "System defaults applied"
