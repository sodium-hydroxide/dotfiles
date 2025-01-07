return function()
    -- Treesitter setup
    require('nvim-treesitter.configs').setup({
        ensure_installed = { "bash" },
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

    -- Bash LSP setup
    lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = _G.lsp_on_attach,
        filetypes = { "sh", "bash", "zsh" },
        settings = {
            bashIde = {
                globPattern = "**/*@(.sh|.inc|.bash|.command)",
            },
        },
    })

    -- Null-ls for formatting and linting
    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
            null_ls.builtins.diagnostics.shellcheck.with({
                diagnostics_format = "[#{c}] #{m} (#{s})",
                extra_args = { "--severity", "warning" },
            }),
            null_ls.builtins.formatting.shfmt.with({
                extra_args = { "-i", "4", "-ci" },
            }),
        },
    })

    -- Completion setup for shell
    local cmp = require('cmp')
    cmp.setup.filetype({ "sh", "bash", "zsh" }, {
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

    -- Debugger setup (using bash-debug-adapter)
    local dap = require('dap')
    dap.adapters.bash = {
        type = 'executable',
        command = 'bash-debug-adapter',
        name = 'bash',
    }

    dap.configurations.sh = {
        {
            type = 'bash',
            request = 'launch',
            name = "Launch file",
            program = "${file}",
            cwd = '${workspaceFolder}',
        }
    }

    -- Auto format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.sh", "*.bash", "*.zsh" },
        callback = function()
            vim.lsp.buf.format()
        end,
    })

    -- Filetype detection
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.sh", "*.bash", "*.zsh" },
        callback = function()
            vim.bo.filetype = "sh"
            vim.bo.syntax = "bash"
        end,
    })
end

