function n
    set -l socket "/tmp/nvim-$ZELLIJ_SESSION_NAME"
    set -l target $argv[1]

    if test -z "$ZELLIJ_SESSION_NAME"; or not test -S "$socket"
        set -l sockets (ls -t /tmp/nvim-* 2>/dev/null)
        if test (count $sockets) -gt 0
            set socket $sockets[1]
            set -gx ZELLIJ_SESSION_NAME (string replace "/tmp/nvim-" "" $socket)
        end
    end

    set -l parts (string split ":" $target)
    set -l file $parts[1]
    set -l line $parts[2]
    set -l col $parts[3]

    if test -S $socket
        if test -n "$line"
            if test -n "$col"
                nvim --server $socket --remote-send "<C-\><C-n>:e $file | call cursor($line, $col)<CR>"
            else
                nvim --server $socket --remote-send "<C-\><C-n>:e $file | $line<CR>"
            end
        else
            nvim --server $socket --remote $file
        end
        zellij --session "$ZELLIJ_SESSION_NAME" action focus-next-pane 2>/dev/null
    else
        if test -n "$line"
            if test -n "$col"
                command nvim "+call cursor($line, $col)" $file
            else
                command nvim "+$line" $file
            end
        else
            command nvim $file
        end
    end
end
