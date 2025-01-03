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

    -- DAP (Debugging) plugins
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },

    -- Treesitter and language configurations
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("languages.python")()
            require("languages.shell")()
            require("languages.c")()
        end,
    },
}
    -- Markdown
    -- LaTeX
    -- Rust
    -- Haskell
    -- Perl
    -- Scheme
    -- R-lang
    -- FORTRAN
    -- MCNP
    --

