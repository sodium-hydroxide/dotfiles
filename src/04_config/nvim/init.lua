-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",       "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before loading plugins
vim.g.mapleader = " "

-- Disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Basic editor options
vim.opt.number = true         -- Show line numbers
vim.opt.mouse = "a"          -- Enable mouse support
vim.opt.termguicolors = false -- Enable 24-bit colors

-- Initialize lazy.nvim with our plugins
require("lazy").setup({
    -- Our UI enhancement package
    {
        "sodium-hydroxide/nvim-ui",
        dependencies = {
            "nvim-tree/nvim-tree.lua",
            "nvim-tree/nvim-web-devicons",
            "akinsho/toggleterm.nvim",
            "nvim-telescope/telescope.nvim",
            "folke/which-key.nvim",
            "nvim-lua/plenary.nvim",  -- Required by telescope
        },
        config = function()
            -- The package will use default settings if we pass an empty table
            require("nvim-ui").setup({})
        end,
    },

     -- MCNP development package
     {
         "sodium-hydroxide/nvim-mcnp",
         dependencies = {
             "L3MON4D3/LuaSnip",
             "hrsh7th/nvim-cmp",
             "nvim-treesitter/nvim-treesitter",
         },
         config = function()
             require("nvim-mcnp").setup({})
         end,
         ft = { "mcnp" },  -- Load only for MCNP files
     },
  
    -- Bash development package
    {
        "sodium-hydroxide/nvim-bash",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "jose-elias-alvarez/null-ls.nvim",
            "L3MON4D3/LuaSnip",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("nvim-bash").setup({})
        end,
        ft = { "sh", "bash", "zsh" },
    },
    -- Python development package
    {
        "sodium-hydroxide/nvim-python",
        dependencies = {
            "neovim/nvim-lspconfig",
            "jose-elias-alvarez/null-ls.nvim",
            "nvim-treesitter/nvim-treesitter",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            require("nvim-python").setup({
                -- Optional: override default options
                venv_path = "~/.venv",
                format_on_save = true
            })
        end
    },
})
