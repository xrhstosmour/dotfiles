-- Initialize wezterm configuration.
local wezterm = require 'wezterm'
local configuration = {}
if wezterm.config_builder then
    configuration = wezterm.config_builder()
end

-- System configuration involving window blur, display protocol, and shell.
local apply_system_configuration = require("system")
apply_system_configuration(configuration)

-- Graphics.
local apply_graphics_configuration = require("graphics")
apply_graphics_configuration(configuration)

-- Font.
local apply_font_configuration = require("font")
apply_font_configuration(configuration)

-- Window.
local apply_window_configuration = require("window")
apply_window_configuration(configuration)

-- Cursor.
local apply_cursor_configuration = require("cursor")
apply_cursor_configuration(configuration)

-- Colors.
configuration.colors = require("colors")
-- configuration.color_scheme = "Oceanic Next (Gogh)"

-- Tabs.
local apply_tabs_configuration = require("tabs")
apply_tabs_configuration(configuration)

return configuration
