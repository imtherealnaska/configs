require("temper")


vim.api.nvim_set_keymap('i', '<c-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {})
-- recommended:
require 'lsp_signature'.setup() -- no need to specify bufnr if you don't use toggle_key

-- You can also do this inside lsp on_attach
-- note: on_attach deprecated

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(args.buf, true)
        end
        -- whatever other lsp config you want
        require("lsp_signature").on_attach({
            bind = true,
            handler_opts = {
                border = "rounded"
            }
        })
    end
})
