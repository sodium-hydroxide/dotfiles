-- lua/core/options.lua
local M = {}

function M.setup()
    local options = {
        shortmess = "I",             -- Hide startup message
        mouse = "a",                 -- Allow mouse to be used
        mousemodel = "popup",        -- Hide mouse unless being used
        number = true,               -- Show line numbers
        relativenumber = false,      -- Use absolute numbering
        syntax = "ON",               -- Syntax highlighting
        backup = false,              -- Suppress backup files
        wrap = true,                 -- Wrap text
        clipboard = "unnamedplus",   -- Use system clipboard

        -- Whitespace handling
        tabstop = 4,                 -- 4 spaces for a tab
        shiftwidth = 4,              -- Same as tabstop
        expandtab = true,            -- Expand tabs to spaces
        smartindent = true,          -- Indent files correctly

        -- UI elements
        cursorline = true,           -- Show cursor
        fixendofline = true,         -- Fix EOL
        fixeol = true,               -- Fix EOL
        colorcolumn = "80",          -- Render at 80 char
    }

    -- Apply all options
    for k, v in pairs(options) do
        vim.opt[k] = v
    end
end

return M
