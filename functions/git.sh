#!/bin/sh

function configure_git {
  install_homebrew_package 'git'
  install_homebrew_package 'git-lfs'
  install_homebrew_package 'gh'

  git config --global credential.helper osxkeychain

  read -p "git user name: " username
  git config --global user.name $username

  read -p "git user email: " email
  git config --global user.email $email

  generate_github_key $email
}

# Generate a SSH key for GitHub and write the SSH config file
# @see https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
#
# @param {String} email   An email address used for the SSH identity file
function generate_github_key {
  local email_address=$1 || read -p "email address:" response
  local ssh_config="~/.ssh/config"
  local identity_file="~/.ssh/github_ed25519"
  local public_key="$identity_file.pub"

  if [ ! -f "$identity_file" ]
  then
    message "Generating ssh key for github.com…"
    ssh-keygen -t ed25519 -C $email_address -f $identity_file
  fi

  if [ ! -f "$ssh_config" ]
  then
    message "Writing $ssh_config file"

    # ensure configuration file exists
    touch $ssh_config

    cat << EOF > $ssh_config
Include ~/.ssh/config.*

Host github
  HostName github.com
  User git
  IdentityFile $identity_file
  IdentitiesOnly yes

Host *
  AddKeysToAgent yes
  Compression yes
  UseKeychain yes
  VisualHostKey yes

EOF
  fi

  # @todo refactor to look for existing ssh
  message "Starting ssh-agent in the background"
  eval "$(ssh-agent -s)"

  message "Adding your SSH key to the ssh-agent"
  /usr/bin/ssh-add --apple-use-keychain $identity_file

  if confirm "Add public key $public_key to your GitHub account?" "Y"
  then
    gh ssh-key add "$public_key" --title "$COMPUTER" --type "authentication"
    ssh -T git@github.com || true
  else
    message "See \"[Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)\""
  fi
}
