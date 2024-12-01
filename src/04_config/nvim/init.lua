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

-- Set leader key before loading plugins
vim.g.mapleader = " "

-- Set which-key health check warnings (set to true to disable warnings)
vim.g.which_key_ignore_health_warning = false

-- Initialize lazy.nvim with our plugins
require("lazy").setup({
    {
        "sodium-hydroxide/nvim-ui",
        dependencies = {
            "nvim-tree/nvim-tree.lua",
            "nvim-tree/nvim-web-devicons",
            "akinsho/toggleterm.nvim",
            "nvim-telescope/telescope.nvim",
            "folke/which-key.nvim",
            "nvim-lualine/lualine.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("nvim-ui").setup({
                settings = {display = {termguicolors = false}},
                statusline = {
                    theme = "auto",           -- Use colorscheme colors
                    global_status = true,     -- Use global statusline
                    sections = {
                        -- Override any section configurations here
                        lualine_c = {
                            {
                                "filename",
                                path = 1,     -- Show relative path
                                symbols = {
                                    modified = "●",
                                    readonly = "",
                                    unnamed = "[No Name]",
                                },
                            },
                        },
                    },
                },
            })
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
        ft = { "mcnp", "in", ".in" },  -- Load only for MCNP files
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
