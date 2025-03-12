-- lua/core/autocmds.lua
local M = {}

function M.setup()
    -- Handle whitespace on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
            local curpos = vim.api.nvim_win_get_cursor(0)
            vim.cmd([[%s/\s\+$//e]])
            vim.cmd([[
                silent! %s/\($\n\s*\)\+\%$//e
                silent! call append(line('$'), '')
            ]])
            vim.api.nvim_win_set_cursor(0, curpos)
        end,
    })
end

return M
