{ self, inputs, lib, pkgs, config, ... }: {
  options = {
    pixie.enable = lib.mkEnableOption "enable pixie";
    pixie.token = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "Path to the git token file";
    };
    pixie.ident = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      readOnly = true;
      description = "Path to the ident file";
    };
  };

  config = lib.mkIf config.pixie.enable (let
    cfg = config.services.pixiecore;
    sys = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        (self + /hosts/dreaminstall/configuration.nix)
      ];
    };

    build = sys.config.system.build;
  in {
    # Add secret
    systemd.services.pixiecore.serviceConfig = {
      LoadCredential = [ "ident:/nix/persistent/secrets/ident.txt" ];

      ExecStart = lib.mkForce (pkgs.writeShellScript "pixiecore-with-ident" ''
        set -euo pipefail

        PW_IDENT="$(${pkgs.coreutils}/bin/base64 -w0 "$CREDENTIALS_DIRECTORY/ident")"

        exec ${pkgs.pixiecore}/bin/pixiecore \
          "boot" \
          ${cfg.kernel} \
          ${cfg.initrd} \
          "--cmdline" "${cfg.cmdLine} PW_IDENT=$PW_IDENT" \
          ${lib.optionalString cfg.debug "--debug"} \
          ${lib.optionalString cfg.dhcpNoBind "--dhcp-no-bind"} \
          --listen-addr ${lib.escapeShellArg cfg.listen} \
          --port ${toString cfg.port} \
          --status-port ${toString cfg.statusPort}
      '');
    };

    services.pixiecore = {
      enable = true;
      mode = "boot";
      openFirewall = true;
      dhcpNoBind = true;
      statusPort = 64172;
      port = 64172;

      kernel = "${build.kernel}/bzImage";
      initrd = "${build.netbootRamdisk}/initrd";
      cmdLine = "init=${build.toplevel}/init loglevel=4";
    };
  });
}
