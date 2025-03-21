-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.font_size = 18
config.window_background_opacity = 0.7
-- config.window_background_image = "~/prog/config/azskalt-little-numbat-boy.jpeg"

config.color_scheme = "Catppuccin Macchiato"

-- and finally, return the configuration to wezterm
return config
