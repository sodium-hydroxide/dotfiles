local M = {}

M.ensure_installed = function(tool_type, tools)
    if type(tools) ~= "table" then return end
    local mason_registry = require("mason-registry")
    for _, tool in ipairs(tools) do
        if not mason_registry.is_installed(tool) then
            vim.notify("Installing " .. tool, vim.log.levels.INFO)
            mason_registry.get_package(tool):install()
        end
    end
end

M.setup_lsp = function(config)
    if not config or not config.servers then return end
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    for server, settings in pairs(config.servers) do
        if lspconfig[server] then
            -- Merge default capabilities with user settings
            local config = vim.tbl_deep_extend("force",
                { capabilities = capabilities },
                settings or {}
            )
            lspconfig[server].setup(config)
        else
            vim.notify("LSP " .. server .. " not found", vim.log.levels.WARN)
        end
    end
end


M.setup_cmp = function(config)
    if not config then return end

    local ok, cmp = pcall(require, 'cmp')
    if not ok then
        vim.notify("nvim-cmp is not available", vim.log.levels.ERROR)
        return
    end

    -- Default mappings that will be used if none provided
    local default_mappings = {
        ['<C-CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }

    -- Convert user-provided mapping definitions to actual cmp mappings
    local mappings = {}
    if config.mapping then
        for key, action in pairs(config.mapping) do
            if action == 'confirm' then
                mappings[key] = cmp.mapping.confirm({ select = true })
            elseif action == 'complete' then
                mappings[key] = cmp.mapping.complete()
            end
        end
    end

    -- Merge default mappings with user mappings, giving priority to user mappings
    local final_mappings = vim.tbl_extend('force',
        default_mappings,
        mappings
    )

    cmp.setup.filetype(config.filetypes or {}, {
        sources = config.sources or {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
        },
        mapping = vim.tbl_extend('force', cmp.mapping.preset.insert(), final_mappings),
        completion = {
            autocomplete = true,
            completeopt = 'menu,menuone,noinsert',
        },
        experimental = {
            ghost_text = true,
        },
    })
end


M.setup_preview = function(config, lang_name)
    if not config then return end

    -- Setup keymap for preview if provided
    if config.keymap and config.command then
        vim.api.nvim_create_autocmd("FileType", {
            pattern = string.lower(lang_name),
            callback = function()
                vim.keymap.set("n", config.keymap,
                    function()
                        vim.cmd(config.command)
                    end,
                    { buffer = true, desc = "Preview " .. lang_name }
                )
            end
        })
    end
end


M.setup_formatter = function(config)
    if not config then return end
    local null_ls = require("null-ls")
    local sources = {}

    for formatter, settings in pairs(config) do
        local formatter_builtins = null_ls.builtins.formatting
        if formatter_builtins[formatter] then
            table.insert(sources,
                formatter_builtins[formatter].with(settings)
            )
        else
            vim.notify("Formatter " .. formatter .. " not found", vim.log.levels.WARN)
        end
    end

    null_ls.setup({
        sources = sources,
        -- You might want to add default settings here
        on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                })
            end
        end,
    })
end

M.setup_dap = function(config)
    if not config then return end
    local dap = require("dap")
    -- Setup DAP based on config
end

M.setup_treesitter = function(lang)
    if not lang then return end
    require('nvim-treesitter.configs').setup({
        ensure_installed = { lang },
        highlight = { enable = true },
        indent = { enable = true },
    })
end

return M

