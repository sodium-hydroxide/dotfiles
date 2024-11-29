return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make'
            }
        },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Show Keymaps" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
            { "<leader>p", "<cmd>Telescope commands<cr>", desc = "Commands" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = "❯ ",
                    selection_caret = "❯ ",
                    path_display = { "truncate" },
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = {
                            mirror = false,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    highlights = {
                        TelescopeSelection = { bg = "#E5E5E5" },
                        TelescopeMatching = { fg = "#0F68A0" },
                        TelescopePromptPrefix = { fg = "#262626" },
                        TelescopePromptNormal = { bg = "#ffffff" },
                        TelescopeResultsNormal = { bg = "#ffffff" },
                        TelescopePreviewNormal = { bg = "#ffffff" },
                        TelescopePromptBorder = { bg = "#ffffff", fg = "#dddddd" },
                        TelescopeResultsBorder = { bg = "#ffffff", fg = "#dddddd" },
                        TelescopePreviewBorder = { bg = "#ffffff", fg = "#dddddd" },
                        TelescopePromptTitle = { bg = "#ffffff", fg = "#262626" },
                        TelescopeResultsTitle = { bg = "#ffffff", fg = "#262626" },
                        TelescopePreviewTitle = { bg = "#ffffff", fg = "#262626" },
                    },
                    mappings = {
                        i = {
                            ["<C-n>"] = actions.cycle_history_next,
                            ["<C-p>"] = actions.cycle_history_prev,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-c>"] = actions.close,
                            ["<CR>"] = actions.select_default,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        },
                        n = {
                            ["<esc>"] = actions.close,
                            ["q"] = actions.close,
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["H"] = actions.move_to_top,
                            ["M"] = actions.move_to_middle,
                            ["L"] = actions.move_to_bottom,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                        previewer = false,
                        hidden = true,
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                    git_files = {
                        theme = "dropdown",
                        previewer = false,
                    },
                    buffers = {
                        theme = "dropdown",
                        previewer = false,
                    },
                    commands = {
                        theme = "dropdown",
                    },
                    keymaps = {
                        theme = "dropdown",
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })

            -- Load extensions
            pcall(telescope.load_extension, "fzf")
        end
    },
-------------------------------------------------------------------------------
    {
        "folke/which-key.nvim",
        version = "*",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
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
                icons = {
                    breadcrumb = "»",
                    separator = "➜",
                    group = "+",
                },
                layout = {
                    height = { min = 4, max = 25 },
                    width = { min = 20, max = 50 },
                    spacing = 3,
                    align = "left",
                },
            })

            -- Register mappings using the new syntax
            wk.register({
                -- Leader mappings
                { "<leader>b", group = "Buffer" },
                { "<leader>c", group = "Code" },
                { "<leader>f", group = "Find/Files" },
                { "<leader>g", group = "Git" },
                { "<leader>t", group = "Terminal" },
                { "<leader>w", group = "Window" },

                -- LSP mappings
                { "g", group = "Goto" },
                { "gD", vim.lsp.buf.declaration, desc = "Declaration" },
                { "gd", vim.lsp.buf.definition, desc = "Definition" },
                { "gi", vim.lsp.buf.implementation, desc = "Implementation" },
                { "gr", vim.lsp.buf.references, desc = "References" },

                -- Telescope mappings
                { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
                { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
                { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
                { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
                { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
                { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
                { "<leader>p", "<cmd>Telescope commands<cr>", desc = "Commands" },

                -- Terminal mappings
                { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float Terminal" },
                { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Horizontal Terminal" },
                { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical Terminal" },
            })
        end
    }

}

