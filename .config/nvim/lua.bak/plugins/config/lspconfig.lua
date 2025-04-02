local lspconfig = require('lspconfig')

-- Setup LSP servers
lspconfig.clangd.setup{}
lspconfig.ruff.setup{}
lspconfig.pyright.setup{}
lspconfig.bashls.setup{}
lspconfig.r_language_server.setup{}
lspconfig.marksman.setup{}

-- Add more servers if needed

