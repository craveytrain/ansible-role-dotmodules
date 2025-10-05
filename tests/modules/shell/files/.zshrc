# Shell configuration
# This file is deployed via GNU Stow

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias ll='exa -la'
alias la='exa -a'
alias ls='exa'
alias cat='bat'
alias grep='rg'
alias find='fd'

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Starship prompt
eval "$(starship init zsh)"
