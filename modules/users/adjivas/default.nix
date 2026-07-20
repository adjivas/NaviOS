{
  den.aspects.adjivas.homeManager = {
    gnome-contacts-vcard-importer,
    munix,
    tincr,
    nix-log-check,
    config,
    lib,
    pkgs,
    ...
  }: let
    homeDir = "/home/adjivas";
  in {
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

    # Programs
    programs.ssh.settings = {
      "*" = {
        identityFile = [
          "${homeDir}/.ssh/yubikey-5a-adjivas"
          "${homeDir}/.ssh/yubikey-5c-adjivas"
        ];
        AddKeysToAgent = "yes";
      };
    };

    gnome-control-center = {
      user = "adjivas";
    };

    sway = {
      window = [
        {
          criteria = {app_id = "ch.proton.bridge-gui";};
          command = "move to workspace 8";
        }
        {
          criteria = {app_id = "thunderbird";};
          command = "move to workspace 8";
        }
        {
          criteria = {app_id = "org.gajim.Gajim";};
          command = "move to workspace 9";
        }
        {
          criteria = {app_id = "im.dino.Dino";};
          command = "move to workspace 9";
        }
        {
          criteria = {app_id = "signal";};
          command = "move to workspace 9";
        }
        {
          criteria = {app_id = "org.telegram.desktop";};
          command = "move to workspace 9";
        }
      ];
    };
    waybar = {
      modules-right = lib.mkBefore [
        "battery#hid"
      ];
      bar."battery#hid" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "Trackpad({capacity}%)";
        bat = "hid-CC2929200Z7J5R9AM-battery";
        interval = 10;
        tooltip-format = "{time} remaining";
      };
    };

    xonotic = {
      net_address = "xonotic.navi";
      port = 26000;
    };

    agent = {
      openaiTokenPath = config.age.secrets.openai.path;
    };

    firefox.policies = {
      Certificates.Install = [config.age.secrets.dreamland_cert_root.path];
    };

    # home.file.".local/share/soh-anchor/oot-debug.z64".source = let
    #   hash = "sha256-yRarMV++gqIhab/xPWuGbp/dyQdGHrawoie4Ks31tQY=";
    #   source = config.age.secrets."games/zelda_ocarina_of_time_64.us.z64".path;
    # in pkgs.stdenvNoCC.mkDerivation {
    #   name = "oot-debug.z64";
    #   phases = [ "installPhase" ];
    #   installPhase = ''cat ${source} > "$out"'';
    #
    #   outputHashMode = "flat";
    #   outputHashAlgo = "sha256";
    #
    #   outputHash = hash;
    # };
    #
    # home.file."baserom.us.z64".source = let
    #   hash = "sha256-F84Hc0PGEz+Mny1tbZpKtiyM0qpXxArqH0kLTIuyHZE=";
    #   source = config.age.secrets."games/super_mario_64.us.z64".path;
    # in pkgs.stdenvNoCC.mkDerivation {
    #   name = "baserom.us.z64";
    #   phases = [ "installPhase" ];
    #   installPhase = ''cat ${source} > "$out"'';
    #
    #   outputHashMode = "flat";
    #   outputHashAlgo = "sha256";
    #
    #   outputHash = hash;
    # };

    # stylix-theme.scheme = {
    #   base05 = "#ccddeb"; # background layer1
    #   base00 = "#1c1b22"; # foreground layer1
    #   base0C = "#7fabcc"; # background layer2
    #   base01 = "#384c5a"; # foreground layer2
    # };
    stylix.targets.firefox.profileNames = [config.firefox.profileName];

    systemd.user.services."gnome-contacts-vcard-importer" = let
      contacts_db = ''${config.home.homeDirectory}/.local/share/evolution/addressbook/system/contacts.db'';
      contacts_path = ''${config.age.secrets."contacts.vcf".path}'';
    in {
      Unit = {
        Description = "Imports vCards into the Gnome-Contacts contact database";
        After = [
          "gnome-contacts-daemon.service"
        ];
        ConditionPathExists = ["!${contacts_db}" "${contacts_path}"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "vcard-importer.sh" ''
          set -euo pipefail

          for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
            if [ -f ${contacts_db} ] && [ -f ${contacts_path} ]; then
              break
            fi
            ${pkgs.coreutils}/bin/sleep 1
          done
          if [ -f ${contacts_db} ] && [ -f ${contacts_path} ]; then
            ${gnome-contacts-vcard-importer}/bin/gnomecontactsvcardimporter ${contacts_db} ${contacts_path} >/dev/null
          fi
        '';
      };
      Install.WantedBy = ["sway-session.target"];
    };

    home.shellAliases = {
      zathura = "${pkgs.zathura}/bin/zathura --fork";
      stat = "${pkgs.coreutils}/bin/stat -c '%a %n (%U:%G)'";
      chmox = "${pkgs.coreutils}/bin/chmod +x";
      chmow = "${pkgs.coreutils}/bin/chmod +w";
      age-crypt = "${pkgs.parallel}/bin/parallel --will-cite age --recipients-file ${homeDir}/.agenix/agenix/recipients -o {}.age {} :::";

      # Nix
      update = ''
        sudo env GITHUB_TOKEN="$GITHUB_TOKEN" nix --extra-access-tokens "github.com=$GITHUB_TOKEN" flake update
      '';
      topology = "nix build ${homeDir}/Repositories/NaviOS#topology.x86_64-linux.config.output";

      # Git
      set-url = "${pkgs.git}/bin/git remote set-url origin";

      vimdiff = "vim -d";
    };

    home.packages =
      [
        nix-log-check
        munix
        tincr
      ]
      ++ (with pkgs; [
        libsecret
        # Tools
        jq
        unar
        wl-clipboard
        cargo-watch
        # Nix
        alejandra
        deadnix
        statix
        # Games
        ryubing
        nsz
        # CAO
        krita
        blender
        freecad
        graphviz
        kicad
        # Chat
        gajim
        signal-desktop
      ]);

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
