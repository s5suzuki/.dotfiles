function hd -d "launch/attach a herdr session for the directory (dev layout on first create)"
    set -l original_dir (pwd)

    if test (count $argv) -gt 0
        cd $argv[1]; or return 1
    end

    set -l session_name (basename (pwd) | string replace -a '.' '-' | string replace -a ' ' '-')
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
        for _ in (seq 1 50)
            test -S "$sock"; and break
            sleep 0.1
        end
        if test -S "$sock"
            herdr-dev --session "$session_name"
        else
            echo "hd: cannot find herdr server ($session_name)" >&2
        end
    end

    herdr --session "$session_name"
    cd $original_dir
end
