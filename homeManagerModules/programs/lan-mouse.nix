{ lib, config, pkgs, fenix, ... }: {
  options = {
    lan-mouse.enable = lib.mkEnableOption "enable lan-mouse";
  };
  config = lib.mkIf config.lan-mouse.enable {
    programs.lan-mouse = {
      enable = true;
      systemd = false;
    };
  };
}
