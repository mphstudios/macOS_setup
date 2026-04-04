#!/bin/bash
set -euo pipefail

#MISE description="Install dotfiles"

source "${MISE_PROJECT_DIR}/lib/output.sh"

dotfiles_dir="$HOME/Code/dotfiles"

if [[ -d "$dotfiles_dir" ]]; then
  skip "Dotfiles"
  exit 0
fi

info "Cloning dotfiles..."
git clone "${DOTFILES_REPO:-https://github.com/mphstudios/dotfiles.git}" "$dotfiles_dir"

info "Running dotfiles setup..."
if ! (cd "$dotfiles_dir" && ./setup); then
  warn "Dotfiles setup script failed — review output above"
  warn "You can re-run manually: cd $dotfiles_dir && ./setup"
  exit 1
fi
ok "Dotfiles installed"
