{
  den.aspects.btrbk.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.btrbk = {
      subvolume = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        description = "BTRFS subvolumes managed by btrbk.";
      };

      remoteHost = lib.mkOption {
        type = lib.types.str;
        description = "Remote host receiving btrbk backups.";
      };

      sshPrivateKey = lib.mkOption {
        type = lib.types.path;
        description = "Path to the private SSH key used by btrbk.";
      };

      sshPublicKey = lib.mkOption {
        type = lib.types.str;
        description = "Public SSH key allowed to access this host through btrbk.";
      };
    };

    config = let
      latest-btrbk-backup = pkgs.writeShellScriptBin "latest-btrbk-backup" ''
        set -euo pipefail

        subvol="''${SSH_ORIGINAL_COMMAND:-}"

        [[ "$subvol" =~ ^(Documents|Etudes|Pictures|PoCs)$ ]] || exit 1

        find /nix/persistent/backups/dream76/adjivas \
          -maxdepth 1 \
          -type d \
          -name "$subvol.*" \
          | sort \
          | tail -n1 \
          | xargs -r basename
      '';
      restore-btrbk-backup = pkgs.writeShellScriptBin "restore-btrbk-backup" ''
        set -euo pipefail

        args="''${SSH_ORIGINAL_COMMAND:-}"

        read -r machine snapshot <<< "$args"

        [[ "$machine" =~ ^(dream00|dream76)$ ]] || exit 1
        [[ "$snapshot" =~ ^(Documents|Etudes|Pictures|PoCs)\.[0-9]{8}T[0-9]{4}$ ]] || exit 1

        sudo ${pkgs.btrfs-progs}/bin/btrfs send "/nix/persistent/backups/$machine/adjivas/$snapshot"
      '';
    in {
      environment.systemPackages = [
        latest-btrbk-backup
        restore-btrbk-backup
      ];
      security.sudo.extraRules = [
        {
          users = ["btrbk-latest"];
          commands = [
            {
              command = "${latest-btrbk-backup}/bin/latest-btrbk-backup";
              options = ["NOPASSWD"];
            }
          ];
        }
        {
          users = ["btrbk-restore"];
          commands = [
            {
              command = "${pkgs.btrfs-progs}/bin/btrfs send /nix/persistent/backups/*/adjivas/*";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
      users.users = {
        btrbk-latest = {
          home = "/var/lib/btrbk-latest";
          group = "btrbk-latest";
          isSystemUser = true;
          createHome = true;
          shell = pkgs.bashInteractive;

          openssh.authorizedKeys.keys = [
            ''
              command="${latest-btrbk-backup}/bin/latest-btrbk-backup",restrict ${config.btrbk.sshPublicKey}
            ''
          ];
        };
        btrbk-restore = {
          home = "/var/lib/btrbk-restore";
          group = "btrbk-restore";
          isSystemUser = true;
          createHome = true;
          shell = pkgs.bashInteractive;

          openssh.authorizedKeys.keys = [
            ''
              command="${restore-btrbk-backup}/bin/restore-btrbk-backup",restrict ${config.btrbk.sshPublicKey}
            ''
          ];
        };

        btrbk = {
          home = "/var/lib/btrbk";
          isSystemUser = true;
          createHome = true;
        };
      };
      users.groups = {
        btrbk = {};
        btrbk-latest = {};
        btrbk-restore = {};
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/btrbk-latest 0755 btrbk-latest btrbk-latest -"
        "d /var/lib/btrbk-latest/.ssh 0700 btrbk-latest btrbk-latest -"
        "d /var/lib/btrbk 0755 btrbk btrbk -"
        "d /var/lib/btrbk/.ssh 0700 btrbk btrbk -"
      ];

      services.btrbk = {
        extraPackages = [pkgs.lz4];
        sshAccess = [
          {
            key = config.btrbk.sshPublicKey;
            roles = [
              "info"
              "receive"
              "send"
            ];
          }
        ];

        # sudo btrbk -c /etc/btrbk/home-local.conf list snapshots
        instances."home-local" = {
          onCalendar = "hourly";

          settings = {
            snapshot_preserve_min = "24h";
            snapshot_preserve = "7d";

            volume."/nix/persistent" = {
              snapshot_dir = "snapshots/adjivas";

              subvolume = config.btrbk.subvolume;
            };
          };
        };

        # sudo btrbk -c /etc/btrbk/home-remote-dream76.conf list backups
        # journalctl -u btrbk-home-remote-dream76.service
        instances."home-remote-${config.btrbk.remoteHost}" = {
          onCalendar = "daily";
          settings = {
            ssh_identity = config.btrbk.sshPrivateKey;
            ssh_user = "btrbk";
            stream_compress = "lz4";

            snapshot_preserve_min = "24h";
            snapshot_preserve = "7d 4w";

            target_preserve_min = "7d";
            target_preserve = "30d 12w 12m";

            volume."/nix/persistent" = {
              snapshot_dir = "snapshots/adjivas";
              target = "ssh://${config.btrbk.remoteHost}:${toString config.ssh.port}/nix/persistent/backups/${config.networking.hostName}/adjivas";

              subvolume = config.btrbk.subvolume;
            };
          };
        };
      };
    };
  };
}
