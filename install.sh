#!/bin/sh
set -e

SCRIPT_URL="https://github.com/linuxdaemon/dotfiles/raw/refs/heads/master/scripts/chezmoi-install.sh"

sh -c "$(curl -fsLS $SCRIPT_URL)" -- init --apply linuxdaemon
