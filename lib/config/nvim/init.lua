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
vim.g.mapleader = " "           -- sets leader key
vim.keymap.set(                 -- Reload vim config
    'n',
    '<leader>r',
    ':source $MYVIMRC<CR>',
    { noremap = true, silent = true }
)

-- Extensions
require("lazy").setup({
    require("filetree"),        -- File Browsing
    require('terminal'),        -- Terminal Emulator
    require('hex-edit'),        -- Hex Editor
    require('cmp-lsp'),         -- Language Server Protocol
    require('cmp-lsp-python'),  -- Python Support
    require('cmp-lsp-shell')    -- Shell Support
    -- C-language
    -- Markdown
    -- LaTeX
    -- Rust
    -- Haskell
    -- Perl
    -- Scheme
    -- R-lang
    -- FORTRAN
    -- MCNP
    --
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
