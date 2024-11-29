## Main Goals

- fix magma
- fix keymaps
- add lsp support for other languages
- add status bar
- show errors below line and break at multiple lines
- remove whitespace and fix eol on save
- build toolchains for certain languages to enable/disable lsp, tree-sitter, syntax, etc
    - add option to toggle in main init.lua file
    - add ability to install needed components by checking for brew, apt, etc
      and include the option just list the needed components
- something related to obsidian (linked documents)
    - add alias to open directory in nvim (using notes)


## Packages

Would eventually want an nvim init.lua to be:

```lua
require('lazy').setup({
    'sodium-hydroxide/nvim-ui',
    'sodium-hydroxide/nvim-python',
    'sodium-hydroxide/nvim-julia',
    'sodium-hydroxide/nvim-bash',
    'sodium-hydroxide/nvim-lua',
    'sodium-hydroxide/nvim-ruby',
    'sodium-hydroxide/nvim-jupyter',
    'sodium-hydroxide/nvim-markdown',
    'sodium-hydroxide/nvim-latex',
    'sodium-hydroxide/nvim-rust',
    'sodium-hydroxide/nvim-jsts',
    'sodium-hydroxide/nvim-data-files', -- csv, toml, yaml, html, xml, css, json
})
```


