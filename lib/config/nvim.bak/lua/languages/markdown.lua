return function()
    -- Treesitter setup
    require('nvim-treesitter.configs').setup({
        ensure_installed = { "markdown", "markdown_inline" },
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

    -- Markdown LSP (marksman) setup
    lspconfig.marksman.setup({
        capabilities = capabilities,
    })

    -- null-ls setup for formatting
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting

    null_ls.setup({
        sources = {
            formatting.prettier.with({
                filetypes = { "markdown" },
                extra_args = { "--prose-wrap", "always" }
            }),
        },
        debug = false,
    })

    -- Format on save with both LSP and null-ls
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.md", "*.markdown" },
        callback = function()
            vim.lsp.buf.format({
                timeout_ms = 1000,
                filter = function(client)
                    -- Allow both null-ls and marksman
                    return client.name == "null-ls" or client.name == "marksman"
                end,
            })
        end,
    })

    -- Make sure prettier is installed
    local prettier_installed = vim.fn.executable('prettier')
    if prettier_installed == 0 then
        vim.notify("prettier is not installed. Please install it with 'npm install -g prettier'", vim.log.levels.WARN)
    end

    -- Glow setup for preview
    require('glow').setup({
        width_ratio = 0.6, -- width of the Glow window divided by the neovim window width
        height_ratio = 1.0,
        border = "shadow", -- floating window border config
        style = "dark",
        pager = false,
    })

    -- Auto-commands for markdown files
    vim.api.nvim_create_augroup("Markdown", { clear = true })

    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = "Markdown",
        pattern = { "*.md", "*.markdown" },
        callback = function()
            vim.lsp.buf.format({
                timeout_ms = 1000,
                filter = function(client)
                    return client.name == "null-ls"
                end,
            })
        end,
    })

    -- Keymaps for Glow preview
    vim.api.nvim_create_autocmd("FileType", {
        group = "Markdown",
        pattern = { "markdown" },
        callback = function()
            -- Open preview in a vertical split to the right
            vim.keymap.set("n", "<leader>p", ":Glow<CR>",
                { buffer = true, desc = "Preview Markdown" })
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
end

