-- lua/terminal.lua
return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                else
                    return 20
                end
            end,
            open_mapping = [[<c-\>]],
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            persist_size = true,
            direction = 'float',
            float_opts = {
                border = 'curved',
                winblend = 0,
            },
        })

        -- Custom terminal functions
        local Terminal = require('toggleterm.terminal').Terminal

        -- Create different terminal types
        local float_term = Terminal:new({ direction = "float" })
        local vertical_term = Terminal:new({ direction = "vertical" })
        local horizontal_term = Terminal:new({ direction = "horizontal" })

        -- Function to toggle specific terminal types
        local function toggle_float()
            float_term:toggle()
        end

        local function toggle_vertical()
            vertical_term:toggle()
        end

        local function toggle_horizontal()
            horizontal_term:toggle()
        end

        -- Keymaps
        vim.keymap.set('n', '<leader>tf', toggle_float, { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>tv', toggle_vertical, { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>th', toggle_horizontal, { noremap = true, silent = true })

        -- Terminal navigation
        function _G.set_terminal_keymaps()
            local opts = {buffer = 0}
            -- Exit terminal mode
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            -- Better terminal navigation
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        end

        -- Auto-apply terminal keymaps
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end
}
