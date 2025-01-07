
return function()
    -- Treesitter setup
    require('nvim-treesitter.configs').setup({
        ensure_installed = { "haskell" },
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

    -- Haskell LSP setup
    lspconfig.hls.setup({
        capabilities = capabilities,
        filetypes = { "haskell", "lhaskell" },
        -- You can add custom settings here if needed
        settings = {
            haskell = {
                checkProject = true,
                formattingProvider = "fourmolu", -- or "brittany", "floskell", "ormolu"
            }
        }
    })

    -- Write on Save
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.hs",
        callback = function()
            vim.lsp.buf.format({
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
    -- Note: Haskell debugging support is limited
    -- You might want to use haskell-debug-adapter if needed
    local status_ok, dap = pcall(require, 'dap')
    if status_ok then
        dap.adapters.haskell = {
            type = 'executable',
            command = 'haskell-debug-adapter',
            args = {}
        }

        dap.configurations.haskell = {
            {
                type = "haskell",
                request = "launch",
                name = "Debug",
                workspace = "${workspaceFolder}",
                startup = "${file}",
                stopOnEntry = true,
                logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
                logLevel = 'WARNING',
                ghciEnv = vim.empty_dict(),
                ghciPrompt = "λ: ",
                ghciInitialPrompt = "λ: ",
                ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
            }
        }
    end
end

