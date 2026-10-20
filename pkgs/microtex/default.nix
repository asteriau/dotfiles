{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  tinyxml-2,
  gtkmm3,
  gtksourceview3,
  gtksourceviewmm,
  sysprof,
  cairomm_1_0,
  fontconfig,
}:
stdenv.mkDerivation {
  pname = "microtex";
  version = "unstable-2026-06-05";

  src = fetchFromGitHub {
    owner = "end-4";
    repo = "MicroTeX";
    rev = "e8c6e58b1306119e51297b02f0b449fa7300416d";
    hash = "sha256-AxzSroxu6hSBaW40TJWttfIFgTAVHg1beC2qPEQPayE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    tinyxml-2
    gtkmm3
    gtksourceview3
    gtksourceviewmm
    sysprof
    cairomm_1_0
    fontconfig
  ];

  # No install target upstream; the shell expects LaTeX and res/ side by side.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/MicroTeX
    cp LaTeX $out/opt/MicroTeX/
    cp -r res $out/opt/MicroTeX/
    runHook postInstall
  '';

  meta = {
    description = "MicroTeX LaTeX renderer (end-4 fork used by illogical-impulse)";
    homepage = "https://github.com/end-4/MicroTeX";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "LaTeX";
  };
}
