local M = {}

function M.setup()
    -- Reset all highlighting to default
    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') then
        vim.cmd('syntax reset')
    end

    -- Set background to light
    vim.opt.background = 'light'

    -- Color palette
    local colors = {
        bg = '#ffffff',
        fg = '#24292e',
        gray = '#6a737d',
        green = '#22863a',
        blue = '#0366d6',
        purple = '#6f42c1',
        red = '#d73a49',
        orange = '#e36209',
        yellow = '#f9c513',
        line_bg = '#f6f8fa',
        selection = '#c8e1ff',
        comment = '#6a737d',
        gutter = '#f6f8fa'
    }

    -- Set terminal colors
    vim.g.terminal_color_0 = colors.fg
    vim.g.terminal_color_1 = colors.red
    vim.g.terminal_color_2 = colors.green
    vim.g.terminal_color_3 = colors.yellow
    vim.g.terminal_color_4 = colors.blue
    vim.g.terminal_color_5 = colors.purple
    vim.g.terminal_color_6 = colors.blue
    vim.g.terminal_color_7 = colors.fg
    vim.g.terminal_color_8 = colors.gray
    vim.g.terminal_color_9 = colors.red
    vim.g.terminal_color_10 = colors.green
    vim.g.terminal_color_11 = colors.yellow
    vim.g.terminal_color_12 = colors.blue
    vim.g.terminal_color_13 = colors.purple
    vim.g.terminal_color_14 = colors.blue
    vim.g.terminal_color_15 = colors.fg

    -- Set editor colors
    local highlights = {
        Normal = { fg = colors.fg, bg = colors.bg },
        LineNr = { fg = colors.gray, bg = colors.gutter },
        CursorLine = { bg = colors.line_bg },
        CursorLineNr = { fg = colors.fg, bg = colors.line_bg },
        Visual = { bg = colors.selection },
        Search = { fg = colors.fg, bg = colors.yellow },
        IncSearch = { fg = colors.fg, bg = colors.yellow },
        ColorColumn = { bg = colors.line_bg },
        SignColumn = { bg = colors.gutter },
        Pmenu = { fg = colors.fg, bg = colors.line_bg },
        PmenuSel = { fg = colors.bg, bg = colors.blue },
        MatchParen = { fg = colors.blue, bold = true },
        Comment = { fg = colors.comment, italic = true },
        Constant = { fg = colors.blue },
        String = { fg = colors.blue },
        Character = { fg = colors.blue },
        Number = { fg = colors.blue },
        Boolean = { fg = colors.blue },
        Float = { fg = colors.blue },
        Identifier = { fg = colors.purple },
        Function = { fg = colors.purple },
        Statement = { fg = colors.red },
        Keyword = { fg = colors.red },
        Type = { fg = colors.red },
        Special = { fg = colors.blue },
        Error = { fg = colors.red },
        Todo = { fg = colors.purple },
        Underlined = { fg = colors.blue, underline = true },
    }

    -- Apply highlights
    for group, settings in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, settings)
    end
end

return M
