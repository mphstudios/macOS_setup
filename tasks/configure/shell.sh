#!/bin/bash
set -euo pipefail

#MISE description="Configure login shells"
#MISE depends=["install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

BREW_PREFIX=$(brew --prefix)

# Add Homebrew-installed shells to /etc/shells (idempotent)
for shell in bash zsh nu; do
  shell_path="$BREW_PREFIX/bin/$shell"
  if [[ -x "$shell_path" ]] && ! grep -qF "$shell_path" /etc/shells; then
    echo "$shell_path" | sudo tee -a /etc/shells >/dev/null
    ok "Added $shell_path to /etc/shells"
  else
    skip "$shell_path"
  fi
done

# Set default shell to nushell if not already
if [[ "$SHELL" != "$BREW_PREFIX/bin/nu" ]]; then
  chsh -s "$BREW_PREFIX/bin/nu"
  ok "Default shell set to nushell"
else
  skip "Default shell"
fi
