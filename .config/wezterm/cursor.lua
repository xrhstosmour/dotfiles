-- Define the function that applies cursor configuration.
local function apply_configuraton(configuration)
    configuration.cursor_blink_rate = 250
    configuration.force_reverse_video_cursor = true
end

return apply_configuraton
