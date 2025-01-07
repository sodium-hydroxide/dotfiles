-- init.lua
return {
    -- Base LSP and completion plugins
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- Markdown Plugins
    { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
    { "lukas-reineke/lsp-format.nvim" },

    -- DAP (Debugging) plugins
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },


    -- Add Mason for LSP management
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = true
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = true
    },
    -- Treesitter and language configurations
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("languages.shell")()
            require("languages.python")()
            require("languages.c")()
            require("languages.haskell")()
            require("languages.markdown")()
        end,
    },
}
-- Markdown -- include previewer
-- LaTeX    -- include previewer
-- Rust
-- Perl
-- Scheme
-- R-lang   -- repl support
-- Python Repl
-- FORTRAN
-- MCNP
-- Quarto   -- previewer and executer

