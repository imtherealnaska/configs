local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
    "simrat39/rust-tools.nvim",
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    },
    "nvim-treesitter/playground",
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('telescope').setup()
        end
    },
    "nvim-treesitter/nvim-treesitter-context",
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    "pbrisbin/vim-colors-off",
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v1.x",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
        }
    },
    "ntk148v/komau.vim",
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup {}
        end
    },
    "ray-x/lsp_signature.nvim",
})
