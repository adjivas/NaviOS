{
  den.aspects.gnome-keyring.homeManager = {
    config = {
      services.gnome-keyring = {
        enable = true;
        components = ["secrets" "pkcs11" "ssh"];
      };
    };
  };
}
