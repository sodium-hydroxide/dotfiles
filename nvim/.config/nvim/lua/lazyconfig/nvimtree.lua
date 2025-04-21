local M = {}

function M.config()
  -- 1) plugin setup
  require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          file          = true,
          folder        = true,
          folder_arrow  = true,
          git           = true,
          modified      = true,
        },
        modified_placement = "after",
        glyphs = {
          modified = "●",
        },
      },
      highlight_opened_files = "all",
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
      },
      change_dir = {
        enable = true,
        global = false,
      },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      -- load default mappings
      api.config.mappings.default_on_attach(bufnr)
    end,
  })

  -- 2) define a custom command :TreeToggle
  vim.api.nvim_create_user_command("TreeToggle",
    function()
      require("nvim-tree.api").tree.toggle()
    end,
    { desc = "Toggle the Nvim‑Tree sidebar" }
  )
end

return M
