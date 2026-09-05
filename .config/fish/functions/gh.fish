function gh --wraps gh --description 'gh with per-repository account switching'
    if test "$argv[1]" = auth
        command gh $argv
        return $status
    end

    if set -q GH_TOKEN; or set -q GITHUB_TOKEN
        command gh $argv
        return $status
    end

    set -l user (command git config --get gh.user 2> /dev/null)
    if test -z "$user"
        command gh $argv
        return $status
    end

    set -l token (command gh auth token --user $user 2> /dev/null)
    if test -z "$token"
        command gh $argv
        return $status
    end

    GH_TOKEN=$token command gh $argv
end
