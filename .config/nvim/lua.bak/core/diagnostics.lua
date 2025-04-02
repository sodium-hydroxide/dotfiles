-- lua/core/diagnostics.lua
local M = {}

function M.setup()
    local config = {
        float = {
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
            width = 80,
            wrap = true,
            focus = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        },
        virtual_text = {
            prefix = '●',
            format = function(diagnostic)
                local message = diagnostic.message
                if #message > 30 then
                    message = string.sub(message, 1, 27) .. "..."
                end
                local code = diagnostic.code or
                            (diagnostic.user_data and
                             diagnostic.user_data.lsp and
                             diagnostic.user_data.lsp.code)
                if code then
                    return string.format("[%s] %s", code, message)
                end
                return message
            end,
            spacing = 4,
        },
        signs = {
            priority = 20,
            text = {
                [vim.diagnostic.severity.ERROR] = "E",
                [vim.diagnostic.severity.WARN] = "W",
                [vim.diagnostic.severity.INFO] = "I",
                [vim.diagnostic.severity.HINT] = "H",
            }
        },
        severity_sort = true,
        update_in_insert = false,
    }

    vim.diagnostic.config(config)
end

return M
