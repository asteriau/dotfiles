{
  # keyboard remapping
  services.kanata = {
    enable = false;

    keyboards.default.config = builtins.readFile (./. + "/main.kbd");
  };
}
