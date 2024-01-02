local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>r', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n' , '<leader>m' , builtin.lsp_dynamic_workspace_symbols)
vim.keymap.set('n' , '<leader>c' , builtin.lsp_document_symbols)

