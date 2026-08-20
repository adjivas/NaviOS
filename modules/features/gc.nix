{
  den.aspects.gc.nixos = {
    config = {
      services.fast-nix-gc = {
        enable = true;
        automatic = true;
        dates = "weekly";
        keepRecent = "1d";
      };
      services.fast-nix-optimise = {
        enable = true;
        automatic = true;
        dates = "weekly";
      };
    };
  };
}
