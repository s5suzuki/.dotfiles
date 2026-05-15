return {
	{
		"declancm/cinnamon.nvim",
		version = "*",
		config = function()
			require("cinnamon").setup({
				keymaps = {
					basic = false,
					extra = false,
				},
				options = {
					mode = "window",
					delay = 3,
					max_length = 500,
					scroll_limit = 150,
				},
			})

			local cinnamon = require("cinnamon")

			vim.keymap.set({ "n", "v" }, "<C-u>", function()
				cinnamon.scroll("<C-u>zz")
			end, { desc = "Smooth scroll up and center" })

			vim.keymap.set({ "n", "v" }, "<C-d>", function()
				cinnamon.scroll("<C-d>zz")
			end, { desc = "Smooth scroll down and center" })

			vim.keymap.set({ "n", "v" }, "<C-b>", function()
				cinnamon.scroll("<C-b>zz")
			end, { desc = "Smooth scroll page up and center" })

			vim.keymap.set({ "n", "v" }, "<C-f>", function()
				cinnamon.scroll("<C-f>zz")
			end, { desc = "Smooth scroll page down and center" })
		end,
	},
}
