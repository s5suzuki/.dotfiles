return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 300,
		win = {
			border = "rounded",
		},
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "全てのキーバインドを表示",
		},
	},
}
