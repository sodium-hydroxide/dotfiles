#!/bin/sh

sudo mkdir -p /opt/homebrew
sudo chown -R "$(whoami):admin" /opt/homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
