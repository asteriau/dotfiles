{
  lib,
  self,
  profile,
  fallback ? "default-dark",
}:
let
  themesDir = "${self}/home/services/quickshell/themes";

  # State files (active-preset, colors.json) are gitignored, so they're absent
  # from the /nix/store copy of the flake. Reach the live filesystem via the
  # absolute path; requires --impure on rebuild.
  liveStateDir = "${profile.flakePath}/home/services/quickshell/state";

  activePresetFile = "${liveStateDir}/active-preset";
  activeModeFile = "${liveStateDir}/active-mode";
  matugenFile = "${liveStateDir}/colors.json";

  load = import ./load.nix { inherit lib; };
  normalize = import ./normalize.nix { inherit lib; };
  format = import ./format.nix { inherit lib; };
  colors = import ../colors lib;

  preset = load.readActivePreset {
    file = activePresetFile;
    inherit fallback;
  };

  mode = load.readActiveMode {
    file = activeModeFile;
    fallback = "preset";
  };

  presetPalette = normalize (
    load.loadPreset {
      dir = themesDir;
      name = preset;
    }
  );

  matugenRaw = if mode == "matugen" then load.readMatugen { file = matugenFile; } else null;
  matugenPalette = if matugenRaw == null then { } else normalize matugenRaw;

  palette = presetPalette // matugenPalette;
  source = if matugenRaw == null then "preset:${preset}" else "preset:${preset}+matugen";
in
{
  inherit
    palette
    preset
    mode
    source
    format
    colors
    ;
}
