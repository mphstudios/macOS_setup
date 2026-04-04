#!/bin/bash
set -euo pipefail

#MISE description="Set computer name and hostname"

source "${MISE_PROJECT_DIR}/lib/output.sh"

[[ -n "${COMPUTER_NAME:-}" ]] || die "COMPUTER_NAME not set — run 'mise run configure:env' first"
current=$(scutil --get ComputerName 2>/dev/null || echo "")

if [[ "$current" == "$COMPUTER_NAME" ]]; then
  verified "Computer name ($COMPUTER_NAME)"
else
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
  ok "Computer name set to $COMPUTER_NAME"
fi
