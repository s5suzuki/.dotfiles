function wtls -d "git worktree picker (fzf): d=remove, D=force remove (discard changes)"
    set -l current (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wtls: not a git repository"
        return 1
    end

    set -l list_cmd "git worktree list | tail -n +2 | grep -vF -- '$current '"
    set -l pause_on_error '|| read -rsn1 -p "press any key to continue"'
    eval $list_cmd | fzf --with-shell 'bash -c' \
        --bind 'j:down,k:up' \
        --bind "d:execute(git worktree remove {1} $pause_on_error)+reload($list_cmd)" \
        --bind "D:execute(git worktree remove --force {1} $pause_on_error)+reload($list_cmd)" \
        --header 'j/k: Select | d: Remove | D: Force remove | ESC/Ctrl-c: Exit'

    set -l fzf_status $status
    switch $fzf_status
        case 0 1 130
            return 0
    end
    return $fzf_status
end
