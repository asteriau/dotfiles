-- This file sources other files in `hyprland` and `custom` folders
-- You wanna add your stuff in files in `custom`

-- Internal stuff --
require("hyprland.lib")
require("hyprland.services")

-- Environment variables --
require("hyprland.env")
if is_file_exists(HOME .. "/.config/hypr/custom/env.lua") then
    require(HOME .. "/.config/hypr/custom/env.lua")
end

-- Default configurations --
require("hyprland.execs")
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")
-- matugen writes the live palette here; the shipped colors.lua is the default
if is_file_exists(HOME .. "/.config/hypr/hyprland/colors.lua") then
    require(HOME .. "/.config/hypr/hyprland/colors.lua")
end
require("hyprland.keybinds")

-- Custom configurations --
if is_file_exists(HOME .. "/.config/hypr/custom/execs.lua") then
    require(HOME .. "/.config/hypr/custom/execs.lua")
end
if is_file_exists(HOME .. "/.config/hypr/custom/general.lua") then
    require(HOME .. "/.config/hypr/custom/general.lua")
end
if is_file_exists(HOME .. "/.config/hypr/custom/rules.lua") then
    require(HOME .. "/.config/hypr/custom/rules.lua")
end
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
    require(HOME .. "/.config/hypr/custom/keybinds.lua")
end

-- nwg-displays support --
if is_file_exists(HOME .. "/.config/hypr/workspaces.lua") then
    require(HOME .. "/.config/hypr/workspaces.lua")
end
if is_file_exists(HOME .. "/.config/hypr/monitors.lua") then
    require(HOME .. "/.config/hypr/monitors.lua")
end

-- Shell overrides --
-- the settings app writes this file; home/quickshell/state.nix seeds it from the shipped default
if is_file_exists(HOME .. "/.config/hypr/hyprland/shellOverrides/main.lua") then
    require(HOME .. "/.config/hypr/hyprland/shellOverrides/main.lua")
else
    require("hyprland.shellOverrides.main")
end
