#!/usr/bin/env bash
set -e

REPO_DIR="$(dirname "$0")"

"$REPO_DIR/bin/dotfiles" setup
