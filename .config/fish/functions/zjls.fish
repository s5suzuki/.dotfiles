function zjls
    zellij ls | fzf --ansi \
        --bind 'j:down,k:up' \
        --bind 'q:execute(zellij kill-session {1} >/dev/null 2>&1)+reload(zellij ls)' \
        --bind 'd:execute(zellij delete-session {1} >/dev/null 2>&1)+reload(zellij ls)' \
        --bind 'enter:become(zellij attach {1})' \
        --header 'j/k: Select | q: Kill | d: Delete | Enter: Attach | ESC/Ctrl-c: Exit'

    # fzf: 1 = no match, 130 = aborted (ESC/Ctrl-c). Neither is an error here.
    set -l fzf_status $status
    switch $fzf_status
        case 1 130
            return 0
    end
    return $fzf_status
end
