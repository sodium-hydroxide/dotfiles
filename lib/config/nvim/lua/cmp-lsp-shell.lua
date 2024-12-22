-- lua/lsp-cmp-shell.lua
return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Bash LSP setup
            lspconfig.bashls.setup({
                capabilities = capabilities,
                on_attach = _G.lsp_on_attach,
                filetypes = { "sh", "bash", "zsh" },
                settings = {
                    bashIde = {
                        -- Glob pattern for finding shell script files
                        globPattern = "**/*@(.sh|.inc|.bash|.command)",
                    },
                },
            })

            -- Configure shellcheck via null-ls
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.diagnostics.shellcheck.with({
                        diagnostics_format = "[#{c}] #{m} (#{s})",
                        -- Optional: if you want to use a specific shellcheck config
                        extra_args = { "--severity", "warning" }, -- or "error" for stricter checks
                    }),
                    -- Add shell script formatting
                    null_ls.builtins.formatting.shfmt.with({
                        extra_args = { "-i", "4", "-ci" }, -- 4 space indentation, indent switch cases
                    }),
                },
            })

            -- Optional: Set up filetype detection for shell scripts
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = { "*.sh", "*.bash", "*.zsh" },
                callback = function()
                    -- Set filetype explicitly
                    vim.bo.filetype = "sh"
                    -- Optional: Set shell dialect if needed
                    vim.bo.syntax = "bash"
                end,
            })
        end
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    }
}
