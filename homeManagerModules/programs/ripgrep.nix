{ lib, config, ... }: {
  options = {
    ripgrep.enable = lib.mkEnableOption "enable ripgrep";
  };
  config = lib.mkIf config.ripgrep.enable {
    programs.ripgrep.enable = true;
  };
}
