return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<C-\>]],
				direction = "float",
				float_opts = {
					border = "curved",
				},
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				persist_size = true,
			})

			vim.keymap.set("n", "<leader>t", "<Cmd>ToggleTerm<CR>", { desc = "Terminal" })

			local function set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*",
				callback = function()
					local file = vim.api.nvim_buf_get_name(0)
					if string.find(file, "lazygit") or string.find(file, "yazi") then
						return
					end

					set_terminal_keymaps()
					vim.cmd(
						"setlocal guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
					)
				end,
			})

			vim.api.nvim_create_autocmd("TermLeave", {
				pattern = "term://*",
				callback = function()
					local file = vim.api.nvim_buf_get_name(0)
					if string.find(file, "lazygit") or string.find(file, "yazi") then
						return
					end
					vim.cmd(
						"set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
					)
				end,
			})
		end,
	},
}
