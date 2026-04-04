#!/bin/bash
set -euo pipefail

#MISE description="Configure environment variables (.env) for setup"

source "${MISE_PROJECT_DIR}/lib/output.sh"

env_file="${MISE_PROJECT_DIR}/.env"
_system_computer=$(scutil --get ComputerName)

if [[ -f "$env_file" ]]; then
  source "$env_file"

  gum style \
    --border rounded --border-foreground 240 \
    --padding "0 1" --margin "1 0" \
    "  Computer name   ${COMPUTER_NAME:-}" \
    "  Dotfiles repo   ${DOTFILES_REPO:-}" \
    "  Git user name   ${GIT_USER_NAME:-}" \
    "  Git email       ${GIT_USER_EMAIL:-}" \
    "  Lock screen     ${LOCK_SCREEN_MESSAGE:-}"

  if gum confirm "Keep current configuration?"; then
    skip "Configuration"
    exit 0
  fi
  printf "\n"
fi

COMPUTER_NAME=$(gum input \
  --prompt "  Computer name   " \
  --value "${COMPUTER_NAME:-$_system_computer}")

DOTFILES_REPO=$(gum input \
  --prompt "  Dotfiles repo   " \
  --value "${DOTFILES_REPO:-https://github.com/mphstudios/dotfiles.git}")

GIT_USER_NAME=$(gum input \
  --prompt "  Git user name   " \
  --value "${GIT_USER_NAME:-}")

GIT_USER_EMAIL=$(gum input \
  --prompt "  Git email       " \
  --value "${GIT_USER_EMAIL:-}")

LOCK_SCREEN_MESSAGE=$(gum input \
  --prompt "  Lock screen     " \
  --value "${LOCK_SCREEN_MESSAGE:-We have achieved normality}")

printf "\n"

printf '%s\n' \
  "COMPUTER_NAME=\"$COMPUTER_NAME\"" \
  "DOTFILES_REPO=$DOTFILES_REPO" \
  "GIT_USER_EMAIL=$GIT_USER_EMAIL" \
  "GIT_USER_NAME=$GIT_USER_NAME" \
  "LOCK_SCREEN_MESSAGE=\"$LOCK_SCREEN_MESSAGE\"" \
  > "$env_file"

ok ".env written"
