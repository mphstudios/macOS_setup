macOS Setup
===========

A shell script to setup and configure a computer running macOS.

This script is influenced and inspired by Mathias Bynens' [dotfiles] scripts and the Thoughtbot [Laptop] script.

[dotfiles]: https://github.com/mathiasbynens/dotfiles
[Laptop]: https://github.com/thoughtbot/laptop

Usage
-----

Download and decompress the repository archive

```sh
curl --output setup.zip https://github.com/mphstudios/macOS_setup/archive/refs/heads/main.zip
unzip setup.zip -d macOS_setup/
```

or 

```sh
curl --output setup.tar.gz https://github.com/mphstudios/macOS_setup/archive/refs/heads/main.tar.gz
mkdir -p ~/Code/macOS_setup
tar -xvf setup.zip --directory ~/Code/macOS_setup/
```

Review the script

```sh
cd ~/Code/macOS_setup
less ~/Code/macOS_setup/setup.sh
```

Execute the script

```sh
sh setup.sh 2>&1 | tee ~/macOS_setup.log
```
