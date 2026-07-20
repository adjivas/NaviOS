{self, ...}: {
  den.aspects.distro.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: let
    distroName = "NAVI-OS";
    distroId = "navios";
    distroLogo = "navios";

    needsEscaping = s: null != builtins.match "[a-zA-Z0-9]+" s;
    escapeIfNecessary = s:
      if needsEscaping s
      then s
      else ''"${lib.escape ["\$" "\"" "\\" "\`"] s}"'';
    attrsToText = attrs:
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: ''${name}=${escapeIfNecessary (toString value)}'') attrs
      )
      + "\n";

    osReleaseContents = {
      NAME = distroName;
      ID = distroId;
      VERSION = "${config.system.nixos.release} (${config.system.nixos.codeName})";
      VERSION_CODENAME = lib.toLower config.system.nixos.codeName;
      VERSION_ID = config.system.nixos.release;
      BUILD_ID = config.system.nixos.version;
      PRETTY_NAME = "${distroName} ${config.system.nixos.release} (${config.system.nixos.codeName})";
      LOGO = distroLogo;
      HOME_URL = "https://github.com/adjivas/navios";
      DOCUMENTATION_URL = "";
      SUPPORT_URL = "";
      BUG_REPORT_URL = "";
    };
    artwork = pkgs.runCommand "navios-artwork" {} ''
      install -Dm444 \
        ${self}/artwork/Nix_Snowflake_Logo_Mouse.svg \
        $out/share/icons/hicolor/scalable/apps/${distroLogo}.svg
    '';
  in {
    environment.etc."os-release".text = lib.mkForce (attrsToText osReleaseContents);
    environment.systemPackages = [
      artwork
    ];

    environment.pathsToLink = [
      "/share/icons"
    ];

    system.nixos.distroName = distroName;
    system.nixos.distroId = distroId;
  };
}
