function wt -d "create a git worktree for BRANCH and open it in a new zellij tab (cd outside zellij)"
    set -l branch $argv[1]
    if test -z "$branch"
        echo "usage: wt <branch>"
        return 1
    end

    set -l common_dir (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "wt: not a git repository"
        return 1
    end
    set -l main_root (path dirname $common_dir)
    set -l repo (path basename $main_root)
    set -l dir (path dirname $main_root)/$repo.worktrees/(string replace -a / - -- $branch)

    if not test -d $dir
        if git show-ref --verify --quiet refs/heads/$branch
            git worktree add $dir $branch
        else if git show-ref --verify --quiet refs/remotes/origin/$branch
            git worktree add --track -b $branch $dir origin/$branch
        else
            git worktree add -b $branch $dir
        end
        or return 1
    end

    if set -q ZELLIJ
        zellij action new-tab --layout dev --cwd $dir >/dev/null
        and zellij action rename-tab $branch
    else
        cd $dir
    end
end
