return {
	{
		"folke/neoconf.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "folke/neoconf.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("neoconf").setup()
			require("lspconfig")

			vim.lsp.config.lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						format = {
							enable = true,
							defaultConfig = {
								indent_style = "space",
								indent_size = "2",
							},
						},
					},
				},
			}

			vim.lsp.config.jsonls = {
				settings = {
					json = {
						validate = { enable = true },
						format = { enable = true },
					},
				},
			}

			vim.lsp.enable("lua_ls")
			vim.lsp.enable("rust_analyzer")
			vim.lsp.enable("jsonls")
			vim.lsp.enable("taplo")
			vim.lsp.enable("bashls")

			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 4,
					source = "if_many",
				},
				underline = true,
				signs = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = true,
					header = "",
					prefix = "",
				},
			})

			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "エラー詳細を表示" })
			vim.keymap.set("n", "[d", function()
				vim.diagnostic.jump({ count = -1 })
			end, { desc = "前のエラーへ" })

			vim.keymap.set("n", "]d", function()
				vim.diagnostic.jump({ count = 1 })
			end, { desc = "次のエラーへ" })

			vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "プロジェクト前のエラーへ" })
			vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "プロジェクト次のエラーへ" })
			vim.keymap.set("n", "<leader>q", function()
				vim.diagnostic.setqflist()
			end, { desc = "全エラーをリスト化" })
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, { desc = "ホバー表示" })

			vim.keymap.set("i", "<C-k>", function()
				vim.lsp.buf.signature_help({ border = "rounded" })
			end, { desc = "シグネチャヘルプ (引数のヒント)" })

			vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "定義元へジャンプ" })
			vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "参照先一覧" })
			vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "実装へジャンプ" })
			vim.keymap.set({ "n", "v" }, "<leader>.", function()
				vim.lsp.buf.code_action()
			end, { desc = "コードアクション (Quick Fix)" })

			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(event)
					local ft = vim.bo[event.buf].filetype

					if ft == "lua" then
						if vim.fn.executable("stylua") == 1 then
							local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
							local output = vim.fn.systemlist({ "stylua", "-" }, lines)

							if vim.v.shell_error == 0 then
								vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, output)
							end
						else
							vim.notify("StyLuaがインストールされていません", vim.log.levels.WARN)
						end
						return
					end

					if ft == "sh" or ft == "bash" then
						if vim.fn.executable("shfmt") == 1 then
							local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
							local output = vim.fn.systemlist({ "shfmt", "-i", "2", "-sr", "-ci" }, lines)

							if vim.v.shell_error == 0 then
								vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, output)
							end
						else
							vim.notify("shfmtがインストールされていません", vim.log.levels.WARN)
						end
						return
					end

					local clients = vim.lsp.get_clients({ bufnr = event.buf })
					if #clients > 0 then
						vim.lsp.buf.format({ async = false })
					end
				end,
			})
		end,
	},
}
