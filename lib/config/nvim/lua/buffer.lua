return {
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({
        options = {
          -- Enable close button
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          -- Separator style
          separator_style = "slant",
          -- Show buffer numbers
          numbers = "ordinal",
          -- Enable mouse actions
          diagnostics = "nvim_lsp",
          -- Show close icon
          show_close_icon = true,
          -- Show buffer icons
          show_buffer_icons = true,
          -- Show unsaved changes indicator
          modified_icon = '●',
          -- Always show tabs
          always_show_bufferline = true,
        }
      })

      -- Keymaps
      local opts = { noremap = true, silent = true }

      -- Navigate between buffers
      vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', opts)
      vim.keymap.set('n', '<S-l>', '<cmd>BufferLineNext<CR>', opts)

      -- Jump to buffer using numbers
      vim.keymap.set('n', '<leader>1', '<cmd>BufferLineGoToBuffer 1<CR>', opts)
      vim.keymap.set('n', '<leader>2', '<cmd>BufferLineGoToBuffer 2<CR>', opts)
      vim.keymap.set('n', '<leader>3', '<cmd>BufferLineGoToBuffer 3<CR>', opts)
      vim.keymap.set('n', '<leader>4', '<cmd>BufferLineGoToBuffer 4<CR>', opts)
      vim.keymap.set('n', '<leader>5', '<cmd>BufferLineGoToBuffer 5<CR>', opts)

      -- Buffer picking and closing
      vim.keymap.set('n', '<leader>p', '<cmd>BufferLinePick<CR>', opts)
      vim.keymap.set('n', '<leader>x', '<cmd>BufferLinePickClose<CR>', opts)
    end,
  }
}

