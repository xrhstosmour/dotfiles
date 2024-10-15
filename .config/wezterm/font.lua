local wezterm = require 'wezterm'

-- Define the function that applies font configuration.
local function apply_configuraton(configuration)
    configuration.font = wezterm.font("Fira Code", {
        weight = "Medium",
        stretch = "SemiExpanded",
        style = "Italic"
    })
    configuration.font_size = 14
    configuration.bold_brightens_ansi_colors = true
end

return apply_configuraton
