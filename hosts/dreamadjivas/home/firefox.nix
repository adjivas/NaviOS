{ config, pkgs, lib, firefox, buildFirefoxXpiAddon, firefox-addons, ... }: {
  # firefox.package = pkgs.firefox_nightly;
  firefox.settings = {
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "extensions.activeThemeID" = "2022blue-colorway@mozilla.org";
    "browser.toolbars.bookmarks.visibility" = "never";
  };
  # firefox.addons = (with firefox-addons; [
  #   (buildFirefoxXpiAddon rec {
  #     pname = "chillaxing";
  #     version = "2.1";
  #     addonId = "2022blue-colorway@mozilla.org";
  #     url = "https://addons.mozilla.org/firefox/downloads/latest/chillaxing/latest.xpi";
  #     sha256 = "f53cb985b060928d99f7cbe3b0e494cce62ba8a337fd760deea4b6ee059e51c1";
  #     meta = { };
  #   })
  # ]);
  firefox.policies = {
    ExtensionSettings = {
      "2022blue-colorway@mozilla.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/chillaxing/latest.xpi";
        default_area = "navbar";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
      "addon@darkreader.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        default_area = "navbar";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
      "passff@invicem.pro" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/passff/latest.xpi";
        default_area = "navbar";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi";
        default_area = "navbar";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
      "idcac-pub@guus.ninja" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
        default_area = "navbar";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
      # View Xpi Id's in Firefox Extension Store
      "queryamoid@kaply.com" = {
        private_browsing = true;
        installation_mode = "force_installed";
        install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
      };
      "sponsorBlocker@ajay.app" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        default_area = "menupanel";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
      # Remove YouTube Recommends
      "kunal@abhashtech.com" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4275238/remove_youtube_recomendation-0.3resigned1.xpi";
        installation_mode = "force_installed";
      };
      # No YouTube comments
      "jid1-YMBCq41qvDdqcA@jetpack" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4270539/no_youtube_comments-0.4resigned1.xpi";
        installation_mode = "force_installed";
      };
      # RYS — Remove YouTube Suggestions
      "{21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4299785/remove_youtube_s_suggestions-4.3.60.xpi";
        installation_mode = "force_installed";
      };
    };
    "3rdparty".Extensions = {
      "addon@darkreader.org" = {
        enabled = true;
        automation = {
          enabled = true;
          behavior = "OnOff";
          mode = "system";
        };
        detectDarkTheme = true;
        enabledByDefault = true;
        changeBrowserTheme = false;
        enableForProtectedPages = true;
        fetchNews = true;
        syncSitesFixes = true;
        previewNewDesign = true;
      };
      "uBlock0@raymondhill.net" = {
        advancedSettings = [
          [
            "userResourcesLocation"
            "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/master/video-swap-new/video-swap-new-ublock-origin.js"
          ]
        ];
        adminSettings = {
          userFilters = lib.concatStringsSep "\n" [
            "www.youtube.com##ytd-yoodle-renderer.ytd-topbar-logo-renderer.style-scope"
            "www.youtube.com##.ytd-topbar-logo-renderer.style-scope > .ytd-logo.style-scope"
            "www.google.com###hplogo"
            "www.google.fr###hplogo"
            "||lawrencehook.com/rys/welcome$domain=lawrencehook.com"
            "||darkreader.org/help/en/"
            "||0c916d20-5033-464b-95e4-93fbe2d21720/help/index.html"
          ];
          userSettings = rec {
            uiTheme = "dark";
            uiAccentCustom = true;
            uiAccentCustom0 = config.stylix.base16Scheme.base05;
            cloudStorageEnabled = lib.mkForce false;
            advancedUserEnabled = true;
            userFiltersTrusted = true;
            importedLists = [
              "https://filters.adtidy.org/extension/ublock/filters/3.txt"
              "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"

              "https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt"
              "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
              "https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters/blob/raw?file=bpc-paywall-filter.txt"
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/BrowseWebsitesWithoutLoggingIn.txt"
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/ClearURLs for uBo/clear_urls_uboified.txt"
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Dandelion Sprout's Anti-Malware List.txt"
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt"
              "https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock.txt?_=rawlist"
              "https://raw.githubusercontent.com/iam-py-test/my_filters_001/main/antimalware.txt"
              "https://raw.githubusercontent.com/liamengland1/miscfilters/master/antipaywall.txt"
              "https://raw.githubusercontent.com/yokoffing/filterlists/main/annoyance_list.txt"
              "https://raw.githubusercontent.com/yokoffing/filterlists/main/privacy_essentials.txt"
            ];
            externalLists = lib.concatStringsSep "\n" importedLists;
            popupPanelSections = 31;
          };
          selectedFilterLists = [
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "adguard-generic"
            "adguard-mobile"
            "easyprivacy"
            "adguard-spyware"
            "adguard-spyware-url"
            "block-lan"
            "urlhaus-1"
            "curben-phishing"
            "plowe-0"
            "dpollock-0"
            "fanboy-cookiemonster"
            "ublock-cookies-easylist"
            "adguard-cookies"
            "ublock-cookies-adguard"
            "fanboy-social"
            "adguard-social"
            "fanboy-thirdparty_social"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "easylist-annoyances"
            "adguard-mobile-app-banners"
            "adguard-other-annoyances"
            "adguard-popup-overlays"
            "adguard-widgets"
            "ublock-annoyances"
            "DEU-0"
            "FRA-0"
            "NLD-0"
            "RUS-0"
            "https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt"
            "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Dandelion Sprout's Anti-Malware List.txt"
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt"
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/BrowseWebsitesWithoutLoggingIn.txt"
            "https://raw.githubusercontent.com/yokoffing/filterlists/main/privacy_essentials.txt"
            "https://raw.githubusercontent.com/yokoffing/filterlists/main/annoyance_list.txt"
            "https://raw.githubusercontent.com/liamengland1/miscfilters/master/antipaywall.txt"
            "https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters/blob/raw?file=bpc-paywall-filter.txt"
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/ClearURLs for uBo/clear_urls_uboified.txt"
            "https://raw.githubusercontent.com/iam-py-test/my_filters_001/main/antimalware.txt"
            # "https://raw.githubusercontent.com/OsborneLabs/Columbia/master/Columbia.txt"
            "https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock.txt?_=rawlist"
            # Enable self rules from "userFilters".
            "user-filters"
          ];
        };
      };
    };
  };
  firefox.pinned = [
    {
      title = "CarteFrama";
      url = "https://framacarte.org/en/map/paris-map_172265";
      customScreenshotURL = "https://framacarte.org/abc/img/icons/favicon.png";
    }
    {
      title = "GendaFrama";
      url = "https://framagenda.org/login";
      customScreenshotURL = "https://framagenda.org/apps/theming/favicon";
    }
    {
      title = "GitHub";
      url = "https://github.com/adjivas";
      customScreenshotURL = "https://framagit.org/uploads/-/system/appearance/favicon/1/git.png";
    }
    {
      title = "GitHub";
      url = "https://github.com/login";
      customScreenshotURL = "https://github.com/fluidicon.png";
    }
    {
      title = "GitLab";
      url = "https://gitlab.com/users/sign_in";
      customScreenshotURL = "https://about.gitlab.com/nuxt-images/ico/favicon-192x192.png";
    }
    {
      title = "CarrefourNumerique.CitéSciences";
      url = "https://carrefour-numerique.cite-sciences.fr";
    }
    {
      title = "Edison Scientific";
      url = "https://platform.edisonscientific.com";
      customScreenshotURL = "https://platform.edisonscientific.com/dark-favicon.png";
    }
    {
      title = "Navi Blog";
      url = "https://blog.adjivas.eu/navi";
      customScreenshotURL = "https://blog.adjivas.eu/navi/images/favicon.svg";
    }
    # {
    #   title = "Gandi";
    #   url = "https://id.gandi.net/fr/login";
    #   customScreenshotURL = "https://www.gandi.net/apple-touch-icon.png";
    # }
    {
      title = "BookMyName by Scaleway";
      url = "https://www.bookmyname.com";
      customScreenshotURL = "https://www.bookmyname.com/favicon.ico";
    }
    {
      title = "LinuxFr";
      url = "https://linuxfr.org";
      customScreenshotURL = "https://linuxfr.org/favicon.png";
    }
  ];
  firefox.bookmarks = [
    { Folder = "Rust"; Title = "A Practical Intro to Macros in Rust 1.0 "; URL = "http://danielkeep.github.io/practical-intro-to-macros.html"; }
    { Folder = "Rust"; Title = "Rust Iterator Cheat Sheet"; URL = "http://danielkeep.github.io/itercheat_baked.html"; }
    { Folder = "Nix"; Title = "Sécuriser son accès SSH 🖥️ avec une clef FIDO2 🔐"; URL = "https://blog.maxds.fr/ssh-with-yubikey"; }
    { Folder = "Nix"; Title = "Generating a docker image with nix"; URL = "https://fasterthanli.me/series/building-a-rust-service-with-nix/part-11"; }
    { Folder = "Nix"; Title = "Local peer to peer binary cache with NixOS and Peerix"; URL = "https://dataswamp.org/~solene/2022-08-25-nixos-with-peerix.html"; }
    { Folder = "Nix"; Title = "Distributing NixOS with IPFS"; URL = "https://sourcediver.org/posts/170118_distributing_nixos_with_ipfs"; }
    { Folder = "Nix"; Title = "Installation non conventionnelle de NixOS"; URL = "https://dee.underscore.world/blog/installing-nixos-unconventionally"; }
    { Folder = "Nix"; Title = "Tvix is a new implementation of Nix, a purely-functional package manager"; URL = "https://tvix.dev"; }
    { Folder = "Nix"; Title = "Lix is a modern, delicious implementation of the Nix package manager"; URL = "https://lix.systems"; }
    { Folder = "Anti-Cheat"; Title = "The issue of anti-cheat on Linux"; URL = "https://tulach.cc/the-issue-of-anti-cheat-on-linux"; }
    { Folder = "Anti-Cheat"; Title = "@Low Level, I was right (again)"; URL = "https://invidious.nerdvpn.de/watch?v=VtHlMTc8lR4"; }
    { Folder = "Anti-Cheat"; Title = "In-depth analysis on Valorant’s Guarded Regions"; URL = "https://reversing.info/posts/guardedregions"; }
    { Folder = "Computing Blog"; Title = "Lucys Blog"; URL = "https://lucy.moe"; }
    { Folder = "Computing Blog"; Title = "Ryan Lahfa Blog"; URL = "https://ryan.lahfa.xyz"; }
  ];

  firefox.nativeMessagingHosts = let
    passageBin = "${config.programs.password-store.package}/bin/passage";
    runtimePath = lib.makeBinPath [
      config.programs.password-store.package
      pkgs.util-linux
      pkgs.age
      pkgs.git
      pkgs.coreutils
    ];
    passff-host = pkgs.passff-host.overrideAttrs (old: {
      dontStrip = true;
      patchPhase = ''
        sed -E -i 's#^COMMAND *= *"pass"#COMMAND = "'"${passageBin}"'"#' src/passff.py

        sed -E -i 's#^COMMAND_ENV *= *\{\}#COMMAND_ENV = {"TREE_CHARSET":"ISO-8859-1","PASSAGE_DIR":"${config.xdg.configHome}/passage/store","PASSAGE_IDENTITIES_FILE":"${config.xdg.configHome}/passage/identities","PATH":"${runtimePath}"}#' src/passff.py

        sed -E -i 's#"PATH": "[^"]*"#"PATH": "'"${runtimePath}"'"#' src/passff.py

        sed -i '/^COMMAND_ENV *= *{$/a\    "PASSAGE_DIR":"'"${config.xdg.configHome}/passage/store"'",'  src/passff.py
        sed -i '/^COMMAND_ENV *= *{$/a\    "PASSAGE_IDENTITIES_FILE":"'"${config.xdg.configHome}/passage/identities"'",' src/passff.py
      '';
    });
    passff-host-json-path = "lib/mozilla/native-messaging-hosts/passff.json";
  in [
    (pkgs.concatTextFile {
      name = "passff-host-json";
      files = [ "${passff-host}/${passff-host-json-path}" ];
      destination = [ "/${passff-host-json-path}" ];
    })
  ];
}
