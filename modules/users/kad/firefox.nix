{inputs, ...}: {
  den.aspects.kad.homeManager = {
    firefox-addons,
    pkgs,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    buildFirefoxXpiAddon = inputs.firefox-addons.lib.${system}.buildFirefoxXpiAddon;
  in {
    firefox.settings = {
      "extensions.activeThemeID" = "expressionist-soft-colorway@mozilla.org";
      "browser.toolbars.bookmarks.visibility" = "always";
    };
    firefox.addons = with firefox-addons; [
      passff
      ublock-origin
      istilldontcareaboutcookies
      sponsorblock
      (buildFirefoxXpiAddon {
        pname = "expressionist-soft";
        version = "2.1";
        addonId = "expressionist-soft-colorway@mozilla.org";
        url = "https://addons.mozilla.org/firefox/downloads/latest/expressionist-soft/latest.xpi";
        sha256 = "WzAF33qnKloY2b148vckr/NZVL2bthIqaedXvhw8MHY=";
        meta = {};
      })
    ];
  };
}
