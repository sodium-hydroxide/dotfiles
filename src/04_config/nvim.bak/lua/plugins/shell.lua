return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- Ensure bash/shell parser is installed
            if opts.ensure_installed ~= "all" then
                opts.ensure_installed = opts.ensure_installed or {}
                table.insert(opts.ensure_installed, "bash")
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            -- Configure bash-language-server
            require("lspconfig").bashls.setup({
                filetypes = { "sh", "bash", "zsh" },
                settings = {
                    bashIde = {
                        globPattern = "*@(.sh|.inc|.bash|.command)",
                    },
                },
            })
        end,
    },
    {
        "nathom/filetype.nvim",
        opts = {
            overrides = {
                extensions = {
                    sh = "bash",
                    bash = "bash",
                    zsh = "bash",
                },
            },
        },
    },
}
