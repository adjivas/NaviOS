{
  den.aspects.yubico.nixos = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        age
        age-plugin-yubikey
        yubikey-manager
        pcsclite
      ];

      services.udev.packages = [pkgs.yubikey-personalization];

      services.pcscd.enable = true;

      # U2F PAM yubikey
      security.pam.services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
      security.pam.u2f.settings = {
        cue = true;
        control = "sufficient";
      };
      security.pam.yubico = {
        enable = true;
        mode = "challenge-response";
        id = ["26273430" "24636935"];
      };
    };
  };
}
