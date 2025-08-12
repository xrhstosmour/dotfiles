local wezterm = require 'wezterm'

local function ctrl_c_action(window, pane)
    local has_selection = window:get_selection_text_for_pane(pane) ~= ""
    if has_selection then
        window:perform_action(
            wezterm.action { CopyTo = "ClipboardAndPrimarySelection" },
            pane
        )
        window:perform_action("ClearSelection", pane)
    else
        window:perform_action(
            wezterm.action { SendKey = {key = "c", mods = "CTRL"} },
            pane
        )
    end
end

return function(config)
    config.keys = {
        {
            key = "c",
            mods = "CTRL",
            action = wezterm.action_callback(ctrl_c_action)
        }, {
            key = "c",
            mods = "CTRL|SHIFT",
            action = wezterm.action {SendKey = {key = "c", mods = "CTRL"}}
        },
        {
            key = "v",
            mods = "CTRL",
            action = wezterm.action.PasteFrom("Clipboard")
        }, {
            key = "v",
            mods = "CTRL|SHIFT",
            action = wezterm.action {SendKey = {key = "v", mods = "CTRL"}}
        }
    }
end
