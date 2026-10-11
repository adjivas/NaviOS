{self, ...}: {
  den.aspects.dream05-gnome-wallpaper.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.dream05-gnome-wallpaper.path = lib.mkOption {
      type = lib.types.path;
      default = "${self.outPath}/artwork/wallpaper.jpg";
      description = ''
        Path to the wallpaper image file.
      '';
    };

    config = {
      # Install wallpaper metadata.
      environment.systemPackages = [
        (pkgs.writeTextFile {
          name = "nixos-fairphone-wallpaper-info";
          text = ''
            <?xml version="1.0"?>
            <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
            <wallpapers>
              <wallpaper deleted="false">
                <name>NixOS Fairphone</name>
                <filename>${config.dream05-gnome-wallpaper.path}</filename>
                <filename-dark>${config.dream05-gnome-wallpaper.path}</filename-dark>
                <options>zoom</options>
                <shade_type>solid</shade_type>
                <pcolor>#000000</pcolor>
                <scolor>#000000</scolor>
              </wallpaper>
            </wallpapers>
          '';
          destination = "/share/gnome-background-properties/nixos-fairphone-wallpaper.xml";
        })
      ];

      programs.dconf = {
        enable = true;

        profiles.user.databases = [
          {
            settings."org/gnome/desktop/background" = {
              color-shading-type = "solid";
              picture-options = "zoom";
              picture-uri = "file:///${config.dream05-gnome-wallpaper.path}";
              picture-uri-dark = "file:///${config.dream05-gnome-wallpaper.path}";
              primary-color = "#000000";
              secondary-color = "#000000";
            };
          }
        ];
      };
    };
  };
}
