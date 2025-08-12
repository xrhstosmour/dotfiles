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

-- WezTerm keybindings:
-- For external keyboards and Linux systems we are going to use CTRL.
-- For internal macOS keyboards we are going to use Globe, which is remapped to CMD.
--   CTRL/Globe+C: Copy selection if present, else send SIGINT to terminal.
--   CTRL/Globe+V: Paste from clipboard.
--   CTRL/Globe+D: Split pane horizontally.
--   CTRL/Globe+T: New terminal tab.
--   CTRL/Globe+N: New terminal window.
return function(config)
    local is_macos = wezterm.target_triple:find("apple") ~= nil
    local mod = is_macos and "CMD" or "CTRL"

    config.keys = {
        {
            key = "c",
            mods = mod,
            action = wezterm.action_callback(ctrl_c_action)
        },
        {
            key = "v",
            mods = mod,
            action = wezterm.action.PasteFrom("Clipboard")
        },
        {
            key = "d",
            mods = mod,
            action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
        }
    }
end
