#!/bin/bash
set -euo pipefail

#MISE description="Configure Git and SSH keys"
#MISE confirm="Configure Git?"
#MISE depends=["install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

# Install GitHub CLI extensions
gh extension install dlvhdr/gh-dash
gh extension install dlvhdr/gh-enhance

# Configure git
git config --global credential.helper osxkeychain
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
ok "Git configured for ${GIT_USER_NAME} <${GIT_USER_EMAIL}>"

# Generate SSH key for GitHub (idempotent)
identity_file="$HOME/.ssh/github_ed25519"
ssh_config="$HOME/.ssh/config"

if [[ -f "$identity_file" ]]; then
  skip "SSH key"
else
  info "Generating SSH key for GitHub..."
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -f "$identity_file"

  # Start ssh-agent and add the new key to the keychain
  eval "$(ssh-agent -s)" >/dev/null
  /usr/bin/ssh-add --apple-use-keychain "$identity_file"
  ok "SSH key generated and added to keychain"

  # Write SSH config if it doesn't exist
  if [[ ! -f "$ssh_config" ]]; then
    cat > "$ssh_config" <<'EOF'
Include ~/.ssh/config.*

Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
  IdentitiesOnly yes

Host *
  AddKeysToAgent yes
  Compression yes
  UseKeychain yes
  VisualHostKey yes
EOF
    ok "SSH config written"
  fi

  # Try to add key to GitHub if gh is authenticated
  key_title="$(scutil --get ComputerName)"
  if gh auth status &>/dev/null; then
    info "Adding SSH key to GitHub..."
    if gh ssh-key add "${identity_file}.pub" --title "$key_title" --type authentication; then
      ok "SSH key added to GitHub"
    else
      warn "Failed to add SSH key to GitHub — add it manually:"
      printf "    gh ssh-key add %s --title \"%s\" --type authentication\n" "${identity_file}.pub" "$key_title"
    fi
  else
    printf "\n"
    warn "gh is not authenticated — add your SSH key to GitHub manually:"
    printf "    gh auth login\n"
    printf "    gh ssh-key add %s --title \"%s\" --type authentication\n" "${identity_file}.pub" "$key_title"
    printf "    ssh -T git@github.com\n"
  fi
fi
