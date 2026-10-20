{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        bibata-hyprcursor = pkgs.callPackage ./bibata-hyprcursor { };
        breeze-plus = pkgs.callPackage ./breeze-plus { };
        google-sans-flex = pkgs.callPackage ./google-sans-flex { };
        readex-pro = pkgs.callPackage ./readex-pro { };
        space-grotesk = pkgs.callPackage ./space-grotesk { };
      };
    };
}
