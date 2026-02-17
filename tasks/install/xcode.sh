#!/bin/bash
set -euo pipefail

#MISE description="Install Xcode Command Line Tools"

source "${MISE_PROJECT_DIR}/lib/output.sh"

if xcode-select -p &>/dev/null; then
  skip "Xcode CLT"
else
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  ok "Xcode CLT installed"
fi

sudo xcodebuild -license accept 2>/dev/null || true
