{
  den.aspects.dream05-gnome-scheme = {colorScheme ? "prefer-dark"}: {
    nixos = {
      assertions = [
        {
          assertion = builtins.elem colorScheme [
            "default"
            "prefer-dark"
          ];
          message = ''
            dream05-gnome-color-scheme.colorScheme must be one of:
            "default", "prefer-dark".
          '';
        }
      ];

      programs.dconf = {
        enable = true;

        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              color-scheme = colorScheme;
            };
          }
        ];
      };
    };
  };
}
