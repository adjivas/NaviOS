{
  den.aspects.persistence-user = {user, ...}: {
    nixos = {pkgs, ...}: let
      userName = user.userName;
      home = "/home/${userName}";
      persistentHome = "/nix/persistent/home/${userName}";
      secretsMount = "home-${userName}-.secrets.mount";
    in {
      system.activationScripts."persistence-user-${userName}".text = ''
        ${pkgs.coreutils}/bin/mkdir -p ${persistentHome}/.secrets

        ${pkgs.coreutils}/bin/chown ${userName}:users ${persistentHome}
        ${pkgs.coreutils}/bin/chmod 0700 ${persistentHome}

        ${pkgs.coreutils}/bin/chown ${userName}:users ${persistentHome}/.secrets
        ${pkgs.coreutils}/bin/chmod 0700 ${persistentHome}/.secrets
      '';

      fileSystems."${home}/.secrets" = {
        device = "${persistentHome}/.secrets";
        fsType = "none";
        options = [
          "bind"
        ];
      };

      systemd.services."home-manager-${userName}" = {
        requires = [
          secretsMount
        ];

        after = [
          secretsMount
        ];
      };
    };
  };
}
