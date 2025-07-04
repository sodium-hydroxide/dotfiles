local neovim = {
    options     = {},
    mcnp_syntax = {},
    themes      = {},
    keymappings = {},
    utils       = {},
    plugins     = { config = {} }
}
function neovim.utils.get_repl_cmd(cwd, filetype)
    local candidates_by_ft = {
        python = {
            -- each entry is either a literal command or a function that returns { cmd, args… }
            function()
                local venv = cwd .. "/.venv/bin/ipython"
                if vim.fn.executable(venv) == 1 then return { venv } end
            end,
            function()
                local venv_py = cwd .. "/.venv/bin/python"
                if vim.fn.executable(venv_py) == 1 then return { venv_py, "-i" } end
            end,
            function()
                if vim.fn.executable("ipython") == 1 then return { "ipython" } end
            end,
            function()
                if vim.fn.executable("python") == 1 then return { "python", "-i" } end
            end,
        },
        julia = {
            function()
                local sys_jl = cwd .. "/.julia/bin/julia"
                if vim.fn.executable(sys_jl) == 1 then return { sys_jl, "--startup-file=no" } end
            end,
            function()
                if vim.fn.executable("julia") == 1 then return { "julia", "--startup-file=no" } end
            end,
        },
        r = {
            function()
                if vim.fn.executable("R") == 1 then return { "R", "--no-save", "--no-restore" } end
            end,
        },
        -- add more ft’s here…
    }

    local candidates = candidates_by_ft[filetype]
    if not candidates then
        return nil
    end

    for _, probe in ipairs(candidates) do
        local cmd = probe()
        if cmd then
            return cmd
        end
    end

    return nil
end

function neovim.utils.python_foldexpr(lnum)
    local line = vim.fn.getline(lnum)

    -- 1) Jupyter-style cell marker: start a new fold one level deeper
    if line:match("^%s*#%s*%%+") then
        -- 'a1' means "add 1 to previous foldlevel" → start a new fold here
        return "a1"
    end

    -- 2) Blank lines: mark undefined so Vim uses surrounding foldlevel
    if line:match("^%s*$") then
        return "-1"
    end

    -- 3) Other comments: fold at the same level as the previous line
    if line:match("^%s*#") then
        return "="
    end

    -- 4) Everything else: indent-based folding
    local indent = vim.fn.indent(lnum)
    local sw     = vim.bo.shiftwidth
    local lvl    = math.floor(indent / sw)
    return tostring(lvl)
end

function _G.custom_foldexpr(lnum)
    local line = vim.fn.getline(lnum)
    -- If it’s a region start…
    if line:match("^%s*region:") then
        return "a1" -- add a new fold
        -- If it’s a region end…
    elseif line:match("^%s*endregion:") then
        return "s1" -- close that fold
    end
    -- Otherwise defer to Tree-sitter’s foldexpr
    return vim.fn["nvim_treesitter#foldexpr"](lnum)
end

function neovim.options.setup(confopts)
    local opt          = vim.opt
    opt.number         = true
    opt.relativenumber = false
    opt.mouse          = "a"
    opt.mousemodel     = "popup" -- optional: default
    opt.backup         = false
    opt.wrap           = true
    opt.tabstop        = 2 -- 2‑space tabs
    opt.shiftwidth     = 2
    opt.expandtab      = true
    opt.smartindent    = true
    opt.cursorline     = false -- can slow down performance
    opt.colorcolumn    = "80"
    opt.showmode       = false
    opt.clipboard      = "unnamedplus"
    opt.breakindent    = true
    opt.undofile       = true
    opt.ignorecase     = true
    opt.smartcase      = true
    opt.signcolumn     = "yes"
    opt.updatetime     = 550
    opt.timeoutlen     = 300
    opt.splitright     = true
    opt.splitbelow     = true
    opt.list           = true
    opt.listchars      = {
        tab = "» ",
        trail = "~",
        nbsp = "‡",
        extends = "›",
        precedes = "‹",
        space = "⋅",
        eol = "¬",
    }
    opt.inccommand     = "split"
    opt.scrolloff      = 10
end

function neovim.folds(opts)
    -- Global: use expr-folding by default (you’ll override for Python below)
    vim.opt.foldmethod     = "expr"
    vim.opt.foldexpr       = "nvim_treesitter#foldexpr()"
    vim.opt.foldlevel      = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable     = true

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            vim.opt_local.foldmethod     = "expr"
            vim.opt_local.foldexpr       = 'v:lua.vim.treesitter.foldexpr()'
            vim.opt_local.foldlevel      = 99
            vim.opt_local.foldlevelstart = 99
            vim.opt_local.foldenable     = true
        end,
    })

    -- Python files: use our custom function
    -- vim.api.nvim_create_autocmd("FileType", {
    --     pattern = "python",
    --     callback = function()
    --         local lopt          = vim.opt_local
    --         lopt.foldmethod     = "expr"
    --         lopt.foldexpr       = "v:lua.neovim.utils.python_foldexpr(v:lnum)"
    --         lopt.foldlevelstart = 1 -- start with all folds closed beyond level 1
    --         lopt.foldcolumn     = "1"
    --     end,
    -- })
end

