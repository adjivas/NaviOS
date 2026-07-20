{
  flake.nixosModules.pixie = {
    self,
    inputs,
    config,
    pkgs,
    lib,
    modulesPath,
    ...
  }: {
    options.pixie = {
      sys = lib.mkOption {
        type = lib.types.raw;
        internal = true;
        readOnly = true;
        default = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs self;
            secretsSystem = inputs.secrets;
            secretsUser = inputs.secretsHomeLand;
          };
          modules = [
            self.nixosModules.hosts.dreaminstall
            (modulesPath + "/installer/netboot/netboot-minimal.nix")
            {
              boot.postBootCommands = ''
                if [[ " $(</proc/cmdline) " =~ \ RED_IDENT=([^[:space:]]+) ]]; then
                  ident="''${BASH_REMATCH[1]}"

                  ${pkgs.coreutils}/bin/printf '%s' "$ident" > /etc/ident-red.txt
                fi
              '';
            }
          ];
        };
      };
    };

    config = let
      cfg = config.services.pixiecore;
      build = config.pixie.sys.config.system.build;
    in {
      systemd.services.pixiecore.serviceConfig = {
        LoadCredential = ["ident:/run/agenix/yubikey-5a-adjivas.ident"];
        ExecStart = lib.mkForce (pkgs.writeShellScript "pixiecore" ''
          RED_IDENT="$(${pkgs.coreutils}/bin/tail -n1 "$CREDENTIALS_DIRECTORY/ident")"

          set -euo pipefail

          exec ${pkgs.pixiecore}/bin/pixiecore \
            "boot" \
            ${cfg.kernel} \
            ${cfg.initrd} \
            "--cmdline" "${cfg.cmdLine} RED_IDENT=$RED_IDENT" \
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
    };
  };
}
