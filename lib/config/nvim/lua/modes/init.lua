local M = {}

-- Table to store our mode configurations
M.modes = {}

-- Function to register a new mode
function M.register_mode(name, setup_fn)
    M.modes[name] = setup_fn
end

-- Function to load and execute a mode
function M.load_mode(mode_name)
    -- If no mode is specified or mode doesn't exist, fall back to default
    if not mode_name or not M.modes[mode_name] then
        if M.modes["default"] then
            M.modes["default"]()
        end
        return
    end

    -- Execute the requested mode setup
    M.modes[mode_name]()
end

return M

