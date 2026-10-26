{
  den.aspects.mako.homeManager = {
    config = {
      stylix.targets.mako.enable = true;

      services.mako = {
        enable = true;
        settings = {default-timeout = 5000;};
      };
    };
  };
}
