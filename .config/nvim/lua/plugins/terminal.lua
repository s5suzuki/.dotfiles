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

			local function terminal_cwd(pid)
				local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/stat")
				if ok and lines and lines[1] then
					local after = lines[1]:match("%)%s+(.*)$")
					if after then
						local f = {}
						for tok in after:gmatch("%S+") do
							f[#f + 1] = tok
						end
						local tpgid = tonumber(f[6])
						if tpgid and tpgid > 0 then
							local cwd = vim.fn.resolve("/proc/" .. tpgid .. "/cwd")
							if vim.fn.isdirectory(cwd) == 1 then
								return cwd
							end
						end
					end
				end
				local cwd = vim.fn.resolve("/proc/" .. pid .. "/cwd")
				if vim.fn.isdirectory(cwd) == 1 then
					return cwd
				end
				return nil
			end

			local function open_under_cursor_in_editor()
				local cfile = vim.fn.expand("<cfile>")
				if cfile == "" then
					return
				end
				local cur = vim.api.nvim_get_current_line()
				local lnum = tonumber(cur:match(vim.pesc(cfile) .. ":(%d+)"))
				local base = vim.fn.getcwd()
				local pid = vim.b.terminal_job_pid
				if pid then
					local tcwd = terminal_cwd(pid)
					if tcwd then
						base = tcwd
					end
				end

				local path = cfile
				if path:sub(1, 1) ~= "/" then
					path = base .. "/" .. cfile
				end
				if vim.fn.filereadable(path) == 0 then
					local found = vim.fn.findfile(cfile, base .. ";")
					if found == "" then
						found = vim.fn.findfile(cfile, vim.fn.getcwd() .. ";")
					end
					if found ~= "" then
						path = found
					end
				end
				path = vim.fn.fnamemodify(path, ":p")
				pcall(vim.cmd, "close")
				if lnum then
					vim.cmd(string.format("edit +%d %s", lnum, vim.fn.fnameescape(path)))
				else
					vim.cmd("edit " .. vim.fn.fnameescape(path))
				end
			end
			_G.__toggleterm_goto_file = open_under_cursor_in_editor

			local function set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)

				local goto_cmd = "<Cmd>lua __toggleterm_goto_file()<CR>"
				vim.keymap.set("n", "gf", goto_cmd, opts)
				vim.keymap.set("n", "gF", goto_cmd, opts)
				vim.keymap.set("n", "<2-LeftMouse>", "<LeftMouse>" .. goto_cmd, opts)
				vim.keymap.set("t", "<2-LeftMouse>", [[<C-\><C-n><LeftMouse>]] .. goto_cmd, opts)
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
