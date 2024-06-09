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
COLOR_DIR=$'%F{243}'
setopt PROMPT_SUBST
export PROMPT='%B${COLOR_DIR}%~${COLOR_DEF} %#%b '

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

# vi mode on ESC, edit command line with `v` in normal mode
bindkey -v
export KEYTIMEOUT=1
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
# extend vi mode capabilities e.g. da" deletes everything inside quotes
# https://thevaluable.dev/zsh-install-configure-mouseless/
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done
# extend vi mode capabilities e.g.
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

# completions
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Use-of-compinit
autoload -U compinit; compinit -d ~/.cache/.zcompdump

export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# Aliases
alias l='ls -lFh'          #size,show type,human readable
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias vim='nvim'

