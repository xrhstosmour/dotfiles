local wezterm = require 'wezterm'

return {
    -- Paste.
    { key = "v", mods = "CTRL", action = wezterm.action({ PasteFrom = "Clipboard" }) }
}
