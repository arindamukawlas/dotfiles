# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/run/user/$UID"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# History
HISTFILE=$XDG_DATA_HOME/zsh/history
HISTSIZE=5000
SAVEHIST=5000

# Man pages
export MANPAGER="nvim +Man!"

# WSL-only
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	# Get IP address of host
	export HOST_IP_ADDRESS=$(/mnt/c/Windows/System32/ipconfig.exe | grep 192.168. | grep -m1 IPv4 | awk "{print $14}" | tr -d "\r")
fi

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
export PYTHON_HISTORY="$XDG_STATE_HOME"/python_history
export OPAMROOT="$XDG_DATA_HOME/opam"
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
export NVM_DIR="$XDG_DATA_HOME"/nvm
export DENO_DIR="$XDG_DATA_HOME/deno"
export DENO_INSTALL_ROOT="$DENO_DIR/bin"
export DENO_REPL_HISTORY="$DENO_DIR/history"

# Auto remove duplicates
typeset -U path PATH fpath

path=(
  /usr/local/bin
  ~/.local/bin
  $path
)
export PATH

fpath+=$ZDOTDIR/functions
autoload -Uz $ZDOTDIR/functions/**/*

# Aliases
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget/history"
alias ls="ls --color=auto"
alias dir="dir --color=auto"
alias vdir="vdir --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias la="ls -A"
alias cd="z"
alias bat="batcat"

# Options
setopt HIST_SAVE_NO_DUPS

# Plugins
export ZPLUGINDIR="$XDG_DATA_HOME/zsh/plugins"
repos=(
  romkatv/zsh-defer
  zsh-users/zsh-completions
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions
)
plugin-load $repos 

# Load Completion
zmodload zsh/complist
autoload -Uz compinit promptinit
compinit
promptinit

# Include hidden files
_comp_options+=(globdots)

zstyle ":completion:*" menu select

# Prompt 
export RPROMPT=""
export PROMPT="%F{green}%~ %F{blue}>%f "

# Vi Mode
bindkey -v
export KEYTIMEOUT=1
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
bindkey -M $km -- "-" vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-"()[]{}<>bB"}; do
    bindkey -M $km $c select-bracketed
  done
done
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "l" vi-forward-char
bindkey -M menuselect "j" vi-down-line-or-history


autoload -Uz add-zsh-hook

# Repair terminal if previous program broke it
function reset_broken_terminal () { printf "%b" "\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8" }
add-zsh-hook -Uz precmd reset_broken_terminal

# Setup help
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help
autoload -Uz run-help-git run-help-ip run-help-sudo

# Add title
function xterm_title_precmd () {
	print -Pn -- "\e]2;%~\a"
}
function xterm_title_preexec () {
	print -Pn -- "\e]2;%~ %# " && print -n -- "${(q)1}\a"
}
add-zsh-hook -Uz precmd xterm_title_precmd
add-zsh-hook -Uz preexec xterm_title_preexec

# Fix exiting with Ctrl-D
exit_zsh() { exit }
zle -N exit_zsh
bindkey "^D" exit_zsh

# Fix clearing screen with Ctrl-L
function clear-screen-and-scrollback() {
    printf "\x1Bc"
    zle clear-screen
}
zle -N clear-screen-and-scrollback
bindkey "^L" clear-screen-and-scrollback


# Setup zoxide completions
eval "$(zoxide init zsh)"

# Setup FZF
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border --inline-info"

# Setup cargo
. "/home/habanero/.local/share/cargo/env"

# Setup deno
. "/home/habanero/.local/share/deno/env"
