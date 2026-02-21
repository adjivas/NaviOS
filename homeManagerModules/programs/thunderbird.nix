{ pkgs, lib, config, ... }: {
  options = {
    thunderbird.enable = lib.mkEnableOption "enable thunderbird";
  };
  config = lib.mkIf config.thunderbird.enable (let
      # PSM Certificate Override Settings file
      # This is a generated file!  Do not edit.
    getProtonmailBridgeCert = pkgs.writeShellScriptBin "getProtonmailBridgeCert.sh" ''
      set -euo pipefail

      cert_dir="${config.xdg.dataHome}/certs"
      ${pkgs.coreutils}/bin/mkdir -p "$cert_dir"

      ${pkgs.netcat}/bin/nc -z -v 127.000.001 1143
      echo | ${pkgs.openssl}/bin/openssl s_client -starttls imap -connect 127.0.0.1:1143 2>/dev/null \
           | ${pkgs.openssl}/bin/openssl x509 > ${config.xdg.dataHome}/certs/protonmail.pem

      out_dir="${config.home.homeDirectory}/.thunderbird/main"
      out_file="$out_dir/cert_override.txt"
      ${pkgs.coreutils}/bin/mkdir -p "$out_dir"

      fingerprint="$(${pkgs.openssl}/bin/openssl x509 -fingerprint -sha256 -noout -in "$cert_dir/protonmail.pem" | ${pkgs.gawk}/bin/awk -F'=' '{print $2}')"

      tmp="$(${pkgs.coreutils}/bin/mktemp)"

      ${pkgs.coreutils}/bin/cat > "$tmp" <<EOF
      127.0.0.1:1143:	OID.2.16.840.1.101.3.4.2.1	''${fingerprint}	
      127.0.0.1:1025:	OID.2.16.840.1.101.3.4.2.1	''${fingerprint}	
      EOF

      ${pkgs.coreutils}/bin/install -m 600 "$tmp" "$out_file"
      ${pkgs.coreutils}/bin/rm -f "$tmp"
    '';
  in {
    # Protonmail-Bridge service
    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Protonmail SMTP/IMAP client";
        After = [ "graphical-session.target" "network.target" ];
        Wants = [ "network.target" ];
        PartOf = [ "sway-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
        ExecStart = "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window";
        Restart = "always";
      };

      Install.WantedBy = [ "sway-session.target" ];
    };

    systemd.user.services.protonmail-bridge-cert = {
      Unit = {
        Description = "Protonmail SMTP/IMAP client certificate";
        Wants = [ "protonmail-bridge.service" ];
        After = [ "protonmail-bridge.service" ];
        PartOf = [ "sway-session.target" ];
        StartLimitIntervalSec = "infinity";
        StartLimitBurst = 3;
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${getProtonmailBridgeCert}/bin/getProtonmailBridgeCert.sh";
        Restart = "on-failure";
        RestartSec = 15;
      };

      Install.WantedBy = [ "sway-session.target" ];
    };

    accounts.email = {
      accounts.adjivas = {
        address = "adjivas@proton.me";
        realName = "adjivas";
        userName = "adjivas@proton.me";

        imap = {
          host = "127.0.0.1";
          port = 1143;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        smtp = {
          host = "127.0.0.1";
          port = 1025;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        passwordCommand = ''${pkgs.libsecret}/bin/secret-tool lookup server "protonmail/bridge-v3/users/bridge-vault-key" username "bridge-vault-key"'';
        primary = true;
        thunderbird.enable = true;
        thunderbird.messageFilters = [
          {
            name = "Tag Github Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "Test6";
            condition = "AND (all addresses,contains,github)";
          }
          {
            name = "Tag Proton Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "Test7";
            condition = "AND (all addresses,contains,proton)";
          }
        ];
      };
    };

    programs.thunderbird = {
      enable = true;

      profiles."main" = {
        isDefault = true;
        withExternalGnupg = true;

        settings = {
          "browser.aboutConfig.showWarning" = false;
          "app.update.auto" = false;
          "app.donation.eoy.version.viewed" = 999;
          "mail.biff.play_sound" = false;
          "mail.biff.show_alert" = false;
          "mail.rights.override" = true;
          "mail.shell.checkDefaultClient" = false;
          "privacy.donottrackheader.enabled" = true;
          "mailnews.message_display.disable_remote_image" = false;
          "mailnews.start_page.enabled" = false;

          "mailnews.tags.$label1.color" = "#FF0000";
          "mailnews.tags.$label1.tag" = "Test1";
          "mailnews.tags.$label2.color" = "#FF9900";
          "mailnews.tags.$label2.tag" = "Test2";
          "mailnews.tags.$label3.color" = "#009900";
          "mailnews.tags.$label3.tag" = "Test3";
          "mailnews.tags.$label4.color" = "#3333FF";
          "mailnews.tags.$label4.tag" = "Test4";
          "mailnews.tags.$label5.color" = "#993399";
          "mailnews.tags.$label5.tag" = "Test5";
          "mailnews.tags.$label6.color" = "#993399";
          "mailnews.tags.$label6.tag" = "Test6";
          "mailnews.tags.$label7.color" = "#993399";
          "mailnews.tags.$label7.tag" = "Test7";
        };
      };
    };
  });
}
