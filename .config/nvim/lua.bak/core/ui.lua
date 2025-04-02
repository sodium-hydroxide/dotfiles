-- lua/core/ui.lua
local M = {}

function M.setup()
    -- Whitespace rendering
    vim.opt.list = true
    vim.opt.listchars = {
        tab = "»·",
        trail = "~",
        nbsp = "‡",
        extends = "›",
        precedes = "‹",
        space = "⋅",
        eol = "¬"
    }

    -- Terminal colors
    vim.opt.termguicolors = true


end

return M
