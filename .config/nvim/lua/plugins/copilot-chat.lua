return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		"zbirenbaum/copilot.lua",
		"nvim-lua/plenary.nvim",
	},
	build = "make tiktoken",
	cmd = "CopilotChat",
	opts = {
		window = { layout = "float" },
	},
	keys = {
		{
			"<leader>cc",
			function()
				local input = vim.fn.input("Quick Chat: ")
				if input ~= "" then
					require("CopilotChat").ask(input, {
						selection = require("CopilotChat.select").buffer,
					})
				end
			end,
			mode = "n",
			desc = "Copilot: 現在のファイルにクイックチャット",
		},
		{
			"<leader>cc",
			function()
				local input = vim.fn.input("Quick Chat: ")
				if input ~= "" then
					require("CopilotChat").ask(input, {
						selection = require("CopilotChat.select").visual,
					})
				end
			end,
			mode = "v",
			desc = "Copilot: 選択範囲にクイックチャット",
		},
	},
}
