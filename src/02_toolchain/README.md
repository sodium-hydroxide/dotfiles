## Toolchain Setup

These are tools for installing and updating the following toolchains:

- `julia` managed via `juliaup`
- `node.js` managed by `nvm`
- `python` managed by `uv`
- `rust` managed by `rustup`

The main language specific scripts will install the respective programs and 
install several important utilities. In the case of `uv`, a virtual environment
is created in the home directory with several system wide utilities. The main
use is the update command with will update the respective languages.

This script also has the tool to update `bash` to the newest version from
homebrew. The original `/bin/bash` is copied to `/bin/bash.bak` and the newest 
version is made the login shell.

