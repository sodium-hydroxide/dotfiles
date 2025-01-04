local M = {}

function M.setup()
    -- Set up NvimTree with the correct working directory
    require('nvim-tree').setup{
        update_cwd = false,  -- Prevent NvimTree from changing the working directory
        respect_buf_cwd = false,  -- Don't change based on buffer directory
    }
    vim.cmd('NvimTreeOpen')
    vim.cmd('wincmd l')  -- Move cursor to main window

    -- Set up terminal with the correct working directory
    require('toggleterm').setup{
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            end
        end,
        dir = require('modes.utils').get_terminal_cwd(),  -- Use our utility function
    }

    local Terminal = require('toggleterm.terminal').Terminal
    local term = Terminal:new({
        direction = "horizontal",
        -- Terminal will inherit the working directory we set
    })
    term:toggle()
end

return M

