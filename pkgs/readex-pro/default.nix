{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "readex-pro";
  version = "unstable-2026-10-20";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/google/fonts/47d54ca1ebb14fd864695f1d39dc734f39017c33/ofl/readexpro/ReadexPro%5BHEXP,wght%5D.ttf";
    hash = "sha256-Jou6fh6POxTXmLP7DkDrqj/DkwjJrAAg4vr23xgcww4=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src "$out/share/fonts/truetype/ReadexPro[HEXP,wght].ttf"
    runHook postInstall
  '';

  meta = {
    description = "Readex Pro variable font";
    homepage = "https://fonts.google.com/specimen/Readex+Pro";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
