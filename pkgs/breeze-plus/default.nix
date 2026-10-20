{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "breeze-plus";
  version = "unstable-2026-06-30";

  src = fetchFromGitHub {
    owner = "mjkim0727";
    repo = "breeze-plus";
    rev = "a7a9dcb6bcb8045966472744f3e8350905b560da";
    hash = "sha256-HyXf0Bn6Z9tOy1jncFHqZctNdqW6GQIH8hYdhDsKPCQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r src/breeze-plus* $out/share/icons/
    runHook postInstall
  '';

  meta = {
    description = "Breeze icon theme with extra app icons";
    homepage = "https://github.com/mjkim0727/breeze-plus";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.all;
  };
}
