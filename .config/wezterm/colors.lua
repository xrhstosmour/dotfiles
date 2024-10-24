return {
    -- Standard foreground/background colors
    foreground = "#ffffff",          -- White text
    background = "#16181a",          -- Dark background

    -- Cursor configuration
    cursor_bg = "#ffffff",     -- White cursor
    cursor_fg = "#16181a",     -- Dark text under the cursor
    cursor_border = "#ffffff", -- White cursor border

    -- Selection colors
    selection_fg = "#16181a", -- Dark text when selected
    selection_bg = "#f1ff5e", -- Bright yellow background for selected text (matches BOLD_YELLOW)

    -- Scrollbar and split line colors
    scrollbar_thumb = "#5e5e5e",
    split = "#5e5e5e",

    -- ANSI colors (adjusted to match your bold preferences)
    ansi = {
        "#16181a", -- Black
        "#ff6e5e", -- Red
        "#32ff32", -- Green (bright, bold green) -> BOLD_GREEN
        "#f1ff5e", -- Yellow (bright yellow) -> BOLD_YELLOW
        "#5ea1ff", -- Blue
        "#bd5eff", -- Magenta
        "#5ef1ff", -- Cyan (light cyan)
        "#e0e0e0"  -- White
    },

    -- Bright colors
    brights = {
        "#4c5058", -- Bright black (dark gray)
        "#ff6e5e", -- Bright red
        "#32ff32", -- Bright green -> BOLD_GREEN
        "#f1ff5e", -- Bright yellow -> BOLD_YELLOW
        "#5ea1ff", -- Bright blue
        "#bd5eff", -- Bright magenta
        "#36e6e6", -- Bright cyan -> BOLD_CYAN
        "#ffffff"  -- Bright white
    },

    -- -- Indexed colors (optional custom colors)
    -- indexed = {
    --     [16] = "#ffbd5e", -- Custom orange
    --     [17] = "#ff6e5e"  -- Custom red
    -- },
}
