local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Basic Appearance & Typography
config.color_scheme = "Catppuccin Latte"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- macOS Window Effects & Transparency
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50

-- macOS Space Transitions & Fullscreen Glitch Fixes
config.native_macos_fullscreen_mode = true

-- Hardware & High Refresh Rate Display Optimizations
config.front_end = "WebGpu"
config.max_fps = 120        -- Unlocks 120Hz ProMotion matching your hardware screen
config.animation_fps = 120  -- Smooths cursor blinks and animations at high refresh rates

-- Crisp font pixel-snapping features for scaled macOS resolutions
config.font_rules = {
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font({
      family = 'Hack Nerd Font',
      harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
    }),
  },
}

-- Prevent cursor ghosting/blurring during rapid 120Hz movements
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"


-- Focus Dimming Logic (Patched for Fullscreen Swipes)
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

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
