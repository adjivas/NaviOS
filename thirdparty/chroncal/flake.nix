{
  description = "chroncal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    chroncal-src = {
      url = "github:DouglasdeMoura/chroncal";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {pkgs, ...}: {
        packages.chroncal =
          (pkgs.buildGoModule.override {
            go = pkgs.go_1_26;
          }) {
            pname = "chroncal";

            version =
              pkgs.lib.trim
              (builtins.readFile "${inputs.chroncal-src}/VERSION");

            src = inputs.chroncal-src;

            vendorHash = "sha256-Hgkau9LsItuSfLErgT1xwLuSMdCyrmRxDyjUWs/ivjY=";

            subPackages = [
              "cmd/chroncal"
            ];

            env.CGO_ENABLED = "0";

            ldflags = [
              "-s"
              "-w"
              "-X main.version=${
                pkgs.lib.trim
                (builtins.readFile "${inputs.chroncal-src}/VERSION")
              }"
            ];

            doCheck = false;

            meta = {
              description = "Terminal-first calendar, todo, and journal manager";
              homepage = "https://github.com/DouglasdeMoura/chroncal";
              license = pkgs.lib.licenses.mit;
              mainProgram = "chroncal";
            };
          };

        packages.default = self.packages.${pkgs.stdenv.hostPlatform.system}.chroncal;

        apps.default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.chroncal}/bin/chroncal";
        };
      };
    };
}
