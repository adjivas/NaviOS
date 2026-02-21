{ pkgs, lib, config, ... }: {
  options = {
    plymouth.enable = lib.mkEnableOption "enable plymouth";
  };
  config = lib.mkIf config.plymouth.enable {
    nixpkgs = {
      overlays = [
        (final: prev: {
          adi1090x-plymouth-themes = prev.adi1090x-plymouth-themes.overrideAttrs (old: {
            installPhase =
              (old.installPhase or "")
              + ''
                cp ${./emblem0.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem0.png
                cp ${./emblem1.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem1.png
                cp ${./emblem2.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem2.png
                cp ${./emblem3.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem3.png
                cp ${./emblem4.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem4.png
                cp ${./emblem5.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem5.png
                cp ${./emblem6.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem6.png
                cp ${./emblem7.png} $out/share/plymouth/themes/${config.boot.plymouth.theme}/emblem7.png
                cp ${pkgs.nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake.png $out/share/plymouth/themes/${config.boot.plymouth.theme}/nixos-logo.png

                echo "
                nixos_image = Image(\"nixos-logo.png\");
                nixos_sprite = Sprite();

                nixos_sprite.SetImage(nixos_image);
                nixos_sprite.SetX(Window.GetX() + (Window.GetWidth() / 2 - nixos_image.GetWidth() / 2));
                nixos_sprite.SetY(Window.GetHeight() - nixos_image.GetHeight() - 100);


                for (i = 1; i < 24; i++)
                  emblem_image[i] = Image(\"emblem\" + (i % 8) + \".png\");
                emblem_sprite = Sprite();

                progress = 1;
                fun refresh_callback ()
                  {
                    emblem_sprite.SetX(Window.GetWidth() / 2 - emblem_image[1].GetWidth() / 2);
                    emblem_sprite.SetY(Window.GetHeight() / 2 - emblem_image[1].GetHeight() / 2);
                    emblem_sprite.SetImage(emblem_image[Math.Int(progress / 6) % 24]);
                    progress++;
                  }
                Plymouth.SetRefreshFunction (refresh_callback);
                " > $out/share/plymouth/themes/${config.boot.plymouth.theme}/${config.boot.plymouth.theme}.script
              '';
          });
        })
      ];
    };

    boot.plymouth = let
      theme = "rings";
    in {
      enable = true;
      inherit theme;
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ theme ];
        })
      ];
    };
  };
}
