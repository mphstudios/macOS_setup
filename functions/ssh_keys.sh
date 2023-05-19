#!/bin/sh

function generate_ssh_keys {
  local config_file = $HOME/.ssh/config
  local identity_file = github_ed25519

  read -p "GitHub email address:" $identity
  read -sp "SSH key passphrase:" $passphrase
  ssh-keygen -t ed25519 -C $identity -f "$HOME/.ssh/$identity_file" -P $passphrase

  if [ ! -f config_file ]; then
    message "Writing to $config_file file"
    cat << EOF > config_file
Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/$identity_file
  IdentitiesOnly yes
EOF
  fi

  message "Adding your SSH key to the ssh-agent"
  ssh-add --apple-use-keychain $HOME/.ssh/$identity_file

  message "Starting ssh-agent in the background"
  eval "$(ssh-agent -s)"

  case $response in
  [Yy]|yes)
    # See https://cli.github.com/manual/gh
    message "Authenticating with GitHub"
    gh auth login
    message "Adding SSH key to your account on GitHub"
    gh ssh-key add $identity_file.pub --title "$HOSTNAME"
    ssh -T git@github.com
    ;;
  [Nn]|no)
    message "See \"[Adding a new SSH key to your account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#about-addition-of-ssh-keys-to-your-account)\""
    ;;
  esac
}
