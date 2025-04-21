local M = {}

function M.setup()
  require("toggleterm").setup {
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.3)
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.8)
      end
      return 20
    end,
    shade_terminals = true,
    start_in_insert = true,
    direction       = "horizontal",
    float_opts      = {
      border = "curved",
      width  = math.floor(vim.o.columns * 0.85),
      height = math.floor(vim.o.lines   * 0.85),
    },
    shell      = os.getenv("INTERACTIVE_SHELL"),
    shell_args = { "--login" },
  }

  vim.api.nvim_create_user_command("TermFloat",
    "ToggleTerm direction=float",
    { desc = "Toggle a floating terminal" }
  )
  vim.api.nvim_create_user_command("TermHorizontal",
    "ToggleTerm direction=horizontal",
    { desc = "Toggle a horizontal split terminal" }
  )
  vim.api.nvim_create_user_command("TermVertical",
    "ToggleTerm direction=vertical",
    { desc = "Toggle a vertical split terminal" }
  )
end

return M