function neovim.mcnp_syntax.setup(opts)
    opts = opts or {}
    local extensions = opts.extensions or { "mcnp", "in" }

    -- Build file patterns from the given extensions (e.g. "*.mcnp")
    local patterns = {}
    for _, ext in ipairs(extensions) do
        table.insert(patterns, "*." .. ext)
    end

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = patterns,
        callback = function()
            vim.cmd([[
        if version < 600
          syntax clear
        elseif exists("b:current_syntax")
          finish
        endif

        syn case ignore

        " ------------- Generals -------------------------------------------------------
        " --- Unprocessed
        " Header
        syn match imcnpUnitHeader	display "\%1l.\+$"
        " Comments
        syn match imcnpComment		display "\%1cc$"
        syn match imcnpComment		display "\%1cc\s.*$"
        syn match imcnpComment		display "\$.*$"
        " --- Commons
        " Characterizig
        syn keyword imcnpKeyword	n
        " --- Numbers of various sorts
        " Integers
        syn match imcnpLabelNumber	display "[-+*#]\=\d\+r\="
        " floating points
        syn match imcnpFloat		display "[-+]\=\d\{2,}\.\d*"
        syn match imcnpFloat		display "[-+]\=\d\=\.\d*\(e[-+]\=\d\+\)\="

        " ------------- Cell cards -----------------------------------------------------
        " descriptives
        syn keyword imcnpKeyword	like but imp ext mat rho vol tmp area trcl u fill lat

        " ------------- Surface cards --------------------------------------------------
        " Surfaces
        syn keyword imcnpType		px py pz p cx cy cz so s sx sy sz kx ky kz sq gq tx ty tz x y z
        syn match imcnpType		"\<[ck]/[xyz]\>"
        " Macrobodies
        syn keyword imcnpType		box rpp sph rcc rhp hex rec trc ell wed arb nlib

        " ------------- Tally cards ----------------------------------------------------
        " --- Materials cards
        " mat number
        syn match imcnpTodo		"m[t]\=\d\+"
        " ENDF library
        syn match imcnpType		display "\<\d\{2,6}\.\d\d[cdytpuemg]\>"
        " --- Tallies cards
        " Tally
        syn match imcnpTodo		"f\(\(mesh\)\|[cqmsut]\)\=\d*"
        syn match imcnpTodo		"e[m]\=\d*"
        syn match imcnpTodo		"t[mf]\=\d\+"
        syn match imcnpTodo		"c[mf]\=\d\+"
        syn match imcnpTodo		"d[efd\(xt\)]\=\d\+"
        syn match imcnpTodo		"s[fd]\=\d\+"
        syn keyword imcnpKeyword	geom origin imesh iints jmesh jints kmesh kints emesh eints out factor
        " Comments
        syn region imcnpComment matchgroup=imcnpTodo start="[sf]c\d\+" end="$" contains=imcnpComment
        " syn match imcnpComment
        " --- Source cards
        " Generic
        syn keyword imcnpKeyword	ksrc sdef
        " Definition
        syn keyword imcnpKeyword	ssw ssr ipt icl jsu cel sur par tr pos rad axs dir vec nrm ccc ara eff erg tme wgt
        " Distribution
        "syn match imcnpTodo		"d\d\+"
        "syn match imcnpTodo		"s[ipbc]\d\+"
        "syn match imcnpTodo		"ds\d\+"
        "syn match imcnpTodo		"tr\d\+"
        " --- Mode cards
        " Simulation
        syn keyword imcnpKeyword	mode kcode
        " Output
        syn keyword imcnpKeyword	print
        syn keyword imcnpType		col cf ij ik jk

        " READ card
        syn keyword imcnpKeyword    read echo noecho
        syn region imcnpType    start=/file\s*=\s*/   end=/\s/ end=/$/
        syn region imcnpComment start=/encode\s*=\s*/ end=/\s/ end=/$/
        syn region imcnpComment start=/decode\s*=\s*/ end=/\s/ end=/$/

        "Catch errors caused by too many right parentheses
        syn region imcnpParen transparent start="(" end=")" contains=ALLBUT,imcnpParenError,@imcnpCommentGroup,cIncluded,@spell
        syn match  imcnpParenError   ")"
        syn region imcnpParen transparent start="\[" end="\]" contains=ALLBUT,imcnpParenError,@imcnpCommentGroup,cIncluded,@spell
        syn match  imcnpParenError   "\]"

        syn match imcnpOperator		"="
        syn match imcnpOperator		":"
        syn match imcnpOperator		"<"

        " Define the default highlighting.
        " For version 5.7 and earlier: only when not done already
        " For version 5.8 and later: only when an item doesn't have highlighting yet
        if version >= 508 || !exists("did_imcnp_syn_inits")
          if version < 508
            let did_imcnp_syn_inits = 1
            command -nargs=+ HiLink hi link <args>
          else
            command -nargs=+ HiLink hi def link <args>
          endif

          HiLink imcnpKeyword	 	Keyword
          HiLink imcnpConstructName	Identifier
          HiLink imcnpConditional	Conditional
          HiLink imcnpRepeat		Repeat
          HiLink imcnpTodo		Todo
          HiLink imcnpContinueMark	Todo
          HiLink imcnpString		String
          HiLink imcnpNumber		Number
          HiLink imcnpOperator		Operator
          HiLink imcnpBoolean		Boolean
          HiLink imcnpLabelError	Error
          HiLink imcnpObsolete		Todo
          HiLink imcnpType		Type
          HiLink imcnpStructure		Type
          HiLink imcnpStorageClass	StorageClass
          HiLink imcnpUnitHeader	Identifier
          HiLink imcnpReadWrite		Keyword
          HiLink imcnpIO		Keyword
          HiLink imcnp90Intrinsic	Function

          HiLink imcnpInclude		Include

          HiLink imcnpLabelNumber	Special
          HiLink imcnpTarget		Special
          HiLink imcnpFormatSpec	Identifier

          HiLink imcnpFloat		Float
          HiLink imcnpPreCondit		PreCondit
          HiLink imcnpInclude		Include
          HiLink cIncluded		imcnpString
          HiLink cInclude		Include
          HiLink cPreProc		PreProc
          HiLink cPreCondit		PreCondit
          HiLink imcnpParenError	Error
          HiLink imcnpComment		Comment
          HiLink imcnpSerialNumber	Todo
          HiLink imcnpTab		Error

          delcommand HiLink
        endif

        let b:current_syntax = "mcnp"
        set sw=6 ts=6
        set expandtab
        set smarttab
        set list "invisible characters cause trouble with mcnp
      ]])
        end
    })
