#!/bin/bash
PATH="\
$HOME/.venv/bin:\
$HOME/.MCNP/mcnparse/bin:\
$HOME/.MCNP/mcnp63/exec/mcnp-6.3.0-Darwin/bin:\
$HOME/.MCNP/mcnp63/exec/mcnp-6.3.0-Qt-preview-Darwin/bin:\
$HOME/.bin:\
$(brew --prefix tcl-tk)/bin:\
$HOME/.local/bin:\
$CARGO_HOME/bin:\
$HOME/.juliaup/bin:\
/opt/homebrew/opt/openjdk/bin:\
/opt/homebrew/opt/julia/bin:\
$(npm config get prefix 2>/dev/null)/bin:\
$HOME/dotfiles/bin:\
/opt/homebrew/bin:\
/opt/homebrew/sbin:\
/usr/local/bin:\
/usr/local/sbin:\
/usr/bin:\
/usr/sbin:\
/bin:\
/sbin:\
/Library/Apple/usr/bin:\
/System/Cryptexes/App/usr/bin:\
/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:\
/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:\
/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\
"

export PATH

