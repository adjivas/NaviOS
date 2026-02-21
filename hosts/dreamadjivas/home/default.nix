{ self, lib, pkgs, inputs, ... }: let
  import_kad = import (self + /hosts/dreamkad/home);
  kad = import_kad { inherit self lib pkgs inputs; };
in {
  home-manager.backupFileExtension = "backup0";

  home-manager.sharedModules = [
    # inputs.impermanence.homeManagerModules.impermanence
    inputs.stylix.homeModules.stylix
    inputs.agenix.homeManagerModules.default
    inputs.lan-mouse.homeManagerModules.default
  ];

  home-manager.extraSpecialArgs = {
    nvf = inputs.nvf.homeManagerModules.default;
    adwaita-cursors-multicolors = inputs.adwaita-cursors-multicolors.packages.${pkgs.stdenv.hostPlatform.system}.default;
    firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    buildFirefoxXpiAddon = inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}.buildFirefoxXpiAddon;
    telegram-desktop = inputs.telegram-desktop-patched.packages.${pkgs.stdenv.hostPlatform.system}.default;
    luanti = inputs.nix-luanti.overlays.default;
    fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};
    gnome-contacts-vcard-importer = inputs.gnome-contacts-vcard-importer.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  home-manager.useUserPackages = true;

  home-manager.users.kad = kad.home-manager.users.kad;

  home-manager.users.adjivas = ({ config, nvf, adwaita-cursors-multicolors, gnome-contacts-vcard-importer, telegram-desktop, ... }: {
    home.username = "adjivas";
    home.homeDirectory = "/home/adjivas";

    home.persistence."/nix/persistent" = {
      directories = [
        ".secrets"
        ".config/passage/store"
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
        #{
        #  directory = ".ssh";
        #  mode = "0700";
        #}
      ];
      files = [
        ".config/passage/identities"
      ];
    };

    # systemctl --user status agenix
    age = {
      identityPaths = [ "${config.home.homeDirectory}/.secrets/ident.txt" ];
      
      secretsDir = "${config.home.homeDirectory}/.agenix/agenix";
      secretsMountPoint = "${config.home.homeDirectory}/.agenix/agenix.d";

      secrets = {
        "contacts.vcf".file = "${config.home.homeDirectory}/.secrets/age/contacts.vcf.age";
        switch_prod = {
          file = "${config.home.homeDirectory}/.secrets/age/prod.keys.age";
          path = "${config.home.homeDirectory}/.switch/prod.keys";
        };
        u2f_keys = {
          file = "${config.home.homeDirectory}/.secrets/age/u2f_keys.age";
          path = "${config.home.homeDirectory}/.config/Yubico/u2f_keys";
        };

        yubikey_5c_adjivas = {
          file = "${config.home.homeDirectory}/.secrets/age/yubikey_5c_adjivas.age";
          path = "${config.home.homeDirectory}/.ssh/yubikey_5c_adjivas";
        };

        yubikey_5a_adjivas = {
          file = "${config.home.homeDirectory}/.secrets/age/yubikey_5a_adjivas.age";
          path = "${config.home.homeDirectory}/.ssh/yubikey_5a_adjivas";
        };

        "fonts/amores.ttf" = {
          file = "${config.home.homeDirectory}/.secrets/age/fonts/Amores.ttf.age";
          path = "${config.home.homeDirectory}/.local/share/fonts/Amores.ttf";
        };
        "fonts/lasericg_chromeregular.ttf" = {
          file = "${config.home.homeDirectory}/.secrets/age/fonts/LaserICG-ChromeRegular.ttf.age";
          path = "${config.home.homeDirectory}/.local/share/fonts/LaserICG-ChromeRegular.ttf";
        };

        "games/zelda_ocarina_of_time_64.us.z64" = {
          file = "${config.home.homeDirectory}/.secrets/age/zelda_ocarina_of_time_64.us.z64.age";
          path = "${config.home.homeDirectory}/.secrets/age/zelda_ocarina_of_time_64.us.z64";
        };
        "games/super_mario_64.us.z64" = {
          file = "${config.home.homeDirectory}/.secrets/age/super_mario_64.us.z64.age";
          path = "${config.home.homeDirectory}/.secrets/age/super_mario_64.us.z64";
        };
      };
    };

    programs.ssh.matchBlocks = {
      "*" = {
        identityFile = [
          "${config.home.homeDirectory}/.ssh/yubikey_5a_adjivas"
          "${config.home.homeDirectory}/.ssh/yubikey_5c_adjivas"
        ];

        # options qui n'ont pas d’option dédiée dans HM
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
    };
      # extraConfig = ''
      #   IdentityFile "${config.home.homeDirectory}/.ssh/yubikey_5a_adjivas"
      #   IdentityFile "${config.home.homeDirectory}/.ssh/yubikey_5c_adjivas"
      #   AddKeysToAgent yes
      # '';

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

    firefox = {
      enable = true;
      # package = pkgs.firefox_nightly;
    };
    sway = {
      enable = true;
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
      chmox = "${pkgs.coreutils}/bin/chmod +x";

      # Nix
      update = "nix flake update";
      # switch = "nixos-rebuild switch --use-remote-sudo --flake  /home/adjivas/Repositories/NaviOS#dreamadjivas";
      profile = "nix build .#nixosConfigurations.dreamadjivas.config.system.build.toplevel --eval-profiler flamegraph --eval-profile-file /tmp/dreamadjivas-eval.profile --eval-profiler-frequency 99";
      topology = "nix build /home/adjivas/Repositories/NaviOS#topology.x86_64-linux.config.output";

      # Git
      set-url = "${pkgs.git}/bin/git remote set-url origin";

      vimdiff = "vim -d";
    };

    home.packages = [
      (pkgs.writeShellScriptBin "switch" ''
        set -euo pipefail

        if ! ${pkgs.nix-output-monitor}/bin/nom build /home/adjivas/Repositories/NaviOS#nixosConfigurations.dreamadjivas.config.system.build.toplevel; then
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

        ${pkgs.nix-fast-build}/bin/nix-fast-build --flake "/nix/persistent/home/adjivas/Repositories/NaviOS#nixosConfigurations.dreamadjivas.config.system.build.toplevel" --eval-workers 2 --eval-max-memory-size 8192 --no-nom |& ${pkgs.nix-output-monitor}/bin/nom
        SYS="$(readlink -f ./result-)"

        echo -e "\a"
        sudo nix-env -p /nix/var/nix/profiles/system --set "$SYS"
        sudo $SYS/bin/switch-to-configuration switch
      '')
      # AGE
      inputs.agenix.packages.x86_64-linux.default
    ] ++ (with pkgs; [
      libsecret
      # Helpers
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
    ]);

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
        "image/png"  = [ "firefox.desktop" ];
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
