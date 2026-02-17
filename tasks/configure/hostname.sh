#!/bin/bash
set -euo pipefail

#MISE description="Set computer name and hostname"
#MISE depends=["install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

current=$(scutil --get ComputerName 2>/dev/null || echo "")

if [[ "$current" == "$COMPUTER_NAME" ]]; then
  skip "Computer name ($COMPUTER_NAME)"
else
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
  ok "Computer name set to $COMPUTER_NAME"
fi
