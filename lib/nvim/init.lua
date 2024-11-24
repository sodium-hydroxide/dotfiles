-- Set leader key
vim.g.mapleader = " "

-- General options
vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.shortmess = "I"

-- Whitespace characters
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

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Editor display
vim.opt.cursorline = true
vim.opt.fixendofline = true
vim.opt.fixeol = true

-- File handling
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false

-- Search
vim.opt.hlsearch = false

-- UI settings
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Keymaps
vim.keymap.set('n', '<leader>v', '<cmd>CHADopen<cr>')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')  -- Fixed: was missing 'j'
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
