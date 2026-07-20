{
  den.aspects.gitlab-runner.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.gitlab-runner = {
      concurrent = lib.mkOption {
        type = lib.types.int;
        default = 4;
      };
      authenticationTokenConfigFile = lib.mkOption {
        type = lib.types.path;
      };
    };

    config = {
      systemd.services.gitlab-runner = {
        after = [
          "docker.service"
        ];

        wants = [
          "docker.service"
        ];
      };
      # GitLab CI et Nix https://cobalt.rocks/posts/nix-gitlab/
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

          authenticationTokenConfigFile = config.gitlab-runner.authenticationTokenConfigFile;
        };
      };
    };
  };
}
