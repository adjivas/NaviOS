{inputs, ...}: {
  den.aspects.gnome-contacts.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    gnome-contacts-vcard-importer = inputs.gnome-contacts-vcard-importer.packages.${system}.default;
  in {
    options.gnome-contacts = {
      database = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.local/share/evolution/addressbook/system/contacts.db";
      };

      book = lib.mkOption {
        type = lib.types.str;
        example = config.age.secrets."contacts.vcf".path;
      };
    };

    config = {
      home.packages = with pkgs; [
        gnome-contacts
        evolution-data-server
      ];

      xdg.configFile."evolution/sources/system-address-book.source".text = ''
        [Data Source]
        DisplayName=Personal
        Enabled=true
        Parent=

        [Address Book]
        BackendName=local
      '';

      systemd.user.services."gnome-contacts-vcard-importer" = {
        Install.WantedBy = [
          "graphical-session.target"
        ];
        Unit = {
          Description = "Imports vCards into the GNOME Contacts database";

          Wants = [
            "agenix.service"
          ];

          After = [
            "agenix.service"
            "gnome-contacts-daemon.service"
          ];

          ConditionPathExists = [
            config.gnome-contacts.book
          ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart = pkgs.writeShellScript "gnome-contacts-vcard-import" ''
            set -euo pipefail

            database=${lib.escapeShellArg config.gnome-contacts.database}
            book=${lib.escapeShellArg config.gnome-contacts.book}
            state=${lib.escapeShellArg "${config.xdg.stateHome}/gnome-contacts-vcard-importer"}

            ${pkgs.coreutils}/bin/mkdir -p "$state"

            hash="$(${pkgs.coreutils}/bin/sha256sum "$book" | ${pkgs.coreutils}/bin/cut -d' ' -f1)"

            if [ -f "$state/imported.sha256" ] \
              && [ "$(${pkgs.coreutils}/bin/cat "$state/imported.sha256")" = "$hash" ]; then
              exit 0
            fi

            ${pkgs.glib}/bin/gdbus call \
              --session \
              --dest org.gnome.evolution.dataserver.AddressBook10 \
              --object-path /org/gnome/evolution/dataserver/AddressBookFactory \
              --method org.gnome.evolution.dataserver.AddressBookFactory.OpenAddressBook \
              system-address-book

            ${lib.getExe gnome-contacts-vcard-importer} \
              "$database" \
              "$book"

            echo "$hash" > "$state/imported.sha256"
          '';
        };
      };
    };
  };
}
