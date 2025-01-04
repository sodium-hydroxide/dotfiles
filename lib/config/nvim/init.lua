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
vim.g.theme_choice = "github_light" --> Sets the theme
vim.opt.termguicolors = true        --> Disable theme when open in terminal

------  Extensions
require("lazy").setup({
    require('plugins.theme'),       --> UI Theme
    require('plugins.filetree'),    --> File Browsing
    require('plugins.terminal'),    --> Terminal Emulator
    require('plugins.hex-edit'),    --> Hex Editor
    require('plugins.fold'),        --> Code folding
    require('plugins.status'),      --> Status Line
    -- require('plugins.buffers'),      --> Status Line
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

require('options.ui')
require('options.whitespace')
require('options.diagnostics')
require('options.navigation')

