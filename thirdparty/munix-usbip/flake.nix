{
  nixConfig = {
    extra-substituters = ["https://cache.clan.lol"];
    extra-trusted-public-keys = ["cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    sidebus.url = "git+https://git.clan.lol/clan/sidebus?shallow=1&ref=main";
    sidebus.inputs.nixpkgs.follows = "nixpkgs";
    sidebus.inputs.flake-parts.follows = "flake-parts";

    wl-backdrop.url = "git+https://git.clan.lol/valpackett/wl-backdrop?shallow=1&ref=main";
    wl-backdrop.inputs.nixpkgs.follows = "nixpkgs";
    wl-backdrop.inputs.flake-parts.follows = "flake-parts";

    # To override with local checkouts during development, use the --override-input CLI flag!
    muvm-src = {
      url = "github:valpackett/muvm/5107ba4170b1e23c6661dbf86d1311d621a928ae"; # v0.6.0+custom-init+dbus
      flake = false;
    };
    libkrun-src = {
      url = "github:valpackett/libkrun/f70dcf152e706429c84285a58107a255efc9a813"; # upstream-rutabaga+dbus
      flake = false;
    };
    # libkrunfw-src = {
    #   url = "github:containers/libkrunfw/20484a2e60290acb74c43ccfd6e1ea4caf41d470"; # v5.1.0
    #   flake = false;
    # };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    sidebus,
    wl-backdrop,
    muvm-src,
    libkrun-src,
    # libkrunfw-src,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        nixosModules.testvm = ./nixosModules/testvm.nix;
        nixosModules.default = nixpkgs.lib.modules.importApply ./nixosModules/default.nix {
          inherit self;
        };

        templates.musictest = {
          description = "Music player demo VM with MPD and Euphonica";
          path = ./templates/musictest;
        };

        nixosConfigurations.testvm-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            self.nixosModules.testvm
            {nixpkgs.config.allowUnfree = true;}
          ];
        };

        nixosConfigurations.testvm-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            self.nixosModules.default
            self.nixosModules.testvm
            {nixpkgs.config.allowUnfree = true;}
          ];
        };
      };

      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        checks =
          (pkgs.lib.mapAttrs' (n: pkgs.lib.nameValuePair "package-${n}") self'.packages)
          // (pkgs.lib.mapAttrs' (n: pkgs.lib.nameValuePair "devShell-${n}") self'.devShells)
          // (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
            nixos-testvm = self.nixosConfigurations.testvm-x86_64.config.system.build.toplevel;
          })
          // (pkgs.lib.optionalAttrs (system == "aarch64-linux") {
            nixos-testvm = self.nixosConfigurations.testvm-aarch64.config.system.build.toplevel;
          });

        packages = {
          # Packages support variant parameter: null (default), "sev", or "tdx"
          # To build a variant: packages.libkrunfw.override { variant = "sev"; }
          libkrunfw = pkgs.callPackage ./packages/libkrunfw {
            # libkrunfw-src = libkrunfw-src;
          };

          libkrun = pkgs.callPackage ./packages/libkrun {
            libkrunfw = self'.packages.libkrunfw;
            libkrun-src = libkrun-src;
          };

          mesa = pkgs.callPackage ./packages/mesa {};

          muvm = pkgs.callPackage ./packages/muvm {
            libkrun = self'.packages.libkrun;
            muvm-src = muvm-src;
          };

          munix = pkgs.callPackage ./packages/munix {
            mesa = self'.packages.mesa;
            muvm = self'.packages.muvm;
            wl-cross-domain-proxy = self'.packages.wl-cross-domain-proxy;
            wl-backdrop = wl-backdrop.packages.${system}.wl-backdrop;
            sidebus-broker = sidebus.packages.${system}.sidebus-broker;
          };

          wl-cross-domain-proxy = pkgs.callPackage ./packages/wl-cross-domain-proxy {};
        };

        devShells.default = pkgs.callPackage ./devShells {
          libkrun = self'.packages.libkrun;
          muvm = self'.packages.muvm;
          wl-cross-domain-proxy = self'.packages.wl-cross-domain-proxy;
          wl-backdrop = wl-backdrop.packages.${system}.wl-backdrop;
          sidebus-broker = sidebus.packages.${system}.sidebus-broker;
        };
      };
    };
}
