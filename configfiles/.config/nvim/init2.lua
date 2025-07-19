-- Utility Definitions
local function keymap(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Set Basic Configuration Settings
vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.mouse          = "a"
vim.opt.mousemodel     = "popup" -- optional: default
vim.opt.backup         = false
vim.opt.wrap           = true
vim.opt.tabstop        = 2 -- 2‑space tabs
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.cursorline     = false -- can slow down performance
vim.opt.colorcolumn    = "80"
vim.opt.showmode       = false
vim.opt.clipboard      = "unnamedplus"
vim.opt.breakindent    = true
vim.opt.undofile       = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.signcolumn     = "yes"
vim.opt.updatetime     = 550
vim.opt.timeoutlen     = 300
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.list           = true
vim.opt.listchars      = {
    tab = "» ",
    trail = "~",
    nbsp = "‡",
    extends = "›",
    precedes = "‹",
    space = "⋅",
    eol = "¬",
}
vim.opt.inccommand     = "split"
vim.opt.scrolloff      = 10
vim.opt.foldmethod     = "expr"
vim.opt.foldexpr       = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel      = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable     = true

-- Syntax Highlighting for MCNP Input Decks
local function mcnp_syntax()
    local patterns = {}
    for _, ext in ipairs({ "mcnp", "in" }) do
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
mcnp_syntax()

-- Github Light Theme
local function theme()
    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') then
        vim.cmd('syntax reset')
    end
    local colors = {
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
    }
    -- Set terminal colors.
    vim.opt.background = "light"
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
theme()

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
keymap("n", "<leader>w", ":set wrap!<CR>", { desc = "Toggle word wrap" })
--keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Get compiled .so files for treesitter
-- Ensure lsps and formatters are on path
