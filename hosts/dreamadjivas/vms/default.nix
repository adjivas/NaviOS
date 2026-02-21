{ lib, ... }: {
  imports = [
    ./dreaminstall.nix
    ./dreamkad.nix
    ./windows
  ];

  dreaminstall.enable = lib.mkDefault false;
  dreamkad.enable = lib.mkDefault false;
  windows.enable = lib.mkDefault false;
}
