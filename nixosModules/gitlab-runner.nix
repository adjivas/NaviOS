{ pkgs, lib, config, ... }: {
  options = {
    gitlab-runner.enable = lib.mkEnableOption "enable gitlab-runner";
    gitlab-runner.concurrent = lib.mkOption {
      type = lib.types.int;
      default = 4;
    };
  };
  config = lib.mkIf config.gitlab-runner.enable {
    docker.enable = true;

    # GitLab CI et Nix  https://cobalt.rocks/posts/nix-gitlab/
    services.gitlab-runner = {
      enable = true;
      settings = {
        concurrent = config.gitlab-runner.concurrent;
        listen_address = "127.0.0.1:9252";
      };

      services.runner = let
        nixJoin = list: builtins.concatStringsSep " " list;
        # enable sandbox & flakes + passthrough of host substituters
        nix-conf = pkgs.writeText "nix.conf" ''
          accept-flake-config = true
          experimental-features = nix-command flakes
          max-jobs = auto
          sandbox = true

          substituters = ${nixJoin (config.nix.settings.substituters or [])}
          trusted-public-keys = ${nixJoin (config.nix.settings.trusted-public-keys or [])}
          trusted-substituters = ${nixJoin (config.nix.settings.trusted-substituters or [])}
        '';
          # extra-trusted-public-keys = ${nixJoin config.nix.settings.extra-trusted-public-keys}
      in {
        # community managed, automatically updated nix image with flakes + commands pre-enabled
        dockerImage = "nixpkgs/nix-flakes:nixos-${config.system.nixos.release}-${pkgs.stdenv.hostPlatform.system}";

        dockerVolumes = [
          "${nix-conf}:/etc/nix/nix.conf:ro"
          # passthrough bash & grep for gitlab ci (used inside the executor, not contained in the base image)
          "${lib.getExe pkgs.pkgsStatic.gnugrep}:/usr/bin/grep:ro"
          "${lib.getExe pkgs.pkgsStatic.bash}:/usr/bin/sh:ro"
          "${lib.getExe pkgs.pkgsStatic.bash}:/usr/bin/bash:ro"
        ];

        registrationFlags = [
          "--docker-pull-policy=if-not-present"
          "--docker-allowed-pull-policies=if-not-present"
          "--docker-allowed-pull-policies=always"
        ];

        authenticationTokenConfigFile = config.age.secrets."gitlab-runner.env".path;
      };
    };
  };
}
