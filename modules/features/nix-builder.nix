{
  den.aspects.nix-builder = {
    publicKeys ? [],
    max-jobs ? 1,
    cores ? 4,
    userName ? "nix-builder",
  }: {
    nixos = {lib, ...}: {
      users.groups."${userName}" = {};
      users.users."${userName}" = {
        isNormalUser = true;
        group = userName;

        home = "/var/lib/${userName}";
        createHome = true;

        openssh.authorizedKeys.keys = publicKeys;
      };

      services.openssh.settings.AllowUsers = lib.mkAfter [userName];

      nix.settings = {
        inherit max-jobs cores;
        trusted-users = lib.mkAfter [
          userName
        ];
      };
    };
  };
}
