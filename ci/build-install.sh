#!/usr/bin/env bash
set -euo pipefail

# Vendor the install script to ensure upstream changes don't break anything
curl -fsLS -o scripts/chezmoi-install.sh https://get.chezmoi.io
chmod +x scripts/chezmoi-install.sh
