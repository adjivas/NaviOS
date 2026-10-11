{den, ...}: {
  den.aspects.ssh = {
    # Server config
    nixos = {
      config,
      lib,
      ...
    }: {
      options.ssh = {
        port = lib.mkOption {
          type = lib.types.port;
          default = 60022;
          description = "SSH port";
        };

        sshPrivateKey = lib.mkOption {
          type = lib.types.path;
          description = "Path to the private SSH host key.";
        };
      };

      config = {
        networking.firewall.allowedTCPPorts = [
          config.ssh.port
        ];

        services.openssh = {
          enable = true;
          ports = [
            config.ssh.port
          ];

          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };

          hostKeys = [
            {
              path = config.ssh.sshPrivateKey;
              type = "ed25519";
            }
          ];
        };
      };
    };

    # Client default config
    homeManager = {
      lib,
      config,
      ...
    }: {
      services.ssh-agent.enable = true;

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };

      home.file.".ssh/known_hosts".text = ''
        gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlA+Z7QPKw2YbC7B+gf3B8Dk3A0wFJqP8jP5x7sKZP
        github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
        git.sr.ht.local ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJD+TJl8ZYl1hekPAQd0fhBmkvjHQZoXTPOiyMI6h77o
      '';

      home.activation.installSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${config.home.homeDirectory}/.ssh"
        chmod 0700 "${config.home.homeDirectory}/.ssh"
      '';
    };
  };

  den.aspects.ssh-user = {
    publicKeys ? [],
    identityFiles ? [],
  }: {
    includes = [
      den.aspects.ssh
    ];

    nixos = {
      lib,
      user,
      ...
    }: {
      services.openssh.settings.AllowUsers = lib.mkAfter [user.userName];

      users.users.${user.userName}.openssh.authorizedKeys.keys = publicKeys;
    };

    homeManager = {
      config,
      lib,
      ...
    }:
      lib.mkIf (identityFiles != []) {
        programs.ssh.settings."*" = {
          identityFile =
            map
            (identityFile: "${config.home.homeDirectory}/.ssh/${identityFile}")
            identityFiles;

          AddKeysToAgent = "yes";
        };
      };
  };
}
