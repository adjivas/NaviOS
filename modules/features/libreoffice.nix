{
  den.aspects.libreoffice.homeManager = {pkgs, ...}: {
    config = let
      libreofficeWrapped = pkgs.writeShellScriptBin "libreoffice" ''exec ${pkgs.libreoffice-still}/bin/libreoffice --nologo "$@"'';
    in {
      home.packages = [
        libreofficeWrapped
        pkgs.hunspellDicts.fr-any
      ];

      xdg.desktopEntries.writer = {
        name = "LibreOffice Writer";
        genericName = "Word Processor";
        exec = "libreoffice --writer %U";
        icon = "libreoffice-writer";
        terminal = false;
        categories = ["Office" "WordProcessor"];
        mimeType = [
          "text/plain"
        ];
      };

      xdg.desktopEntries.calc = {
        name = "LibreOffice Calc";
        genericName = "Spreadsheet";
        exec = "libreoffice --calc %U";
        icon = "libreoffice-calc";
        terminal = false;
        categories = ["Office" "Spreadsheet"];
        mimeType = [
          "text/csv"
        ];
      };
    };
  };
}
