-- lua/lsp-cmp-python.lua
return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",
            "mfussenegger/nvim-dap-python",  -- Optional: for debugging
        },
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Pyright LSP setup
            lspconfig.pyright.setup({
                capabilities = capabilities,
                on_attach = _G.lsp_on_attach,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            })

            -- Ruff LSP setup
            lspconfig.ruff.setup({
                capabilities = capabilities,
                on_attach = _G.lsp_on_attach,
                init_options = {
                    settings = {
                        -- Ruff settings
                        args = {},
                    }
                }
            })

            -- Configure diagnostics
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- Add mypy to null-ls for type checking
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.diagnostics.mypy.with({
                        command = vim.fn.expand("~/.venv/bin/mypy"),
                    }),
                },
            })
        end
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    }
}
