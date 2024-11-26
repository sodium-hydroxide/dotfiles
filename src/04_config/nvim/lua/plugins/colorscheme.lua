return {
    {
        "arzg/vim-colors-xcode",
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.background = 'light'
            vim.g.xcodelight_green_comments = 1
            vim.g.xcodelight_emph_types = 1
            vim.g.xcodelight_emph_funcs = 1
            vim.g.xcodelight_emph_idents = 1
            vim.g.xcodelight_match_paren_style = 1
            vim.g.xcodelight_dim_punctuation = 1

            -- Enable Treesitter highlighting before setting colorscheme
            vim.opt.termguicolors = false

            vim.cmd([[colorscheme xcodelight]])

            -- Add these Treesitter-specific highlights after colorscheme
            vim.cmd([[
                highlight! link @variable Normal
                highlight! link @function Function
                highlight! link @function.call Function
                highlight! link @operator Operator
                highlight! link @keyword Keyword
                highlight! link @keyword.function Keyword
                highlight! link @parameter Normal
                highlight! link @string String
                highlight! link @boolean Boolean
                highlight! link @number Number
                highlight! link @comment Comment
                highlight! link @conditional Conditional
                highlight! link @repeat Repeat
                highlight! link @label Label
                highlight! link @include Include
                highlight! link @type Type
                highlight! link @constant Constant
            ]])

            -- Your existing custom highlights
            vim.cmd([[
                highlight Normal guibg=#FFFFFF guifg=#262626
                highlight Comment guifg=#008F00
                highlight String guifg=#C41A16
                highlight Constant guifg=#326D74
                highlight Function guifg=#326D74
                highlight Identifier guifg=#326D74
                highlight Statement guifg=#800080
                highlight PreProc guifg=#643820
                highlight Type guifg=#0F68A0
                highlight Special guifg=#800080
                highlight LineNr guifg=#A0A0A0
                highlight CursorLine guibg=#F5F5F5
                highlight Visual guibg=#B4D8FD
                highlight Search guibg=#FFE792 guifg=NONE
                highlight IncSearch guibg=#FFE792 guifg=NONE
                highlight MatchParen guibg=#B4D8FD guifg=NONE
            ]])
        end
    },

    -- Update Treesitter configuration
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
    },
}

