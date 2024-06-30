#!/bin/bash
## Common functions for supported shells (currently bash and ZSH)

source_if_exists() {
    local file
    file="$1"
    if [[ "$file" != /* ]]; then
        file="$HOME/$file"
    fi
    test -f "$file" && source "$file"
}

add_to_path() {
    if [ -d "$1" ]; then
        export PATH="$1${PATH+:$PATH}"
    fi
}

has_cmd() {
    type "$1" &>/dev/null
}

PLATFORM="$(uname)"

is_mac() {
    [[ "$PLATFORM" = "Darwin" ]]
}

macos_pre_big_sur() {
    local vers
    vers="$(sw_vers -productversion)"
    [[ "${vers%%.*}" -lt 11 ]]
}

get_link_target() {
    if is_mac; then
        if has_cmd greadlink; then
            greadlink -f "$1"
        elif macos_pre_big_sur; then
            python3 -c 'import sys;from pathlib import Path;print(Path(sys.argv[1]).resolve())' "$1"
        else
            stat -f '%R' "$1"
        fi
    else
        readlink -f "$1"
    fi
}
