-- Set vi paste buffer to work with system buffer
vim.opt.clipboard = unnamedplus
vim.keymap.set({'n', 'v'}, 'y', '"+y')
vim.keymap.set({'n', 'v'}, 'd', '"+d')
vim.keymap.set({'n', 'v'}, 'p', '"+p')
