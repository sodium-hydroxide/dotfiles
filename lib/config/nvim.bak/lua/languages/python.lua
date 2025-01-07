return function()
    -- Treesitter setup
    require('nvim-treesitter.configs').setup({
        ensure_installed = { "python" },
        highlight = {
            enable = true,
        },
        indent = {
            enable = true,
        },
    })

    -- LSP and Completion setup
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Python LSP (pyright) setup
    lspconfig.pyright.setup({
        capabilities = capabilities,
    })

    -- Ruff LSP setup
    require('lspconfig').ruff.setup({
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
        end,
        init_options = {
            settings = {
                -- Ruff settings
                line_length = 79,
                format = {
                    enabled = true,
                },
                -- Optional: add more rules
                select = {
                    "E",    -- pycodestyle errors
                    "F",    -- pyflakes
                    "I",    -- isort
                    "UP",   -- pyupgrade
                    "RUF",  -- ruff-specific rules
                },
                -- Enable import sorting
                isort = {
                    enabled = true,
                },
            }
        }
    })

    -- Write on Save
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.py",
        callback = function()
            vim.lsp.buf.format({
                filter = function(client)
                    return client.name == "ruff"
                end,
                timeout_ms = 1000
            })
        end,
    })

    -- Completion setup
    local cmp = require('cmp')
    cmp.setup({
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
        }),
    })

    -- Debugger setup (optional)
    local status_ok, dap = pcall(require, 'dap')
    if status_ok then
        dap.adapters.python = {
            type = 'executable',
            command = 'python',
            args = { '-m', 'debugpy.adapter' },
        }

        dap.configurations.python = {
            {
                type = 'python',
                request = 'launch',
                name = "Launch file",
                program = "${file}",
                pythonPath = function()
                    return '/usr/bin/python3'
                end,
            },
        }
    end
end

