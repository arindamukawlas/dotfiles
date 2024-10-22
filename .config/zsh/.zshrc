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
	export HOST_IP_ADDRESS=$(\
	  /mnt/c/Windows/System32/ipconfig.exe | \
	  grep -m1 IPv4 | tr " " "\n" | grep 192.168. | tr -d "\r")
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

fpath+=($ZDOTDIR/functions $ZDOTDIR/completions)
autoload -Uz $ZDOTDIR/functions/**/*
autoload -Uz $ZDOTDIR/completions/**/*

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
setopt GLOB_COMPLETE     
setopt MENU_COMPLETE    
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END  
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
setopt EXTENDED_GLOB
unsetopt FLOW_CONTROL
unsetopt BEEP

LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;\
01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}

# Plugins
export ZPLUGINDIR="$XDG_DATA_HOME/zsh/plugins"
repos=(
  romkatv/zsh-defer
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions
)

# Load Completion
zmodload zsh/complist
autoload -Uz compinit 
for dump in ~/.zcompdump(N.mh+24); do
  compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"
done
compinit -C -d "$XDG_CACHE_HOME/zsh/.zcompdump"

# Include hidden files
_comp_options+=(globdots)

zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*' complete true
zstyle ':completion:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{yellow}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{blue}-- %D %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' complete-options true
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:-command-:*:*' group-order aliases functions commands builtins 
zstyle ':completion:*:*:-command-:*:*' ignored-patterns '*.dll' '*.mof' '*.nls' '*.msc'

# Prompt 
RPROMPT=""
PROMPT="%F{green}%~ %F{blue}>%f "

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

# Repair terminal if previous command broke it
function reset_broken_terminal () {
  printf "%b" "\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8"
}
add-zsh-hook -Uz precmd reset_broken_terminal

# Setup help
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help
autoload -Uz run-help-git run-help-sudo

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
exit-zsh() { exit }
zle -N exit-zsh
bindkey "^D" exit-zsh

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
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border --inline-info"
source <(fzf --zsh)

# Setup cargo
. "/home/habanero/.local/share/cargo/env"

# Setup deno
. "/home/habanero/.local/share/deno/env"

plugin-load $repos 
