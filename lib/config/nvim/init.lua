------  Setup Lazy  ----------------------------------------------------------|
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end


------  Important Globals
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "               --> sets leader key
vim.g.maplocalleader = "\\"         --> sets local leader key
vim.g.theme_choice = "github_dark"   --> Sets the theme
vim.opt.termguicolors = true        --> Disable theme when open in terminal


------  Extensions
require("lazy").setup({
    require('theme'),            --> UI Theme
    require('filetree'),            --> File Browsing
    -- require('buffer'),           --> Show open buffers
    require('terminal'),            --> Terminal Emulator
    require('hex-edit'),            --> Hex Editor
    require('languages'),           --> LSP + Syntax Highlighting
}, {
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})


------  General UI Settings
vim.opt.shortmess = "I"             --> Hide startup message
vim.opt.mouse = "a"                 --> Allow mouse to be used
vim.opt.mousemodel = "popup"        --> Hide mouse unless being used
vim.opt.number = true               --> show line numbers
vim.opt.relativenumber = false      --> use absolute numbering
vim.opt.syntax = "ON"               --> syntax highlighting
vim.opt.backup = false              --> supress generation of backup files
vim.opt.wrap = true                 --> wrap text


------  Navigation around different windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })


------  Set VI Paste Buffer
vim.opt.clipboard = unnamedplus
vim.keymap.set({'n', 'v'}, 'y', '"+y')
vim.keymap.set({'n', 'v'}, 'd', '"+d')
vim.keymap.set({'n', 'v'}, 'p', '"+p')


------  Whitespace Handling
vim.opt.tabstop = 4                 --> 4 spaces for a tab
vim.opt.shiftwidth = 4              --> ''
vim.opt.expandtab = true            --> expand tabs to spaces
vim.opt.smartindent = true          --> indent files correctly
vim.opt.list = true                 --> render whitespace
vim.opt.listchars = {               --> specific whitespace to render
    tab = "»·",
    trail = "~",
    nbsp = "‡",
    extends = "›",
    precedes = "‹",
    space = "⋅",
    eol = "¬"
}
vim.opt.cursorline = true           --> Show cursor
vim.opt.fixendofline = true         -->
vim.opt.fixeol = true               -->
vim.opt.colorcolumn = "80"          --> Render at 80 char


------  Handle Whitespace on Save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      -- Save cursor position
      local curpos = vim.api.nvim_win_get_cursor(0)
      -- Trim trailing whitespace
      vim.cmd([[%s/\s\+$//e]])
      -- Trim trailing newlines while ensuring single final newline
      -- Go to last line
      vim.cmd([[
        silent! %s/\($\n\s*\)\+\%$//e
        silent! call append(line('$'), '')
      ]])
      -- Restore cursor position
      vim.api.nvim_win_set_cursor(0, curpos)
    end,
  })

