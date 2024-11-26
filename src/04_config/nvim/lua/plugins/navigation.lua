return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make'
            }
        },
        keys = {
            -- Command palette style keybinding
            { "<leader>p", "<cmd>Telescope commands<cr>", desc = "Command Palette" },
            -- Other useful Telescope bindings
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Show Keymaps" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<esc>"] = actions.close
                        },
                    },
                    layout_config = {
                        prompt_position = "top",
                    },
                    sorting_strategy = "ascending",
                },
                pickers = {
                    commands = {
                        theme = "dropdown",
                        previewer = false,
                    },
                    keymaps = {
                        theme = "dropdown",
                        previewer = false,
                    }
                },
            })
            
            -- Enable fzf native for better performance
            telescope.load_extension('fzf')
        end
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            
            wk.setup({
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                    presets = {
                        operators = true,
                        motions = true,
                        text_objects = true,
                        windows = true,
                        nav = true,
                        z = true,
                        g = true,
                    },
                },
                window = {
                    border = "single",
                    position = "bottom",
                    margin = { 1, 0, 1, 0 },
                    padding = { 1, 2, 1, 2 },
                },
                layout = {
                    height = { min = 4, max = 25 },
                    width = { min = 20, max = 50 },
                    spacing = 3,
                    align = "left",
                },
                show_help = true,
                show_keys = true,
            })

            -- Register groups for better organization
            wk.register({
                ["<leader>"] = {
                    f = { name = "Find/Files" },
                    t = { name = "Terminal" },
                },
            })
        end
    }
}
