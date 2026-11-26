function zjrelayout -d "override the active zellij tab with the dev layout rooted at the current directory"
    set -l layout (string replace -r '^layout \{$' "layout {
    cwd \"$PWD\"" < ~/.config/zellij/layouts/dev.kdl | string collect)
    zellij action override-layout --apply-only-to-active-tab --layout-string "$layout"
end
