{
  den.aspects.location = {geoProviderUrl, ...}: {
    nixos = {
      # Enable location services.
      services.geoclue2 = {
        enable = true;
        inherit geoProviderUrl;
      };
    };
  };
}
