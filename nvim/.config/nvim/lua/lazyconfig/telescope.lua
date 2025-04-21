      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
local M = {}

-- Custom picker: Commands + Keymaps
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values

local function palette_commands_keymaps(opts)
  opts = opts or {}

  -- 1) Gather all Ex commands
  local entries = {}
  for _, cmd in ipairs(vim.fn.getcompletion('', 'command')) do
    table.insert(entries, {
      label = string.format('[CMD]  %s', cmd),
      ord   = cmd,
      kind  = 'command',
      cmd   = cmd,
    })
  end

  -- 2) Gather normal- and visual-mode keymaps
  for _, mode in ipairs({ 'n', 'v' }) do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      -- Protect against mappings without an explicit RHS
      local lhs = km.lhs or ''
      local rhs = km.rhs or ''
      -- Skip unmapped or empty entries if desired
      -- if rhs == '' then goto continue end
      table.insert(entries, {
        label = string.format('[KMAP] %s → %s', lhs, rhs),
        ord   = lhs .. rhs,
        kind  = 'keymap',
        lhs   = lhs,
      })
      -- ::continue::
    end
  end

  -- 3) Create and show the picker
  pickers.new(opts, {
    prompt_title = ' Commands & Keymaps',
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          value   = entry,
          display = entry.label,
          ordinal = entry.ord,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local function run_selection()
        local sel = action_state.get_selected_entry().value
        actions.close(prompt_bufnr)
        if sel.kind == 'command' then
          vim.cmd(sel.cmd)
        else
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(sel.lhs, true, false, true),
            'n', false
          )
        end
      end
      map('i', '<CR>', run_selection)
      map('n', '<CR>', run_selection)
      return true
    end,
  }):find()
end
function M.setup()
  -- Telescope core setup
  require('telescope').setup({
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  })

  -- Load Telescope extensions
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- Common builtin pickers
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
  vim.keymap.set('n', '<leader>bf', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Fuzzy search in current buffer
  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- Live grep in open files
  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
  end, { desc = '[S]earch [/] in Open Files' })

  -- Search Neovim config files
  vim.keymap.set('n', '<leader>sn', function()
    builtin.find_files({ cwd = vim.fn.stdpath('config') })
  end, { desc = '[S]earch [N]eovim files' })

  -- Command Palette + Keymaps
  vim.keymap.set('n', '<leader><leader>', palette_commands_keymaps, { desc = 'Command Palette + Keymaps' })
end

return M
