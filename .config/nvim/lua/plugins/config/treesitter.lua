require('nvim-treesitter.configs').setup({
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
    -- Install parsers asynchronously (set to false to install synchronously)
    sync_install = false,
    -- Automatically install missing parsers when entering a buffer
    auto_install = true,
    highlight = {
        enable = true,                      -- Enable Treesitter-based highlighting
        additional_vim_regex_highlighting = false, -- Disable legacy Vim regex highlighting
    },
    indent = {
        enable = true,                      -- Enable Treesitter-based indentation
    },
  })

