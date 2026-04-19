return {
	{
		"sindrets/diffview.nvim",
		opts = {
			file_panel = {
				listing_style = "tree",
				tree_options = {
					flatten_dirs = true,
					folder_statuses = "only_folded",
				},
			},
			keymaps = {
				disable_defaults = false,
				view = {
					["q"] = "<Cmd>DiffviewClose<CR>",
				},
				file_panel = {
					["q"] = "<Cmd>DiffviewClose<CR>",
				},
				file_history_panel = {
					["q"] = "<Cmd>DiffviewClose<CR>",
				},
			},
		},
	},
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
		config = function() end,
	},
	{
		"isakbm/gitgraph.nvim",
		dependencies = {
			"sindrets/diffview.nvim",
		},
		opts = {
			symbols = {
				merge_commit = "○",
				commit = "●",
				merge_commit_end = "○",
				commit_end = "●",

				GVER = "│",
				GHOR = "─",
				GCLD = "╮",
				GCRD = "╭",
				GCLU = "╯",
				GCRU = "╰",
				GLRU = "┴",
				GLRD = "┬",
				GLUD = "┤",
				GRUD = "├",
				GFORK = "┼",
				GFORKCR = "┼",
			},
			format = {
				timestamp = "%Y-%m-%d %H:%M:%S",
				fields = { "hash", "timestamp", "author", "branch_name", "tag" },
			},
			hooks = {
				on_select_commit = function(commit)
					vim.notify("Diffview " .. commit.hash .. "^!")
					vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
				end,
				on_select_range_commit = function(from, to)
					vim.notify("Diffview " .. from.hash .. "~1.." .. to.hash)
					vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
				end,
			},
		},
		keys = {
			{
				"<leader>gl",
				function()
					require("gitgraph").draw({}, { all = true, max_count = 5000 })
				end,
				desc = "GitGraphを開く",
			},
		},
		config = function(_, opts)
			local colors = {
				"#F14C4C",
				"#3794FF",
				"#89D185",
				"#CCA700",
				"#B267E6",
				"#4CBF99",
			}
			for i, color in ipairs(colors) do
				vim.api.nvim_set_hl(0, "GitGraphBranch" .. i, { fg = color, bold = true })
			end
			vim.api.nvim_set_hl(0, "GitGraphTimestamp", { fg = "#6a9955" })
			vim.api.nvim_set_hl(0, "GitGraphAuthor", { fg = "#4EC9B0" })

			require("gitgraph").setup(opts)
		end,
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
					vim.fn.termopen(cmd)
					vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
				end, { desc = "Deltaで差分を表示" })
			end,
		},
	},
}
