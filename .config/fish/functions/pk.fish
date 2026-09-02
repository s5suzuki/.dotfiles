function pk -d "process picker (fzf): Enter=SIGTERM, Ctrl-X=SIGKILL, Tab=multi select"
    set -l lister
    if command -q procs
        set lister "procs --no-header --pager disable --color always"
    else
        set lister "command ps -eo pid,user,pcpu,pmem,etime,args --sort=-pcpu"
    end

    set -l selected (eval $lister | fzf --ansi --multi \
        --query "$argv" \
        --expect ctrl-x \
        --bind "ctrl-r:reload($lister)" \
        --bind 'ctrl-a:toggle-all' \
        --preview 'ps -o pid=,ppid=,user=,stat=,etime= -p {1} 2>/dev/null; ps -o args= -p {1} 2>/dev/null' \
        --preview-window 'down,4,wrap' \
        --header 'Tab: Mark | Enter: SIGTERM | Ctrl-X: SIGKILL | Ctrl-R: Reload | ESC: Exit')

    set -l fzf_status $status
    switch $fzf_status
        case 0
        case 1 130
            return 0
        case '*'
            return $fzf_status
    end

    set -l signal TERM
    test "$selected[1]" = ctrl-x; and set signal KILL

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
