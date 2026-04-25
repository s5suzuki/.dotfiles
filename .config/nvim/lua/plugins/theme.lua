return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			transparent_background = false,
			show_end_of_buffer = false,
			integration = {
				blink_cmp = true,
				cmp = true,
				copilot_vim = true,
				diffview = true,
				gitsigns = true,
				gitgraph = true,
				nvimtree = true,
				neotree = true,
				treesitter = true,
				telescope = true,
				notify = false,
				noice = true,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				lualine = true,
			},
		})

		vim.cmd.colorscheme("catppuccin")
	end,
}
