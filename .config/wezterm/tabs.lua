local wezterm = require 'wezterm'
local constants = require 'constants'

-- Define the function that applies tabs configuration.
local function apply_configuraton(configuration)
    configuration.use_fancy_tab_bar = true
    configuration.tab_max_width = 100
    configuration.enable_tab_bar = true
    configuration.hide_tab_bar_if_only_one_tab = true
    configuration.show_tab_index_in_tab_bar = false
    configuration.window_frame = {
        font_size = configuration.font_size
    }
    configuration.colors.tab_bar = {
        new_tab = { bg_color = constants.palette.transparent, fg_color = constants.palette.dark_gray },
        new_tab_hover = { bg_color = constants.palette.transparent, fg_color = constants.palette.white },
        active_tab = {
            bg_color = constants.palette.gray,
            fg_color = constants.palette.white,
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = constants.palette.dark_gray,
            fg_color = constants.palette.light_gray
        },
        inactive_tab_hover = {
            bg_color = constants.palette.dark_gray,
            fg_color = constants.palette.light_gray
        },
    }

    wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
        local title = tostring(tab.tab_index + 1)
        local background = config.colors.tab_bar.inactive_tab.bg_color
        local foreground = config.colors.tab_bar.inactive_tab.fg_color

        if tab.is_active then
            background = config.colors.tab_bar.active_tab.bg_color
            foreground = config.colors.tab_bar.active_tab.fg_color
        elseif hover then
            background = config.colors.tab_bar.inactive_tab_hover.bg_color
            foreground = config.colors.tab_bar.inactive_tab_hover.fg_color
        end

        return {
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            { Text = " " .. title .. " " },
        }
    end)
end

return apply_configuraton
