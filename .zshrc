# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

DOTFILE_CONFIG="$HOME/.config/dotfiles/repo_path"

if [ -r "$DOTFILE_CONFIG" ]; then
    DOTFILE_REPO="$(< "$DOTFILE_CONFIG")"
else
    DOTFILE_REPO=""
    echo "Failed to locate dotfile config, please re-run 'bin/dotfiles setup'" >&2
    exit 1
fi

source "$DOTFILE_REPO/lib/common/functions.sh"

brew_get_formula_path() {
    formula="$1"
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

add_homebrew() {
    local path="$1"
    local arch="$2"
    local alias_name="$3"
    if [ -n "$alias_name" ]; then
        alias ibrew="arch -x86_64 $path"
    fi
    eval "$($path shellenv zsh)"
    FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions${FPATH+:$FPATH}"
}

add_ibrew() {
    if [ -x "$ibrew_bin" ]; then
        alias ibrew="arch -x86_64 $ibrew_bin"
        eval "$(ibrew shellenv zsh)"
        FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions${FPATH+:$FPATH}"
    fi
}

add_mbrew() {
    if [ -x "$mbrew_bin" ]; then
        alias mbrew="arch -arm64e $mbrew_bin"
        eval "$(mbrew shellenv zsh)"
        FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions${FPATH+:$FPATH}"
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

    asdf_path="$(brew_get_formula_path asdf || echo "none")"
    if [[ "$asdf_path" != "none" ]]; then
        source_if_exists "$asdf_path/libexec/asdf.sh"
    fi
    unset asdf_path
fi

brew_add_formula_bin "postgresql@15"

source_if_exists ".iterm2_shell_integration.zsh"

add_to_path "$HOME/Library/Python/3.9/bin"
add_to_path "$HOME/.local/bin"

# We finished init, set up completions
autoload -Uz compinit
compinit

add_to_path "$DOTFILE_REPO/bin"
