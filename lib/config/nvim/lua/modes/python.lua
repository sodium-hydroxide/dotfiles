local M = {}

function M.setup()
    -- Set up NvimTree
    require('nvim-tree').setup{}
    vim.cmd('NvimTreeOpen')
    vim.cmd('wincmd l')  -- Move cursor to main window

    -- Configure ToggleTerm
    require('toggleterm').setup{
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            end
        end,
    }

    -- Open and configure terminal windows
    local Terminal = require('toggleterm.terminal').Terminal

    -- First terminal with virtual environment
    local term1 = Terminal:new({
        cmd = "source .venv/bin/activate",
        direction = "horizontal",
        count = 1
    })

    -- Second terminal with IPython
    local term2 = Terminal:new({
        cmd = "source .venv/bin/activate && ipython",
        direction = "horizontal",
        count = 2
    })

    -- Open terminals
    term1:toggle()
    term2:toggle()
end

return M

