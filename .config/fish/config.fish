set -U fish_greeting

fish_add_path ~/.local/bin
fish_add_path ~/.npm-global/bin

starship init fish | source
zoxide init fish | source
atuin init fish | source

fish_vi_key_bindings

set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block

function __fish_vi_fcitx_off --on-variable fish_bind_mode
    if test "$fish_bind_mode" != "insert"
        command -q fcitx5-remote; and fcitx5-remote -c
    end
end

function fish_user_key_bindings
    bind -M insert j __fish_vi_escape_j
    bind -M insert k __fish_vi_escape_k

    for mode in default visual
        bind -M $mode gh beginning-of-line
        bind -M $mode gl end-of-line
    end
    bind -M operator gh 'fish_vi_exec_motion beginning-of-line'
    bind -M operator gl 'fish_vi_exec_motion end-of-line'

    bind -M visual \ck 'set -g fish_bind_mode default; commandline -f force-repaint'

    bind -M insert \cl accept-autosuggestion

    bind -M default k _atuin_search
end

function __fish_vi_escape_j
    set -l cursor (commandline -C)
    if test $cursor -gt 0
        set -l cmd (commandline -b)
        set -l last_char (string sub -s $cursor -l 1 -- "$cmd")
        if test "$last_char" = "j" -o "$last_char" = "っ"
            commandline -f backward-delete-char
            set -g fish_bind_mode default
            commandline -f force-repaint
            return
        end
    end
    commandline -i j
end

function __fish_vi_escape_k
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
    commandline -i k
end

export SUDO_EDITOR=nvim

abbr --add !! 'eval $history[1] | wl-copy'
abbr --add yz 'yazi'
abbr --add lg 'lazygit'
abbr --add ga 'git commit --amend -m'

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
alias clip='wl-copy'

fish_config theme choose catppuccin-mocha

if test -f ~/.config/fish/local-config.fish
    source ~/.config/fish/local-config.fish
end
