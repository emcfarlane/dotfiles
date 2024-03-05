# prompt
GIT_PS1_SHOWDIRTYSTATE="true"
GIT_PS1_SHOWSTASHSTATE="true"
GIT_PS1_SHOWUNTRACKEDFILES="true"
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS="true"
setopt prompt_subst
. ~/src/github.com/git/git/contrib/completion/git-prompt.sh
export RPROMPT=$'$(__git_ps1 "%s")'

COLOR_DEF=$'%f'
COLOR_USR=$'%F{243}'
COLOR_DIR=$'%F{74}'
setopt PROMPT_SUBST
export PROMPT='${COLOR_USR}%n ${COLOR_DIR}%~${COLOR_DEF} %# '

# man zshmisc
export HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
export HISTSIZE=10000 # Maximum events for internal history
export SAVEHIST=10000 # Maximum events in history file

export EDITOR="nvim"
export VISUAL="nvim"

# ignore <C-d> (EOF), force logout with `exit`
setopt ignoreeof

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
source ~/src/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/src/github.com/zsh-users/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# completions
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Use-of-compinit
autoload -U compinit; compinit -d ~/.cache/.zcompdump

export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# Aliases
alias l='ls -lFh'          #size,show type,human readable
alias -g ...='../..'
alias -g ....='../../..'
alias vim='nvim'

