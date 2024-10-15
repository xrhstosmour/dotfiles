-- Initialize wezterm configuration.
local wezterm = require 'wezterm'
local configuration = wezterm.config_builder()

-- Wayland.
configuration.enable_wayland = true
configuration.webgpu_power_preference = "HighPerformance"

-- Font.
configuration.font = wezterm.font("Fira Code Nerd")
configuration.font_size = 14
configuration.bold_brightens_ansi_colors = true

-- Colors.
configuration.colors = require("colors")
configuration.force_reverse_video_cursor = true

-- Window.
configuration.initial_rows = 40
configuration.initial_cols = 120
configuration.window_decorations = "RESIZE"
configuration.window_background_opacity = 0.75
configuration.window_close_confirmation = "NeverPrompt"
configuration.max_fps = 144
configuration.animation_fps = 60
configuration.cursor_blink_rate = 250

-- Tabs
configuration.enable_tab_bar = true
configuration.hide_tab_bar_if_only_one_tab = true
configuration.show_tab_index_in_tab_bar = false
configuration.use_fancy_tab_bar = false
configuration.colors.tab_bar = {
    background = "rgba(22, 24, 26, " .. 0.75 .. ")",
    new_tab = { fg_color = configuration.colors.background, bg_color = configuration.colors.brights[6] },
    new_tab_hover = { fg_color = configuration.colors.background, bg_color = configuration.colors.foreground },
}

-- wezterm.on("format-tab-title", function(tab, _, _, _, hover)
--     local background = configuration.colors.brights[1]
--     local foreground = configuration.colors.foreground

--     if tab.is_active then
--         background = configuration.colors.brights[7]
--         foreground = configuration.colors.background
--     elseif hover then
--         background = configuration.colors.brights[8]
--         foreground = configuration.colors.background
--     end

--     local title = tostring(tab.tab_index + 1)
--     return {
--         { Foreground = { Color = background } },
--         { Text = "█" },
--         { Background = { Color = background } },
--         { Foreground = { Color = foreground } },
--         { Text = title },
--         { Foreground = { Color = background } },
--         { Text = "█" },
--     }
-- end)

-- Keybindings.
configuration.keys = require("keybindings")

return configuration
