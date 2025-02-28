return {
  {
    "benlubas/molten-nvim",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      -- Use active virtualenv if it exists, otherwise fall back to global
      local venv = os.getenv('VIRTUAL_ENV')
      if venv then
        vim.g.python3_host_prog = venv .. '/bin/python'
      else
        vim.g.python3_host_prog = vim.fn.expand('~/.venv/bin/python')
      end

      -- Rest of the configuration
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true

      -- Key mappings (you can change localleader to whatever you prefer)
      vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>')
      vim.keymap.set('n', '<localleader>me', ':MoltenEvaluateOperator<CR>')
      vim.keymap.set('n', '<localleader>mr', ':MoltenReevaluateCell<CR>')
      vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>')
    end,
    ft = { "python" },
  }
}

