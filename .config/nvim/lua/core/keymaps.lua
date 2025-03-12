local M = {}

-- Helper function for mapping keys
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Leader keys
function M.setup()
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"

    -- General mappings
    ----------------
    -- Clipboard operations
    map({'n', 'v'}, 'y', '"+y')
    map({'n', 'v'}, 'd', '"+d')
    map({'n', 'v'}, 'p', '"+p')

    -- Window navigation
    map('n', '<C-h>', '<C-w>h')
    map('n', '<C-j>', '<C-w>j')
    map('n', '<C-k>', '<C-w>k')
    map('n', '<C-l>', '<C-w>l')

    -- Text wrapping
    map('n', '<leader>w', ':set wrap!<CR>', { desc = "Toggle word wrap" })

    -- File explorer
    map('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = "Toggle file explorer" })
    map('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle file explorer" })

    -- Diagnostic navigation
    map('n', '<leader>r', vim.diagnostic.open_float, { desc = "Show diagnostic details" })
    map('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    map('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    map('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })

    -- Terminal mappings
    local terminal_maps = {
        ['<leader>tf'] = 'float',       -- toggle float term
        ['<leader>tv'] = 'vertical',    -- toggle vertical term
        ['<leader>th'] = 'horizontal'   -- toggle horizontal term
    }

    -- Terminal navigation (will be applied in terminal mode)
    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
            local term_maps = {
                ['<esc><esc>'] = [[<C-\><C-n>]],  -- Double ESC to go to normal mode
                ['<C-h>'] = [[<Cmd>wincmd h<CR>]], -- Move to left window
                ['<C-j>'] = [[<Cmd>wincmd j<CR>]], -- Move to bottom window
                ['<C-k>'] = [[<Cmd>wincmd k<CR>]], -- Move to top window
                ['<C-l>'] = [[<Cmd>wincmd l<CR>]], -- Move to right window
            }
            for k, v in pairs(term_maps) do
                map('t', k, v, { buffer = 0 })
            end
        end,
    })

    -- Which Key integration
    map('n', '<leader>?', function()
        require("which-key").show({ global = false })
    end, { desc = "Buffer Local Keymaps (which-key)" })
end

return M