end

function neovim.themes.setup(opts)
    -- Setup function accepts an optional options table.
    -- Pass a theme name via opts.theme; valid values:
    -- "github_light", "catppuccin_latte", "catppuccin_frappe",
    -- "catppuccin_macchiato", or "catppuccin_mocha".
    opts = opts or {}
    local theme_name = opts.theme or "github_light"

    -- Define available themes.
    local themes = {
        github_light = {
            bkg = "light",
            colors = {
                bg        = "#ffffff",
                fg        = "#24292e",
                gray      = "#6a737d",
                green     = "#22863a",
                blue      = "#0366d6",
                purple    = "#6f42c1",
                red       = "#d73a49",
                orange    = "#e36209",
                yellow    = "#f9c513",
                line_bg   = "#f6f8fa",
                selection = "#c8e1ff",
                comment   = "#6a737d",
                gutter    = "#f6f8fa",
            },
        },
        catppuccin_latte = {
            bkg = "light",
            colors = {
                bg        = "#eff1f5",
                fg        = "#4c4f69",
                gray      = "#6c6f85",
                green     = "#40a02b",
                blue      = "#1e66f5",
                purple    = "#8839ef",
                red       = "#d20f39",
                orange    = "#fe640b",
                yellow    = "#df8e1d",
                line_bg   = "#ccd0da",
                selection = "#c8e1ff", -- You can adjust this to taste.
                comment   = "#6c6f85",
                gutter    = "#eff1f5",
            },
        },
        catppuccin_frappe = {
            bkg = "dark",
            colors = {
                bg        = "#303446",
                fg        = "#c6d0f5",
                gray      = "#a5adce",
                green     = "#a6d189",
                blue      = "#8caaee",
                purple    = "#ca9ee6",
                red       = "#e78284",
                orange    = "#ef9f76",
                yellow    = "#e5c890",
                line_bg   = "#414559",
                selection = "#99d1db",
                comment   = "#626880",
                gutter    = "#303446",
            },
        },
        catppuccin_macchiato = {
            bkg = "dark",
            colors = {
                bg        = "#24273a",
                fg        = "#cad3f5",
                gray      = "#a5adcb",
                green     = "#a6da95",
                blue      = "#8aadf4",
                purple    = "#c6a0f6",
                red       = "#ed8796",
                orange    = "#f5a97f",
                yellow    = "#eed49f",
                line_bg   = "#363a4f",
                selection = "#91d7e3",
                comment   = "#939ab7",
                gutter    = "#24273a",
            },
        },
        catppuccin_mocha = {
            bkg = "dark",
            colors = {
                bg        = "#1e1e2e",
                fg        = "#cdd6f4",
                gray      = "#a6adc8",
                green     = "#a6e3a1",
                blue      = "#89b4fa",
                purple    = "#cba6f7",
                red       = "#f38ba8",
                orange    = "#fab387",
                yellow    = "#f9e2af",
                line_bg   = "#313244",
                selection = "#89dceb",
                comment   = "#9399b2",
                gutter    = "#1e1e2e",
            },
        },
    }

    local theme = themes[theme_name] or themes.github_light
    local colors = theme.colors

    -- Clear previous highlights and reset syntax if enabled.
    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') then
        vim.cmd('syntax reset')
    end

    -- Set the Neovim background (light or dark) according to the theme.
    vim.opt.background      = theme.bkg

    -- Set terminal colors.
    vim.g.terminal_color_0  = colors.fg
    vim.g.terminal_color_1  = colors.red
    vim.g.terminal_color_2  = colors.green
    vim.g.terminal_color_3  = colors.yellow
    vim.g.terminal_color_4  = colors.blue
    vim.g.terminal_color_5  = colors.purple
    vim.g.terminal_color_6  = colors.blue
    vim.g.terminal_color_7  = colors.fg
    vim.g.terminal_color_8  = colors.gray
    vim.g.terminal_color_9  = colors.red
    vim.g.terminal_color_10 = colors.green
    vim.g.terminal_color_11 = colors.yellow
    vim.g.terminal_color_12 = colors.blue
    vim.g.terminal_color_13 = colors.purple
    vim.g.terminal_color_14 = colors.blue
    vim.g.terminal_color_15 = colors.fg

    -- Define editor highlight groups.
    local highlights        = {
        Normal       = { fg = colors.fg, bg = colors.bg },
        LineNr       = { fg = colors.gray, bg = colors.gutter },
        CursorLine   = { bg = colors.line_bg },
        CursorLineNr = { fg = colors.fg, bg = colors.line_bg },
        Visual       = { bg = colors.selection },
        Search       = { fg = colors.fg, bg = colors.yellow },
        IncSearch    = { fg = colors.fg, bg = colors.yellow },
        ColorColumn  = { bg = colors.line_bg },
        SignColumn   = { bg = colors.gutter },
        Pmenu        = { fg = colors.fg, bg = colors.line_bg },
        PmenuSel     = { fg = colors.bg, bg = colors.blue },
        MatchParen   = { fg = colors.blue, bold = true },
        Comment      = { fg = colors.comment, italic = true },
        Constant     = { fg = colors.blue },
        String       = { fg = colors.blue },
        Character    = { fg = colors.blue },
        Number       = { fg = colors.blue },
        Boolean      = { fg = colors.blue },
        Float        = { fg = colors.blue },
        Identifier   = { fg = colors.purple },
        Function     = { fg = colors.purple },
        Statement    = { fg = colors.red },
        Keyword      = { fg = colors.red },
        Type         = { fg = colors.red },
        Special      = { fg = colors.blue },
        Error        = { fg = colors.red },
        Todo         = { fg = colors.purple },
        Underlined   = { fg = colors.blue, underline = true },
    }

    -- Apply the highlights.
    for group, settings in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, settings)
    end
