vim.g.have_nerd_font = true    -- Using Nerd Font
vim.opt.termguicolors = true   -- Render themes correctly
vim.opt.number = true          -- Display Line Numbers
vim.opt.relativenumber = false -- Relative line numbers
vim.opt.mouse = "a"
vim.opt.shortmess = "I"        -- Hide startup message
vim.opt.mousemodel = "popup"   -- Hide mouse unless being used
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = false -- Use absolute numbering
vim.opt.syntax = "ON"          -- Syntax highlighting
vim.opt.backup = false         -- Suppress backup files
vim.opt.wrap = true            -- Wrap text
vim.opt.tabstop = 4            -- 4 spaces for a tab
vim.opt.shiftwidth = 4         -- Same as tabstop
vim.opt.expandtab = true       -- Expand tabs to spaces
vim.opt.smartindent = true     -- Indent files correctly
vim.opt.cursorline = true      -- Show cursor
vim.opt.fixendofline = true    -- Fix EOL
vim.opt.fixeol = true          -- Fix EOL
vim.opt.colorcolumn = "80"     -- Render at 80 char
vim.opt.showmode = false
vim.schedule(function()        -- Use same clipboard as OS
  vim.opt.clipboard = "unnamedplus"
end)
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true    -- Save undo history
vim.opt.ignorecase = true  -- Case insensitive searching
vim.opt.smartcase = true   -- Case insensitive searching
vim.opt.signcolumn = "yes" -- Keep signcolumn on by default
vim.opt.updatetime = 550   -- Decrease update time
vim.opt.timeoutlen = 300   -- Decrease mapped sequence wait time
vim.opt.splitright = true  -- Configure how new splits should be opened
vim.opt.splitbelow = true  -- Configure how new splits should be opened
vim.opt.list = true        -- Rendering of whitespace
vim.opt.listchars = {
  tab = "»·",
  trail = "~",
  nbsp = "‡",
  extends = "›",
  precedes = "‹",
  space = "⋅",
  eol = "¬",
}
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
vim.opt.cursorline = true    -- Show which line your cursor is on
vim.opt.scrolloff = 10       -- Minimal # of screen lines to keep above and below the cursor.
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- Trim Whitespace on Save
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
