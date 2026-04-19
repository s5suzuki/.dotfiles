return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		ft = { "markdown" },
		opts = {
			heading = { enabled = false },
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
		},
	},
	{
		"toppair/peek.nvim",
		event = { "VeryLazy" },

		build = "deno task --quiet build",
		config = function()
			require("peek").setup({
				app = "firefox",
				theme = "dark",
				update_on_change = true,
				throttle_at = 200000,
				throttle_time = "auto",
			})
			vim.keymap.set("n", "<leader>mp", function()
				local peek = require("peek")
				if peek.is_open() then
					peek.close()
				else
					peek.open()
				end
			end, { desc = "Markdownプレビュー(Peek)" })
		end,
	},
}
