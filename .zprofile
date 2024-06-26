DOTFILE_CONFIG="$HOME/.config/dotfiles/repo_path"

if [ -r "$DOTFILE_CONFIG" ]; then
    export DOTFILE_REPO="$(< "$DOTFILE_CONFIG")"
else
    export DOTFILE_REPO=""
    echo "Failed to locate dotfile config, please re-run 'bin/dotfiles setup'" >&2
    exit 1
fi

source "$DOTFILE_REPO/lib/common/functions.sh"

brew_get_formula_path() {
    local formula="$1"
    if ! has_cmd brew; then
        return 1
    fi

    brew --prefix --installed "$formula" 2>/dev/null && return 0
    has_cmd mbrew && mbrew --prefix --installed "$formula" 2>/dev/null && return 0
    has_cmd ibrew && ibrew --prefix --installed "$formula" 2>/dev/null && return 0
    return 1
}

brew_add_formula_bin() {
    if ! has_cmd brew; then
        return
    fi

    local formula_path="$(brew_get_formula_path "$1" || echo "none")"

    if [[ "$formula_path" != "none" ]]; then
        add_to_path "$formula_path/bin"
    fi
}

ARCH="$(uname -m)"

is_arm() {
    [[ "$ARCH" = "arm64" ]]
}

# Apple Silicon default brew path
mbrew_bin="/opt/homebrew/bin/brew"

# Intel default brew path
ibrew_default_bin="/usr/local/bin/brew"

# Alternate install location for x86 brew on Apple Silicon mac
ibrew_alt_bin="/usr/local/homebrew/bin/brew"

if [ -x "$ibrew_default_bin" ]; then
    ibrew_bin= "$ibrew_default_bin"
else
    ibrew_bin="$ibrew_alt_bin"
fi

add_ibrew() {
    if [ -x "$ibrew_bin" ]; then
        alias ibrew="arch -x86_64 $ibrew_bin"
        eval "$(ibrew shellenv zsh)"
        export FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions${FPATH+:$FPATH}"
    fi
}

add_mbrew() {
    if [ -x "$mbrew_bin" ]; then
        alias mbrew="arch -arm64e $mbrew_bin"
        eval "$(mbrew shellenv zsh)"
        export FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions${FPATH+:$FPATH}"
    fi
}

if is_arm; then
    add_ibrew
    add_mbrew
else
    add_ibrew
fi

unset ibrew_bin mbrew_bin ibrew_default_bin mbrew_default_bin

if has_cmd brew; then
    gcloud_dir="$HOMEBREW_PREFIX/share/google-cloud-sdk"
    source_if_exists "$gcloud_dir/path.zsh.inc"
    source_if_exists "$gcloud_dir/completion.zsh.inc"
    unset gcloud_dir
fi

source_if_exists "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"

add_to_path "$HOME/Library/Python/3.9/bin"
add_to_path "$HOME/.local/bin"
add_to_path "$DOTFILE_REPO/bin"
