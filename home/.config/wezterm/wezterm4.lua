local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- 🎨 Matches the high-contrast slate dark theme from your screenshot
config.color_scheme = "Twilight" -- Alternative closest matches: "Dracula", "Sublime Snazzy"

-- 🔤 Matches the Apple developer font profile in the image
config.font = wezterm.font("SF Mono", { weight = "Regular" }) -- Or use "SFMono Nerd Font"
config.font_size = 14.5 -- Adjusted slightly for SF Mono's native scaling height

config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- 📐 Spacing match: Tight line and letter packing for maximum data density
config.line_height = 1.0  -- Brought down from 1.2 to match standard dense layouts
config.cell_width = 1.0   -- Brought down from 1.1 to eliminate wide letter tracking

-- Background profile matching the screenshot (Solid, no blur/leakage)
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

-- macOS Space Transitions & Fullscreen Glitch Fixes
config.native_macos_fullscreen_mode = true

-- Hardware & High Refresh Rate Display Optimizations
config.front_end = "WebGpu"
config.max_fps = 120        
config.animation_fps = 120  

-- Subpixel anti-aliasing features optimized for SF Mono rendering
config.font_rules = {
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font({
      family = 'SF Mono',
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

-- Focus Dimming parameters updated to match the high contrast text weight
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
