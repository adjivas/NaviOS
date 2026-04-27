{ lib, config, ... }: {
  options = {
    swaylock.enable = lib.mkEnableOption "enable swaylock";
  };
  config = lib.mkIf config.swaylock.enable {
    programs.swaylock = {
      enable = true;
    };
  };
}
