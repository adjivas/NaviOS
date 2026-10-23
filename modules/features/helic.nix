{inputs, ...}: {
  den.aspects.helic.nixos = {
    imports = [
      inputs.helic.nixosModules.default
    ];

    nixpkgs.overlays = [
      (final: prev: {
        haskellPackages = prev.haskellPackages.override {
          overrides = _: hprev: {
            vcr = final.haskell.lib.dontCheck hprev.vcr;
          };
        };
      })
    ];

    services.helic = {
      enable = true;

      net.enable = false;
      wayland.enable = true;
    };
  };

  den.batteries.helic = {
    target,
    display,
  }: {user, ...}: {
    name = "helic-${user.userName}-${target}";

    homeManager = {
      systemd.user.services.helic = {
        after = [target];
        partOf = [target];
        wantedBy = [target];

        environment = {
          WAYLAND_DISPLAY = display;
          XDG_RUNTIME_DIR = "%t";
        };
      };
    };
  };
}
