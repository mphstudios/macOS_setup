## Homebrew bundles

[Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) files for Homebrew packages, Homebrew Cask applications, and Mac App Store applications.

Bundle files are read by the macOS setup [`install_homebrew_bundles`](/functions/homebrew.sh) function.

### Generating Homebrew bundle files

To generate a base Brewfile run the following commands:

```sh
brew tap | sed "s/^.*/tap '&'/" > Brewfile
brew leaves | sed "s/^.*/brew '&'/" >> Brewfile
```

To generate a Brewfile listing all installed packages, casks, and dependecies,
run `brew bundle dump -f > Brewfile`.

A brewfile can also be used to uninstall all Homebrew formulae not listed in the brewfile by using the `brew bundle cleanup` command.

Running `brew leaves` will show installed formulae that are not dependencies
of another installed formula.
