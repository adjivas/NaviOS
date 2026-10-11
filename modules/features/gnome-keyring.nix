{
  den.aspects.gnome-keyring.homeManager = {
    services.gnome-keyring = {
      enable = true;
      components = ["secrets" "pkcs11" "ssh"];
    };
  };
}
