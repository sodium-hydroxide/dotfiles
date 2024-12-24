
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

-- Basic vim options
vim.g.mapleader = " "
vim.opt.number = false
vim.opt.fillchars = { eob = " " }  -- Remove ~ from empty lines

-- Plugin specifications
require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 40,
          side = "left",
        },
        renderer = {
          icons = {
            glyphs = {
              default = "",
              symlink = "",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")

          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- Custom mappings
          vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 't', api.node.open.tab, opts('Open Tab'))
        end,
      })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = function(term)
          if term.direction == "horizontal" then
            return vim.o.lines * 0.8
          end
        end,
        start_in_insert = true,
        on_open = function(term)
          -- Start in insert mode and home directory
          vim.cmd("startinsert!")
          term:send("cd ~\n")
        end,
      })
    end,
  },
})

-- Auto open nvim-tree and terminal on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
    vim.cmd("ToggleTerm")
  end
})

-- Keymaps
vim.keymap.set('n', '<C-t>', ':ToggleTerm<CR>')
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:ToggleTerm<CR>')

