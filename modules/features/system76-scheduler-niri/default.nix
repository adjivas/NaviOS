{inputs, ...}: {
  den.aspects.system76-scheduler-niri = {
    nixos = {
      services.system76-scheduler.enable = true;
    };

    homeManager = {pkgs, ...}: let
      system = pkgs.stdenv.hostPlatform.system;
      system76-scheduler-niri = inputs.system76-scheduler-niri.packages.${system}.default;
    in {
      imports = [
        inputs.system76-scheduler-niri.homeModules.default
      ];

      services.system76-scheduler-niri = {
        enable = true;

        package = let
          upstream = system76-scheduler-niri;

          src = pkgs.applyPatches {
            name = "system76-scheduler-niri-source";
            src = upstream.src;

            patches = [
              ./system76-scheduler-niri-niri-26.4.patch
            ];
          };
        in
          upstream.overrideAttrs (_old: {
            inherit src;

            cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-6OVy0QeDYWR0BMgppB40U8TYa/N44T4Ag9Sj4ZH7luM=";
            };
          });
      };
    };
  };
}
