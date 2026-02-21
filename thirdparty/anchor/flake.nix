{
  description = "Package Anchor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    anchor-src = {
      url = "github:garrettjoecox/anchor/main";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, anchor-src, ... }: flake-parts.lib.mkFlake {
    inherit inputs;
  } {
    systems = [ "x86_64-linux" "aarch64-linux" ];

    perSystem = { self', pkgs, ... }: {
      packages.anchor = pkgs.writeShellApplication {
        name = "anchor";
        text = ''
          set -euo pipefail

          exec ${pkgs.deno}/bin/deno run --allow-all ${anchor-src}/mod.ts
        '';
      };

      # nix build .#
      packages.default = self'.packages.anchor;

      apps.default = {
        type = "app";
        program = "${self.packages.default}/bin/anchor";
      };

      # nix dev
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.deno ];
      };
    };
  };
}
