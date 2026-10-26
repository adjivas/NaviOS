{
  den.aspects.firefox-adjivas.homeManager = {lib, ...}: {
    firefox.settings = {
      "intl.locale.requested" = "fr-FR";
      "browser.ctrlTab.sortByRecentlyUsed" = true;
      "widget.disable-swipe-tracker" = true;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.tabs.altNumberSwitch" = false;

      "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Self styles
      "xpinstall.signatures.required" = false; # Self plugins

      # Firefox Browser Toolbox debugging
      "devtools.debugger.prompt-connection" = false;
      "devtools.chrome.enabled" = true;
      "devtools.debugger.remote-enabled" = true;
    };
    firefox.userChrome = lib.concatLines [
      (builtins.readFile ./australisTab.css)
      (builtins.readFile ./australisTabGroup.css)
      (builtins.readFile ./closeButton.css)
      ''
        #nav-bar {
          background: linear-gradient(
            to bottom,
            #0dcdcd 0%,
            color-mix(in srgb, #0dcdcd 75%, black 25%) 100%
          ) !important;

          color: #000000 !important;
          fill: #000000 !important;

          --toolbar-color: #000000 !important;
          --toolbarbutton-icon-fill: #000000 !important;
        }

        /* URL bar colors */
        #urlbar {
          background: #42414d !important;
          color: #ffffff !important;
          fill: #ffffff !important;
        }

        /* URL bar background */
        /* Keep rounded corners when the suggestions menu is open */
        #urlbar > .urlbar-background {
          background: #42414d !important;
          border-radius: 10px !important;
        }
        #main-button > .button-background {
          border-radius: 10px !important;
        }
        #urlbar-zoom-button {
          border-radius: 10px !important;
        }
        #urlbar,
        #urlbar[open] > .urlbar-background,
        #urlbar[breakout-extend] > .urlbar-background {
          border-radius: 10px !important;
        }
        .urlbar-container *[role="button"] {
          border-radius: 10px !important;
        }

        /* Zoom button */
        #urlbar-zoom-button {
          color: #ffffff !important;
        }

        #urlbar-zoom-button:hover {
          color: #000000 !important;
        }

        /* Keep the tab bar fully opaque when the Firefox window is inactive */
        #TabsToolbar {
          opacity: 1 !important;
        }

        /* Dark-gray background on even URL bar result rows */
        .urlbarView,
        .urlbarView-body,
        .urlbarView-body-inner {
          background-color: #3b3b49 !important;
        }
        .urlbarView-row:nth-child(even):not([selected]):not(:hover) {
          background-color: #4b4a57 !important;
        }

        /* Hide window close button */
        #new-tab-button, .titlebar-close {
          display: none !important;
        }

        /* Hide the tab bar scrollbox periphery */
        #tabbrowser-arrowscrollbox-periphery {
          display: none !important;
        }

        /* Hide the link/loading status panel in the bottom-left corner */
        #statuspanel {
          display: none !important;
        }
      ''
    ];
    # firefox.userContent = ''
    #   @-moz-document url-prefix("http://"), url-prefix("https://") {
    #     :root {
    #       background-color: #222222 !important;
    #     }
    #   }
    # '';
    firefox.policies = {
      ExtensionSettings = {
        "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
          installation_mode = "force_installed";
        };
        "fr-dicollecte@dictionaries.addons.mozilla.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/3581786/dictionnaire_francais1-latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
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
        # "kunal@abhashtech.com" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/file/4275238/remove_youtube_recomendation-0.3resigned1.xpi";
        #   installation_mode = "force_installed";
        # };
        # No YouTube comments
        # "jid1-YMBCq41qvDdqcA@jetpack" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/file/4270539/no_youtube_comments-0.4resigned1.xpi";
        #   installation_mode = "force_installed";
        # };
        # RYS — Remove YouTube Suggestions
        # "{21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26}" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/file/4299785/remove_youtube_s_suggestions-4.3.60.xpi";
        #   installation_mode = "force_installed";
        # };
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
      };
    };
  };
}
