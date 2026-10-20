{
  imports = [
    ./greetd.nix
    ./pipewire.nix
  ];

  services.dbus.implementation = "broker";
}
