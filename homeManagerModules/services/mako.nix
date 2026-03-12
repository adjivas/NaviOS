{ lib, config, ... }: {
  options = {
    mako.enable = lib.mkEnableOption "enable mako";
  };
  config = lib.mkIf config.mako.enable {
    stylix.targets.mako.enable = true;

    services.mako = {
      enable = true;
      settings = { default-timeout = 5000; };
    };
  };
}