end

function neovim.keymappings.setup(opts)
    local function map(mode, lhs, rhs, opts)
        local options = { noremap = true, silent = true }
        if opts then
            options = vim.tbl_extend("force", options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
    end
    map("n", "<Esc>", "<cmd>nohlsearch<CR>")
    map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
    map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
    map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
    map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
    map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
    map("n", "<leader>w", ":set wrap!<CR>", { desc = "Toggle word wrap" })
    map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
end

function neovim.plugins.bootstrap(opts)
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            error("Error cloning lazy.nvim:\n" .. out)
        end
    end ---@diagnostic disable-next-line: undefined-field
    vim.opt.rtp:prepend(lazypath)
    require("lazy").setup(opts, {
        ui = { icons = {} },
    })
end

function neovim.plugins.config.vim_sleuth(confopts)
    -- Detect tabstop and shiftwidth automatically
    return "tpope/vim-sleuth"
end

function neovim.plugins.config.gitsigns(confopts)
    -- Adds git related signs to the gutter
    local opts = {
        signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
        },
    }
    return {
        "lewis6991/gitsigns.nvim",
        opts = opts
    }
end

function neovim.plugins.config.conform(confopts)
    -- autoformatter
    local opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true, tex = true, latex = true }
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
                lsp_format_opt = "never"
            else
                lsp_format_opt = "fallback"
            end
            return {
                timeout_ms = 500,
                lsp_format = lsp_format_opt,
            }
        end,
        formatters_by_ft = {
            -- lua = { "stylua" },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use 'stop_after_first' to run the first available formatter from the list
            -- javascript = { "prettierd", "prettier", stop_after_first = true },
            python = { "ruff_format" },
        },
        formatters = {
            ruff_format = {
                command = "ruff",
                args = {
                    "format",
                    "--line-length=80",
                    "--stdin-filename",
                    "$FILENAME", "-"
                }
            }
        }
    }
    return {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "",
                desc = "[F]ormat buffer",
            },
        },
        opts = opts,
    }
end

function neovim.plugins.config.nvim_tree(confopts)
    local function config()
        require("nvim-tree").setup({
            sort_by = "case_sensitive",
            view = {
                width = 30,
                side  = "right",
            },
            renderer = {
                group_empty = true,
                icons = {
                    show = {
                        file         = true,
                        folder       = true,
                        folder_arrow = true,
                        git          = true,
                        modified     = true,
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
    return {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = true,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = config
    }
end

function neovim.plugins.config.toggleterm(confopts)
    local function config()
        require("toggleterm").setup {
            size            = function(term)
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
                height = math.floor(vim.o.lines * 0.85),
            },
            shell           = os.getenv("INTERACTIVE_SHELL"),
            shell_args      = { "--login" },
        }
        local Terminal = require('toggleterm.terminal').Terminal

        local horizterm = Terminal:new({ direction = "horizontal" })
        function horizterm_toggle()
            horizterm:toggle()
        end

        vim.api.nvim_set_keymap(
            "n",
            "<leader>tt",
            "<cmd>lua horizterm_toggle()<CR>",
            { noremap = true, silent = true }
        )

        local gitterm = Terminal:new({ direction = "float", cmd = "lazygit" })
        function gitterm_toggle()
            gitterm:toggle()
        end

        vim.api.nvim_set_keymap(
            "n",
            "<leader>g",
            "<cmd>lua gitterm_toggle()<CR>",
            { noremap = true, silent = true }
        )

        local function get_python_cmd()
            local cwd         = vim.fn.getcwd()
            local venv_path   = cwd .. "/.venv"
            local ipy_in_venv = venv_path .. "/bin/ipython"
            local py_in_venv  = venv_path .. "/bin/python3"

            -- 1) prefer .venv/bin/ipython
            if vim.fn.executable(ipy_in_venv) == 1 then
                return ipy_in_venv
            end
            -- 2) then .venv/bin/python3 in interactive mode
            if vim.fn.executable(py_in_venv) == 1 then
                return py_in_venv .. " -i"
            end
            -- 3) then global ipython
            if vim.fn.executable("ipython") == 1 then
                return "ipython"
            end
            -- 4) fallback to plain python
            return "python"
        end

        -- create a horizontal Terminal; cmd will be overwritten on each toggle
        local pyterm = Terminal:new({
            direction = "horizontal",
            -- initial dummy command; will be replaced in toggle
            cmd       = "python -i",
        })

        -- toggle function: recompute cmd every time before opening
        function _G.toggle_pyterm()
            pyterm.cmd = get_python_cmd()
            pyterm:toggle()
        end

        -- map <leader>tp to our toggle
        vim.api.nvim_set_keymap(
            "n",
            "<leader>tp",
            "<cmd>lua toggle_pyterm()<CR>",
            { noremap = true, silent = true }
        )
    end
    return {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = config,
        event = "VeryLazy"
    }
