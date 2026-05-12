{
  lib,
  self,
  fallback ? "default-dark",
}:
let
  themesDir = "${self}/home/services/quickshell/themes";
  stateDir = "${self}/home/services/quickshell/state";

  activePresetFile = "${stateDir}/active-preset";
  matugenFile = "${stateDir}/colors.json";

  load = import ./load.nix { inherit lib; };
  normalize = import ./normalize.nix { inherit lib; };
  format = import ./format.nix { inherit lib; };
  colors = import ../colors lib;

  preset = load.readActivePreset {
    file = activePresetFile;
    inherit fallback;
  };

  presetPalette = normalize (
    load.loadPreset {
      dir = themesDir;
      name = preset;
    }
  );

  matugenRaw = load.readMatugen { file = matugenFile; };
  matugenPalette = if matugenRaw == null then { } else normalize matugenRaw;

  palette = presetPalette // matugenPalette;
  source = if matugenRaw == null then "preset:${preset}" else "preset:${preset}+matugen";
in
{
  inherit
    palette
    preset
    source
    format
    colors
    ;
}
