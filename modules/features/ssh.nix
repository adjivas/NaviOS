{
  den.aspects.ssh-server = {
    key,
    pubs ? [],
    port ? 60022,
    interfaces ? [],
  }: {
    nixos = {
      config,
      lib,
      user,
      ...
    }: {
      users.users.${user.userName}.openssh.authorizedKeys.keys = pubs;
      services.openssh = {
        enable = true;
        openFirewall = false; # Firewall managed separately
        ports = [port];

        settings = {
          AllowUsers = [user.userName];
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };

        hostKeys = [
          {
            path = key config;
            type = "ed25519";
          }
        ];
      };

      networking.firewall.interfaces = lib.genAttrs interfaces (_: {
        allowedTCPPorts = [port];
      });
    };
  };

  den.aspects.ssh-client = {
    identityFiles ? [],
    hosts ? {},
    term ? "xterm",
    port ? 60022,
  }: {
    homeManager = {
      config,
      lib,
      ...
    }: {
      home.activation.installSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${config.home.homeDirectory}/.ssh"
        chmod 0700 "${config.home.homeDirectory}/.ssh"
      '';

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings =
          {
            "*" = {
              AddKeysToAgent = "yes";
            };
          }
          // lib.mapAttrs (_: host: {
            HostName = host.address;
            Port = host.port or port;
            SetEnv.TERM = host.term or term;

            IdentityFile =
              map (identity: "~/.ssh/${identity}")
              (host.identityFiles or identityFiles);

            IdentitiesOnly = true;
          })
          hosts;
      };

      services.ssh-agent.enable = true;
    };
  };
}
