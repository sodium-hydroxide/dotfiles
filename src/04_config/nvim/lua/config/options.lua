local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = " "

-- General options
opt.number = true
opt.relativenumber = false
opt.shortmess = "I"

-- Whitespace characters
opt.list = true
opt.listchars = {
    tab = "»·",
    trail = "~",
    nbsp = "‡",
    extends = "›",
    precedes = "‹",
    space = "⋅",
    eol = "¬"
}

-- Indentation settings
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- Editor display
opt.cursorline = true
opt.fixendofline = true
opt.fixeol = true
opt.colorcolumn = "80"
opt.termguicolors = false

opt.mouse = "a"
opt.mousemodel = "popup"



