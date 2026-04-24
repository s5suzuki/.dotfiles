local keymap = vim.keymap

keymap.set("i", "jj", "<Esc>", { silent = true, desc = "ノーマルモードへ戻る" })
keymap.set("i", "っj", "<Esc>", { silent = true })

keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "ファイルを保存" })

keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "検索ハイライトをクリア" })

keymap.set("x", "p", '"_dP', { desc = "ペースト時にレジスタを上書きしない" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "選択行を下に移動" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "選択行を上に移動" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "下へスクロールし中央へ" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "上へスクロールし中央へ" })

keymap.set("n", "n", "nzzzv", { desc = "次の検索結果へ(中央保持)" })
keymap.set("n", "N", "Nzzzv", { desc = "前の検索結果へ(中央保持)" })

keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "1行コメントアウト" })
keymap.set("v", "<C-/>", "gc", { remap = true, desc = "選択範囲をコメントアウト" })
keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "1行コメントアウト" })
keymap.set("v", "<C-_>", "gc", { remap = true, desc = "選択範囲をコメントアウト" })

vim.keymap.set("n", "sv", "<cmd>vsplit<cr>", { desc = "垂直に分割" })
vim.keymap.set("n", "sx", "<cmd>split<cr>", { desc = "水平に分割" })

keymap.set("n", "<A-h>", "<C-w>h")
keymap.set("n", "<A-j>", "<C-w>j")
keymap.set("n", "<A-k>", "<C-w>k")
keymap.set("n", "<A-l>", "<C-w>l")

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
