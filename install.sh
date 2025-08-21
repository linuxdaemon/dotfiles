#!/usr/bin/env bash
set -euo pipefail

SCRIPT_URL="https://github.com/linuxdaemon/dotfiles/raw/refs/heads/master/scripts/chezmoi-install.sh"

sh -c "$(curl -fsLS $SCRIPT_URL)" -- init --apply linuxdaemon
