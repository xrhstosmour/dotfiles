local wezterm = require 'wezterm'

-- Initialize the window opacity.
local opacity = 0.70

-- Define the function that applies tabs configuration.
local function apply_configuraton(configuration)
    configuration.tab_max_width = 50
    configuration.enable_tab_bar = true
    configuration.hide_tab_bar_if_only_one_tab = false
    configuration.show_tab_index_in_tab_bar = false
    configuration.window_frame = {
        font = configuration.font,
        font_size = configuration.font_size
    }
    configuration.colors.tab_bar = {
        background = "rgba(22, 24, 26, " .. opacity .. ")",
        new_tab = { fg_color = configuration.colors.background, bg_color = configuration.colors.brights[5] },
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

    --     -- Get the current working directory
    --     local cwd_uri = tab.active_pane.current_working_dir
    --     local cwd = cwd_uri and wezterm.uri_parse(cwd_uri) or ""

    --     -- Extract the directory name from the full path
    --     local title = cwd:match("[^/]+$") or tostring(tab.tab_index + 1)

    --     -- Set a maximum length for the title to avoid wrapping
    --     local max_length = 50 -- You can adjust this value to your preference
    --     if #title > max_length then
    --         title = title:sub(1, max_length) .. "…" -- Truncate with an ellipsis
    --     end
    --     -- local title = tostring(tab.tab_index + 1)
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
end

return apply_configuraton
