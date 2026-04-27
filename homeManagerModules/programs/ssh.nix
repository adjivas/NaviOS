{ lib, config, ... }: {
  options = {
    ssh.enable = lib.mkEnableOption "enable ssh";
  };
  config = lib.mkIf config.ssh.enable {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks."github" = {
        user = "adjivas";
        hostname = "github.com";
      };
      matchBlocks."mario.navi" = {
        user = "root";
        hostname = "mario.navi";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."mario.navi" = {
        user = "root";
        hostname = "mario.navi";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."zelda.navi" = {
        user = "root";
        hostname = "zelda.navi";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."xonotic.navi" = {
        user = "root";
        hostname = "xonotic.navi";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."tux.navi" = {
        user = "root";
        hostname = "tux.navi";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."blue.seat" = {
        user = "root";
        hostname = "blue.seat";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."orange.seat" = {
        user = "root";
        hostname = "orange.seat";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      matchBlocks."purple.seat" = {
        user = "root";
        hostname = "purple.seat";
        port = 39903;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        setEnv = {
          TERM = "xterm-256color";
        };
      };
    };

    home.file.".ssh/known_hosts".text = ''
      gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlA+Z7QPKw2YbC7B+gf3B8Dk3A0wFJqP8jP5x7sKZP
    '';

    home.activation.installSsh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.ssh"
      chmod 0700 "${config.home.homeDirectory}/.ssh"
    '';
  };
}
