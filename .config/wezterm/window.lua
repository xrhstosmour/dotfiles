-- Define the function that applies window configuration.
local function apply_configuraton(configuration)
    configuration.initial_rows = 40
    configuration.initial_cols = 120
    configuration.window_background_opacity = 0.75
    configuration.window_close_confirmation = "NeverPrompt"
    configuration.window_padding = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5
    }
end

return apply_configuraton