end

function neovim.plugins.config.todo_comments(confopts)
    return {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    }
end

function neovim.plugins.config.lazydev(confopts)
    local opts = {
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    }
    return {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = opts
    }
end

function neovim.plugins.config.treesitter(confopts)
    local opts = {
        ensure_installed = {
            "bash",
            "c",
            "cpp",
            "diff",
            "fortran",
            "haskell",
            "html",
            "javascript",
            "jsdoc",
            "json",
            "jsonc",
            "julia",
            "latex",
            "lua",
            "luadoc",
            "luap",
            "make",
            "markdown",
            "markdown_inline",
            "matlab",
            "perl",
            "printf",
            "python",
            "query",
            "r",
            "regex",
            "rust",
            "toml",
            "tsx",
            "typescript",
            "vim",
            "vimdoc",
            "xml",
            "yaml",
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
            enable = true,
            -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
            --  If you are experiencing weird indenting issues, add the language to
            --  the list of additional_vim_regex_highlighting and disabled languages for indent.
            additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby", "latex" } },
    }
    return {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = opts
    }
end

function neovim.plugins.config.mini_nvim(confopts)
    local function config()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup({ n_lines = 500 })

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require("mini.surround").setup()

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        local statusline = require("mini.statusline")
        -- set use_icons to true if you have a Nerd Font
        statusline.setup({ use_icons = vim.g.have_nerd_font })

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return "%2l:%-2v"
        end

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
    end

    return {
        "echasnovski/mini.nvim",
        config = config,
        event = "VeryLazy"
    }
end

function neovim.plugins.config.which_key(confopts)
    local opts = {
        -- delay between pressing a key and opening which-key (milliseconds)
        -- this setting is independent of vim.opt.timeoutlen
        delay = 0,
        icons = {
            -- set icon mappings to true if you have a Nerd Font
            mappings = vim.g.have_nerd_font,
            -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
            -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
            keys = vim.g.have_nerd_font and {} or {
                Up = "<Up> ",
                Down = "<Down> ",
                Left = "<Left> ",
                Right = "<Right> ",
                C = "<C-…> ",
                M = "<M-…> ",
                D = "<D-…> ",
                S = "<S-…> ",
                CR = "<CR> ",
                Esc = "<Esc> ",
                ScrollWheelDown = "<ScrollWheelDown> ",
                ScrollWheelUp = "<ScrollWheelUp> ",
                NL = "<NL> ",
                BS = "<BS> ",
                Space = "<Space> ",
                Tab = "<Tab> ",
                F1 = "<F1>",
                F2 = "<F2>",
                F3 = "<F3>",
                F4 = "<F4>",
                F5 = "<F5>",
                F6 = "<F6>",
                F7 = "<F7>",
                F8 = "<F8>",
                F9 = "<F9>",
                F10 = "<F10>",
                F11 = "<F11>",
                F12 = "<F12>",
            },
        },
        spec = {
            { "<leader>c", group = "[C]ode",     mode = { "n", "x" } },
            { "<leader>d", group = "[D]ocument" },
            { "<leader>r", group = "[R]ename" },
            { "<leader>s", group = "[S]earch" },
            { "<leader>w", group = "[W]orkspace" },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        },
    }
    return {
        "folke/which-key.nvim",
        event = "VimEnter",
        opts = opts
    }
end

function neovim.plugins.config.lspconfig(confopts)
    local function config()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                -- Find references for the word under your cursor.
                map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

                -- Fuzzy find all the symbols in your current workspace.
                --  Similar to document symbols, except searches over your entire project.
                map(
                    "<leader>ws",
                    require("telescope.builtin").lsp_dynamic_workspace_symbols,
                    "[W]orkspace [S]ymbols"
                )

                -- Rename the variable under your cursor.
                --  Most Language Servers support renaming across files, etc.
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                ---@param client vim.lsp.Client
                ---@param method vim.lsp.protocol.Method
                ---@param bufnr? integer some lsp support methods only in specific files
                ---@return boolean
                local function client_supports_method(client, method, bufnr)
                    if vim.fn.has("nvim-0.11") == 1 then
                        return client:supports_method(method, bufnr)
                    else
                        return client.supports_method(method, { bufnr = bufnr })
                    end
                end

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --  See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if
                    client
                    and client_supports_method(
                        client,
                        vim.lsp.protocol.Methods.textDocument_documentHighlight,
                        event.buf
                    )
                then
                    local highlight_augroup =
                        vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                -- The following code creates a keymap to toggle inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if
                    client
                    and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
                then
                    map("<leader>th", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, "[T]oggle Inlay [H]ints")
                end
            end,
        })

        -- Diagnostic Config
        -- See :help vim.diagnostic.Opts
        vim.diagnostic.config({
            severity_sort = true,
            float = { border = "rounded", source = "if_many" },
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = "󰅚 ",
                    [vim.diagnostic.severity.WARN] = "󰀪 ",
                    [vim.diagnostic.severity.INFO] = "󰋽 ",
                    [vim.diagnostic.severity.HINT] = "󰌶 ",
                },
            } or {},
            virtual_text = {
                source = "if_many",
                spacing = 2,
                format = function(diagnostic)
                    local diagnostic_message = {
                        [vim.diagnostic.severity.ERROR] = diagnostic.message,
                        [vim.diagnostic.severity.WARN] = diagnostic.message,
                        [vim.diagnostic.severity.INFO] = diagnostic.message,
                        [vim.diagnostic.severity.HINT] = diagnostic.message,
                    }
                    return diagnostic_message[diagnostic.severity]
                end,
            },
        })
        -- VSCode-style diagnostics: gutter-only + Problems list
        vim.diagnostic.config({
            virtual_text     = false, -- no inline text
            signs            = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = "󰅚 ",
                    [vim.diagnostic.severity.WARN]  = "󰀪 ",
                    [vim.diagnostic.severity.INFO]  = "󰋽 ",
                    [vim.diagnostic.severity.HINT]  = "󰌶 ",
                },
            } or {},
            update_in_insert = false,
            underline        = true,
            severity_sort    = true,
            float            = { border = "rounded", source = "if_many" },
        })

        local vt_enabled = false

        -- Toggle inline virtual text on/off
        vim.keymap.set("n", "<leader>vt", function()
            vt_enabled = not vt_enabled
            vim.diagnostic.config({ virtual_text = vt_enabled })
            print(string.format(
                "Diagnostics inline text %s",
                vt_enabled and "enabled" or "disabled"
            ))
        end, { desc = "Toggle inline diagnostics text" })

        -- Toggle the “Problems” location list
        vim.keymap.set("n", "<leader>pp", function()
            local info = vim.fn.getloclist(0, { size = 0 })
            if info.size and info.size > 0 then
                vim.cmd("lclose")
            else
                vim.diagnostic.setloclist({ open = true })
            end
        end, { desc = "Toggle Problems pane" })



        vim.keymap.set(
            "n",
            "<leader>p",
            function() vim.diagnostic.setloclist({ open = true }) end,
            { desc = "Open [P]roblems List" }
        )

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --  For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
            -- clangd = {},
            -- gopls = {},
            -- pyright = {},
            -- rust_analyzer = {},
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --  https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`ts_ls`) will work just fine
            -- ts_ls = {},
            --

            lua_ls = {
                -- cmd = { ... },
                -- filetypes = { ... },
                -- capabilities = {},
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                        -- diagnostics = { disable = { 'missing-fields' } },
                    },
                },
            },
        }

        -- Ensure the servers and tools above are installed
        --
        -- To check the current status of installed tools and/or manually install
        -- other tools, you can run
        --  :Mason
        --
        -- You can press `g?` for help in this menu.
        --
        -- `mason` had to be setup earlier: to configure its options see the
        -- `dependencies` table for `nvim-lspconfig` above.
        --
        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            -- Lua
            "stylua", -- Used to format Lua code
            "lua-language-server",

            -- Shell
            "shfmt",
            "shellcheck",

            -- Python
            "ruff",
            "mypy",
            "ruff-lsp",
            "pyright",
            "jupytext",
            -- Rust
            "rust_analyzer",

            -- LaTeX / Markdown
            "ltex-ls",
            "glow",
            "markdown-oxide",
            "marksman",

            -- Misc.
            -- "r-languageserver",
            "julia-lsp",
            "json-lsp",
            "cbfmt",
        })
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
            ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
            automatic_installation = false,
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off formatting for ts_ls)
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        })
    end
    return {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            -- Mason must be loaded before its dependents so we need to set it up here.
            -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
            { "williamboman/mason.nvim", opts = {} },
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- Useful status updates for LSP.
            { "j-hui/fidget.nvim",       opts = {} },

            -- Allows extra capabilities provided by nvim-cmp
            "hrsh7th/cmp-nvim-lsp",
        },
        config = config
    }
