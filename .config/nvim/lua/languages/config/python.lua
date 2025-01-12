
return {
    name = "Python",
    lsp = {
        servers = {
            pyright = {
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        }
                    }
                }
            },
            ruff = {
                settings = {
                    line_length = 79,
                    select = {"E", "F", "I", "UP", "RUF"},
                }
            }
        }
    },
    formatter = {
        ruff = {
            extra_args = {"--line-length", "79"},
            filetypes = {"python"}
        },
        -- isort = {
        --     extra_args = {"--profile", "black"},
        -- }
    },
    dap = {
        adapter = {
            type = 'executable',
            command = 'python',
            args = { '-m', 'debugpy.adapter' }
        },
        configurations = {
            {
                type = 'python',
                request = 'launch',
                name = "Launch file",
                program = "${file}",
                pythonPath = function()
                    return '.venv/bin/python'
                end,
            }
        }
    },
    treesitter = "python",
    cmp = {
        sources = {
            {name = 'nvim_lsp'},
            {name = 'buffer'},
            {name = 'path'},
        }
    },
    terminal = function()
        vim.cmd([[
            TermOpen horizontal
            wincmd j
            TermOpen horizontal cmd=.venv/bin/ipython name=REPL-Python
        ]])
    end,
}

