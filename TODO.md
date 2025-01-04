# TODO

- Remove much of the python complexity
  - Use a lib/{config,macos,pkg} directory
  - Symlink all of config to ~/.config
  - Keep all of macos as is
  - Move pkg out of folders to single directory
- Move toolchain management to simple toml file:
  - schema will be {install command, update command}

New usage:

sys {config, pkg, macos, edit}

- config update config directory
- pkg update packages from list
- macos update settings
- edit (edit lib directory)
