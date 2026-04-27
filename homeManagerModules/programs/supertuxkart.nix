{ pkgs, lib, config, ... }: {
  options = {
    supertuxkart.enable = lib.mkEnableOption "enable supertuxkart";
    supertuxkart.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.superTuxKart;
    };
  };
  config = lib.mkIf config.supertuxkart.enable {
    home.packages = [
      config.supertuxkart.package
    ];

    home.file = let
      mario = pkgs.fetchzip {
        url = "https://filecache46.gamebanana.com/mods/stk_wildwingmario.zip";
        name = "stk_wildwingmario";
        sha256 = "sha256-jFwsgPAeXt//nPT23Hxl5IuqLGwCmN67K/jeYiq5ahI=";
        extension = "zip";
      };
      waluigi = pkgs.fetchzip {
        url = "https://filecache37.gamebanana.com/mods/waluigi_53b69.zip";
        name = "waluigi";
        sha256 = "sha256-hm8MJFPTg5iFWcruwDR2UVu9+sLOJZM8/s6Uf/Zv4Q8=";
        extension = "zip";
      };
      rosalina = pkgs.fetchzip {
        url = "https://filecache42.gamebanana.com/mods/rosalina_acfd9.zip";
        name = "rosalina";
        sha256 = "sha256-nAtk+waDz3WS/fRUn/mpAHs9CE3LDD8rQsrzoSZNrDM=";
        extension = "zip";
      };
      rougethebat_modern = pkgs.fetchzip {
        url = "https://filecache38.gamebanana.com/mods/rougethebat_modern.zip";
        name = "rougethebat_modern";
        sha256 = "sha256-0ek8Zu0PLIrPsCLBqtu2va/0evSn5ReBST2F8EHvsW0=";
        extension = "zip";
      };
      rougethebat_dreamcast = pkgs.fetchzip {
        url = "https://filecache36.gamebanana.com/mods/rougethebat_dreamcast.zip";
        name = "rougethebat_dreamcast";
        sha256 = "sha256-pX4zGBorNp9aYg24WTTv+D4RA9AmaH6dmhWuULG9mAo=";
        extension = "zip";
      };
      sonic = pkgs.fetchzip {
        url = "https://filecache31.gamebanana.com/mods/sonic_8287c.zip";
        name = "sonic";
        sha256 = "sha256-Wfm6CFOL1rsVK10PTk3F8wTOy2Y4uwpfxy/kHLE9jB0=";
        extension = "zip";
      };

      alternate-ice-mine = pkgs.fetchzip {
        url = "https://online.supertuxkart.net/dl/283993917659b2201523a8.zip";
        name = "alternate-ice-mine";
        sha256 = "sha256-7KkQvWoyMUKXv5/2zqIQs24XTTCzOae1NVm9VVFsGz4=";
        extension = "zip";
        stripRoot = false;
      };
      imminent-cold-effects = pkgs.fetchzip {
        url = "https://online.supertuxkart.net/dl/118834126366d9fec907e79.zip";
        sha256 = "sha256-h7fbOfeFYBIoTf3M0N5dMiGJi0DtCg4VJVSjPQzWJdM=";
        name = "imminent-cold-effects";
        extension = "zip";
        stripRoot = false;
      };
    in {
      ".local/share/supertuxkart/addons/karts/mario".source = "${mario}";
      ".local/share/supertuxkart/addons/karts/waluigi".source = "${waluigi}";
      ".local/share/supertuxkart/addons/karts/rosalina".source = "${rosalina}";
      ".local/share/supertuxkart/addons/karts/rougethebat_modern".source = "${rougethebat_modern}";
      ".local/share/supertuxkart/addons/karts/rougethebat_dreamcast".source = "${rougethebat_dreamcast}";
      ".local/share/supertuxkart/addons/karts/sonic".source = "${sonic}";
      ".local/share/supertuxkart/addons/tracks/alternate-ice-mine".source = "${alternate-ice-mine}";
      ".local/share/supertuxkart/addons/tracks/imminent-cold-effects".source = "${imminent-cold-effects}";
    };
  };
}
