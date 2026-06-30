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

    git switch $target_branch
    if test $status -ne 0
        echo "❌ Failed to switch to $target_branch"
        return 1
    end

    git pull origin $target_branch
    if test $status -ne 0
        echo "❌ Failed to pull"
        return 1
    end

    git branch -d $current_branch
    if test $status -ne 0
        echo "⚠ Could not safely delete $current_branch (there may be unmerged commits)."
    else
        echo "✅ Done!"
    end

    git fetch --prune
end

