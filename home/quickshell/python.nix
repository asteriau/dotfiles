{ lib, pkgs, ... }:
let
  env = pkgs.python3.withPackages (
    ps: with ps; [
      build
      pillow
      setuptools-scm
      wheel
      pywayland
      psutil
      # Outside Plasma this tool crashes on KWin and konsole paths; same fix as
      # celesrenata/end-4-flakes. plasma-apply-colorscheme is stubbed in fakeVenv.
      (kde-material-you-colors.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          for f in $out/lib/python*/site-packages/kde_material_you_colors/utils/kwin_utils.py; do
            substituteInPlace "$f" --replace-quiet 'def reload():' $'def reload():\n    return  # no KWin outside Plasma'
          done
          for f in $out/lib/python*/site-packages/kde_material_you_colors/utils/konsole_utils.py; do
            substituteInPlace "$f" --replace-quiet 'os.makedirs(settings.KONSOLE_DIR)' 'os.makedirs(settings.KONSOLE_DIR, exist_ok=True)'
          done
        '';
      }))
      materialyoucolor
      libsass
      material-color-utilities
      setproctitle
      click
      loguru
      pycairo
      pygobject3
      tqdm
      numpy
      opencv4
      google-auth
      requests
    ]
  );

  # Upstream scripts `source "$TACHYON_VIRTUAL_ENV/bin/activate"`,
  # then call python3 / kde-material-you-colors / their .py by name.
  fakeVenv = pkgs.runCommand "tachyon-venv" { } ''
    mkdir -p $out/bin
    cat > $out/bin/activate <<EOF
    export VIRTUAL_ENV="$out"
    export PATH="${env}/bin:$out/bin:\$PATH"
    export GI_TYPELIB_PATH="${
      lib.makeSearchPath "lib/girepository-1.0" (
        with pkgs;
        [
          gnome-desktop
          gtk4
          libadwaita
          libsoup_3
          libportal-gtk4
          glib.out
          graphene
          gobject-introspection-unwrapped.out # cairo-1.0 typelib
          gsettings-desktop-schemas # GDesktopEnums for GnomeDesktop
          gdk-pixbuf
          pango.out
          harfbuzz
        ]
      )
    }:\$GI_TYPELIB_PATH"
    deactivate() { :; }
    EOF
    printf '#!/bin/sh\nexit 0\n' > $out/bin/plasma-apply-colorscheme
    chmod +x $out/bin/plasma-apply-colorscheme
  '';
in
{
  _module.args.tachyonPython = {
    inherit env fakeVenv;
  };

  home.packages = [ env ];
}
