macOS Setup
===========

A shell script to setup and configure a new computer running macOS.

This script is influenced, inspired, and in part copied from Mathias Bynens' [dotfiles] scripts and the Thoughtbot [Laptop] script.

[dotfiles]: https://github.com/mathiasbynens/dotfiles
[Laptop]: https://github.com/thoughtbot/laptop


Usage
-----

Download the script:

```sh
curl -L https://github.com/mphstudios/macOS_setup/raw/master/setup.sh
```

Review the script:

```sh
less setup
```

Execute the script:

```sh
sh setup 2>&1 | tee ~/macOS_setup.log
```

