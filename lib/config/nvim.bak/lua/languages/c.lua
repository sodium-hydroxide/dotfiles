return function()
    -- Treesitter setup
    require('nvim-treesitter.configs').setup({
        ensure_installed = { "c" },
        highlight = {
            enable = true,
        },
        indent = {
            enable = true,
        },
    })

    -- LSP setup
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- clangd setup
    lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = _G.lsp_on_attach,
        cmd = {
            "clangd",
            "--background-index",
            "--suggest-missing-includes",
            "--clang-tidy",
            "--header-insertion=iwyu",
        },
    })

    -- Formatting setup
    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
            null_ls.builtins.formatting.clang_format.with({
                extra_args = {"--style={BasedOnStyle: Mozilla, IndentWidth: 4, UseTab: Never}"}
            }),
        },
    })

    -- Completion setup for C
    local cmp = require('cmp')
    cmp.setup.filetype({ "c", "cpp", "h", "hpp" }, {
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

    -- Debugger setup (using lldb)
    local status_ok, dap = pcall(require, 'dap')
    if status_ok then
        dap.adapters.lldb = {
            type = 'executable',
            command = '/usr/bin/lldb-vscode',
            name = 'lldb'
        }

        dap.configurations.c = {
            {
                name = 'Launch',
                type = 'lldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},
            }
        }
    end

    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.c", "*.h", "*.cpp", "*.hpp" },
        callback = function()
            vim.lsp.buf.format({
                timeout_ms = 1000
            })
        end,
    })
end

