function zjls
    zellij ls | fzf --ansi \
        --bind 'j:down,k:up' \
        --bind 'q:execute(zellij kill-session {1} >/dev/null 2>&1)+reload(zellij ls)' \
        --bind 'd:execute(zellij delete-session {1} >/dev/null 2>&1)+reload(zellij ls)' \
        --header 'j/k: Select | q: Kill | d: Delete | ESC/Ctrl-c: Exit'
end
