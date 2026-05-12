{
  lib,
  self,
  fallback ? "default-dark",
}:
let
  themesDir = "${self}/home/services/quickshell/themes";
  stateDir = "${self}/home/services/quickshell/state";

  activePresetFile = "${stateDir}/active-preset";

  load = import ./load.nix { inherit lib; };
  normalize = import ./normalize.nix { inherit lib; };
  format = import ./format.nix { inherit lib; };
  colors = import ../colors lib;

  preset = load.readActivePreset {
    file = activePresetFile;
    inherit fallback;
  };

  presetRaw = load.loadPreset {
    dir = themesDir;
    name = preset;
  };

  palette = normalize presetRaw;
in
{
  inherit
    palette
    preset
    format
    colors
    ;
  source = "preset:${preset}";
}