end

function neovim.plugins.config.nvimcmp(confopts)
    local function config()
        -- See `:help cmp`
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        luasnip.config.setup({})

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            completion = { completeopt = "menu,menuone,noinsert" },
            mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-R>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete({}),
                ["<C-l>"] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { "i", "s" }),
                ["<C-h>"] = cmp.mapping(function()
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    end
                end, { "i", "s" }),
            }),
            sources = {
                {
                    name = "lazydev",
                    -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                    group_index = 0,
                },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
                { name = "nvim_lsp_signature_help" },
            },
        })
    end

    return {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    -- Build Step is needed for regex support in snippets.
                    -- This step is not supported in many windows environments.
                    -- Remove the below condition to re-enable on windows.
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
                dependencies = {
                    -- `friendly-snippets` contains a variety of premade snippets.
                    --  See the README about individual language/framework/plugin snippets:
                    --  https://github.com/rafamadriz/friendly-snippets
                    -- {
                    --   'rafamadriz/friendly-snippets',
                    --   config = function()
                    --   require('luasnip.loaders.from_vscode').lazy_load()
                    --   end,
                    -- },
                },
            },
            "saadparwaiz1/cmp_luasnip",

            -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        config = config
    }
end

function neovim.plugins.config.telescope(confopts)
    local function config()
        -- ① picker that mixes commands + keymaps
        local pickers      = require("telescope.pickers")
        local finders      = require("telescope.finders")
        local actions      = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf         = require("telescope.config").values

        local function palette_commands_keymaps(opts)
            opts = opts or {}
            local entries = {}

            -- collect :Ex‑commands
            for _, cmd in ipairs(vim.fn.getcompletion("", "command")) do
                table.insert(entries, {
                    label = ("[CMD]  %s"):format(cmd),
                    ord = cmd,
                    kind = "command",
                    cmd = cmd
                })
            end
            -- collect keymaps (normal & visual)
            for _, mode in ipairs({ "n", "v" }) do
                for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
                    local lhs, rhs = km.lhs or "", km.rhs or ""
                    table.insert(entries, {
                        label = ("[KMAP] %s → %s"):format(lhs, rhs),
                        ord = lhs .. rhs,
                        kind = "keymap",
                        lhs = lhs
                    })
                end
            end

            pickers.new(opts, {
                prompt_title    = "  Commands & Keymaps",
                finder          = finders.new_table {
                    results = entries,
                    entry_maker = function(e)
                        return { value = e, display = e.label, ordinal = e.ord }
                    end,
                },
                sorter          = conf.generic_sorter(opts),
                attach_mappings = function(bufnr, map)
                    local function run()
                        local sel = action_state.get_selected_entry().value
                        actions.close(bufnr)
                        if sel.kind == "command" then
                            vim.cmd(sel.cmd) -- run :Ex‑command
                        else
                            vim.api.nvim_feedkeys(
                                vim.api.nvim_replace_termcodes(sel.lhs, true, false, true),
                                "n", false) -- replay keymap
                        end
                    end
                    map("i", "<CR>", run)
                    map("n", "<CR>", run)
                    return true
                end,
            }):find()
        end

        -- Telescope’s normal setup  +  extensions
        require("telescope").setup({
            extensions = { ["ui-select"] = require("telescope.themes").get_dropdown() },
        })
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")

        ---------------------------------------------------------------------------
        -- frequently‑used pickers ------------------------------------------------
        local builtin = require("telescope.builtin")
        local map     = vim.keymap.set
        map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
        map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
        map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
        map("n", "<leader>ss", builtin.builtin, { desc = "[S]elect Telescope" })
        map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
        map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
        map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
        map("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
        map("n", "<leader>bf", builtin.buffers, { desc = "[ ] buffers" })

        -- in‑buffer fuzzy search
        map("n", "<leader>/", function()
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
                winblend = 10, previewer = false })
        end, { desc = "[/] Fuzzy search buffer" })

        -- live‑grep only open files
        map("n", "<leader>s/", function()
            builtin.live_grep { grep_open_files = true, prompt_title = "Live Grep in Open Files" }
        end, { desc = "[S]earch [/] in open files" })

        -- search your Neovim config
        map("n", "<leader>sn", function()
            builtin.find_files { cwd = vim.fn.stdpath("config") }
        end, { desc = "[S]earch [N]eovim files" })

        -- command‑palette picker (re‑uses function above)
        map("n", "<leader><leader>", palette_commands_keymaps,
            { desc = "Command Palette + Keymaps" })
    end
    return { -- telescope Fuzzy Finder (files, lsp, etc)
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end
            },
            "nvim-telescope/telescope-ui-select.nvim",
            { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
        },
        config = function()
            config()
        end,
    }
