# sodium-hydroxide dotfiles

The following are the dotfiles, scripts, and package lists for my computer.
This setup assumes the mac is being used.

## bin

This directory contains utility scripts which are on the PATH. These include
compressing and decompressing files as well as updating the system. The update
script is a python script which assumes at least python 3.9. This (along with
curl and other utilities) can be installed with the following command:

```sh
xcode-select –-install
```

Then running `python3 ~/dotfiles/bin/update` should install `homebrew`, `uv`,
`rustup`, and then use `gnu-stow` to move the dotfiles to their correct
locations. Additionally, any tools within the `package-list` directory will be
installed.

## package-list

This currently contains a `Brewfile` for packages installed via `homebrew`,
a `pyproject.toml` for utilities which should be in the global python
environment (`~/.local/.venv/bin/`), and `tool-list.txt` which are tools for
`uv` to install globally.

## Other Dotfiles

The majority of the dotfiles are stored under `config-misc/.config` which gets
stowed to `~/.config/`. Configuration for `git`, `neovim`, and the shell are in
their own directories.

The `shell` directory contains the `.profile` which sources scripts to set the
`$PATH` and other environment variables. There is also the environment variables
`$LOGIN_SHELL` and `$INTERACTIVE_SHELL`. When the shell is interactive, it will
drop into `$INTERACTIVE_SHELL`. It is advised that `$LOGIN_SHELL` is a POSIX
complient shell, such as `sh` or `dash`. It is alright if `bash` is used, but as
it is a superset of `sh`, but it may be slower for certain scripts.
