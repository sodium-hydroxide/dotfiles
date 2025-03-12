local M = {}

-- Setup function accepts an optional options table.
-- Pass a theme name via opts.theme; valid values:
-- "github_light", "catppuccin_latte", "catppuccin_frappe",
-- "catppuccin_macchiato", or "catppuccin_mocha".
function M.setup(opts)
  opts = opts or {}
  local theme_name = opts.theme or "github_light"

  -- Define available themes.
  local themes = {
    github_light = {
      bkg = "light",
      colors = {
        bg        = "#ffffff",
        fg        = "#24292e",
        gray      = "#6a737d",
        green     = "#22863a",
        blue      = "#0366d6",
        purple    = "#6f42c1",
        red       = "#d73a49",
        orange    = "#e36209",
        yellow    = "#f9c513",
        line_bg   = "#f6f8fa",
        selection = "#c8e1ff",
        comment   = "#6a737d",
        gutter    = "#f6f8fa",
      },
    },
    catppuccin_latte = {
      bkg = "light",
      colors = {
        bg        = "#eff1f5",
        fg        = "#4c4f69",
        gray      = "#6c6f85",
        green     = "#40a02b",
        blue      = "#1e66f5",
        purple    = "#8839ef",
        red       = "#d20f39",
        orange    = "#fe640b",
        yellow    = "#df8e1d",
        line_bg   = "#ccd0da",
        selection = "#c8e1ff",  -- You can adjust this to taste.
        comment   = "#6c6f85",
        gutter    = "#eff1f5",
      },
    },
    catppuccin_frappe = {
      bkg = "dark",
      colors = {
        bg        = "#303446",
        fg        = "#c6d0f5",
        gray      = "#a5adce",
        green     = "#a6d189",
        blue      = "#8caaee",
        purple    = "#ca9ee6",
        red       = "#e78284",
        orange    = "#ef9f76",
        yellow    = "#e5c890",
        line_bg   = "#414559",
        selection = "#99d1db",
        comment   = "#626880",
        gutter    = "#303446",
      },
    },
    catppuccin_macchiato = {
      bkg = "dark",
      colors = {
        bg        = "#24273a",
        fg        = "#cad3f5",
        gray      = "#a5adcb",
        green     = "#a6da95",
        blue      = "#8aadf4",
        purple    = "#c6a0f6",
        red       = "#ed8796",
        orange    = "#f5a97f",
        yellow    = "#eed49f",
        line_bg   = "#363a4f",
        selection = "#91d7e3",
        comment   = "#939ab7",
        gutter    = "#24273a",
      },
    },
    catppuccin_mocha = {
      bkg = "dark",
      colors = {
        bg        = "#1e1e2e",
        fg        = "#cdd6f4",
        gray      = "#a6adc8",
        green     = "#a6e3a1",
        blue      = "#89b4fa",
        purple    = "#cba6f7",
        red       = "#f38ba8",
        orange    = "#fab387",
        yellow    = "#f9e2af",
        line_bg   = "#313244",
        selection = "#89dceb",
        comment   = "#9399b2",
        gutter    = "#1e1e2e",
      },
    },
  }

  local theme = themes[theme_name] or themes.github_light
  local colors = theme.colors

  -- Clear previous highlights and reset syntax if enabled.
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  -- Set the Neovim background (light or dark) according to the theme.
  vim.opt.background = theme.bkg

  -- Set terminal colors.
  vim.g.terminal_color_0  = colors.fg
  vim.g.terminal_color_1  = colors.red
  vim.g.terminal_color_2  = colors.green
  vim.g.terminal_color_3  = colors.yellow
  vim.g.terminal_color_4  = colors.blue
  vim.g.terminal_color_5  = colors.purple
  vim.g.terminal_color_6  = colors.blue
  vim.g.terminal_color_7  = colors.fg
  vim.g.terminal_color_8  = colors.gray
  vim.g.terminal_color_9  = colors.red
  vim.g.terminal_color_10 = colors.green
  vim.g.terminal_color_11 = colors.yellow
  vim.g.terminal_color_12 = colors.blue
  vim.g.terminal_color_13 = colors.purple
  vim.g.terminal_color_14 = colors.blue
  vim.g.terminal_color_15 = colors.fg

  -- Define editor highlight groups.
  local highlights = {
    Normal       = { fg = colors.fg, bg = colors.bg },
    LineNr       = { fg = colors.gray, bg = colors.gutter },
    CursorLine   = { bg = colors.line_bg },
    CursorLineNr = { fg = colors.fg, bg = colors.line_bg },
    Visual       = { bg = colors.selection },
    Search       = { fg = colors.fg, bg = colors.yellow },
    IncSearch    = { fg = colors.fg, bg = colors.yellow },
    ColorColumn  = { bg = colors.line_bg },
    SignColumn   = { bg = colors.gutter },
    Pmenu        = { fg = colors.fg, bg = colors.line_bg },
    PmenuSel     = { fg = colors.bg, bg = colors.blue },
    MatchParen   = { fg = colors.blue, bold = true },
    Comment      = { fg = colors.comment, italic = true },
    Constant     = { fg = colors.blue },
    String       = { fg = colors.blue },
    Character    = { fg = colors.blue },
    Number       = { fg = colors.blue },
    Boolean      = { fg = colors.blue },
    Float        = { fg = colors.blue },
    Identifier   = { fg = colors.purple },
    Function     = { fg = colors.purple },
    Statement    = { fg = colors.red },
    Keyword      = { fg = colors.red },
    Type         = { fg = colors.red },
    Special      = { fg = colors.blue },
    Error        = { fg = colors.red },
    Todo         = { fg = colors.purple },
    Underlined   = { fg = colors.blue, underline = true },
  }

  -- Apply the highlights.
  for group, settings in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, settings)
  end
