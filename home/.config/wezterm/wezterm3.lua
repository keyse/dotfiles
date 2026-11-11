local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- 👁️ EYE STRAIN REDUCTION: Applied your preferred theme choice
config.color_scheme = "Tokyo Night"

-- Basic Layout & Typography
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- 👁️ READING COMFORT: Premium text spacing parameters
config.line_height = 1.2  -- Adds a comfortable 20% cushion between lines
config.cell_width = 1.1   -- Adds a 10% horizontal tracking gap between characters

-- 👁️ EYE STRAIN REDUCTION: Solid backgrounds prevent back-layer visual clutter
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

-- macOS Space Transitions & Fullscreen Glitch Fixes
config.native_macos_fullscreen_mode = true

-- Hardware & High Refresh Rate Display Optimizations
config.front_end = "WebGpu"
config.max_fps = 120        
config.animation_fps = 120  

-- 👁️ EYE STRAIN REDUCTION: Crisp, slightly heavier font rendering for text reading
config.font_rules = {
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font({
      family = 'Hack Nerd Font',
      weight = 'DemiBold', -- Makes text thicker and more legible on dark backgrounds
      harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
    }),
  },
}

-- Prevent cursor ghosting/blurring during rapid 120Hz movements
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Custom macOS-Style Keybindings (Font Size & Panes)
config.keys = {
  -- Font Resizing
  { key = '=', mods = 'CMD', action = act.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = act.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = act.ResetFontSize },

  -- Split Panes
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  
  -- Close Active Pane/Tab
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane({ confirm = true }) },
}


-- 👁️ EYE STRAIN REDUCTION: Relaxed focus-dimming parameters
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.8, brightness = 0.7 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 1.0

-- Helper to safely compare HSB color values
local function same_text_hsb(actual, expected)
        if actual == nil or expected == nil then
                return actual == expected
        end
        return actual.hue == expected.hue
                and actual.saturation == expected.saturation
                and actual.brightness == expected.brightness
end

-- Event listener to handle window focus shifts dynamically
wezterm.on("window-focus-changed", function(window)
        local overrides = window:get_config_overrides() or {}
        local text_hsb, opacity

        -- Read window dimensions to detect active native full screen state
        local is_fullscreen = window:get_dimensions().is_full_screen

        -- Skip opacity shifts if in fullscreen to protect macOS trackpad animations
        if not window:is_focused() and not is_fullscreen then
                text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
                opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
        end

        -- Guard clause: return early if no layout updates are actually required
        if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
                return
        end

        overrides.foreground_text_hsb = text_hsb
        overrides.window_background_opacity = opacity
        window:set_config_overrides(overrides)
end)

return config
