{
  den.aspects.yubico-swaylock.nixos = {
    security.pam.services = {
      swaylock.u2f = {
        enable = true;
        control = "sufficient";
      };
    };
  };
}
