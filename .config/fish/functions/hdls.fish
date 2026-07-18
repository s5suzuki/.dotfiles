function hdls -d "herdr session picker (fzf): Enter=attach, q=stop, d=delete"
    herdr-sessions | fzf --ansi \
        --bind 'j:down,k:up' \
        --bind 'q:execute(herdr session stop {1} >/dev/null 2>&1)+reload(herdr-sessions)' \
        --bind 'd:execute(herdr session delete {1} >/dev/null 2>&1)+reload(herdr-sessions)' \
        --bind 'enter:become(herdr session attach {1})' \
        --header 'j/k: Select | q: Stop | d: Delete | Enter: Attach | ESC/Ctrl-c: Exit'
end
