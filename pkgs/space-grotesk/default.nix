{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "space-grotesk";
  version = "unstable-2026-10-20";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/google/fonts/47d54ca1ebb14fd864695f1d39dc734f39017c33/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf";
    hash = "sha256-rK1t4fyTQ29cDx9BN3Ue8E8a6jBj5wNlNZcP/PvXn3I=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src "$out/share/fonts/truetype/SpaceGrotesk[wght].ttf"
    runHook postInstall
  '';

  meta = {
    description = "Space Grotesk variable font";
    homepage = "https://fonts.google.com/specimen/Space+Grotesk";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
