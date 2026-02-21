{ lib, firefox, buildFirefoxXpiAddon, firefox-addons, ... }: {
  firefox.settings = {
    "extensions.activeThemeID" = "expressionist-soft-colorway@mozilla.org";
    "browser.toolbars.bookmarks.visibility" = "always";
  };
  firefox.addons = (with firefox-addons; [
    passff
    ublock-origin
    istilldontcareaboutcookies
    sponsorblock
    (buildFirefoxXpiAddon rec {
      pname = "expressionist-soft";
      version = "2.1";
      addonId = "expressionist-soft-colorway@mozilla.org";
      url = "https://addons.mozilla.org/firefox/downloads/latest/expressionist-soft/latest.xpi";
      sha256 = "WzAF33qnKloY2b148vckr/NZVL2bthIqaedXvhw8MHY=";
      meta = { };
    })
  ]);
}
