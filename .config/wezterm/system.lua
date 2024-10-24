local wezterm = require 'wezterm'

-- Determine the operating system.
local is_mac_os = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

-- Define the function that applies operating system configuration.
local function apply_configuraton(configuration)
    if is_linux then
        -- Configure display protocol for Linux.
        configuration.enable_wayland = true
    elseif is_mac_os then
        -- Configure window blur for macOS.
        configuration.macos_window_background_blur = 20
    else
        -- Configure window blur and shell for Windows.
        configuration.win32_system_backdrop = "Acrylic"
        configuration.default_prog = { "pwsh", "-NoLogo" }
    end
end

return apply_configuraton
