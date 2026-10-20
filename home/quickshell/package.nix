{
  lib,
  pkgs,
  inputs,
  quickshellDeps,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  upstream = inputs.quickshell.packages.${system}.default;

  # QML modules the ii config imports that quickshell's own wrapper does not add.
  qmlPath = lib.makeSearchPath "lib/qt-6/qml" (
    [ upstream ]
    ++ (with pkgs.kdePackages; [
      qtdeclarative
      qt5compat
      qtpositioning
      qtlocation
      qtsensors
      qtmultimedia
      qtsvg
      qtimageformats
      qtpositioning
      qtquicktimeline
      qtvirtualkeyboard
      qtwayland
      kirigami.unwrapped
      syntax-highlighting
    ])
  );

  pluginPath = lib.makeSearchPath "lib/qt-6/plugins" (
    with pkgs.kdePackages;
    [
      qtbase
      qtsvg
      qtwayland
      qtimageformats
      qtpositioning
    ]
  );

  quickshell = pkgs.symlinkJoin {
    name = "quickshell-ii";
    paths = [ upstream ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in qs quickshell; do
        wrapProgram $out/bin/$bin \
          --prefix QML2_IMPORT_PATH : "${qmlPath}" \
          --prefix QT_PLUGIN_PATH : "${pluginPath}" \
          --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}" \
          --prefix PATH : "${lib.makeBinPath quickshellDeps}"
      done
    '';
  };
in
{
  _module.args.quickshell = quickshell;

  home.packages = [ quickshell ] ++ quickshellDeps;
}
