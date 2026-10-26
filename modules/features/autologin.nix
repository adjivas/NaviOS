{
  den.aspects.autologin = {
    user,
    defaultSession,
    ...
  }: {
    user = {
      extraGroups = [
        "autologin"
      ];
    };

    provides.to-hosts.nixos = {
      services.displayManager = {
        enable = true;
        inherit defaultSession;

        autoLogin = {
          enable = true;
          user = user.userName;
        };
      };
    };
  };
}
