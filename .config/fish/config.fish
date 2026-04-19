set -U fish_greeting

starship init fish | source
zoxide init fish | source

export SUDO_EDITOR=nvim

fish_add_path ~/.npm-global/bin
fish_add_path ~/.local/bin

abbr --add !! 'eval $history[1] | wl-copy'
abbr --add yz 'yazi'
abbr --add lg 'lazygit'

