return {

	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = { "^%.git/", "node_modules/" },
			},
			pickers = {
				find_files = {
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
				live_grep = {
					additional_args = function()
						return { "--hidden", "--glob", "!**/.git/*" }
					end,
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "ファイルを検索" })
		vim.keymap.set("n", "<leader>ff", builtin.live_grep, { desc = "文字を検索 (Grep)" })
		vim.keymap.set("n", "<leader>fs", function()
			builtin.live_grep({
				additional_args = function()
					return { "--fixed-strings", "--hidden", "--glob", "!**/.git/*" }
				end,
			})
		end, { desc = "文字を検索 (リテラル/正規表現オフ)" })
	end,
}
