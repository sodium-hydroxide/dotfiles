-- ------  Setup Lazy  ----------------------------------------------------------|
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable",
--     lazypath,
--   })
-- end
-- --

-- vim.opt.rtp:prepend(lazypath)
-- vim.g.mapleader = " "               --> sets leader key
-- vim.g.maplocalleader = "\\"         --> sets local leader key
-- vim.g.python3_host_prog=vim.fn.expand("~/.venv/bin/python3")

-- local plugins = require("plugins")
-- local opts = {
--     defaults = {
--         lazy = false,
--     },
--     checker = {
--         enabled = true,
--         notify = false,
--     },
--     change_detection = {
--         notify = false,
--     },
--     hooks = {
--       post_install = function()
--         vim.fn.system('nvim --headless +UpdateRemotePlugins +qall')
--       end,
--       post_update = function()
--         vim.fn.system('nvim --headless +UpdateRemotePlugins +qall')
--       end,
--     },
-- }

-- require("lazy").setup(plugins, opts)
-- require("core").setup()

-- -- Todo
-- --  - molten / magma / notebook stuff
-- --      - quarto especially would be nice
-- --  - something like command pallete in vscode
-- --  - attachting to docker session (especially running code)
-- --  - adding dependencies like node and others to the config to autoload as needed
-- --  - previewing for pdfs and other files
