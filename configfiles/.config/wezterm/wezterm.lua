-- Use Wezterm API
local wezterm = require('wezterm')
local config = wezterm.config_builder()

config.initial_cols = 100
config.initial_rows = 30
config.font_size = 14
config.font = wezterm.font "JetBrains Mono"
config.animation_fps = 60
config.cursor_blink_rate = 800
config.default_cursor_style = "BlinkingBlock"

config.front_end = "WebGpu"

config.colors = {
  foreground = "#24292e",
  background = "#ffffff",
  cursor_bg = "#24292e",
  cursor_fg = "#ffffff",
  cursor_border = "#24292e",
  selection_bg = "#c8e1ff",
  selection_fg = "#24292e",

  ansi = {
    "#586069", "#d73a49", "#22863a", "#b08800",
    "#0366d6", "#5a32a3", "#005cc5", "#6a737d",
  },
  brights = {
    "#959da5", "#cb2431", "#28a745", "#dbab09",
    "#2188ff", "#7e5bef", "#005cc5", "#6a737d",
  },
}


return config
