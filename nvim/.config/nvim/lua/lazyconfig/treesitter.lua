local M = {}
function M.setup()
  return {
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
    indent = { enable = true, disable = { "ruby" } },
  }
end
return M
