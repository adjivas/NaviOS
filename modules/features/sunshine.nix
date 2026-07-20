{
  den.aspects.sunshine.nixos = {pkgs, ...}: {
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 47984;
        to = 48010;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48010;
      }
    ];

    security.wrappers.sunshine = {
      source = "${pkgs.sunshine}/bin/sunshine";
      capabilities = "cap_sys_admin+p";
      owner = "root";
      group = "root";
    };
  };

  den.aspects.sunshine.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.sunshine = {
      username = lib.mkOption {
        type = lib.types.str;
        default = config.home.username;
        description = "Sunshine pairing username.";
      };
      password = lib.mkOption {
        type = lib.types.str;
        description = "Sunshine pairing password.";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "UID used to build XDG_RUNTIME_DIR.";
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
      systemd.user.services.sunshine = {
        Unit = {
          Description = "Sunshine game streaming server";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Install = {
          WantedBy = ["default.target"];
        };

        Service = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "5s";

          Environment = [
            "HOME=${config.home.homeDirectory}"
            "XDG_CONFIG_HOME=${config.xdg.configHome}"
            "XDG_RUNTIME_DIR=/run/user/${toString config.sunshine.uid}"
          ];

          ExecStartPre = [
            "${pkgs.coreutils}/bin/mkdir -p ${config.xdg.configHome}/sunshine"
            "/run/wrappers/bin/sunshine --creds ${config.sunshine.username} ${config.sunshine.password}"
          ];

          ExecStart = lib.mkForce ''
            /run/wrappers/bin/sunshine \
              pkey=${config.sunshine.key} \
              cert=${config.sunshine.cert}
          '';
        };
      };
    };
  };
}
