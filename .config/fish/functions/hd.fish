function hd -d "launch/attach a herdr session for the directory (dev layout on first create; -r rebuilds layout)"
    set -l original_dir (pwd)

    set -l reset 0
    set -l target
    for a in $argv
        switch $a
            case -r --reset
                set reset 1
            case '*'
                set target $a
        end
    end

    if test -n "$target"
        cd $target; or return 1
    end

    set -l dir (pwd)

    set -l session_name (basename "$dir" | string replace -a '.' '-' | string replace -a ' ' '-')
    set session_name (string replace -r -- '^-+' '' $session_name)
    if test "$session_name" = "" -o "$session_name" = "/"
        set session_name root
    end

    set -l exists (herdr session list --json 2>/dev/null \
        | jq -r --arg n "$session_name" '.sessions[] | select(.name == $n) | .name')

    if test -z "$exists"
        set -l sock "$HOME/.config/herdr/sessions/$session_name/herdr.sock"
        setsid herdr --session "$session_name" server >/dev/null 2>&1 &
        disown
        for i in (seq 1 50)
            test -S "$sock"; and break
            sleep 0.1
        end
        if test -S "$sock"
            herdr-dev --session "$session_name" --cwd "$dir"
        else
            echo "hd: cannot find herdr server ($session_name)" >&2
        end
    else if test $reset -eq 1
        herdr-dev --session "$session_name" --cwd "$dir"
    end

    herdr --session "$session_name"
    cd $original_dir
end
