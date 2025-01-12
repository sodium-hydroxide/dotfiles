return {
    name = "Shell",
    lsp = {
        servers = {
            bashls = {}  -- Use default settings
        }
    },
    formatter = {
        shfmt = {
            extra_args = { "-i", "4", "-ci" }
        }
    },
    treesitter = "bash"
}

