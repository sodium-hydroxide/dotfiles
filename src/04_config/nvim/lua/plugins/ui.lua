return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- Optional, for file icons
        },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
            { "<leader>o", "<cmd>NvimTreeFocus<cr>", desc = "Focus NvimTree" },
        },
        opts = {
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 30,
                relativenumber = false,
            },
            renderer = {
                group_empty = true,
                highlight_git = true,
                icons = {
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                    },
                },
            },
            filters = {
                dotfiles = false,
            },
            git = {
                enable = true,
                ignore = false,
            },
        },
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        keys = {
            { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
            { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
            { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Toggle vertical terminal" },
        },
        opts = {
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-\>]], -- Use Ctrl+\ to toggle terminal
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = 'float',
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = 'curved',
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                }
            }
        }
    }
}
