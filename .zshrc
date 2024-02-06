# prompt
COLOR_DEF=$'%f'
COLOR_USR=$'%F{243}'
COLOR_DIR=$'%F{197}'
setopt PROMPT_SUBST
export PROMPT='${COLOR_USR}%n ${COLOR_DIR}%~${COLOR_DEF} %# '
# git prompt
GIT_PS1_SHOWDIRTYSTATE="true"
GIT_PS1_SHOWSTASHSTATE="true"
GIT_PS1_SHOWUNTRACKEDFILES="true"
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS="true"
setopt prompt_subst
. ~/src/github.com/git/git/contrib/completion/git-prompt.sh
export RPROMPT=$'$(__git_ps1 "%s")'

# man zshmisc
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

export EDITOR="nvim"
export VISUAL="nvim"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
source ~/src/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/src/github.com/zsh-users/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

autoload -U compinit; compinit # completions

export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# Aliases
alias l='ls -lFh'          #size,show type,human readable
alias -g ...='../..'
alias -g ....='../../..'

