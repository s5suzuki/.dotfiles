function zj -d "launch zellij in the specified directory"
    set -l original_dir (pwd)

    if test (count $argv) -gt 0
        cd $argv[1]
    end

    set -l session_name (basename (pwd) | string replace -a '.' '-' | string replace -a ' ' '-')
    
    set session_name (string replace -r -- '^-+' '' $session_name)

    if test "$session_name" = "" -o "$session_name" = "/"
        set session_name "root"
    end

    zellij --layout dev attach -c "$session_name"

    cd $original_dir
end
