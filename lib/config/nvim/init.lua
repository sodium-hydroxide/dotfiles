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
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "jose-elias-alvarez/null-ls.nvim",
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        config = function()
            -- Method 1: Direct import of language configs
            local language = require('languages')
            language({
                require('languages.config.python'),
                require('languages.config.shell'),
                -- Add more languages as needed
            })
        end
    },
    require('plugins.keybindings')  --> Which key support
}, {
    checker = {enabled = true, notify = false,},
    change_detection = {notify = false,},
})

require('options.ui')
require('options.whitespace')
require('options.diagnostics')
require('options.navigation')
require('modes')

