-- ~/.config/nvim/lua/modes/utils.lua
local M = {}

-- Function to set the working directory from environment variable
function M.set_working_directory()
    local working_dir = vim.env.NVIM_WORKING_DIR
    if working_dir then
        -- Change Neovim's working directory
        vim.cmd('cd ' .. vim.fn.fnameescape(working_dir))
    end
end

-- Function to get the current working directory for terminals
function M.get_terminal_cwd()
    return vim.env.NVIM_WORKING_DIR or vim.fn.getcwd()
end

return M

-- Modify ~/.config/nvim/lua/modes/ide.lua to use the working directory
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

