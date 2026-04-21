set -U fish_greeting

fish_add_path ~/.local/bin
fish_add_path ~/.npm-global/bin

starship init fish | source
zoxide init fish | source

export SUDO_EDITOR=nvim

abbr --add !! 'eval $history[1] | wl-copy'
abbr --add yz 'yazi'
abbr --add lg 'lazygit'

