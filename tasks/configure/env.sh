#!/bin/bash
set -euo pipefail

#MISE description="Configure environment variables (.env) for setup"

source "${MISE_PROJECT_DIR}/lib/output.sh"

env_file="${MISE_PROJECT_DIR}/.env"
system_computer=$(scutil --get ComputerName)

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
    verified "Configuration"
    exit 0
  fi
  printf "\n"
fi

# Print a cancellation message if gum input exits non-zero (Esc or Ctrl+C)
trap 'printf "\n  %s Configuration cancelled — .env unchanged.\n" "${STATUS_WARN}" >&2' ERR

COMPUTER_NAME=$(gum input \
  --prompt "  Computer name   " \
  --value "${COMPUTER_NAME:-$system_computer}")

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

if [[ -z "$GIT_USER_NAME" ]]; then
  die "Git user name is required"
fi
if [[ -z "$GIT_USER_EMAIL" ]]; then
  die "Git email is required"
fi

printf "\n"

# Escape embedded double quotes so values are safe to re-source
esc() { printf '%s' "${1//\"/\\\"}"; }

# Write atomically so a mid-write interruption never produces a partial .env
tmp=$(mktemp)
printf '%s\n' \
  "COMPUTER_NAME=\"$(esc "$COMPUTER_NAME")\"" \
  "DOTFILES_REPO=\"$(esc "$DOTFILES_REPO")\"" \
  "GIT_USER_EMAIL=\"$(esc "$GIT_USER_EMAIL")\"" \
  "GIT_USER_NAME=\"$(esc "$GIT_USER_NAME")\"" \
  "LOCK_SCREEN_MESSAGE=\"$(esc "$LOCK_SCREEN_MESSAGE")\"" \
  > "$tmp"
mv "$tmp" "$env_file"

ok ".env written"
