{ config, pkgs, lib, ... }: let
  distroName = "NAVI-OS";
  distroId = "navios";

  needsEscaping = s: null != builtins.match "[a-zA-Z0-9]+" s;
  escapeIfNecessary = s: if needsEscaping s then s else ''"${lib.escape [ "\$" "\"" "\\" "\`" ] s}"'';
  attrsToText = attrs: lib.concatStringsSep "\n" (
    lib.mapAttrsToList (n: v: ''${n}=${escapeIfNecessary (toString v)}'') attrs
  ) + "\n";

  osReleaseContents = {
    NAME = distroName;
    ID = distroId;
    VERSION = "${config.system.nixos.release} (${config.system.nixos.codeName})";
    VERSION_CODENAME = lib.toLower config.system.nixos.codeName;
    VERSION_ID = config.system.nixos.release;
    BUILD_ID = config.system.nixos.version;
    PRETTY_NAME = "${distroName} ${config.system.nixos.release} (${config.system.nixos.codeName})";
    LOGO = "nix-snowflake";
    HOME_URL = "https://github.com/adjivas/navios";
    DOCUMENTATION_URL = "";
    SUPPORT_URL = "";
    BUG_REPORT_URL = "";
  };
in {
  environment.etc."os-release".text = lib.mkForce (attrsToText osReleaseContents);

  environment.systemPackages = [
    # Gnome-control-center
    (pkgs.writeTextDir "share/icons/hicolor/scalable/apps/nix-snowflake.svg" (builtins.readFile ./hosts/dreamadjivas/Nix_Snowflake_Logo_Mouse.svg))
  ];

  system.nixos.distroName = distroName;
  system.nixos.distroId = distroId;
}
