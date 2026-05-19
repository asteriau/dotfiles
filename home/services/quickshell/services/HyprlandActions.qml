pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    // Hyprland 0.55's Lua config evaluates `hyprctl dispatch <arg>` as Lua
    // (`return hl.dispatch(<arg>)`), so the legacy "workspace N" string no
    // longer works — pass the hl.dsp.* dispatcher expression instead.
    function switchToWorkspace(id: int): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    function nextWorkspace(): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "r+1" })`);
    }

    function prevWorkspace(): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "r-1" })`);
    }
}
