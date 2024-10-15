-- Initialize wezterm configuration.
local wezterm = require 'wezterm'
local configuration = wezterm.config_builder()

-- Wayland.
configuration.enable_wayland = true
configuration.webgpu_power_preference = "HighPerformance"

-- Fonts.
configuration.font = wezterm.font("Fira Code Nerd")
configuration.font_size = 16
configuration.bold_brightens_ansi_colors = true

-- Colors.
configuration.force_reverse_video_cursor = true

-- Window.
configuration.window_decorations = "RESIZE"
configuration.window_background_opacity = 0.75
configuration.window_close_confirmation = "NeverPrompt"
configuration.max_fps = 144
configuration.animation_fps = 60
configuration.cursor_blink_rate = 250

return configuration
