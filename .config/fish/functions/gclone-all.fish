function gclone-all -d "git clone + every remote branch as a local branch + pull --all (for backup)"
    set -l url $argv[1]
    set -l dir $argv[2]
    if test -z "$url"
        echo "Usage: gclone-all <url> [dir]"
        return 1
    end
    test -n "$dir"; or set dir (basename $url .git)

    git clone $url $dir; or return 1

    for b in (git -C $dir for-each-ref --format='%(refname:strip=3)' refs/remotes/origin)
        test "$b" = HEAD; and continue
        git -C $dir show-ref --verify --quiet refs/heads/$b; and continue
        git -C $dir branch --track $b origin/$b >/dev/null; or return 1
    end

    git -C $dir fetch --all --tags; or return 1
    git -C $dir pull --all; or return 1

    if test -n "$(git -C $dir log --all -S filter=lfs --format=%h -- .gitattributes)"
        if command -q git-lfs
            git -C $dir lfs fetch --all; or return 1
        else
            echo "⚠ $dir uses Git LFS but git-lfs is not installed: LFS files are NOT backed up"
            return 1
        end
    end

    echo "✅ "(git -C $dir branch | count)" local branches in $dir"
end
