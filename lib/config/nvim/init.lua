-- Neovim Configuration
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
vim.g.mapleader = " "               -- sets leader key
vim.g.maplocalleader = "\\"         -- sets local leader key
vim.g.theme_choice = "github_light" -- Sets the theme
vim.keymap.set(                     -- Reload vim config
    'n',
    '<leader>r',
    ':source $MYVIMRC<CR>',
    { noremap = true, silent = true }
)

-- Extensions
require("lazy").setup({
    require('theme'),               -- UI Theme
    require('filetree'),            -- File Browsing
    -- require('buffer'),              -- Show open buffers
    require('terminal'),            -- Terminal Emulator
    require('hex-edit'),            -- Hex Editor
    require('languages'),           -- LSP + Syntax Highlighting
}, {
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})

-- Other Settings
require('ui')                   -- General UI Settings
require('paste')                -- Paste Buffer
require('whitespace')           -- Rendering and trimming whitespace

