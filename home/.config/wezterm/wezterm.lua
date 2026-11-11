local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- 🎨 Base Theme Definition
config.color_scheme = "Twilight"

-- 🎨 COLOR MATCH OVERRIDE: Softens the comments to match your first image perfectly
-- WezTerm's palette has no "comment" field; comment text is drawn with an ANSI
-- color, so the override belongs on that slot. Twilight paints dimmed text with
-- bright black (brights[1]); if comments still look orange they are using
-- yellow instead, so move the gray to brights[4]/ansi[4].
config.colors = {
  brights = {
    "#8e908c", -- bright black: calm, readable gray for dimmed/comment text
    "#cf6a4c",
    "#8f9d6a",
    "#f9ee98",
    "#7587a6",
    "#9b859d",
    "#afc4db",
    "#ffffff",
  },
}

-- 🔤 Crisp, error-free native macOS Monospace font
config.font = wezterm.font_with_fallback({
  { family = "Menlo" },
  { family = "Hack Nerd Font" }, 
})
config.font_size = 14.5

config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- 📐 High-density layout tracking
config.line_height = 1.0  
config.cell_width = 1.0   

-- Solid background profile 
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

-- macOS Space Transitions & Fullscreen Glitch Fixes
config.native_macos_fullscreen_mode = true

-- Hardware & High Refresh Rate Display Optimizations
config.front_end = "WebGpu"
config.max_fps = 120        
config.animation_fps = 120  

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

-- Focus Dimming parameters
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
