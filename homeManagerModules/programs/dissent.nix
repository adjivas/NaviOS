{ lib, pkgs, config, ... }: {
  options = {
    dissent.enable = lib.mkEnableOption "enable dissent";
  };
  config = lib.mkIf config.dissent.enable {
    home.packages = [
      pkgs.dissent
    ];
  };
}
