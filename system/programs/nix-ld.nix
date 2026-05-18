{ pkgs, ... }:

{
  # Some tools ship prebuilt, generically dynamically-linked ELF binaries
  # that expect the FHS loader at /lib64/ld-linux-x86-64.so.2. On NixOS that
  # path is only stub-ld, so such binaries exit 127 ("NixOS cannot run
  # dynamically linked executables intended for generic linux environments").
  #
  # So the fix for that is literally just this
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++ / libgcc_s for the Bun-compiled binary
      zlib
    ];
  };
}
