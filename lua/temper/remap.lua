vim.g.mapleader = ","
vim.keymap.set("n", "<leader>q", vim.cmd.Ex)

vim.keymap.set("n", "<C-f>", vim.lsp.buf.format)
