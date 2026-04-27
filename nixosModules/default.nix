{ lib, ... }: {
  imports = [
    ./yubico.nix
    ./pipewire.nix
    ./cache.nix
    ./pixie.nix
    ./gc.nix
    ./lact.nix
    ./lafayette.nix
    ./i18n.nix
    ./steam.nix
    ./greetd.nix
    ./wayvnc.nix
    ./power.nix
    ./nvidia.nix
    ./gitlab-runner.nix
    ./docker.nix

    ./virtualisation.nix
    ./plymouth
  ];

  yubico.enable = lib.mkDefault false;
  pipewire.enable = lib.mkDefault false;
  cache.enable = lib.mkDefault false;
  pixie.enable = lib.mkDefault false;
  plymouth.enable = lib.mkDefault false;
  gc.enable = lib.mkDefault false;
  lact.enable = lib.mkDefault false;
  lafayette.enable = lib.mkDefault false;
  i18n.enable = lib.mkDefault false;
  steam.enable = lib.mkDefault false;
  wayvnc.enable = lib.mkDefault false;
  power.enable = lib.mkDefault false;
  nvidia.enable = lib.mkDefault false;
  gitlab-runner.enable = lib.mkDefault false;
  docker.enable = lib.mkDefault false;

  virtualisation.enable = lib.mkDefault false;
}
