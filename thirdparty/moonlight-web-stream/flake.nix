{
  description = "Moonlight Web Stream packaged";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    fenix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        fenixPkgs = fenix.packages.${system};

        toolchain = fenixPkgs.toolchainOf {
          channel = "nightly";
          date = "2026-02-13";
          sha256 = "sha256-S4LusOItdSmt4Z+R5llNu9B3h1Lt+BXQuY9BUnl2xFg=";
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = toolchain.cargo;
          rustc = toolchain.rustc;
        };
      in {
        packages.moonlight-web-stream = pkgs.callPackage ./package.nix {
          inherit rustPlatform;
        };

        packages.default = self.packages.${system}.moonlight-web-stream;
      };
    };
}
