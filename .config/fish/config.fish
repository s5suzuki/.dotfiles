set -U fish_greeting

fish_add_path ~/.local/bin
fish_add_path ~/.npm-global/bin

starship init fish | source
zoxide init fish | source
atuin init fish | source

fish_vi_key_bindings

function fish_user_key_bindings
    bind -M insert j __fish_jj_binding
    bind -M default k _atuin_search
end

function __fish_jj_binding
    set -l cursor (commandline -C)
    if test $cursor -gt 0
        set -l cmd (commandline -b)
        set -l last_char (string sub -s $cursor -l 1 -- "$cmd")
        if test "$last_char" = "j"
            commandline -f backward-delete-char
            set -g fish_bind_mode default
            commandline -f force-repaint
            return
        end
    end
    commandline -i j
end

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
alias start='xdg-open'

fish_config theme choose catppuccin-mocha
