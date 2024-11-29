return {
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSUpdateSync" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        opts = {
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "bash", "sh" },
            },
            indent = { enable = true },
            ensure_installed = {
                "bash", -- Added this line
                "python",
                "rust",
                "julia",
                "typescript",
                "javascript",
                "tsx",
                "latex",
                "ruby",
                "lua",
                "markdown",
                "markdown_inline",
                "toml",
                "yaml",
                "json",
                "jsonc",
                "csv",
                "make",
                "dockerfile",
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                    },
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}

