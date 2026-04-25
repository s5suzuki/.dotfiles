set -U fish_greeting

fish_add_path ~/.local/bin
fish_add_path ~/.npm-global/bin

starship init fish | source
zoxide init fish | source

export SUDO_EDITOR=nvim

abbr --add !! 'eval $history[1] | wl-copy'
abbr --add yz 'yazi'
abbr --add lg 'lazygit'

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat'
alias top='btm'
alias find='fd'
alias grep='rg'
alias ps='procs'
alias du='dust'
alias sed='sd'

fish_config theme choose catppuccin-mocha
