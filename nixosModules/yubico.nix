{ lib, config, ... }: {
  options = {
    yubico.enable = lib.mkEnableOption "enable yubico";
  };
  config = lib.mkIf config.yubico.enable {
    # U2F PAM yubikey
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    security.pam.u2f.settings = {
      cue = true;
      control = "required";
    };
    security.pam.yubico = {
      enable = true;
      mode = "challenge-response";
      id = [ "26273430" "24636935" ];
    };
  };
}
