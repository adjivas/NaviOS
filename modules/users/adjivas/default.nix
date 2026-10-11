{
  den.aspects."adjivas@dream76".homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.persistence."/nix/persistent" = {
      directories = [
        {
          directory = ".secrets";
          mode = "0700";
        }
        ".local/share/keyrings"
        # Proton
        ".config/protonmail/bridge-v3"
        ".local/share/protonmail/bridge-v3"
        # Mozilla
        ".mozilla/firefox"
        ".config/mozilla/firefox"
        ".thunderbird"
        # Chat
        ".local/share/TelegramDesktop"
        ".local/share/dino"
        ".local/share/gajim"
        ".config/gajim"
        ".config/Signal"
        ".purple"
        # Game
        ".local/share/aspyr-media/Sid Meier's Civilization VI"
        # Newsboat (RSS)
        ".local/share/newsboat"
        # PS2 Emulator
        ".config/PCSX2"
        # Switch Emulator
        ".config/Ryujinx"
        # Luanti
        ".minetest"
        # User
        "Documents"
        "Repositories"
        "PoCs"
        "Etudes"
        "Pictures"
        "Archives"
      ];
    };

    home.shellAliases = {
      vimdiff = "vim -d";
      zathura = "${lib.getExe pkgs.zathura} --fork";
      nautilus = toString (pkgs.writeShellScript "nautilus-detached" ''
        if [ "$#" -eq 0 ]; then
          set -- .
        fi
        exec ${lib.getExe' pkgs.libuuid "setsid"} -f ${lib.getExe pkgs.nautilus} "$@" &>/dev/null
      '');
      to-pdf = "${lib.getExe pkgs.imagemagick} -density 300 -compress Zip";
      age-encrypt = "${lib.getExe pkgs.parallel} --will-cite age --recipients-file ${config.home.homeDirectory}/.agenix/agenix/recipients -o {}.age {} :::";

      # Systemd
      systemctl = "${lib.getExe' pkgs.systemd "systemctl"} --no-pager --full";
      services = "${lib.getExe' pkgs.systemd "systemctl"} --no-pager list-units --type=service";
      user-services = "${lib.getExe' pkgs.systemd "systemctl"} --no-pager --user list-units --type=service";

      # Shell
      stat = "${lib.getExe' pkgs.coreutils "stat"} -c '%a %n (%U:%G)'";
      chmox = "${lib.getExe' pkgs.coreutils "chmod"} +x";
      chmow = "${lib.getExe' pkgs.coreutils "chmod"} +w";
      ip = "${lib.getExe' pkgs.iproute2 "ip"} -color=always";
      watch = "${lib.getExe' pkgs.procps "watch"} --color";

      # Nix
      update = ''
        sudo env GITHUB_TOKEN="$GITHUB_TOKEN" nix --extra-access-tokens "github.com=$GITHUB_TOKEN" flake update
      '';
    };

    home.packages = with pkgs; [
      libsecret
      # Tools
      jq
      unar
      wl-clipboard
      cargo-watch
      nautilus
      binutils
      file
      # Nix
      alejandra
      deadnix
      statix
      vulnix
      # Chat
      cheese
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
        "image/kra" = [""];
        "image/svg+xml" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
        "image/jpeg" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
        "image/jpg" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
        "image/png" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
        "text/plain" = ["nvim.desktop"];
        "image/webp" = ["firefox.desktop"];
        "application/x-krita" = ["org.kde.krita.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
      };
    };
  };
}
