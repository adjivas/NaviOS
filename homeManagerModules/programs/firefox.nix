{ pkgs, firefox-addons, lib, config, ... }: {
  options = let
    policyFormat = pkgs.formats.json { };
  in {
    firefox.enable = lib.mkEnableOption "enable firefox";
    firefox.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox;
    };
    firefox.nativeMessagingHosts = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    firefox.addons = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    firefox.policies = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
    firefox.bookmarks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    firefox.pinned = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    firefox.settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
  config = lib.mkIf config.firefox.enable {
    stylix.targets.firefox.profileNames = [ "user" ];

    programs.firefox = {
      enable = true;
      package = config.firefox.package;

      languagePacks = ["fr" "en-US"];

      nativeMessagingHosts = config.firefox.nativeMessagingHosts;

      policies = lib.recursiveUpdate config.firefox.policies {
        DontCheckDefaultBrowser = true;
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "never";
        SearchBar = "unified";
        NoDefaultBookmarks = true;
        PasswordManagerEnabled = false;
        UseSystemPrintDialog = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
        PictureInPicture = {
          Enabled = true;
          Locked = true;
        };

        ExtensionSettings = {
          "@testpilot-containers" = {
            installation_mode = "blocked";
            blocked_install_message = "Not needed";
          };
        };
        Bookmarks = config.firefox.bookmarks ++ [
          { Folder = "Dreamland"; Title = "Luanti (Navy Industry)"; URL = "https://luanti.navi"; }
        ];
      };

      profiles.user = {
        isDefault = true;
        id = 0;

        extensions.packages = config.firefox.addons;
        search = {
          force = true;
          default = "google";
          engines = {
            "NixOS Wiki" = {
              urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@wnix" "@winix" "@wikinix" ];
            };
            "Nix Packages" = {
              urls = [{ template = "https://search.nixos.org/packages?type=packages&query={searchTerms}"; }];
              definedAliases = [ "@nix" ];
            };
            "Nix Options" = {
              urls = [{ template = "https://search.nixos.org/options?query={searchTerms}"; }];
              definedAliases = [ "@opt" "@option" ];
            };
            "Home Manager NixOs" = {
              urls = [{ template = "https://home-manager-options.extranix.com?query={searchTerms}"; }];
              definedAliases = ["@hm" "@home" ];
            };
            "Nix Github" = {
              urls = [{ template = "https://github.com/search?type=code&q=Language%3ANix+{searchTerms}"; }];
              definedAliases = ["@nixgit" "@git"];
            };
            "Crates" = {
              urls = [{ template = "https://crates.io/search?q={searchTerms}"; }];
              definedAliases = [ "@crates" "@crate" "@cargo" ];
            };
            "CTAN" = {
              urls = [{ template = "https://ctan.org/search?phrase={searchTerms}"; }];
              definedAliases = [ "@ctan" ];
            };
            "Firefox Extension" = {
              urls = [{ template = "https://addons.mozilla.org/fr/firefox/search/?q={searchTerms}&sort=users&type=extension"; }];
              definedAliases = [ "@moz" "@firefox" "@addons" "@addon" "@extension" ];
            };
            "Free Software Fundation Dictionary" = {
              urls = [{ template = "https://directory.fsf.org/wiki?search={searchTerms}&profile=default&fulltext=1"; }];
              definedAliases = [ "@fsf" ];
            };
            "French Wiktionary Dictionary" = {
              urls = [{ template = "https://fr.wiktionary.org/wiki/{searchTerms}"; }];
              definedAliases = [ "@wiktionary" "@wik" ];
            };
            "DeepL" = {
              urls = [{ template = "https://www.deepl.com/en/translator#en/fr/{searchTerms}"; }];
              definedAliases = [ "@deepl" ];
            };
            "Luanti" = {
              urls = [{ template = "https://content.luanti.org/packages/?q={searchTerms}"; }];
              definedAliases = [ "@luanti" ];
            };
            "youtube" = {
              urls = [{ template = "https://www.youtube.com/results?search_query={searchTerms}"; }];
              definedAliases = ["@youtube" "@you" "@yt" ];
            };
            "wikipedia".metaData.alias = "@wiki";
            "amazondotcom-fr".metaData.hidden = true;
            "bing".metaData.hidden = true;
            "ebay".metaData.hidden = true;
            "qwant".metaData.hidden = true;
            "google".metaData.alias = "@g";
          };
        };
        # about:config
        settings = lib.recursiveUpdate config.firefox.settings {
          # Enable all plugins
          "extensions.autoDisableScopes" = 0;

          # Configure the new tab page
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.pinned" = config.firefox.pinned;

          # Common
          "browser.translations.automaticallyPopup" = false;
          "browser.quitShortcut.disabled" = true;
          "browser.tabs.firefox-view" = false;
          "social.toast-notifications.enabled" = false;
          "browser.download.open_pdf_attachments_inline" = true;

          # Url bar
          "browser.urlbar.suggest.calculator" = true;
          "browser.urlbar.unitConversion.enabled" = true;
          "browser.urlbar.trending.featureGate" = false;

          # Disable sponsored content on new tab page
          "browser.newtabpage.activity-stream.feeds.topsites" = true;
          "browser.newtabpage.activity-stream.system.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;

          # First run
          "trailhead.firstrun.didSeeAboutWelcome" = true; # Disable welcome splash
          "browser.aboutwelcome.enabled" = false;
          "browser.reader.detectedFirstArticle" = false;

          # Privacy settings
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.partition.network_state.ocsp_cache" = true;

          # Geolocation settings
          "geo.enabled" = false;
          "geo.provider.use_corelocation" = false;
          "geo.provider.use_gpsd" = false;
          "geo.provider.use_geoclue" = false;

          # Firefox Data Collection
          "app.shield.optoutstudies.enabled" = false; # Allow Firefox to install and run studies.
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # Allow Firefox to send backlogged crash reports on your behalf.
          "datareporting.healthreport.uploadEnabled" = false; # Allow Firefox to send technical and interaction data to Mozilla.
          # Disable the 'Firefox automatically sends some data to Mozilla...'
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.service.firstRun" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.policy.dataSubmissionPolicyAccepted" = false;
          "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;

          # Cookie banner handling
          "cookiebanners.ui.desktop.enabled" = true;
          "cookiebanners.service.mode" = 1;
          "cookiebanners.service.mode.privateBrowsing" = 1;
          "cookiebanners.service.enableGlobalRules" = true;

          # As well as Firefox 'experiments'
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "network.allow-experiments" = false;

          # Disable Firefox Services
          "signon.rememberSignons" = false; # Password Manager
          "identity.fxaccounts.enabled" = false; # Account
          "extensions.pocket.enabled" = false; # Pocket
          "extensions.formautofill.creditCards.enabled" = false;

          # Warning when opening about:config
          "browser.aboutConfig.showWarning" = false;

          # Restore preview session on start
          "browser.startup.page" = 3;
          "browser.sessionstore.resume_from_crash" = true;

          # Disable Alt key, helpful for Mod1 of sway
          "ui.key.menuAccessKeyFocuses" = true;

          # Active userChrome.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;

          # Wallpapers New Page
          "browser.newtabpage.activity-stream.newtabWallpapers.customColor.enabled" = true;
          "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "solid-color-picker-#1c1b22";

          # Disabling "thought-provoking stories" on Firefox new tab
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

          # Prefer Dark Website appearance
          "ui.systemUsesDarkTheme" = 1;
          "reader.color_scheme" = "dark";
          "devtools.theme" = "dark";
          # "browser.display.use_system_colors" = false;
          "layout.css.prefers-color-scheme.content-override" = 0;

          # Disable Side Bar
          "sidebar.revamp" = false;
          "sidebar.revamp.defaultLauncherVisible" = false;

          # Yubikey
          "security.webauth.u2f" = true;
          "security.webauth.webauthn" = true;
          "security.webauth.webauthn_enable_softtoken" = true;
          "security.webauth.webauthn_enable_usbtoken" = true;
        };

        userChrome = ''
          #sidebar-button {
            display: none !important;
          }
          #toolbar-menubar {
            display: none !important;
          }
          #bookmarks-toolbar {
            display: none !important;
          }
          #firefox-view-button {
            display: none !important;
          }
          #alltabs-button {
            display: none !important;
          }
        '';
      };
    };
  };
}
