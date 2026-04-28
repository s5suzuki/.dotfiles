return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				window = {
					mappings = {
						["l"] = "open",
						["h"] = "close_node",
						["<C-v>"] = "open_vsplit",
						["<C-x>"] = "open_split",
						["s"] = "none",
						["S"] = "none",
					},
				},
				source_selector = {
					winbar = true,
					content_layout = "center",
					sources = {
						{ source = "filesystem", display_name = " 󰉏 Files " },
						{ source = "git_status", display_name = " 󰊢 Git " },
					},
				},

				filesystem = {
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
					},
					follow_current_file = {
						enabled = true,
					},
				},

				git_status = {
					window = {
						position = "left",
						mappings = {
							["<CR>"] = "open_delta_full",
							["l"] = "open_delta_full",
							["d"] = "open_delta_diff",
							["o"] = "open",
						},
					},
					commands = {
						open_delta_full = function(state)
							state.commands._open_delta(state, true)
						end,
						open_delta_diff = function(state)
							state.commands._open_delta(state, false)
						end,
						_open_delta = function(state, is_full)
							local node = state.tree:get_node()
							if node.type ~= "file" then
								state.commands.open(state)
								return
							end
							local filepath = node:get_id()

							vim.fn.system("git ls-files --error-unmatch " .. vim.fn.shellescape(filepath))
							local is_untracked = vim.v.shell_error ~= 0

							local cmd
							local width_ratio = 0.8
							local delta_args = ""
							local diff_args = "HEAD"

							if is_full then
								width_ratio = 0.9
								delta_args = "--side-by-side"
								diff_args = "-U9999 HEAD"
							end

							if is_untracked then
								cmd = string.format(
									"git diff --no-index --color=always /dev/null %s | delta %s --paging=never",
									vim.fn.shellescape(filepath),
									delta_args
								)
							else
								cmd = string.format(
									"git diff %s --color=always -- %s | delta %s --paging=never",
									diff_args,
									vim.fn.shellescape(filepath),
									delta_args
								)
							end

							local width = math.ceil(vim.o.columns * width_ratio)
							local height = math.ceil(vim.o.lines * 0.8)
							local buf = vim.api.nvim_create_buf(false, true)
							vim.api.nvim_open_win(buf, true, {
								relative = "editor",
								width = width,
								height = height,
								col = math.ceil((vim.o.columns - width) / 2),
								row = math.ceil((vim.o.lines - height) / 2),
								style = "minimal",
								border = "rounded",
							})
							vim.cmd.terminal(cmd)
							vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
						end,
					},
				},
			})

			vim.keymap.set(
				"n",
				"<C-b>",
				"<Cmd>Neotree toggle position=left source=filesystem<CR>",
				{ desc = "ファイルツリーを開閉" }
			)

			vim.keymap.set(
				"n",
				"<leader>gs",
				"<Cmd>Neotree focus position=left source=git_status<CR>",
				{ desc = "Gitステータスを開く" }
			)
		end,
	},
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>-",
				function()
					require("yazi").yazi()
				end,
				desc = "Yaziを現在のファイルの位置で開く",
			},
			{
				"<leader>cw",
				function()
					require("yazi").yazi(nil, vim.fn.getcwd())
				end,
				desc = "Yaziをワーキングディレクトリで開く",
			},
		},
		opts = {
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
		config = function(_, opts)
			require("yazi").setup(opts)
		end,
	},
}
