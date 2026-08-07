function gd -d "git done: remove current branch and switch to target branch"
    set target_branch $argv[1]

    if test -z "$target_branch"
        if git show-ref --verify --quiet refs/heads/main
            set target_branch "main"
        else if git show-ref --verify --quiet refs/heads/master
            set target_branch "master"
        else
            echo "Error: Please specify the target branch (e.g., gd main)"
            return 1
        end
    end

    set current_branch (git branch --show-current)

    if test -z "$current_branch"
        echo "Error: You are not on any branch (Detached HEAD)"
        return 1
    end

    if test "$current_branch" = "$target_branch"
        echo "Error: Already on branch $target_branch"
        return 1
    end

    set -l stash_sha ""
    set -l dirty (git status --porcelain)
    if test -n "$dirty"
        git stash push --include-untracked --message "gd-autostash: $current_branch"
        if test $status -ne 0
            echo "❌ Failed to stash local changes"
            return 1
        end
        set stash_sha (git rev-parse refs/stash)
        echo "📦 Stashed local changes"
    end

    git switch $target_branch
    if test $status -ne 0
        echo "❌ Failed to switch to $target_branch"
        _gd_pop_stash $stash_sha
        return 1
    end

    git pull origin $target_branch
    if test $status -ne 0
        echo "❌ Failed to pull"
        _gd_pop_stash $stash_sha
        return 1
    end

    git branch -d $current_branch
    if test $status -ne 0
        echo "⚠ Could not safely delete $current_branch (there may be unmerged commits)."
    else
        echo "✅ Done!"
    end

    git fetch --prune

    _gd_pop_stash $stash_sha
end

function _gd_pop_stash -d "gd helper: reapply the stash gd created, identified by commit sha"
    set -l stash_sha $argv[1]

    if test -z "$stash_sha"
        return 0
    end

    set -l ref ""
    for line in (git stash list --format='%gd %H')
        set -l parts (string split ' ' -- $line)
        if test "$parts[2]" = "$stash_sha"
            set ref $parts[1]
            break
        end
    end

    if test -z "$ref"
        echo "⚠ Could not locate the stash $stash_sha; check `git stash list`"
        return 1
    end

    git stash pop $ref
    if test $status -ne 0
        echo "⚠ Failed to reapply the stashed changes (conflicts?). They are kept in $ref"
        return 1
    end

    echo "♻ Restored stashed changes"
end
