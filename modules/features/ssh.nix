{
  den.aspects.ssh = {
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
          description = "Path to the private SSH key.";
        };
      };

      config = {
        networking.firewall.allowedTCPPorts = [config.ssh.port];

        services.openssh = {
          enable = true;
          ports = [config.ssh.port];

          settings = {
            AllowUsers = ["adjivas" "btrbk" "btrbk-latest" "btrbk-restore"];
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

    homeManager = {
      osConfig,
      lib,
      config,
      ...
    }: {
      services.ssh-agent.enable = true;

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings.dream00 = {
          hostname = "dream00";
          user = "adjivas";
          port = osConfig.ssh.port;
          addressFamily = "inet";
        };

        settings.dream76 = {
          hostname = "dream76";
          user = "adjivas";
          port = osConfig.ssh.port;
          addressFamily = "inet";
        };

        settings."blue.seat" = {
          user = "root";
          hostname = "blue.seat";
          port = 39903;
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          setEnv = ["TERM=xterm-256color"];
        };

        settings."orange.seat" = {
          user = "root";
          hostname = "orange.seat";
          port = 39903;
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          setEnv = ["TERM=xterm-256color"];
        };

        settings."purple.seat" = {
          user = "root";
          hostname = "purple.seat";
          port = 39903;
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          setEnv = ["TERM=xterm-256color"];
        };
      };

      home.file.".ssh/known_hosts".text = ''
        [dream00]:60022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9ppVfpZznDAjOi0hTrChskdVslnNYJL4e+Msv+1F/b
        [dream76]:60022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9ppVfpZznDAjOi0hTrChskdVslnNYJL4e+Msv+1F/b

        gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlA+Z7QPKw2YbC7B+gf3B8Dk3A0wFJqP8jP5x7sKZP
        github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      '';

      home.activation.installSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${config.home.homeDirectory}/.ssh"
        chmod 0700 "${config.home.homeDirectory}/.ssh"
      '';
    };
  };
}
