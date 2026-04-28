vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,t:ver25,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.g.mapleader = " "
vim.opt.whichwrap:append("<,>,[,],h,l")

vim.opt.swapfile = false

vim.opt.fillchars:append({
	diff = " ",
	eob = " ",
})

if os.getenv("ZELLIJ_SESSION_NAME") then
	local pipe_path = "/tmp/nvim-" .. os.getenv("ZELLIJ_SESSION_NAME")
	if not vim.uv.fs_stat(pipe_path) then
		vim.fn.serverstart(pipe_path)
	end
end

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		vim.fn.system("fcitx5-remote -c")
	end,
})

vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
	callback = function(args)
		local bufnr = args.buf
		local ft = vim.bo[bufnr].filetype
		if ft == "" then
			return
		end

		local lang = vim.treesitter.language.get_lang(ft) or ft

		if pcall(vim.treesitter.language.add, lang) then
			pcall(vim.treesitter.start, bufnr, lang)
		end
	end,
})
