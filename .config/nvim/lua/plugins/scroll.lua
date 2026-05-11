return {
	{
		"declancm/cinnamon.nvim",
		version = "*",
		config = function()
			require("cinnamon").setup({
				keymaps = {
					basic = true,
					extra = true,
				},
				options = {
					mode = "cursor",
					delay = 3,
					max_length = 500,
					scroll_limit = 150,
				},
			})

			vim.keymap.set({ "n", "v" }, "<C-u>", function()
				require("cinnamon").scroll("<C-u>zz")
			end, { desc = "Smooth scroll up and center" })

			vim.keymap.set({ "n", "v" }, "<C-d>", function()
				require("cinnamon").scroll("<C-d>zz")
			end, { desc = "Smooth scroll down and center" })
		end,
	},
}
