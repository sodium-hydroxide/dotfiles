-- General UI Settings
vim.opt.shortmess = "I"         -- Hide startup message
vim.opt.mouse = "a"             -- Allow mouse to be used
vim.opt.mousemodel = "popup"    -- Hide mouse unless being used
vim.opt.number = true           -- show line numbers
vim.opt.relativenumber = false  -- use absolute numbering
vim.opt.syntax = "ON"           -- syntax highlighting
vim.opt.backup = false          -- supress generation of backup files
vim.opt.wrap = true             -- wrap text

-- Navigation around different windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

