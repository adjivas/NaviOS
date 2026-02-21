{ pkgs, lib, config, ... }: {
  options = {
    pcsx2.enable = lib.mkEnableOption "enable pcsx2";
  };
  config = let
    pcsx2-qt = pkgs.writeShellScriptBin "pcsx2-qt.sh" ''
      export VK_LOADER_LAYERS_DISABLE=~implicit~
      exec ${pkgs.pcsx2}/bin/pcsx2-qt "$@"
    '';
  in lib.mkIf config.pcsx2.enable {
    home.packages = with pkgs; [ pcsx2 ];

    home.file = let
      popNMusic8 = pkgs.fetchurl {
        url = "https://archive.org/download/popnmusic8/popnmusic8.iso";
        sha256 = "sha256-XxyCAt78GJlIuTws2lJcg++eTe3upvcupCNb14PNO9E=";
      };
      ps2BiosJapan = pkgs.fetchzip {
        url = "https://pcsx2bios.com/wp-content/uploads/download/ps2/ps2-bios-japan.zip";
        name = "ps2-bios-japan";
        sha256 = "sha256-VI7pPlmfSjiTDjtNYbXDuv0p9Q8CIb0kNF+WcMaeyEM=";
        extension = "zip";
        stripRoot = false;
      };
      japanBIOS = "SCPH-77000_BIOS_V15_JAP_220_(NTSC)";
    in {
      ".config/PCSX2/bios/${japanBIOS}".source = "${ps2BiosJapan}/ps2 bios japan/${japanBIOS}";
      ".local/share/PCSX2/isos/popnmusic8.iso".source = "${popNMusic8}";
    };

    xdg.desktopEntries.pcsx2 = {
      name = "PCSX2";
      genericName = "PlayStation 2 Emulator";
      exec = "${pcsx2-qt}/bin/pcsx2-qt.sh %f";
      terminal = false;
      type = "Application";
      categories = [ "Game" "Emulator" ];
      icon = "pcsx2";
    };
    home.shellAliases.pcsx2-qt = "${pcsx2-qt}/bin/pcsx2-qt.sh";
  };
}
