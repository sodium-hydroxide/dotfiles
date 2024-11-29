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
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                -- Default mappings
                api.config.mappings.default_on_attach(bufnr)
            end,
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 30,
                relativenumber = false,
                float = {
                    enable = false,
                    quit_on_focus_loss = true,
                },
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
            actions = {
                open_file = {
                    quit_on_open = false,
                    resize_window = true,
                },
            },
            notify = {
                threshold = vim.log.levels.WARN,
            },
            log = {
                enable = true,
                truncate = true,
                types = {
                    all = false,
                    config = false,
                    copy_paste = false,
                    diagnostics = false,
                    git = false,
                    profile = false,
                },
            },
        },
        config = function(_, opts)
            -- Ensure that nvim-tree handles the case where a buffer already exists
            local function open_nvim_tree(data)
                local directory = vim.fn.isdirectory(data.file) == 1
                if not directory then
                    return
                end
                vim.cmd.cd(data.file)
                require("nvim-tree.api").tree.open()
            end

            vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
            require("nvim-tree").setup(opts)
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        event = "VeryLazy",
        keys = {
            { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
            { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
            { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Toggle vertical terminal" },
        },
        config = function()
            require("toggleterm").setup({
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
            })
        end,
    }
}

