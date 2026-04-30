local function lsp_servers()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return "No LSP"
	end

	local names = {}
	for _, client in ipairs(clients) do
		if client.name ~= "copilot" then
			table.insert(names, client.name)
		end
	end

	return " " .. table.concat(names, ", ")
end

return {
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					close_command = "bdelete! %d",
					right_mouse_command = "bdelete! %d",
					offsets = {
						{
							filetype = "neo-tree",
							text = "File Explorer",
							text_align = "left",
							separator = true,
						},
					},
				},
			})
			vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "次のタブ" })
			vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "前のタブ" })
			vim.keymap.set("n", "<leader>w", "<Cmd>bdelete<CR>", { desc = "タブを閉じる" })
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin-nvim",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1, -- 0: Just filename, 1: Relative path, 2: Absolute path
						},
					},
					lualine_x = {
						{
							"diagnostics",
							sources = { "nvim_lsp" },
							symbols = { error = " ", warn = " ", info = " ", hint = " " },
						},
						{
							lsp_servers,
							color = { fg = "#3794FF", gui = "bold" },
						},
						"encoding",
						"fileformat",
						"filetype",
					},
				},
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("notify").setup({
				stages = "fade",
				timeout = 3000,
				render = "minimal",
				max_width = 50,
			})

			vim.notify = require("notify")

			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = false,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = true,
				},
				views = {
					cmdline_popup = {
						position = {
							row = "30%",
							col = "50%",
						},
						size = {
							width = 60,
							height = "auto",
						},
					},
				},
			})
		end,
	},
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup()
		end,
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		config = function()
			local ai = require("mini.ai")
			ai.setup({
				custom_textobjects = {
					['"'] = ai.gen_spec.pair('"', '"', { type = "greedy" }),
					["'"] = ai.gen_spec.pair("'", "'", { type = "greedy" }),
					["`"] = ai.gen_spec.pair("`", "`", { type = "greedy" }),
					["*"] = ai.gen_spec.pair("*", "*", { type = "greedy" }),
					["_"] = ai.gen_spec.pair("_", "_", { type = "greedy" }),
				},
			})
		end,
	},
}
