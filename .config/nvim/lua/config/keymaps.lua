local keymap = vim.keymap

keymap.set("i", "jj", "<Esc>", { silent = true, desc = "ノーマルモードへ戻る" })
keymap.set("v", "<C-k>", "<Esc>", { desc = "ノーマルモードへ戻る" })
keymap.set("i", "jk", "<Esc>:w<CR>", { desc = "Escape and save" })
keymap.set("i", "っj", "<Esc>", { silent = true })

keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "ファイルを保存" })

keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "検索ハイライトをクリア" })

keymap.set("x", "p", '"_dP', { desc = "ペースト時にレジスタを上書きしない" })
keymap.set({ "n", "v" }, "-", '"_', { desc = "ブラックホールレジスタを使用" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "選択行を下に移動" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "選択行を上に移動" })

keymap.set("n", "n", "nzzzv", { desc = "次の検索結果へ(中央保持)" })
keymap.set("n", "N", "Nzzzv", { desc = "前の検索結果へ(中央保持)" })

keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "1行コメントアウト" })
keymap.set("v", "<C-/>", "gc", { remap = true, desc = "選択範囲をコメントアウト" })
keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "1行コメントアウト" })
keymap.set("v", "<C-_>", "gc", { remap = true, desc = "選択範囲をコメントアウト" })

keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "行頭(空白を除く)へ移動" })
keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "行末へ移動" })

local function gf_file_only(key)
	return function()
		local cur = vim.api.nvim_get_current_buf()
		local ok, err = pcall(vim.cmd, "keepalt normal! " .. key)
		if not ok then
			vim.api.nvim_echo({ { tostring(err):gsub("^.-Vim[^:]*:", ""), "ErrorMsg" } }, true, {})
			return
		end
		local buf = vim.api.nvim_get_current_buf()
		local name = vim.api.nvim_buf_get_name(buf)
		if buf ~= cur and name ~= "" and vim.fn.isdirectory(name) == 1 then
			vim.api.nvim_set_current_buf(cur)
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
			vim.api.nvim_echo({ { "E: ディレクトリは開けません: " .. name, "ErrorMsg" } }, true, {})
		end
	end
end
keymap.set("n", "gf", gf_file_only("gf"), { desc = "gf (ディレクトリは開かない)" })
keymap.set("n", "gF", gf_file_only("gF"), { desc = "gF (ディレクトリは開かない)" })

keymap.set("n", "sv", "<cmd>vsplit<cr>", { desc = "垂直に分割" })
keymap.set("n", "sx", "<cmd>split<cr>", { desc = "水平に分割" })

keymap.set("n", "<C-h>", "<C-w>h", { desc = "左のウィンドウへ移動" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウへ移動" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウへ移動" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "右のウィンドウへ移動" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitgraph" },
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>bdelete<CR>", {
			buffer = event.buf,
			silent = true,
			desc = "バッファを閉じる",
		})
	end,
})
