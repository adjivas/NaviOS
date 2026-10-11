{inputs, ...}: {
  den.aspects.gc.nixos = {
    imports = [
      inputs.fast-nix-gc.nixosModules.default
    ];
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
}
