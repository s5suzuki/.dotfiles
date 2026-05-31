return {
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
