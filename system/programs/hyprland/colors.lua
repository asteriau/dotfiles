-- Runtime theme overlay. Generated into ~/.config/quickshell/state/
-- hyprland-colors.lua by services/Theme.qml (preset mode) or
-- services/Matugen.qml (matugen mode). Loaded with a guard so a missing or
-- malformed overlay can never brick the WM. hyprctl reload re-evaluates the
-- Lua config fresh, so live theme changes apply. See repo CLAUDE.md
-- "Theme system — the dual-write contract".
local p = os.getenv("HOME") .. "/.config/quickshell/state/hyprland-colors.lua"
local f = io.open(p, "r")
if f then
  f:close()
  pcall(dofile, p)
end
