function pk -d "process picker (fzf)"
    set -l lister
    if command -q procs
        set lister "procs --no-header --pager disable --color always"
    else
        set lister "command ps -eo pid,user,pcpu,pmem,etime,args --sort=-pcpu"
    end

    set -l normal_only_keys j k g G v x q p r i a / space ctrl-d ctrl-u
    set -l enter_insert_keys "unbind("(string join , $normal_only_keys)")"
    set -l enter_normal_keys "rebind("(string join , $normal_only_keys)")"

    set -l prompt_insert 'INSERT ❯ '
    set -l prompt_normal 'NORMAL ❯ '
    set -l header_insert '-- INSERT --  ESC: NORMAL | Tab: mark | Enter: SIGTERM | C-x: SIGKILL | C-r: reload'
    set -l header_normal '-- NORMAL --  j/k: move | g/G: top/bottom | space: mark | i or /: INSERT | x: SIGKILL | Enter: SIGTERM | q: quit'

    set -l enter_insert "$enter_insert_keys+change-prompt($prompt_insert)+change-header($header_insert)"
    set -l enter_normal "$enter_normal_keys+change-prompt($prompt_normal)+change-header($header_normal)"

    set -l selected (eval $lister | fzf --ansi --multi --layout reverse \
        --with-shell 'sh -c' \
        --query "$argv" \
        --prompt "$prompt_normal" \
        --header "$header_normal" \
        --bind "esc:transform{ if [ \"\$FZF_PROMPT\" = \"$prompt_normal\" ]; then echo abort; else echo \"$enter_normal\"; fi }" \
        --bind "i:$enter_insert" \
        --bind "a:$enter_insert" \
        --bind "/:clear-query+$enter_insert" \
        --bind 'j:down' \
        --bind 'k:up' \
        --bind 'g:first' \
        --bind 'G:last' \
        --bind 'ctrl-d:half-page-down' \
        --bind 'ctrl-u:half-page-up' \
        --bind 'space:toggle+down' \
        --bind 'v:toggle' \
        --bind 'q:abort' \
        --bind 'p:toggle-preview' \
        --bind 'x:print(KILL)+accept' \
        --bind 'enter:print(TERM)+accept' \
        --bind 'ctrl-x:print(KILL)+accept' \
        --bind "r:reload($lister)" \
        --bind "ctrl-r:reload($lister)" \
        --bind 'ctrl-a:toggle-all' \
        --preview 'ps -o pid=,ppid=,user=,stat=,etime= -p {1} 2>/dev/null; ps -o args= -p {1} 2>/dev/null' \
        --preview-window 'down,4,wrap')

    set -l fzf_status $status
    switch $fzf_status
        case 0
        case 1 130
            return 0
        case '*'
            return $fzf_status
    end

    set -l signal $selected[1]
    contains -- $signal TERM KILL; or set signal TERM

    set -l failed 0
    for line in $selected[2..-1]
        set -l pid (string match -rg '^\s*(\d+)' -- $line)
        test -n "$pid"; or continue

        set -l name (command ps -o comm= -p $pid 2>/dev/null | string trim)
        if kill -$signal $pid 2>/dev/null
            echo "pk: SIG$signal -> $pid $name"
        else
            echo "pk: failed to signal $pid $name" >&2
            set failed 1
        end
    end

    return $failed
end
