local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- config.color_scheme = "Catppuccin Mocha"
config.color_scheme = "rose-pine"
config.font_size = 20
config.window_background_opacity = 1

config.default_prog = { "pwsh.exe" }
return config
