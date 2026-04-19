return {
    "saghen/blink.cmp",
    version = "*",

    dependencies = { "nvim-tree/nvim-web-devicons" },

    opts = {
        keymap = { preset = "super-tab" },
        completion = {
            menu = { border = "rounded" },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                window = { border = "rounded" },
            },
        },

        signature = {
            enabled = true,
            window = { border = "rounded" },
        },

        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
    },
}
