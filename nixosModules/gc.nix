{ lib, config, ... }: {
  options = {
    gc.enable = lib.mkEnableOption "enable gc nix";
  };
  config = lib.mkIf config.gc.enable {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      # options = "--delete-older-than 14d --keep-generations 10";
      options = "--max-old-generations 10";
    };
    
    nix.optimise = {
      automatic = true;
      dates = [ "04:45" ];
    };
  };
}
