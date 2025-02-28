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
--

vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "               --> sets leader key
vim.g.maplocalleader = "\\"         --> sets local leader key

local plugins = require("plugins")
local opts = {
    defaults = {
        lazy = false,
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
}
require("lazy").setup(plugins, opts)

require("core").setup()
