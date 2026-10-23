{inputs, ...}: {
  den.aspects.megapixels.nixos = {pkgs, ...}: let
    libmegapixels = pkgs.libmegapixels.overrideAttrs (old: {
      mesonFlags =
        (old.mesonFlags or [])
        ++ [
          "--sysconfdir=/etc"
        ];
    });

    megapixelsPackage =
      (pkgs.megapixels.override {
        inherit libmegapixels;
      }).overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ./fix-dcp-discovery.patch
          ];
      });

    megapixels = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;

      package = megapixelsPackage;

      runtimeInputs = [
        libmegapixels
        pkgs.v4l-utils
      ];
    };
  in {
    environment.systemPackages = [
      megapixels
      libmegapixels
      pkgs.v4l-utils
    ];

    # Thanks Abyss for the config file.
    environment.etc."megapixels/config/fairphone,fp5.conf".source =
      ./fairphone-fp5.conf;
  };
}
