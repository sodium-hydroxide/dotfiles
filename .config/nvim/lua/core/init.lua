-- lua/core/init.lua
local M = {}

function M.setup()
    -- Load core modules in a specific order
    -- Order matters here because some settings might depend on others

    -- Basic options should load first as other modules might depend on them
    require('core.options').setup()

    -- UI settings can load next since they're fundamental but independent
    require('core.ui').setup()
    require('core.theme').setup()

    -- Diagnostics should load before keymaps since some keymaps might use diagnostic functions
    require('core.diagnostics').setup()

    -- Keymaps can load after diagnostics since they might reference diagnostic commands
    require('core.keymaps').setup()

    -- Autocommands can load last as they often depend on settings from other modules
    require('core.autocmds').setup()
end

return M
