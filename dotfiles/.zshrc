eval "$(/opt/homebrew/bin/brew shellenv)"

HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_DUPS SHARE_HISTORY AUTO_CD INTERACTIVE_COMMENTS

autoload -Uz compinit
compinit

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

alias gst="git status"
alias gb="git branch"
alias gco="git checkout"
alias gc="git commit"
alias gd="git diff"
alias gp="git push"
alias gl="git pull"

# `uv` needs this.
export PATH="$HOME/.local/bin:$PATH"