end

function neovim.plugins.config.ufo(confopts)
    return {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        config = function()
            -- Tell ufo which providers to try, in order
            require("ufo").setup({
                provider_selector = function()
                    return { "treesitter", "indent", "marker" }
                end
            })
        end
    }
end

function neovim.plugins.config.autopairs(confopts)
    local function config()
        local npairs = require("nvim-autopairs")
        local Rule   = require("nvim-autopairs.rule")

        -- 1) Core setup
        npairs.setup({
            -- disable in these filetypes
            disable_filetype = { "TelescopePrompt", "vim" },
            -- integrate with treesitter for smarter pairing
            check_ts = true,
            ts_config = {
                lua        = { "string", "comment" },
                javascript = { "template_string" },
                tex        = { "environment", "math_zone", "text_mode" },
                latex      = { "environment", "math_zone", "text_mode" },
            },
            -- fast wrap (M-e to trigger)
            fast_wrap = {
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'" },
                pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                offset = 0,
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "PmenuSel",
                highlight_grey = "LineNr",
            },
        })

        -- 2) LaTeX-specific extra rules
        npairs.add_rules({
            -- \left( … \right)
            Rule("\\\\left%(", "\\\\right%)", "tex"):use_regex(true),
            -- \left[ … \right]
            Rule("\\\\left%[", "\\\\right%]", "tex"):use_regex(true),
            -- \left\{ … \right\}
            Rule("\\\\left\\{", "\\\\right\\}", "tex"):use_regex(true),
            -- \begin{env} … \end{env}
            Rule("\\\\begin\\{([^}]*)\\}", "\\\\end{%1}", { "tex", "latex" })
                :use_regex(true),
        })
    end

    return {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = config,
    }
end

function neovim.plugins.config.jupytext(confopts)
    return {
        "goerz/jupytext.nvim",
        version = "0.2.0",
        ft = { "ipynb" },
        opts = {
            jupytext = { sync = true }, -- keep a .py/.md partner in sync
        },
        config = function(_, opts)
            require("jupytext").setup(opts.jupytext)
        end,
    }
end

function neovim.plugins.config.obsidian(confopts)
    -- Add obsidian.nvim plugin with lazy.nvim
    return {
        "epwalsh/obsidian.nvim",
        version = "*",               -- Keep it updated with the latest release
        lazy = true,                 -- Enable lazy loading (only load when needed)
        ft = "markdown",             -- Load plugin when editing markdown files
        dependencies = {
            "nvim-lua/plenary.nvim", -- Dependency for plenary functions
        },
        config = function()
            require("obsidian").setup({
                -- Do not define workspaces, rely on Neovim's auto-detection
                -- Optionally, you can specify a default vault directory if necessary
                -- dir = "~/notes",  -- Set a fallback directory (optional)
                disable_frontmatter = false,                   -- Keep frontmatter enabled
                wiki_link_func = function(opts)
                    return string.format("[[%s]]", opts.label) -- Handle link formatting
                end,
            })
        end,
    }
