{den, ...}: {
  den.aspects.yubico = {
    policies.swaylock = {
      host,
      lib,
      ...
    }:
      lib.optional host.config.programs.swaylock.enable (
        den.lib.policy.include den.aspects.yubico-swaylock
      );

    nixos = {pkgs, ...}: {
      config = {
        environment.systemPackages = with pkgs; [
          age
          age-plugin-yubikey
          yubikey-manager
          pcsclite
        ];

        services.udev.packages = with pkgs; [
          libfido2
        ];

        services.pcscd.enable = true;

        security.pam.u2f.settings = {
          cue = true;
          # debug = true;
        };

        # U2F PAM yubikey
        security.pam.services = {
          login.u2f = {
            enable = true;
            control = "sufficient";
          };

          sudo.u2f = {
            enable = true;
            control = "sufficient";
          };
        };

        # Allow remote/headless sessions to access FIDO devices through the libfido2 udev rules.
        users.groups.plugdev = {};

        users.users.adjivas.extraGroups = [
          "plugdev"
        ];
      };
    };
  };
}
