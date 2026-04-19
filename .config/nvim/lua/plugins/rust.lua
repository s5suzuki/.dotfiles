return {
	"saecki/crates.nvim",
	tag = "stable",
	event = { "BufRead Cargo.toml" },
	config = function()
		local crates = require("crates")
		crates.setup({
			lsp = {
				enabled = true,
				actions = true,
				completion = true,
				hover = true,
			},
			popup = {
				autofocus = true,
				border = "rounded",
			},
		})

		local opts = { silent = true }
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { silent = true, desc = "Crates: " .. desc })
		end

		map("n", "<leader>ct", crates.toggle, "Toggle virtual text")
		map("n", "<leader>cr", crates.reload, "Reload")

		map("n", "<leader>cv", crates.show_versions_popup, "Show versions")
		map("n", "<leader>cf", crates.show_features_popup, "Show features")
		map("n", "<leader>cd", crates.show_dependencies_popup, "Show dependencies")

		map("n", "<leader>cu", crates.update_crate, "Update crate")
		map("v", "<leader>cu", crates.update_crates, "Update crates")
		map("n", "<leader>ca", crates.update_all_crates, "Update all")
		map("n", "<leader>cU", crates.upgrade_crate, "Upgrade crate")
		map("v", "<leader>cU", crates.upgrade_crates, "Upgrade crates")
		map("n", "<leader>cA", crates.upgrade_all_crates, "Upgrade all")

		map("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, "Expand to inline table")
		map("n", "<leader>cX", crates.extract_crate_into_table, "Extract into table")

		map("n", "<leader>cH", crates.open_homepage, "Open homepage")
		map("n", "<leader>cR", crates.open_repository, "Open repository")
		map("n", "<leader>cD", crates.open_documentation, "Open documentation")
		map("n", "<leader>cC", crates.open_crates_io, "Open crates.io")
	end,
}
