{
  den.aspects.thunderbird.homeManager = {
    config,
    pkgs,
    lib,
    wrappers,
    ...
  }: {
    options.thunderbird = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "adjivas";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "contact@adjivas.eu";
      };
    };

    config = let
      thunderbird = wrappers {
        inherit pkgs;

        package = pkgs.thunderbird;

        env = {
          GTK_USE_PORTAL = "1";
          DICPATH = "${pkgs.hunspellDicts.fr-any}/share/hunspell";
        };
      };
    in {
      home.packages = with pkgs; [
        hunspell
        libnotify
      ];

      accounts.email.accounts.${config.thunderbird.user} = {
        address = config.thunderbird.address;
        realName = config.thunderbird.user;
        userName = config.thunderbird.address;

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

        primary = true;

        thunderbird = {
          enable = true;

          messageFilters = [
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
        package = thunderbird;

        profiles.main = {
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
    };
  };
}
