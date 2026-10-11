{
  den.aspects.moonlight-web-stream.homeManager = {
    inputs,
    lib,
    pkgs,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    toolchain = inputs.fenix.packages.${system}.toolchainOf {
      channel = "nightly";
      date = "2026-02-13";
      sha256 = "sha256-S4LusOItdSmt4Z+R5llNu9B3h1Lt+BXQuY9BUnl2xFg=";
    };

    package = pkgs.callPackage ./_package.nix {
      rustPlatform = pkgs.makeRustPlatform {
        cargo = toolchain.cargo;
        rustc = toolchain.rustc;
      };
    };
  in {
    options.moonlight-web-stream = {
      package = lib.mkOption {
        type = lib.types.package;
        default = package;
        description = "moonlight-web-stream package to use.";
      };
      cert = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/microvm-certs/microvm.crt";
        description = "TLS certificate used by novnc.";
      };
      key = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/microvm-certs/microvm.key";
        description = "TLS private key used by novnc.";
      };
    };
    config = {
      systemd.user.services.moonlight-web-stream = {
        Unit = {
          Description = "Moonlight Web Stream";
          After = [
            "graphical-session.target"
            "sunshine.service"
          ];
          Requires = [
            "sunshine.service"
          ];
          PartOf = [
            "graphical-session.target"
          ];
        };
        Install.WantedBy = ["default.target"];

        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = "5s";

          ExecStartPre = pkgs.writeShellScript "moonlight-web-stream-prepare" ''
            set -e

            state_dir="${config.xdg.stateHome}/moonlight-web-stream"

            ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
            ${pkgs.coreutils}/bin/ln -sfn ${config.moonlight-web-stream.package}/share/moonlight-web-stream/static "$state_dir/static"
            ${pkgs.coreutils}/bin/ln -sfn ${config.moonlight-web-stream.package}/bin/streamer "$state_dir/streamer"
          '';

          ExecStart = pkgs.writeShellScript "moonlight-web-stream-start" ''
            set -e

            state_dir="${config.xdg.stateHome}/moonlight-web-stream"
            cd "$state_dir"

            exec ${config.moonlight-web-stream.package}/bin/web-server \
              --ssl-certificate ${config.moonlight-web-stream.cert} \
              --ssl-private-key ${config.moonlight-web-stream.key}
          '';
        };
      };
    };
  };
}
