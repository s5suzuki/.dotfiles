return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGitを起動" },
		},
		init = function()
			vim.g.lazygit_floating_window_scaling_factor = 0.98
		end,
		config = function() end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 500,
			},
			current_line_blame_formatter = " <author> • <author_time:%Y-%m-%d> • <summary>",

			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map("n", "]h", function()
					if vim.wo.diff then
						return "]h"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "次の変更(Hunk)へ" })

				map("n", "[h", function()
					if vim.wo.diff then
						return "[h"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "前の変更(Hunk)へ" })

				map("n", "<leader>ghp", gs.preview_hunk, { desc = "Hunkをプレビュー" })
				map("n", "<leader>ghr", gs.reset_hunk, { desc = "Hunkを元に戻す" })
				map("n", "<leader>ghs", gs.stage_hunk, { desc = "Hunkをステージング" })

				map("n", "<leader>gd", function()
					local file = vim.fn.expand("%")
					local cmd = string.format("git diff --color=always %s | delta --paging=never", file)

					local width = math.ceil(vim.o.columns * 0.8)
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
				end, { desc = "Deltaで差分を表示" })
			end,
		},
	},
}
