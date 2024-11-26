-- init.lua

-- Bootstrap lazy.nvim
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
vim.opt.rtp:prepend(lazypath)

-- Load options
require("config.options")


-- Initialize lazy.nvim
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("lazy").setup("plugins")

-- Reload config keybind
vim.keymap.set('n', '<leader>r', ':source $MYVIMRC<CR>', { silent = true, desc = "Reload init.lua" })



--  -- -- Set leader key
--  -- vim.g.mapleader = " "
--  -- 
--  -- -- General options
--  -- vim.opt.number = true
--  -- vim.opt.relativenumber = false
--  -- 
--  -- vim.opt.shortmess = "I"
--  -- 
--  -- -- Whitespace characters
--  -- vim.opt.list = true
--  -- vim.opt.listchars = {
--  --     tab = "»·",
--  --     trail = "~",
--  --     nbsp = "‡",
--  --     extends = "›",
--  --     precedes = "‹",
--  --     space = "⋅",
--  --     eol = "¬"
--  -- }
--  -- 
--  -- -- Indentation settings
--  -- vim.opt.tabstop = 4
--  -- vim.opt.shiftwidth = 4
--  -- vim.opt.expandtab = true
--  -- vim.opt.smartindent = true
--  -- vim.opt.wrap = false
--  -- 
--  -- -- Editor display
--  -- vim.opt.cursorline = true
--  -- vim.opt.fixendofline = true
--  -- vim.opt.fixeol = true
--  -- 
--  -- -- File handling
--  -- vim.opt.swapfile = false
--  -- vim.opt.backup = false
--  -- vim.opt.undofile = false
--  -- 
--  -- -- Search
--  -- vim.opt.hlsearch = false
--  -- 
--  -- -- UI settings
--  -- vim.opt.termguicolors = false
--  -- vim.opt.scrolloff = 8
--  -- vim.opt.signcolumn = "yes"
--  -- vim.opt.updatetime = 50
--  -- vim.opt.colorcolumn = "80"
--  -- 
--  -- vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
--  -- vim.opt.mouse = "a"  -- Enable mouse support
--  -- vim.opt.scrolloff = 8  -- Keep 8 lines above/below cursor when scrolling
--  -- 
--  -- -- Keymaps
--  -- vim.keymap.set('n', '<leader>v', '<cmd>CHADopen<cr>')
--  -- vim.keymap.set('n', '<C-h>', '<C-w>h')
--  -- vim.keymap.set('n', '<C-j>', '<C-w>j')
--  -- vim.keymap.set('n', '<C-k>', '<C-w>k')
--  -- vim.keymap.set('n', '<C-l>', '<C-w>l')
--  -- vim.keymap.set('n', '<leader>r', ':source $MYVIMRC<CR>', { silent = true, desc = "Reload init.lua" })
--  -- 
--  -- -- Search
--  -- vim.opt.ignorecase = true
--  -- vim.opt.smartcase = true
--  -- vim.opt.hlsearch = true
--  -- vim.opt.incsearch = true
--  -- 
--  -- 
--  -- 
--  -- 
