return {
    -- Mason for managing LSP servers, linters, and formatters
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Open Mason" } },
        build = ":MasonUpdate",
        opts = {
            ensure_installed = {
                -- LSPs
                "pyright",
                "ruff-lsp",
                "rust-analyzer",
                "shellcheck",
                "julia-lsp",
                -- "ts_ls",
                "typescript-language-server",
                "texlab",
                "solargraph", -- Ruby
                "lua-language-server",
                "marksman", -- Markdown

                -- Linters
                "ruff",
                "shellcheck",
                "yamllint",
                "jsonlint",
                
                -- Formatters
                "black", -- Python
                "rustfmt",
                "prettier", -- JS/TS/JSON/YAML/Markdown
                "stylua", -- Lua
                "latexindent",
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            local function ensure_installed()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then
                        p:install()
                    end
                end
            end
            if mr.refresh then
                mr.refresh(ensure_installed)
            else
                ensure_installed()
            end
        end,
    },

    -- LSP Support
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            {
                "hrsh7th/nvim-cmp",
                dependencies = {
                    "hrsh7th/cmp-nvim-lsp",
                    "hrsh7th/cmp-buffer",
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-cmdline",
                    "L3MON4D3/LuaSnip",
                    "saadparwaiz1/cmp_luasnip",
                    "rafamadriz/friendly-snippets",
                },
            },
        },
        config = function()
            -- Setup LSP keybindings
            local on_attach = function(_, bufnr)
                local nmap = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
                end

                nmap('gD', vim.lsp.buf.declaration, "Go to declaration")
                nmap('gd', vim.lsp.buf.definition, "Go to definition")
                nmap('K', vim.lsp.buf.hover, "Hover documentation")
                nmap('gi', vim.lsp.buf.implementation, "Go to implementation")
                nmap('<C-k>', vim.lsp.buf.signature_help, "Signature help")
                nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, "Add workspace folder")
                nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
                nmap('<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, "List workspace folders")
                nmap('<leader>D', vim.lsp.buf.type_definition, "Type definition")
                nmap('<leader>rn', vim.lsp.buf.rename, "Rename")
                nmap('<leader>ca', vim.lsp.buf.code_action, "Code actions")
                nmap('gr', vim.lsp.buf.references, "Go to references")
                nmap('<leader>f', function()
                    vim.lsp.buf.format { async = true }
                end, "Format file")
            end

            -- Setup completion
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Configure LSP servers
            -- PYTHON LSP==================================================================
            local lspconfig = require('lspconfig')
            -- Python (update the existing pyright config)
            lspconfig.pyright.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            pythonPath = vim.fn.exepath('python3') or vim.fn.exepath('python'),
                        },
                    },
                },
            })
            
            -- Rust (update the existing rust_analyzer config) =========================
            lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    ['rust-analyzer'] = {
                        checkOnSave = {
                            command = "clippy",
                        },
                    },
                },
                -- Rust analyzer will automatically find rustup's installation
            })
            
            -- Julia (update the existing julials config) ==============================
            lspconfig.julials.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                -- Julia LSP will automatically find juliaup's installation
                settings = {
                    julia = {
                        environmentPath = vim.fn.expand("~/.julia/environments/v1.9"), -- Adjust version as needed
                    },
                },
            })
            -- TypeScript/JavaScript  ==========================
            lspconfig.tsserver.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- LaTeX  ==========================
            lspconfig.texlab.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- Ruby
            lspconfig.solargraph.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            -- Markdown
            lspconfig.marksman.setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
        },
        opts = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
                formatting = {
                    format = function(_, vim_item)
                        vim_item.menu = vim_item.kind
                        return vim_item
                    end,
                },
            }
        end,
    },
}
