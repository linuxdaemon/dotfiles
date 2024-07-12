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
        add_to_path_always "$1"
    fi
}

add_to_path_always() {
    export PATH="$1${PATH+:$PATH}"
}

has_cmd() {
    type "$1" &>/dev/null
}

vscode_wait() {
    code --wait $*
}

todo() {
    $EDITOR "$HOME/Documents/todo.md"
}
