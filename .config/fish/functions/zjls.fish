function zjls
    set -l sel (zellij ls | fzf --ansi \
        --bind 'j:down,k:up' \
        --bind 'q:execute(zellij kill-session {1} >/dev/null 2>&1)+reload(zellij ls)' \
        --bind 'd:execute(zellij delete-session {1} >/dev/null 2>&1)+reload(zellij ls)' \
        --header 'j/k: Select | q: Kill | d: Delete | Enter: Attach | ESC/Ctrl-c: Exit')

    # fzf: 1 = no match, 130 = aborted (ESC/Ctrl-c). Neither is an error here.
    set -l fzf_status $status
    switch $fzf_status
        case 0
        case 1 130
            return 0
        case '*'
            return $fzf_status
    end

    set -l name (string replace -ra '\e\[[0-9;]*m' '' -- $sel | string split -f1 ' ')

    set -l dbs ~/.cache/zellij/*/session_index.sqlite
    set -l session_cwd
    if test -n "$dbs[1]"
        set -l quoted (string replace -a "'" "''" -- $name)
        set session_cwd (sqlite3 -readonly $dbs[-1] "select folder from sessions where name = '$quoted'" 2>/dev/null)[1]
    end

    set -l original_dir (pwd)
    test -n "$session_cwd" -a -d "$session_cwd"; and cd $session_cwd
    zellij attach $name --force-run-commands
    cd $original_dir
end
