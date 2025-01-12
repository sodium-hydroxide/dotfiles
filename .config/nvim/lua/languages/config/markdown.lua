return {
    name = "Markdown",
    lsp = {servers = {marksman = {}}},
    formatter = {prettier = {filetypes = {"markdown"}}},
    treesitter = "markdown",
    cmp = {sources = {name = 'nvim_lsp'}},
    preview = {
        command = "Glow",
        keymap = "<leader>mp"
    },
}

