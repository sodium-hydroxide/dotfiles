#!/usr/bin/env bash

BASH_CONFIG="${HOME}/.config/bash"
source "${BASH_CONFIG}/env.d/standard.sh"   # standard environment variables
source "${BASH_CONFIG}/env.d/dev.sh"        # development environment variables
source "${BASH_CONFIG}/env.d/PATH.sh"       # PATH Variable
source "${BASH_CONFIG}/alias.sh"            # Aliases
source "${BASH_CONFIG}/interactive.sh"      # Prompts

