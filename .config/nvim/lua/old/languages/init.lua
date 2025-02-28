local utils = require("languages.utils")

local function setup_base_tools()
    -- Ensure base tools are installed
    require("mason").setup()
    require("mason-lspconfig").setup()
    require("nvim-treesitter").setup()
end

local function language(configs)
    if type(configs) ~= "table" then
        vim.notify("Invalid language configuration", vim.log.levels.ERROR)
        return
    end

    setup_base_tools()

    for _, config in ipairs(configs) do
        -- Validate config
        if not config.name then
            vim.notify("Language configuration missing name", vim.log.levels.WARN)
            goto continue
        end

        -- Setup components
        if config.lsp then
            utils.setup_lsp(config.lsp)
        end

        if config.formatter then
            utils.setup_formatter(config.formatter)
        end

        if config.dap then
            utils.setup_dap(config.dap)
        end

        if config.cmp then
            utils.setup_cmp(config.cmp)
        end

        if config.preview then
            utils.setup_preview(config.preview, config.name)
        end

        if config.treesitter then
            utils.setup_treesitter(config.treesitter)
        end

        -- Setup terminal command if provided
        if config.terminal then
            -- Create the terminal command
            vim.api.nvim_create_user_command(
                'Terminal' .. config.name,
                config.terminal,
                {}
            )
        end


        -- Setup syntax highlighting if provided
        if config.syntax then
            -- Handle both string and table syntax definitions
            if type(config.syntax) == "string" then
                vim.cmd(config.syntax)
            elseif type(config.syntax) == "table" then
                for _, rule in ipairs(config.syntax) do
                    vim.cmd(rule)
                end
            end
        end

        ::continue::
    end
end

return language

