-- Define the function that applies graphics configuration.
local function apply_configuraton(configuration)
    configuration.webgpu_power_preference = "HighPerformance"
    configuration.max_fps = 144
    configuration.animation_fps = 60
end

return apply_configuraton
