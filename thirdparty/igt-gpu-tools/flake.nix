{
  description = "intel-gpu-tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem = {pkgs, ...}: let
        patchShebangsPhase = ''
          patchShebangs lib man scripts tests docs
        '';

        intel-gpu-tools = pkgs.intel-gpu-tools.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "drm";
            repo = "igt-gpu-tools";
            rev = "faad2cd0e3e8eb2e18111c2358823a7bdfb56d94";
            hash = "sha256-Es4WNc/PHxyVptTxsER2dF3Uxh+QO0z67bz3tEglhPU=";
          };

          version = "git";

          buildInputs =
            (old.buildInputs or [])
            ++ [
              pkgs.pciutils
              pkgs.jansson
            ];

          mesonFlags =
            (old.mesonFlags or [])
            ++ [
              "-Doverlay=disabled"
            ];

          preConfigure = patchShebangsPhase;

          meta =
            old.meta
            // {
              platforms = pkgs.lib.platforms.linux;
            };
        });
      in {
        packages = {
          inherit intel-gpu-tools;
          default = intel-gpu-tools;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            intel-gpu-tools
          ];

          packages = [
            pkgs.perf
          ];

          shellHook = patchShebangsPhase;
        };
      };
    };
}
