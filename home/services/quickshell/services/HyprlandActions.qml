pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    function switchToWorkspace(id: int): void {
        Hyprland.dispatch(`workspace ${id}`);
    }

    function nextWorkspace(): void {
        Hyprland.dispatch("workspace r+1");
    }

    function prevWorkspace(): void {
        Hyprland.dispatch("workspace r-1");
    }
}
