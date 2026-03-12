{ lib, ... }: {
  imports = [
    ./yubico.nix
    ./pipewire.nix
    ./pixie.nix
    ./gc.nix
    ./lact.nix
    ./lafayette.nix
    ./i18n.nix
    ./steam.nix
    ./greetd.nix
    ./wayvnc.nix

    ./virtualisation.nix
    ./plymouth
  ];

  yubico.enable = lib.mkDefault false;
  pipewire.enable = lib.mkDefault false;
  pixie.enable = lib.mkDefault false;
  plymouth.enable = lib.mkDefault false;
  gc.enable = lib.mkDefault false;
  lact.enable = lib.mkDefault false;
  lafayette.enable = lib.mkDefault false;
  i18n.enable = lib.mkDefault false;
  steam.enable = lib.mkDefault false;
  wayvnc.enable = lib.mkDefault false;

  virtualisation.enable = lib.mkDefault false;
}