end

function neovim.plugins.config.telescope_media_images(confopts)
    local confopts = confopts or {}
    vim.keymap.set("n", "<leader>mp",
        "<cmd>Telescope media_files media_files filetypes={'pdf'}<CR>",
        { desc = "Telescope: Preview PDF pages" }
    )
    return {
        "nvim-telescope/telescope-media-files.nvim",
        event = "VeryLazy",
        config = function()
            require("telescope").load_extension("media_files")
        end,
    }
end

function neovim.plugins.config.ironnvim(confopts)
    -- this will be called by lazy.nvim when loading Vigemus/iron.nvim
    local confopts = confopts or {}
    local function config()
        local iron     = require("iron.core")
        local view     = require("iron.view")
        local common   = require("iron.fts.common")

        -- 1) prefer .venv/bin/python, else fallback to `python -i`
        local cwd      = vim.fn.getcwd()
        local ft       = vim.bo.filetype
        local repl_cmd = neovim.utils.get_repl_cmd(cwd, ft)
            or vim.tbl_flatten({ ft, "-i" }) -- fallback to "<ft> -i"

        iron.setup {
            config = {
                repl_definition = {
                    -- only define Python here; other REPLs will use defaults
                    python = {
                        command        = repl_cmd,
                        format         = common.bracketed_paste_python,
                        block_dividers = { "# %%", "#%%" }, -- cell markers
                    },
                },
                -- open REPL in a 30%-height bottom split
                repl_open_cmd = view.split.botright(0.3),
            },
            keymaps = {
                -- basic REPL control
                toggle_repl              = "<leader>rr", -- open/close REPL
                -- send_motion              = "<leader>sc", -- send current motion or cell
                -- visual_send              = "<leader>sc", -- send visual selection
                send_code_block          = "<C-CR>",
                send_code_block_and_move = "<leader>sn",
                send_file                = "<leader>sf", -- send entire buffer
                send_line                = "<leader>sl", -- send current line
                cr                       = "<leader>sr", -- send <CR> to REPL
                interrupt                = "<leader>sk", -- interrupt
                exit                     = "<leader>rq", -- exit REPL
                clear                    = "<leader>cl", -- clear REPL buffer
            },
        }
    end

    return {
        "Vigemus/iron.nvim",
        ft           = { "python" },          -- load on Python files
        config       = function() config() end,
        dependencies = { "nvim-treesitter" }, -- for better block detection if you like
    }
end

function neovim.plugins.config.neogen(confopts)
    confopts = confopts or {}
    return {
        'danymat/neogen',
        -- lazy-load on demand (you can change this to suit your workflow)
        event = 'BufReadPost',
        -- if you use LuaSnip and Treesitter, load them first
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'L3MON4D3/LuaSnip',
        },
        -- these get passed directly into require('neogen').setup()
        opts = {
            snippet_engine = 'luasnip',
            languages = {
                python = {
                    template = {
                        annotation_convention = 'numpydoc',
                    },
                },
            },
        },
        keys = {
            {
                '<leader>cd',
                '<cmd>Neogen<CR>',
                mode = 'n',
                desc = 'Generate NumPy-style docstring for current function/class',
            },
        },
        -- call setup with the opts table above
        config = function(_, opts)
            require('neogen').setup(opts)
        end,
    }
end

function neovim.plugins.setup(plugin_opts)
    return {
        neovim.plugins.config.vim_sleuth({}),
        neovim.plugins.config.gitsigns({}),
        neovim.plugins.config.which_key({}),
        neovim.plugins.config.treesitter({}),
        neovim.plugins.config.nvim_tree({}),
        neovim.plugins.config.toggleterm({}),
        neovim.plugins.config.lazydev({}),
        neovim.plugins.config.lspconfig({}),
        neovim.plugins.config.conform({}),
        neovim.plugins.config.nvimcmp({}),
        neovim.plugins.config.todo_comments({}),
        neovim.plugins.config.mini_nvim({}),
        neovim.plugins.config.telescope({}),
        neovim.plugins.config.autopairs({}),
        neovim.plugins.config.jupytext({}),
        neovim.plugins.config.ironnvim({}),
        neovim.plugins.config.obsidian({}),
        neovim.plugins.config.neogen({}),
        neovim.plugins.config.telescope_media_images({})
    }
end

function neovim.neovide(opts)
    local opts = opts or {}
    vim.g.neovide_remember_window_size = true

    vim.api.nvim_create_autocmd("UIEnter", {
        once = true,
        callback = function()
            vim.cmd('ToggleTerm direction=horizontal')
            vim.cmd('NvimTreeToggle')
        end
    })
end

function neovim.setup(opts)
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    neovim.options.setup()
    neovim.folds()
    neovim.keymappings.setup()
    neovim.mcnp_syntax.setup()
    neovim.themes.setup({ theme = opts.theme })
    neovim.plugins.bootstrap(neovim.plugins.setup())
    if vim.g.neovide then
        neovim.neovide(opts.neovide)
    end
end

neovim.defaults = {
    theme         = "github_light",
    enable_python = true,
    enable_latex  = true,
    enable_rust   = true,
}

neovim.setup(neovim.defaults)
-- "github_light", "catppuccin_latte", "catppuccin_frappe",
-- "catppuccin_macchiato", or "catppuccin_mocha".
