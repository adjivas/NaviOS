{ lib, config, ... }: {
  options = {
    kanshi.enable = lib.mkEnableOption "enable kanshi";
  };
  config = lib.mkIf config.kanshi.enable {
    services.kanshi = {
      enable = true;
      systemdTarget = "";
    };
  };
}
