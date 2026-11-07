-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
o.bind("SUPER + d", "Omarchy menu", "omarchy-menu toggle root")

-- Kill active window
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Switch workspaces with SUPER + CTRL + arrow keys
hl.bind("SUPER + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + SHIFT + j",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.focus({ workspace = "e+1" }))

-- Toggle split: it's a layout *message*, not a method under .layout
hl.unbind("SUPER + W")
hl.bind("SUPER + w", hl.dsp.layout("togglesplit"))

-- Focus left / right: focus() lives directly under hl.dsp, not under .window
hl.unbind("SUPER + j")
hl.bind("SUPER + j", hl.dsp.focus({ direction = "left" }))
hl.unbind("SUPER + k")
hl.bind("SUPER + k", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + CTRL + j", hl.dsp.focus({ workspace = "e-1" }))
hl.unbind("SUPER + CTRL + k")
hl.bind("SUPER + CTRL + k", hl.dsp.focus({ workspace = "e+1" }))

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- F1/F2/F3 media keys (mirror XF86 audio keys)
o.bind("F1", "Mute", "omarchy-audio-output-volume mute-toggle", { locked = true })
o.bind("F2", "Volume down", "omarchy-audio-output-volume lower", { locked = true, repeating = true })
o.bind("F3", "Volume up", "omarchy-audio-output-volume raise", { locked = true, repeating = true })
o.bind("F4", "Mute microphone", "omarchy-audio-input-mute", { locked = true })
o.bind("F5", "Brightness down", "omarchy-brightness-display 5%-", { locked = true, repeating = true })
o.bind("F6", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })

-- Sway-like resize mode via Hyprland submap: SUPER+R, then H/J/K/L or arrows, ESC/ENTER to exit
o.bind("SUPER + R", "Resize mode", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  hl.bind("j", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true, description = "Resize left" })
  hl.bind("k", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true, description = "Resize right" })
  hl.bind("LEFT", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true, description = "Resize left" })
  hl.bind("RIGHT", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true, description = "Resize right" })
  hl.bind("UP", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true, description = "Resize up" })
  hl.bind("DOWN", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true, description = "Resize down" })
  hl.bind("ESCAPE", hl.dsp.submap("reset"), { description = "Exit resize mode" })
  hl.bind("RETURN", hl.dsp.submap("reset"), { description = "Exit resize mode" })
end)

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
