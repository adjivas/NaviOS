{ self, hostname, lib, pkgs, inputs, ... }: {
  home-manager.users.adjivas = ({ config, nvf, adwaita-cursors-multicolors, gnome-contacts-vcard-importer, telegram-desktop, ... }: {
    home.username = "adjivas";
    home.homeDirectory = "/home/adjivas";

    home.persistence."/nix/persistent" = {
      directories = [
        { directory = ".secrets"; mode = "0700"; }
        ".local/share/keyrings"
        # Proton
        ".config/protonmail/bridge-v3"
        ".local/share/protonmail/bridge-v3"
        # Mozilla
        ".mozilla/firefox"
        ".thunderbird"
        # Chat
        ".local/share/TelegramDesktop"
        ".local/share/dino"
        ".config/Signal"
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

    systemd.user.services."gnome-contacts-vcard-importer" = let
      contacts_db = ''${config.home.homeDirectory}/.local/share/evolution/addressbook/system/contacts.db'';
      contacts_path = ''${config.age.secrets."contacts.vcf".path}'';
    in {
      Unit = {
        Description = "Imports vCards into the Gnome-Contacts contact database";
        After = [
          "gnome-contacts-daemon.service"
        ];
         ConditionPathExists = [ "!${contacts_db}" "${contacts_path}" ];
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
      Install.WantedBy = [ "sway-session.target" ];
    };

    # Programs
    imports = [
      nvf
      (self + /homeManagerModules)
      ./firefox.nix
      ./sway.nix
      ./agenix.nix
      ./ssh.nix
    ];
    nvf.enable = true;
    swaylock.enable = true;
    rofi.enable = true;
    gnome-control-center = {
      enable = true;
      user = "adjivas";
    };
    gnome-keyring.enable = true; # Probably required by protonmail-bridge
    telegram.enable = true;
    thunderbird.enable = true;
    libreoffice.enable = true;
    # luanti.enable = true;
    inkscape.enable = true;
    rust.enable = true;
    wl-kbptr.enable = true;
    virt-manager.enable = true;
    kanshi.enable = true;
    ripgrep.enable = true;
    kitty.enable = true;
    git.enable = true;
    fzf.enable = true;
    zathura.enable = true;
    ssh.enable = true;
    bash.enable = true;
    starship.enable = true;
    supertuxkart.enable = true;
    htop.enable = true;
    # dissent.enable = true;
    password-store.enable = true;
    mako.enable = true;
    wlsunset.enable = true;
    pcsx2.enable = true;
    lan-mouse.enable = true;
    gpg.enable = true;

    firefox = {
      enable = true;
      # package = pkgs.firefox_nightly;
    };
    sway = {
      enable = true;
      window = [
        {
          criteria = { app_id = "im.dino.Dino"; };
          command = "move to workspace 9";
        }
        {
          criteria = { app_id = "ch.proton.bridge-gui"; };
          command = "move to workspace 8";
        }
        {
          criteria = { app_id = "thunderbird"; };
          command = "move to workspace 8";
        }
        {
          criteria = { app_id = "org.telegram.desktop"; };
          command = "move to workspace 9";
        }
      ];
    };
    waybar = {
      enable = true;
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
    mangohud = {
      enable = true;
      package = pkgs.mangohud;
    };

    newsboat = {
      enable = true;
      # browser = "${pkgs.firefox_nightly}/bin/firefox-nightly";
      urls = [
        { url = "https://linuxfr.org/news.atom"; }
      ];
    };

    xonotic = {
      enable = true;
      net_address = "xonotic.navi";
      port = 26000;
    };

    home.file.".local/share/soh-anchor/oot-debug.z64".source = let
      hash = "sha256-yRarMV++gqIhab/xPWuGbp/dyQdGHrawoie4Ks31tQY=";
      source = config.age.secrets."games/zelda_ocarina_of_time_64.us.z64".path;
    in pkgs.stdenvNoCC.mkDerivation {
      name = "oot-debug.z64";
      phases = [ "installPhase" ];
      installPhase = ''cat ${source} > "$out"'';

      outputHashMode = "flat";
      outputHashAlgo = "sha256";

      outputHash = hash;
    };

    home.file."baserom.us.z64".source = let
      hash = "sha256-F84Hc0PGEz+Mny1tbZpKtiyM0qpXxArqH0kLTIuyHZE=";
      source = config.age.secrets."games/super_mario_64.us.z64".path;
    in pkgs.stdenvNoCC.mkDerivation {
      name = "baserom.us.z64";
      phases = [ "installPhase" ];
      installPhase = ''cat ${source} > "$out"'';

      outputHashMode = "flat";
      outputHashAlgo = "sha256";

      outputHash = hash;
    };
    sm64ex = {
      enable = true;
      baserom = config.home.file."baserom.us.z64".path;
    };

    stylix-theme.cursorPackage = adwaita-cursors-multicolors;
    stylix-theme.scheme = {
      base05 = "#ccddeb"; # background layer1
      base00 = "#1c1b22"; # foreground layer1
      base0C = "#7fabcc"; # background layer2
      base01 = "#384c5a"; # foreground layer2
    };

    home.shellAliases = {
      zathura = "${pkgs.zathura}/bin/zathura --fork";
      tldr = "${pkgs.tealdeer}/bin/tealdeer";
      stat =  "${pkgs.coreutils}/bin/stat -c '%a %n (%U:%G)'";
      chmox = "${pkgs.coreutils}/bin/chmod +x";
      chmow = "${pkgs.coreutils}/bin/chmod +w";

      # Nix
      update = "nix flake update";
      profile = "nix build .#nixosConfigurations.${hostname}.config.system.build.toplevel --eval-profiler flamegraph --eval-profile-file /tmp/${hostname}-eval.profile --eval-profiler-frequency 99";
      topology = "nix build /home/adjivas/Repositories/NaviOS#topology.x86_64-linux.config.output";

      # Git
      set-url = "${pkgs.git}/bin/git remote set-url origin";

      vimdiff = "vim -d";
    };

    home.packages = [
      (pkgs.writeShellScriptBin "switch" ''
        set -euo pipefail

        if ! ${pkgs.nix-output-monitor}/bin/nom build /home/adjivas/Repositories/NaviOS#nixosConfigurations.${hostname}.config.system.build.toplevel; then
          echo -e "\a" >&2
          exit 1
        fi

        echo -e "\a"

        sudo ./result/bin/switch-to-configuration switch
      '')
      (pkgs.writeShellScriptBin "switch-fast-build" ''
        set -euo pipefail

        TMPDIR=/nix/persistent/tmp
        mkdir -p $TMPDIR

        ${pkgs.nix-fast-build}/bin/nix-fast-build --flake "/nix/persistent/home/adjivas/Repositories/NaviOS#nixosConfigurations.${hostname}.config.system.build.toplevel" --eval-workers 2 --eval-max-memory-size 8192 --no-nom |& ${pkgs.nix-output-monitor}/bin/nom
        SYS="$(readlink -f ./result-)"

        echo -e "\a"
        sudo nix-env -p /nix/var/nix/profiles/system --set "$SYS"
        sudo $SYS/bin/switch-to-configuration switch
      '')
      # AGE
      inputs.agenix.packages.x86_64-linux.default
    ] ++ (with pkgs; [
      libsecret
      # Tools
      jq
      unar
      wl-clipboard
      cargo-watch
      # Games
      ryubing
      nsz
      luanti-client
      # CAO
      krita
      blender
      freecad
      graphviz
      kicad
      # Chat
      dino
      cheese
    ]);

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
        "image/jpeg" = [ "firefox.desktop" ];
        "image/png" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "shipwright-anchor"
      "sm64coopdx"
    ];

    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "25.05";

    # Let home Manager install and manage itself.
    programs.home-manager.enable = true;
  });
}
