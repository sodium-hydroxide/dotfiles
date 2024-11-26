return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- Add any custom parsers if they become available for MCNP
            if opts.ensure_installed ~= "all" then
                opts.ensure_installed = opts.ensure_installed or {}
            end
        end,
    },
    {
        "nathom/filetype.nvim",
        opts = {
            overrides = {
                extensions = {
                    i = "mcnp",    -- Input files
                    o = "mcnp",    -- Output files
                    r = "mcnp",    -- RUNTPE files
                    m = "mcnp",    -- MCTAL files
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            -- Create MCNP syntax highlighting rules
            vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
                pattern = {"*.i", "*.o", "*.r", "*.m"},
                callback = function()
                    -- Set filetype
                    vim.bo.filetype = "mcnp"
                    
                    -- Define syntax highlighting
                    vim.cmd([[
                        syntax clear
                        
                        " Cell cards
                        syntax match mcnpCell        '^\s*\d\+'
                        syntax match mcnpComment     '^c.*$'
                        syntax match mcnpComment     '^C.*$'
                        
                        " Surface cards
                        syntax match mcnpSurface     '^\s*\d\+\s\+\(px\|py\|pz\|p\|so\|s\|sx\|sy\|sz\|c\/x\|c\/y\|c\/z\|cx\|cy\|cz\|k\/x\|k\/y\|k\/z\|sq\|gq\|tx\|ty\|tz\)'
                        
                        " Data cards
                        syntax match mcnpDataCard    '^\s*\(imp\|vol\|u\|fill\|tr\|m\|mt\|f\|e\|fc\|fm\|de\/df\|sd\|si\|sp\|sb\|ds\|c\)\d*'
                        
                        " Numbers
                        syntax match mcnpNumber      '\<\d\+\>'
                        syntax match mcnpFloat       '\<\d\+\.\d*\>'
                        syntax match mcnpFloat       '\<\.\d\+\>'
                        syntax match mcnpScientific  '\<\d\+\.\d*[eE][-+]\?\d\+\>'
                        
                        " Materials
                        syntax match mcnpMaterial    '^\s*m\d\+'
                        
                        " Tallies
                        syntax match mcnpTally       '^\s*f\d\+'
                        
                        " Importance
                        syntax match mcnpImportance  '^\s*imp:\(n\|p\|e\)'
                        
                        " Set highlighting colors
                        highlight default link mcnpCell        Identifier
                        highlight default link mcnpComment     Comment
                        highlight default link mcnpSurface     Statement
                        highlight default link mcnpDataCard    Type
                        highlight default link mcnpNumber      Number
                        highlight default link mcnpFloat       Float
                        highlight default link mcnpScientific  Float
                        highlight default link mcnpMaterial    Special
                        highlight default link mcnpTally       Function
                        highlight default link mcnpImportance  Keyword
                    ]])
                end
            })
        end,
    }
}