end

return M


-- local M = {}

-- function M.setup()
--     -- Reset all highlighting to default
--     vim.cmd('highlight clear')
--     if vim.fn.exists('syntax_on') then
--         vim.cmd('syntax reset')
--     end

--     -- Set background to light
--     local themes = {
--         github_light = {
--             bkg = "light",
--             colors = {
--                 bg = '#ffffff',
--                 fg = '#24292e',
--                 gray = '#6a737d',
--                 green = '#22863a',
--                 blue = '#0366d6',
--                 purple = '#6f42c1',
--                 red = '#d73a49',
--                 orange = '#e36209',
--                 yellow = '#f9c513',
--                 line_bg = '#f6f8fa',
--                 selection = '#c8e1ff',
--                 comment = '#6a737d',
--                 gutter = '#f6f8fa'
--             }
--         }
--     }
--     local theme = themes.github_light
--     vim.opt.background = theme.bkg

--     -- Color palette
--     local colors = theme.colors

--     -- Set terminal colors
--     vim.g.terminal_color_0 = colors.fg
--     vim.g.terminal_color_1 = colors.red
--     vim.g.terminal_color_2 = colors.green
--     vim.g.terminal_color_3 = colors.yellow
--     vim.g.terminal_color_4 = colors.blue
--     vim.g.terminal_color_5 = colors.purple
--     vim.g.terminal_color_6 = colors.blue
--     vim.g.terminal_color_7 = colors.fg
--     vim.g.terminal_color_8 = colors.gray
--     vim.g.terminal_color_9 = colors.red
--     vim.g.terminal_color_10 = colors.green
--     vim.g.terminal_color_11 = colors.yellow
--     vim.g.terminal_color_12 = colors.blue
--     vim.g.terminal_color_13 = colors.purple
--     vim.g.terminal_color_14 = colors.blue
--     vim.g.terminal_color_15 = colors.fg

--     -- Set editor colors
--     local highlights = {
--         Normal = { fg = colors.fg, bg = colors.bg },
--         LineNr = { fg = colors.gray, bg = colors.gutter },
--         CursorLine = { bg = colors.line_bg },
--         CursorLineNr = { fg = colors.fg, bg = colors.line_bg },
--         Visual = { bg = colors.selection },
--         Search = { fg = colors.fg, bg = colors.yellow },
--         IncSearch = { fg = colors.fg, bg = colors.yellow },
--         ColorColumn = { bg = colors.line_bg },
--         SignColumn = { bg = colors.gutter },
--         Pmenu = { fg = colors.fg, bg = colors.line_bg },
--         PmenuSel = { fg = colors.bg, bg = colors.blue },
--         MatchParen = { fg = colors.blue, bold = true },
--         Comment = { fg = colors.comment, italic = true },
--         Constant = { fg = colors.blue },
--         String = { fg = colors.blue },
--         Character = { fg = colors.blue },
--         Number = { fg = colors.blue },
--         Boolean = { fg = colors.blue },
--         Float = { fg = colors.blue },
--         Identifier = { fg = colors.purple },
--         Function = { fg = colors.purple },
--         Statement = { fg = colors.red },
--         Keyword = { fg = colors.red },
--         Type = { fg = colors.red },
--         Special = { fg = colors.blue },
--         Error = { fg = colors.red },
--         Todo = { fg = colors.purple },
--         Underlined = { fg = colors.blue, underline = true },
--     }

--     -- Apply highlights
--     for group, settings in pairs(highlights) do
--         vim.api.nvim_set_hl(0, group, settings)
--     end
-- end

-- return M
