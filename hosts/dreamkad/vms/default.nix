{ lib, ... }: {
  imports = [
    ./arkad.nix
  ];

  arkad.enable = lib.mkDefault false;
}
